<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tồn kho - Mộc Trà Admin</title>
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
        <jsp:param name="activePage" value="inventory"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý tồn kho</h1>
            </div>
            <div class="header-right">
                <div class="header-search">
                    <i class="fas fa-search"></i>
                    <input type="text" name="keyword" form="inventoryFilterForm"
                           value="${currentKeyword}"
                           placeholder="Tìm sản phẩm, variant, SKU..."
                           autocomplete="off">
                </div>
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
                    <h2>Tồn kho biến thể</h2>
                    <p>Mỗi dòng là một biến thể; số nhập thêm sẽ được cộng vào tồn hiện tại.</p>
                </div>
                <div class="page-actions">
                    <a href="admin/products" class="btn btn-secondary">
                        <i class="fas fa-box"></i> Sản phẩm
                    </a>
                </div>
            </div>

            <div class="import-box inventory-import-box">
                <div class="import-left">
                    <div class="import-icon">
                        <i class="fas fa-boxes-stacked"></i>
                    </div>
                    <div>
                        <h3>Import tồn kho bằng Excel</h3>
                        <p>Dùng variant_id hoặc variant_sku và quantity_add để cộng thêm số lượng nhập hàng.</p>
                    </div>
                </div>

                <div class="import-right">
                    <a href="${pageContext.request.contextPath}/admin/products/inventory-template"
                       class="import-btn inventory-template-btn">
                        <i class="fas fa-download"></i>
                        Tải mẫu tồn kho
                    </a>

                    <form action="${pageContext.request.contextPath}/admin/products/inventory-import"
                          method="post"
                          enctype="multipart/form-data"
                          class="import-form">
                        <label class="file-upload-box">
                            <i class="fas fa-paperclip"></i>
                            <span id="inventoryFileName">Chọn file tồn kho</span>
                            <input type="file"
                                   name="inventoryFile"
                                   accept=".xlsx"
                                   required
                                   onchange="document.getElementById('inventoryFileName').innerText = this.files[0].name">
                        </label>
                        <button type="submit" class="import-btn inventory-upload-btn">
                            <i class="fas fa-upload"></i>
                            Import tồn kho
                        </button>
                    </form>
                </div>
            </div>

            <div class="admin-product-quick-filters">
                <button type="button" class="admin-product-quick-btn ${currentStockFilter == 'need-reorder' ? 'active' : ''}"
                        data-filter-field="stockFilter" data-filter-value="need-reorder">
                    <i class="fas fa-box-open"></i> Cần nhập hàng
                </button>
                <button type="button" class="admin-product-quick-btn ${currentStockFilter == 'low-stock' ? 'active' : ''}"
                        data-filter-field="stockFilter" data-filter-value="low-stock">
                    <i class="fas fa-battery-quarter"></i> Sắp hết hàng
                </button>
                <button type="button" class="admin-product-quick-btn ${currentStockFilter == 'out-of-stock' ? 'active' : ''}"
                        data-filter-field="stockFilter" data-filter-value="out-of-stock">
                    <i class="fas fa-triangle-exclamation"></i> Hết hàng
                </button>
            </div>

            <form id="inventoryFilterForm" action="admin/inventory" method="get" class="filters-section">
                <div class="filters-grid admin-product-filters-grid">
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
                        <label for="stock-filter">Tồn kho</label>
                        <select name="stockFilter" id="stock-filter" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả tồn kho</option>
                            <option value="in-stock" ${currentStockFilter == 'in-stock' ? 'selected' : ''}>Còn nhiều</option>
                            <option value="need-reorder" ${currentStockFilter == 'need-reorder' ? 'selected' : ''}>Cần nhập hàng</option>
                            <option value="low-stock" ${currentStockFilter == 'low-stock' ? 'selected' : ''}>Sắp hết hàng</option>
                            <option value="out-of-stock" ${currentStockFilter == 'out-of-stock' ? 'selected' : ''}>Hết hàng</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label>Ngưỡng tồn kho</label>
                        <div class="admin-product-range-row">
                            <input type="number" name="reorderThreshold" class="form-select" value="${currentReorderThreshold}" min="1">
                            <input type="number" name="lowStockThreshold" class="form-select" value="${currentLowStockThreshold}" min="1">
                        </div>
                    </div>

                    <div class="filter-group">
                        <label for="sort-filter">Sắp xếp</label>
                        <select name="sort" id="sort-filter" class="form-select" onchange="this.form.submit()">
                            <option value="stock-asc" ${currentSort == 'stock-asc' ? 'selected' : ''}>Tồn thấp nhất</option>
                            <option value="stock-desc" ${currentSort == 'stock-desc' ? 'selected' : ''}>Tồn cao nhất</option>
                            <option value="name-asc" ${currentSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
                        </select>
                    </div>

                    <div class="filter-group admin-product-filter-actions">
                        <label>&nbsp;</label>
                        <div class="admin-product-action-row">
                            <button type="submit" class="admin-product-apply-btn"><i class="fas fa-filter"></i> Lọc</button>
                            <a href="admin/inventory" class="admin-product-reset-btn"><i class="fas fa-rotate-left"></i> Xóa</a>
                        </div>
                    </div>
                </div>
            </form>

            <form action="admin/inventory" method="post" class="products-container" onsubmit="return confirmInventoryUpdate(this)">
                <div class="table-header inventory-table-header">
                    <div class="products-count">Tổng cộng: <strong>${totalVariants} biến thể</strong></div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> Cộng tồn kho đã nhập
                    </button>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Biến thể</th>
                            <th style="width: 130px;">SKU variant</th>
                            <th style="width: 120px;">Giá</th>
                            <th style="width: 110px;">Tồn hiện tại</th>
                            <th style="width: 130px;">Nhập thêm</th>
                            <th style="width: 120px;">Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="v" items="${variants}">
                            <tr data-product-name="${v.productName}"
                                data-variant-name="${v.variantName}"
                                data-current-stock="${v.stockQuantity}">
                                <td>
                                    <div class="product-name-cell">${v.productName}</div>
                                    <div class="product-description-cell">${v.categoryName} · ${v.productSku}</div>
                                </td>
                                <td>${v.variantName}</td>
                                <td>${v.sku}</td>
                                <td>
                                    <fmt:formatNumber value="${v.salePrice > 0 ? v.salePrice : v.price}" pattern="#,###"/>đ
                                    <c:if test="${v.salePrice > 0 && v.salePrice < v.price}">
                                        <div class="product-price-original">
                                            <fmt:formatNumber value="${v.price}" pattern="#,###"/>đ
                                        </div>
                                    </c:if>
                                </td>
                                <td>
                                    <span class="${v.stockQuantity > currentLowStockThreshold ? 'product-stock-high' : 'product-stock-low'}">
                                            ${v.stockQuantity}
                                    </span>
                                </td>
                                <td>
                                    <input type="hidden" name="variantIds" value="${v.id}">
                                    <input type="number" name="quantityAdds" class="form-select inventory-add-input"
                                           min="0" placeholder="0">
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${v.stockQuantity == 0}">
                                            <span class="admin-stock-pill out">Hết hàng</span>
                                        </c:when>
                                        <c:when test="${v.stockQuantity > 0 && v.stockQuantity < currentReorderThreshold}">
                                            <span class="admin-stock-pill reorder">Cần nhập</span>
                                        </c:when>
                                        <c:when test="${v.stockQuantity >= currentReorderThreshold && v.stockQuantity <= currentLowStockThreshold}">
                                            <span class="admin-stock-pill low">Sắp hết</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="admin-stock-pill ok">Ổn</span>
                                        </c:otherwise>
                                    </c:choose>
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
                        <div class="pagination">
                            <a href="admin/inventory?page=${currentPage - 1 < 1 ? 1 : currentPage - 1}${filterQuery}"
                               class="page-btn ${currentPage <= 1 ? 'disabled' : ''}">&laquo;</a>
                            <c:forEach begin="1" end="${totalPages}" var="i">
                                <a href="admin/inventory?page=${i}${filterQuery}"
                                   class="page-btn ${currentPage == i ? 'active' : ''}">${i}</a>
                            </c:forEach>
                            <a href="admin/inventory?page=${currentPage + 1 > totalPages ? totalPages : currentPage + 1}${filterQuery}"
                               class="page-btn ${currentPage >= totalPages ? 'disabled' : ''}">&raquo;</a>
                        </div>
                    </c:if>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
    function applyInventoryQuickFilter(fieldName, value) {
        const form = document.getElementById('inventoryFilterForm');
        if (!form || !fieldName || !form.elements[fieldName]) return;
        form.elements[fieldName].value = form.elements[fieldName].value === value ? '' : value;
        if (form.requestSubmit) form.requestSubmit();
        else form.submit();
    }

    function confirmInventoryUpdate(form) {
        const rows = Array.from(form.querySelectorAll('tbody tr'));
        const updates = [];

        rows.forEach(function (row) {
            const input = row.querySelector('input[name="quantityAdds"]');
            const quantity = parseInt(input && input.value ? input.value : '0', 10);
            if (quantity > 0) {
                const currentStock = parseInt(row.getAttribute('data-current-stock') || '0', 10);
                updates.push({
                    productName: row.getAttribute('data-product-name') || '',
                    variantName: row.getAttribute('data-variant-name') || '',
                    quantity: quantity,
                    nextStock: currentStock + quantity
                });
            }
        });

        if (updates.length === 0) {
            alert('Vui lòng nhập số lượng cần cộng cho ít nhất một biến thể.');
            return false;
        }

        const preview = updates.slice(0, 8).map(function (item) {
            return '- ' + item.productName + ' / ' + item.variantName + ': +' + item.quantity + ' => ' + item.nextStock;
        }).join('\n');
        const more = updates.length > 8 ? '\n... và ' + (updates.length - 8) + ' biến thể khác' : '';

        return confirm('Xác nhận cộng tồn kho cho ' + updates.length + ' biến thể?\n\n' + preview + more);
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.admin-product-quick-btn').forEach(function (button) {
            button.addEventListener('click', function () {
                applyInventoryQuickFilter(this.getAttribute('data-filter-field'), this.getAttribute('data-filter-value'));
            });
        });
    });
</script>
</body>
</html>
