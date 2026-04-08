<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sản phẩm yêu thích - Mộc Trà</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">


</head>
<body class="user-dashboard-page">

<jsp:include page="/common/header.jsp"></jsp:include>

<div class="container">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="yeu-thich"/>
    </jsp:include>

    <main class="main-content">
        <div class="orders-header">
            <h2 class="page-title" style="margin-bottom: 0;">Sản phẩm yêu thích</h2>
        </div>

        <form action="${pageContext.request.contextPath}/san-pham-yeu-thich" method="get" class="favorites-filters">
            <div class="filters-grid">
                <div class="filter-group">
                    <label for="category-filter">Danh mục</label>
                    <select name="categoryId" id="category-filter" class="form-select" onchange="this.form.submit()">
                        <option value="">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categoryList}">
                            <option value="${cat.id}" ${currentCategoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filter-group">
                    <label for="price-filter">Khoảng giá</label>
                    <select name="maxPrice" id="price-filter" class="form-select" onchange="this.form.submit()">
                        <option value="">Tất cả giá</option>
                        <option value="50000" ${currentMaxPrice == '50000' ? 'selected' : ''}>Dưới 50.000₫</option>
                        <option value="100000" ${currentMaxPrice == '100000' ? 'selected' : ''}>Dưới 100.000₫</option>
                        <option value="200000" ${currentMaxPrice == '200000' ? 'selected' : ''}>Dưới 200.000₫</option>
                        <option value="500000" ${currentMaxPrice == '500000' ? 'selected' : ''}>Dưới 500.000₫</option>
                    </select>
                </div>

                <div class="filter-group">
                    <label for="sort-filter">Sắp xếp</label>
                    <select name="sort" id="sort-filter" class="form-select" onchange="this.form.submit()">
                        <option value="newest" ${currentSort == 'newest' ? 'selected' : ''}>Yêu thích mới nhất</option>
                        <option value="oldest" ${currentSort == 'oldest' ? 'selected' : ''}>Yêu thích lâu nhất</option>
                        <option value="price-asc" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                        <option value="price-desc" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                        <option value="name-asc" ${currentSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
                    </select>
                </div>
            </div>
        </form>

        <div class="favorites-container">
            <div class="table-header">
                <div class="products-count">
                    Tổng cộng: <strong id="favoriteTotalCount" data-total="${totalProducts}">${totalProducts} sản phẩm</strong>
                </div>
            </div>

            <div id="favoriteBulkBar" class="favorite-bulk-bar">
                <div><strong id="selectedFavoriteCount">0</strong> sản phẩm được chọn</div>
                <div style="display:flex; gap:10px;">
                    <button type="button" class="favorite-bulk-btn" onclick="bulkRemoveFavorites()">Xóa khỏi danh sách</button>
                    <button type="button" class="favorite-bulk-cancel" onclick="clearFavoriteSelection()">Hủy</button>
                </div>
            </div>

            <c:choose>
                <c:when test="${not empty favoriteList}">
                    <div class="table-responsive">
                        <table class="favorites-table">
                            <thead>
                            <tr>
                                <th style="width: 50px;">
                                    <input type="checkbox" class="favorite-checkbox" id="selectAllFavorites">
                                </th>
                                <th style="width: 90px;">Hình ảnh</th>
                                <th>Tên sản phẩm</th>
                                <th style="width: 140px;">Giá bán</th>
                                <th style="width: 180px;">Mức giảm sau khuyến mãi</th>
                                <th style="width: 120px; text-align: center;">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="p" items="${favoriteList}">
                                <tr id="favorite-row-${p.id}">
                                    <td>
                                        <input type="checkbox" class="favorite-checkbox favorite-row-checkbox" value="${p.id}">
                                    </td>
                                    <td>
                                        <img src="${p.imageUrl}" alt="${p.name}" class="favorite-image-thumb">
                                    </td>
                                    <td>
                                        <div class="favorite-name">${p.name}</div>
                                        <div class="favorite-desc">${p.shortDescription}</div>
                                    </td>
                                    <td>
                                        <div class="favorite-price-main">
                                            <fmt:formatNumber value="${p.salePrice > 0 && p.salePrice < p.price ? p.salePrice : p.price}" pattern="#,###"/>₫
                                        </div>
                                        <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                                            <div class="favorite-price-old">
                                                <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                                            </div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.salePrice > 0 && p.salePrice < p.price}">
                                                <span class="favorite-discount">
                                                    Giảm <fmt:formatNumber value="${p.price - p.salePrice}" pattern="#,###"/>₫
                                                    (<fmt:formatNumber value="${(p.price - p.salePrice) / p.price * 100}" maxFractionDigits="0"/>%)
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="favorite-discount none">Không có</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="favorite-actions">
                                            <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}" class="btn-action" title="Xem chi tiết">
                                                <i class="fa-solid fa-eye"></i>
                                            </a>

                                            <button type="button"
                                                    class="btn-action danger"
                                                    title="Xóa khỏi danh sách"
                                                    onclick="removeFavorite(${p.id})">
                                                <i class="fa-solid fa-heart-crack"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="empty-favorites">
                        <i class="fa-regular fa-heart"></i>
                        <h3>Chưa có sản phẩm yêu thích</h3>
                        <p>Danh sách yêu thích của bạn hiện đang trống.</p>
                        <a href="${pageContext.request.contextPath}/san-pham" class="btn-action"
                           style="display: inline-flex; width: auto; padding: 10px 18px; margin-top: 15px;">
                            Đi mua sắm
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>

            <div class="pagination-container">
                <div class="pagination-info">
                    Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong>
                </div>

                <c:if test="${totalPages > 1}">
                    <c:set var="windowSize" value="6" />
                    <c:set var="currentBlock" value="${(currentPage - 1) div windowSize}" />
                    <c:set var="startPage" value="${currentBlock * windowSize + 1}" />
                    <c:set var="endPage" value="${startPage + windowSize - 1}" />

                    <c:if test="${endPage > totalPages}">
                        <c:set var="endPage" value="${totalPages}" />
                    </c:if>

                    <c:set var="prevPage" value="${currentPage - windowSize}" />
                    <c:set var="nextPage" value="${currentPage + windowSize}" />

                    <div class="pagination">
                        <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${prevPage < 1 ? 1 : prevPage}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
                           class="page-btn ${currentPage <= windowSize ? 'disabled' : ''}">
                            &laquo;
                        </a>

                        <c:forEach begin="${startPage}" end="${endPage}" var="i">
                            <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${i}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
                               class="page-btn ${currentPage == i ? 'active' : ''}">
                                    ${i}
                            </a>
                        </c:forEach>

                        <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${nextPage > totalPages ? totalPages : nextPage}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
                           class="page-btn ${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                            &raquo;
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </main>
</div>

<div id="favoriteToast" class="favorite-toast"></div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    function showFavoriteToast(message, type) {
        const toast = document.getElementById('favoriteToast');
        const icon = type === 'success'
            ? '<i class="fa-solid fa-circle-check"></i>'
            : '<i class="fa-solid fa-circle-xmark"></i>';

        toast.className = 'favorite-toast ' + type + ' show';
        toast.innerHTML = icon + '<span>' + message + '</span>';

        setTimeout(() => {
            toast.className = 'favorite-toast';
            toast.innerHTML = '';
        }, 2000);
    }

    function removeFavorite(productId) {
        fetch('${pageContext.request.contextPath}/san-pham-yeu-thich', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({
                action: 'remove',
                productId: productId
            })
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    const row = document.getElementById('favorite-row-' + productId);
                    if (row) {
                        row.remove();
                    }

                    updateFavoriteBulkBar();
                    updateFavoriteCount(1);;
                    checkFavoriteEmptyState();

                    showFavoriteToast(data.message, 'success');
                } else {
                    showFavoriteToast(data.message, 'error');
                }
            })
            .catch(() => showFavoriteToast('Xóa sản phẩm thất bại', 'error'));
    }
    function updateFavoriteCount(removedCount = 1) {
        const countBox = document.getElementById('favoriteTotalCount');
        if (!countBox) return;

        let currentTotal = parseInt(countBox.dataset.total || '0', 10);
        currentTotal = Math.max(0, currentTotal - removedCount);

        countBox.dataset.total = currentTotal;
        countBox.textContent = currentTotal + ' sản phẩm';
    }
    function checkFavoriteEmptyState() {
        const tbody = document.querySelector('.favorites-table tbody');
        const container = document.querySelector('.favorites-container');

        if (!tbody || tbody.querySelectorAll('tr').length > 0) return;

        const tableResponsive = document.querySelector('.table-responsive');
        const paginationContainer = document.querySelector('.pagination-container');
        const bulkBar = document.getElementById('favoriteBulkBar');

        if (tableResponsive) tableResponsive.remove();
        if (paginationContainer) paginationContainer.remove();
        if (bulkBar) bulkBar.classList.remove('active');

        const emptyHtml = `
        <div class="empty-favorites">
            <i class="fa-regular fa-heart"></i>
            <h3>Chưa có sản phẩm yêu thích</h3>
            <p>Danh sách yêu thích của bạn hiện đang trống.</p>
            <a href="${pageContext.request.contextPath}/san-pham" class="btn-action"
               style="display: inline-flex; width: auto; padding: 10px 18px; margin-top: 15px;">
                Đi mua sắm
            </a>
        </div>
    `;
        container.insertAdjacentHTML('beforeend', emptyHtml);
    }

    function bulkRemoveFavorites() {
        const checked = Array.from(document.querySelectorAll('.favorite-row-checkbox:checked')).map(cb => cb.value);
        if (checked.length === 0) {
            showFavoriteToast('Chưa chọn sản phẩm nào', 'error');
            return;
        }

        fetch('${pageContext.request.contextPath}/san-pham-yeu-thich', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: new URLSearchParams({
                action: 'bulk-remove',
                productIds: checked.join(',')
            })
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    checked.forEach(id => {
                        const row = document.getElementById('favorite-row-' + id);
                        if (row) row.remove();
                    });

                    clearFavoriteSelection();
                    updateFavoriteCount(checked.length);
                    checkFavoriteEmptyState();

                    showFavoriteToast(data.message, 'success');
                } else {
                    showFavoriteToast(data.message, 'error');
                }
            })
            .catch(() => showFavoriteToast('Xóa danh sách yêu thích thất bại', 'error'));
    }

    function updateFavoriteBulkBar() {
        const checked = document.querySelectorAll('.favorite-row-checkbox:checked').length;
        const bar = document.getElementById('favoriteBulkBar');
        const count = document.getElementById('selectedFavoriteCount');

        count.textContent = checked;
        if (checked > 0) bar.classList.add('active');
        else bar.classList.remove('active');
    }

    function clearFavoriteSelection() {
        document.querySelectorAll('.favorite-row-checkbox').forEach(cb => cb.checked = false);
        document.getElementById('selectAllFavorites').checked = false;
        updateFavoriteBulkBar();
    }

    document.addEventListener('DOMContentLoaded', function () {
        const selectAll = document.getElementById('selectAllFavorites');
        const rowCheckboxes = document.querySelectorAll('.favorite-row-checkbox');

        if (selectAll) {
            selectAll.addEventListener('change', function () {
                rowCheckboxes.forEach(cb => cb.checked = this.checked);
                updateFavoriteBulkBar();
            });
        }

        rowCheckboxes.forEach(cb => {
            cb.addEventListener('change', updateFavoriteBulkBar);
        });
    });
</script>

</body>
</html>