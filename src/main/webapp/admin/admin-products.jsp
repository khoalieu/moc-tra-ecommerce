<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sản phẩm - Mộc Trà Admin</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
    <link rel="stylesheet" href="admin/assets/css/admin-add-product.css">
    <link rel="stylesheet" href="admin/assets/css/admin-products.css">
</head>
<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="products"/>
    </jsp:include>


    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Sản phẩm</h1>
            </div>

            <div class="header-right">
                <div class="header-search">
                    <i class="fas fa-search"></i>
                    <input type="text"  name="keyword"  form="productFilterForm"
                           value="${currentKeyword}"
                           placeholder="Tìm kiếm sản phẩm..."
                           autocomplete="off">
                </div>

                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <c:if test="${not empty sessionScope.importMessage}">
                <div class="import-message">
                        ${sessionScope.importMessage}
                </div>
                <c:remove var="importMessage" scope="session"/>
            </c:if>

            <div class="page-header">
                <div class="page-title">
                    <h2>Danh sách sản phẩm</h2>
                    <p>Quản lý tất cả sản phẩm trà và nguyên liệu pha chế</p>
                </div>
                <div class="page-actions">
                    <a href="admin/product/add" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Thêm sản phẩm
                    </a>
                </div>
            </div>

            <div class="admin-product-quick-filters">
                <button type="button"
                        class="admin-product-quick-btn ${currentStockFilter == 'need-reorder' ? 'active' : ''}"
                        data-filter-field="stockFilter"
                        data-filter-value="need-reorder">
                    <i class="fas fa-box-open"></i> Cần nhập hàng
                </button>
                <button type="button"
                        class="admin-product-quick-btn ${currentPromotionFilter == 'discounted' ? 'active' : ''}"
                        data-filter-field="promotionFilter"
                        data-filter-value="discounted">
                    <i class="fas fa-percent"></i> Đang giảm giá
                </button>
                <button type="button"
                        class="admin-product-quick-btn ${currentStockFilter == 'low-stock' ? 'active' : ''}"
                        data-filter-field="stockFilter"
                        data-filter-value="low-stock">
                    <i class="fas fa-battery-quarter"></i> Sắp hết hàng
                </button>
                <button type="button"
                        class="admin-product-quick-btn ${currentStockFilter == 'out-of-stock' ? 'active' : ''}"
                        data-filter-field="stockFilter"
                        data-filter-value="out-of-stock">
                    <i class="fas fa-triangle-exclamation"></i> Hết hàng
                </button>
            </div>

            <form id="productFilterForm" action="admin/products" method="get" class="filters-section">
                <div class="filters-grid admin-product-filters-grid">
                    <div class="filter-group">
                        <label for="category-filter">Danh mục</label>
                        <select name="categoryId" id="category-filter" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả danh mục</option>
                            <c:forEach var="cat" items="${categoryList}">
                                <c:if test="${cat.parentId == null}">
                                    <option value="${cat.id}" ${currentCategoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                                    <c:forEach var="child" items="${categoryList}">
                                        <c:if test="${child.parentId == cat.id}">
                                            <option value="${child.id}" ${currentCategoryId == child.id ? 'selected' : ''}>-- ${child.name}</option>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="status-filter">Trạng thái</label>
                        <select name="status" id="status-filter" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="active" ${currentStatus == 'active' ? 'selected' : ''}>Đang bán</option>
                            <option value="inactive" ${currentStatus == 'inactive' ? 'selected' : ''}>Ngừng bán</option>
                            <option value="out-of-stock" ${currentStatus == 'out-of-stock' ? 'selected' : ''}>Hết hàng</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="stock-filter">Tồn kho</label>
                        <select name="stockFilter" id="stock-filter" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả tồn kho</option>
                            <option value="in-stock" ${currentStockFilter == 'in-stock' ? 'selected' : ''}>Còn hàng</option>
                            <option value="need-reorder" ${currentStockFilter == 'need-reorder' ? 'selected' : ''}>Cần nhập hàng</option>
                            <option value="low-stock" ${currentStockFilter == 'low-stock' ? 'selected' : ''}>Sắp hết hàng</option>
                            <option value="out-of-stock" ${currentStockFilter == 'out-of-stock' ? 'selected' : ''}>Hết hàng</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="promotion-filter">Khuyến mãi</label>
                        <select name="promotionFilter" id="promotion-filter" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả khuyến mãi</option>
                            <option value="active" ${currentPromotionFilter == 'active' ? 'selected' : ''}>Đang khuyến mãi</option>
                            <option value="discounted" ${currentPromotionFilter == 'discounted' ? 'selected' : ''}>Đang giảm giá</option>
                            <option value="none" ${currentPromotionFilter == 'none' ? 'selected' : ''}>Không khuyến mãi</option>
                            <c:forEach var="promo" items="${activePromos}">
                                <c:set var="promoFilterValue" value="promo-${promo.id}" />
                                <option value="${promoFilterValue}" ${currentPromotionFilter == promoFilterValue ? 'selected' : ''}>${promo.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>Khoảng giá</label>
                        <div class="admin-product-range-row">
                            <input type="number" name="minPrice" class="form-select" value="${currentMinPrice}" min="0" placeholder="Từ giá">
                            <input type="number" name="maxPrice" class="form-select" value="${currentMaxPrice}" min="0" placeholder="Đến giá">
                        </div>
                    </div>

                    <div class="filter-group">
                        <label>Ngưỡng tồn kho</label>
                        <div class="admin-product-range-row">
                            <input type="number" name="reorderThreshold" class="form-select" value="${currentReorderThreshold}" min="1" title="Dưới ngưỡng này là cần nhập">
                            <input type="number" name="lowStockThreshold" class="form-select" value="${currentLowStockThreshold}" min="1" title="Đến ngưỡng này là sắp hết">
                        </div>
                    </div>

                    <div class="filter-group">
                        <label for="sort-filter">Sắp xếp</label>
                        <select name="sort" id="sort-filter" class="form-select" onchange="this.form.submit()">
                            <option value="newest" ${currentSort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="oldest" ${currentSort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                            <option value="price-asc" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá thấp đến cao</option>
                            <option value="price-desc" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá cao đến thấp</option>
                            <option value="stock-asc" ${currentSort == 'stock-asc' ? 'selected' : ''}>Tồn kho thấp nhất</option>
                            <option value="name-asc" ${currentSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
                        </select>
                    </div>

                    <div class="filter-group admin-product-filter-actions">
                        <label>&nbsp;</label>
                        <div class="admin-product-action-row">
                            <button type="submit" class="admin-product-apply-btn"><i class="fas fa-filter"></i> Lọc</button>
                            <a href="admin/products" class="admin-product-reset-btn"><i class="fas fa-rotate-left"></i> Xóa</a>
                        </div>
                    </div>
                </div>
            </form>

            <script>
                function applyProductQuickFilter(fieldName, value) {
                    var form = document.getElementById('productFilterForm');
                    if (!form || !fieldName) return;

                    var field = form.elements[fieldName];
                    if (!field) return;

                    var nextValue = field.value === value ? '' : value;
                    field.value = nextValue;

                    if (fieldName === 'stockFilter' && nextValue && form.elements['status']) {
                        form.elements['status'].value = '';
                    }

                    if (form.requestSubmit) {
                        form.requestSubmit();
                    } else {
                        form.submit();
                    }
                }

                document.addEventListener('DOMContentLoaded', function () {
                    var buttons = document.querySelectorAll('.admin-product-quick-btn');
                    for (var i = 0; i < buttons.length; i++) {
                        buttons[i].addEventListener('click', function () {
                            applyProductQuickFilter(this.getAttribute('data-filter-field'), this.getAttribute('data-filter-value'));
                        });
                    }
                });
            </script>

            <div class="bulk-actions-bar full-width" id="bulkActionsBar">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <input type="checkbox" class="product-checkbox" id="selectAllProducts">
                    <span class="bulk-actions-info">
                        <strong id="selectedCount">0</strong> sản phẩm được chọn
                    </span>
                </div>

                <div class="bulk-actions-buttons">
                    <button class="btn-bulk btn-bulk-quick-discount" onclick="openQuickDiscountModal()">
                        <i class="fas fa-percentage"></i> Giảm giá nhanh
                    </button>
                    <button class="btn-bulk btn-bulk-cancel" onclick="clearQuickDiscount()">
                        <i class="fas fa-eraser"></i> Gỡ giảm giá nhanh
                    </button>
                    <button class="btn-bulk btn-bulk-promo" onclick="openPromoModal()">
                        <i class="fas fa-tags"></i> Thêm vào KM
                    </button>
                    <button class="btn-bulk btn-bulk-cancel" onclick="bulkRemovePromo()"
                            style="background: rgba(255,255,255,0.1);">
                        <i class="fas fa-eraser"></i> Gỡ khỏi KM
                    </button>

                    <button class="btn-bulk btn-bulk-activate" onclick="bulkActivate()">
                        <i class="fas fa-check-circle"></i> Kích hoạt
                    </button>
                    <button class="btn-bulk btn-bulk-deactivate" onclick="bulkDeactivate()">
                        <i class="fas fa-ban"></i> Ngừng bán
                    </button>

                    <button class="btn-bulk btn-bulk-cancel" onclick="cancelSelection()">
                        <i class="fas fa-times"></i> Hủy
                    </button>
                </div>
            </div>

            <div class="products-container">
                <div class="table-header">
                    <div class="products-count">Tổng cộng: <strong>${totalProducts} sản phẩm</strong></div>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th style="width: 50px;" class="check-col">
                                <input type="checkbox" class="product-checkbox" id="selectAllCheckbox"
                                       onchange="toggleSelectAll(this)">
                            </th>
                            <th style="width: 80px;">Hình ảnh</th>
                            <th>Tên sản phẩm</th>
                            <th style="width: 120px;">SKU</th>
                            <th style="width: 150px;">Danh mục</th>
                            <th style="width: 120px;">Giá bán</th>
                            <th style="width: 100px;">Tồn kho</th>
                            <th style="width: 120px;">Trạng thái</th>
                            <th style="width: 150px; text-align: center;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="p" items="${productList}">
                            <tr>
                                <td class="check-col">
                                    <input type="checkbox" class="product-checkbox row-checkbox"
                                           value="${p.id}"
                                           data-promo-id="${p.currentPromotionId}"
                                           onchange="updateBulkActions()">
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${empty p.imageUrl}">
                                            <img src="${pageContext.request.contextPath}/assets/images/no-image.jpg"
                                                 alt="${p.name}"
                                                 class="product-image-thumb"
                                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:when>
                                        <c:when test="${p.imageUrl.startsWith('http')}">
                                            <img src="${p.imageUrl}"
                                                 alt="${p.name}"
                                                 class="product-image-thumb"
                                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/${p.imageUrl}"
                                                 alt="${p.name}"
                                                 class="product-image-thumb"
                                                 style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="product-name-cell" style="font-weight: 500;">${p.name}</div>
                                    <div class="product-description-cell" style="font-size: 0.8rem; color: #666;">
                                            ${p.shortDescription}
                                    </div>
                                </td>
                                <td>${p.sku}</td>
                                <td>
                                    <c:forEach var="c" items="${categoryList}">
                                        <c:if test="${c.id == p.categoryId}">${c.name}</c:if>
                                    </c:forEach>
                                </td>
                                <td>
                                    <div class="admin-product-price-cell">
                                        <div class="product-price-main">
                                            <fmt:formatNumber value="${p.displayMinPrice}" pattern="#,###"/>đ
                                            <c:if test="${p.displayPriceRange}">
                                                - <fmt:formatNumber value="${p.displayMaxPrice}" pattern="#,###"/>đ
                                            </c:if>
                                        </div>
                                        <c:if test="${p.displayOnSale}">
                                            <div class="product-price-original">
                                                <fmt:formatNumber value="${p.originalMinPrice}" pattern="#,###"/>đ
                                                <c:if test="${p.originalMinPrice != p.originalMaxPrice}">
                                                    - <fmt:formatNumber value="${p.originalMaxPrice}" pattern="#,###"/>đ
                                                </c:if>
                                            </div>
                                        </c:if>
                                        <c:if test="${p.variantCount > 0}">
                                            <span class="admin-variant-count-pill">
                                                ${p.variantCount} biến thể
                                            </span>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <div class="admin-product-stock-cell">
                                        <span class="admin-stock-total-wrap">
                                            <span class="${p.totalStockQuantity > currentLowStockThreshold ? 'product-stock-high' : 'product-stock-low'}"
                                                  style="font-weight: 600; color: ${p.totalStockQuantity > currentLowStockThreshold ? '#28a745' : '#dc3545'}">
                                                    Tổng: ${p.totalStockQuantity}
                                            </span>
                                            <c:if test="${not empty p.variantInventorySummary}">
                                                <span class="admin-variant-popover">
                                                    <span class="admin-variant-popover-title">Tồn kho biến thể</span>
                                                    <span class="admin-variant-popover-table">
                                                        <span class="admin-variant-popover-row head">
                                                            <span>Biến thể</span>
                                                            <span>Giá</span>
                                                            <span>Tồn</span>
                                                        </span>
                                                        <c:forEach var="variantLine" items="${fn:split(p.variantInventorySummary, ';;')}">
                                                            <c:set var="variantParts" value="${fn:split(variantLine, '|')}" />
                                                            <span class="admin-variant-popover-row">
                                                                <span>${variantParts[0]}</span>
                                                                <span><fmt:formatNumber value="${variantParts[1]}" pattern="#,###"/>đ</span>
                                                                <span>${variantParts[2]}</span>
                                                            </span>
                                                        </c:forEach>
                                                    </span>
                                                </span>
                                            </c:if>
                                        </span>
                                        <c:choose>
                                            <c:when test="${p.totalStockQuantity == 0}">
                                                <span class="admin-stock-pill out">Hết hàng</span>
                                            </c:when>
                                            <c:when test="${p.totalStockQuantity > 0 && p.totalStockQuantity < currentReorderThreshold}">
                                                <span class="admin-stock-pill reorder">Cần nhập</span>
                                            </c:when>
                                            <c:when test="${p.totalStockQuantity >= currentReorderThreshold && p.totalStockQuantity <= currentLowStockThreshold}">
                                                <span class="admin-stock-pill low">Sắp hết</span>
                                            </c:when>
                                        </c:choose>
                                        <c:if test="${p.lowStockVariantCount > 0}">
                                            <span class="admin-stock-variant-note" title="${p.lowStockVariantSummary}">
                                                ${p.lowStockVariantCount} biến thể cần nhập
                                            </span>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <span class="status-badge ${p.status == 'ACTIVE' ? 'status-confirmed' : 'status-cancelled'}"
                                          style="padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 600;
                                                  background: ${p.status == 'ACTIVE' ? '#d4edda' : '#f8d7da'};
                                                  color: ${p.status == 'ACTIVE' ? '#155724' : '#721c24'};">
                                            ${p.status == 'ACTIVE' ? 'Đang bán' : (p.status == 'INACTIVE' ? 'Ngừng bán' : 'Hết hàng')}
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons" style="justify-content: center;">
                                        <a href="chi-tiet-san-pham?id=${p.id}" target="_blank" class="btn-action"
                                           title="Xem chi tiết">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="admin/product/edit?id=${p.id}" class="btn-action" title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </a>

                                        <c:choose>
                                            <c:when test="${p.status == 'ACTIVE'}">
                                                <button class="btn-action danger" title="Ngừng bán"
                                                        onclick="updateSingleStatus(${p.id}, 'INACTIVE')">
                                                    <i class="fas fa-ban"></i>
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn-action" style="color: green; border-color: green;"
                                                        title="Kích hoạt lại"
                                                        onclick="updateSingleStatus(${p.id}, 'ACTIVE')">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
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
                            <!-- Lùi 6 trang -->
                            <a href="admin/products?page=${prevPage < 1 ? 1 : prevPage}${filterQuery}"
                               class="page-btn ${currentPage <= windowSize ? 'disabled' : ''}">
                                &laquo;
                            </a>

                            <!-- Các trang trong block hiện tại -->
                            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                <a href="admin/products?page=${i}${filterQuery}"
                                   class="page-btn ${currentPage == i ? 'active' : ''}">
                                        ${i}
                                </a>
                            </c:forEach>

                            <!-- Tiến 6 trang -->
                            <a href="admin/products?page=${nextPage > totalPages ? totalPages : nextPage}${filterQuery}"
                               class="page-btn ${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                                &raquo;
                            </a>
                        </div>
                    </c:if>
                </div>

            </div>
        </div>
    </main>
</div>

<div id="promoModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-header" style="display: flex; justify-content: space-between; margin-bottom: 20px;">
            <h3>Thêm vào chương trình KM</h3>
            <span class="close-modal" onclick="closePromoModal()"
                  style="cursor: pointer; font-size: 24px;">&times;</span>
        </div>
        <div class="modal-body">
            <p>Bạn đang chọn <strong id="promoSelectedCount" style="color: #e67e22;">0</strong> sản phẩm.</p>
            <div class="form-group">
                <label for="promoSelect">Chọn chương trình áp dụng:</label>
                <select id="promoSelect" class="form-select full-width">
                    <option value="">-- Chọn chương trình --</option>
                    <c:forEach var="promo" items="${activePromos}">
                        <option value="${promo.id}">🔥 ${promo.name}</option>
                    </c:forEach>
                </select>
                <p id="promoWarning" style="color: red; display: none; margin-top: 10px; font-size: 0.9em;">
                    <i class="fas fa-exclamation-triangle"></i> Sản phẩm này đang thuộc chương trình khác. Chọn chương
                    trình mới sẽ ghi đè.
                </p>
            </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
            <button id="btnRemovePromo" class="btn btn-danger" style="display: none; margin-right: auto;"
                    onclick="submitRemovePromo()">
                <i class="fas fa-trash-alt"></i> Gỡ khỏi KM
            </button>
            <button class="btn btn-secondary" onclick="closePromoModal()"
                    style="background: #ccc; border: none; padding: 8px 16px; border-radius: 4px;">Hủy
            </button>
            <button class="btn btn-primary" onclick="submitAddToPromo()">Lưu thay đổi</button>
        </div>
    </div>
</div>

<div id="quickDiscountModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-header" style="display: flex; justify-content: space-between; margin-bottom: 20px;">
            <h3>Giảm giá nhanh</h3>
            <span class="close-modal" onclick="closeQuickDiscountModal()" style="cursor: pointer; font-size: 24px;">&times;</span>
        </div>
        <div class="modal-body">
            <p>Bạn đang chọn <strong id="discountSelectedCount" style="color: #e67e22;">0</strong> sản phẩm.</p>

            <div class="form-group">
                <label>Loại giảm giá:</label>
                <div class="radio-group" style="display: flex; flex-direction: column; gap: 10px; margin-top: 5px;">
                    <label class="radio-label" style="display: flex; gap: 10px; cursor: pointer;">
                        <input type="radio" name="discountType" value="percent" checked>
                        <span>Giảm theo phần trăm (%)</span>
                    </label>
                    <label class="radio-label" style="display: flex; gap: 10px; cursor: pointer;">
                        <input type="radio" name="discountType" value="amount">
                        <span>Giảm số tiền cố định (đ)</span>
                    </label>
                </div>
            </div>

            <div class="form-group" style="margin-top: 15px;">
                <label for="discountValue">Nhập giá trị:</label>
                <input type="number" id="discountValue" class="form-input full-width" placeholder="Ví dụ: 15" min="0">
            </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px;">
            <button class="btn btn-secondary" onclick="closeQuickDiscountModal()"
                    style="background: #ccc; border: none; padding: 8px 16px; border-radius: 4px;">Hủy
            </button>
            <button class="btn btn-primary" onclick="submitQuickDiscount()">Áp dụng</button>
        </div>
    </div>
</div>

<script>
    function updateStatusAPI(ids, status) {
        const actionName = status === 'ACTIVE' ? 'Kích hoạt' : 'Ngừng bán';

        const params = new URLSearchParams();
        params.append('ids', ids);
        params.append('status', status);

        fetch('admin/product/status', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("Đã " + actionName + " thành công!");
                location.reload();
            } else {
                alert("Lỗi máy chủ! Vui lòng thử lại.");
            }
        }).catch(err => {
            console.error(err);
            alert("Lỗi kết nối!");
        });
    }

    // --- 2. BULK ACTIONS ---
    function bulkActivate() {
        const selectedIds = getSelectedProducts();
        if (selectedIds.length === 0) return;
        if (confirm(`Bạn có chắc muốn KÍCH HOẠT ${selectedIds.length} sản phẩm đã chọn?`)) {
            updateStatusAPI(selectedIds.join(','), 'ACTIVE');
        }
    }

    function bulkDeactivate() {
        const selectedIds = getSelectedProducts();
        if (selectedIds.length === 0) return;
        if (confirm(`Bạn có chắc muốn NGỪNG BÁN ${selectedIds.length} sản phẩm đã chọn?`)) {
            updateStatusAPI(selectedIds.join(','), 'INACTIVE');
        }
    }

    // --- 3. SINGLE ACTIONS ---
    function updateSingleStatus(id, status) {
        const actionName = status === 'ACTIVE' ? 'Kích hoạt lại' : 'Ngừng bán';
        if (!confirm(`Bạn muốn ${actionName} sản phẩm này?`)) return;
        updateStatusAPI(id, status);
    }

    // --- 4. CHECKBOX UTILS ---
    function toggleSelectAll(checkbox) {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const bulkActionsCheckbox = document.getElementById('selectAllProducts');
        rowCheckboxes.forEach(cb => cb.checked = checkbox.checked);
        bulkActionsCheckbox.checked = checkbox.checked;
        updateBulkActions();
    }

    function updateBulkActions() {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const bulkActionsCheckbox = document.getElementById('selectAllProducts');
        const bulkActionsBar = document.getElementById('bulkActionsBar');
        const selectedCount = document.getElementById('selectedCount');

        const checkedCount = Array.from(rowCheckboxes).filter(cb => cb.checked).length;
        const totalCount = rowCheckboxes.length;

        selectedCount.textContent = checkedCount;

        if (checkedCount > 0) bulkActionsBar.classList.add('active');
        else bulkActionsBar.classList.remove('active');

        // Sync
        const isAllChecked = checkedCount === totalCount && totalCount > 0;
        selectAllCheckbox.checked = isAllChecked;
        bulkActionsCheckbox.checked = isAllChecked;
    }

    document.getElementById('selectAllProducts').addEventListener('change', function () {
        document.getElementById('selectAllCheckbox').checked = this.checked;
        toggleSelectAll(this);
    });

    function cancelSelection() {
        document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
        document.getElementById('selectAllCheckbox').checked = false;
        document.getElementById('selectAllProducts').checked = false;
        updateBulkActions();
    }

    function getSelectedProducts() {
        return Array.from(document.querySelectorAll('.row-checkbox:checked')).map(cb => cb.value);
    }

    // --- 5. MODAL LOGIC (Promo & Discount) ---
    function openPromoModal() {
        const checkboxes = document.querySelectorAll('.row-checkbox:checked');
        if (checkboxes.length === 0) {
            alert("Chưa chọn sản phẩm!");
            return;
        }
        document.getElementById('promoSelectedCount').textContent = checkboxes.length;
        document.getElementById('promoModal').classList.add('active');
    }

    function closePromoModal() {
        document.getElementById('promoModal').classList.remove('active');
        document.getElementById('promoSelect').value = "";
    }

    function openQuickDiscountModal() {
        const checkboxes = document.querySelectorAll('.row-checkbox:checked');
        if (checkboxes.length === 0) {
            alert("Chưa chọn sản phẩm!");
            return;
        }
        document.getElementById('discountSelectedCount').textContent = checkboxes.length;
        document.getElementById('quickDiscountModal').classList.add('active');
    }

    function closeQuickDiscountModal() {
        document.getElementById('quickDiscountModal').classList.remove('active');
    }

    function submitAddToPromo() {
        const promotionId = document.getElementById('promoSelect').value;
        const selectedProductIds = getSelectedProducts();
        if (!promotionId) {
            alert("Vui lòng chọn chương trình!");
            return;
        }

        const params = new URLSearchParams();
        params.append('promoId', promotionId);
        params.append('productIds', selectedProductIds.join(','));

        fetch('admin/promotion/add-products', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("✅ Đã thêm vào chương trình!");
                location.reload();
            } else alert("Lỗi khi thêm.");
        });
    }

    function submitQuickDiscount() {
        const selectedIds = getSelectedProducts();
        const discountType = document.querySelector('input[name="discountType"]:checked').value;
        const discountValue = document.getElementById('discountValue').value;

        if (!discountValue) {
            alert("Nhập giá trị giảm!");
            return;
        }

        const params = new URLSearchParams();
        params.append('type', discountType);
        params.append('value', discountValue);
        params.append('productIds', selectedIds.join(','));

        fetch('admin/product/quick-discount', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("Đã cập nhật giá!");
                location.reload();
            } else alert("Lỗi cập nhật.");
        });
    }

    function bulkRemovePromo() {
        const selectedIds = getSelectedProducts();
        if (selectedIds.length === 0) return;
        if (!confirm(`Gỡ ${selectedIds.length} sản phẩm khỏi mọi chương trình KM?`)) return;

        const params = new URLSearchParams();
        params.append('action', 'remove');
        params.append('productIds', selectedIds.join(','));

        fetch('admin/promotion/add-products', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("Đã gỡ KM thành công!");
                location.reload();
            } else alert("Lỗi khi xử lý.");
        });
    }
    function clearQuickDiscount() {
        const selectedIds = getSelectedProducts();
        if (selectedIds.length === 0) {
            alert("Chưa chọn sản phẩm!");
            return;
        }
        if (!confirm("Gỡ giảm giá nhanh cho các sản phẩm đã chọn?")) {
            return;
        }

        const params = new URLSearchParams();
        params.append('action', 'clear');
        params.append('productIds', selectedIds.join(','));

        fetch('admin/product/quick-discount', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("Đã gỡ giảm giá nhanh!");
                location.reload();
            } else {
                alert("Lỗi khi gỡ giảm giá nhanh.");
            }
        }).catch(() => {
            alert("Lỗi kết nối!");
        });
    }
</script>

</body>
</html>
