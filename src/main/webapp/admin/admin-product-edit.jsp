<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập nhật sản phẩm - Mộc Trà Admin</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin-add-product.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">
</head>
<body>
<div class="admin-container">
    <aside class="admin-sidebar">
        <div class="sidebar-header">
            <div class="admin-logo">
                <img src="${pageContext.request.contextPath}/assets/images/logoweb.png" alt="Mộc Trà">
                <h2>Mộc Trà Admin</h2>
            </div>
        </div>

        <nav class="admin-nav">
            <ul>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp"><i
                            class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
                </li>
                <li class="nav-item active">
                    <a href="${pageContext.request.contextPath}/admin/products"><i class="fas fa-box"></i><span>Tất cả Sản phẩm</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/banners.jsp"><i class="fas fa-images"></i><span>Quản lý Banner</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/categories.jsp"><i
                            class="fas fa-sitemap"></i><span>Danh mục Sản phẩm</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/orders.jsp"><i
                            class="fas fa-shopping-cart"></i><span>Đơn hàng</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/customers.jsp"><i class="fas fa-users"></i><span>Khách hàng</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/blog.jsp"><i class="fas fa-newspaper"></i><span>Tất cả Bài viết</span></a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/blog-categories.jsp"><i class="fas fa-folder"></i><span>Danh mục Blog</span></a>
                </li>
            </ul>
        </nav>
    </aside>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Cập nhật sản phẩm</h1>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline">
                    <i class="fas fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>
        </header>

        <div class="admin-content">

            <%-- THÔNG BÁO CẬP NHẬT THÀNH CÔNG --%>
            <c:if test="${param.msg == 'update_success'}">
                <div class="alert alert-success" style="background-color: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #c3e6cb; font-weight: 500;">
                    <i class="fas fa-check-circle" style="margin-right: 5px;"></i> Cập nhật sản phẩm thành công!
                </div>
            </c:if>

            <form class="form-container" action="${pageContext.request.contextPath}/admin/product/edit" method="POST"
                  enctype="multipart/form-data" onsubmit="return validateForm()">

                <input type="hidden" name="id" value="${product.id}">
                <input type="hidden" name="current_image" value="${product.imageUrl}">

                <div class="form-header">
                    <h2>Chỉnh sửa thông tin</h2>
                    <p>Cập nhật thông tin chi tiết cho sản phẩm: <strong><c:out value="${product.name}"/></strong></p>
                </div>

                <div class="form-content">
                    <div class="form-grid">
                        <div class="form-left">
                            <div class="form-section">
                                <h3><i class="fas fa-info-circle"></i> Thông tin cơ bản</h3>

                                <div class="form-group">
                                    <label for="product_name">Tên sản phẩm <span class="required">*</span></label>
                                    <input type="text" id="product_name" name="name" class="form-control"
                                           value="${product.name}" required>
                                </div>

                                <div class="form-group">
                                    <label for="product_slug">Slug</label>
                                    <input type="text" id="product_slug" name="slug" class="form-control"
                                           value="${product.slug}">
                                </div>

                                <div class="form-group">
                                    <label for="short_description">Mô tả ngắn</label>
                                    <textarea id="short_description" name="short_description"
                                              class="form-control textarea"
                                              rows="4">${product.shortDescription}</textarea>
                                </div>

                                <div class="form-group">
                                    <label for="description">Mô tả chi tiết</label>
                                    <textarea id="description" name="description" class="form-control textarea large"
                                              rows="8">${product.description}</textarea>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-leaf"></i> Thông cải bổ sung</h3>

                                <div class="form-group">
                                    <label for="ingredients">Thành phần nguyên liệu</label>
                                    <textarea id="ingredients" name="ingredients" class="form-control textarea"
                                              rows="4">${product.ingredients}</textarea>
                                </div>

                                <div class="form-group">
                                    <label for="usage_instructions">Hướng dẫn sử dụng</label>
                                    <textarea id="usage_instructions" name="usage_instructions"
                                              class="form-control textarea"
                                              rows="4">${product.usageInstructions}</textarea>
                                </div>
                            </div>
                        </div>

                        <div class="form-right">
                            <div class="form-section">
                                <h3><i class="fas fa-cog"></i> Trạng thái & Phân loại</h3>

                                <div class="form-group">
                                    <label for="status">Trạng thái <span class="required">*</span></label>
                                    <select id="status" name="status" class="form-control" required>
                                        <option value="active" ${product.status == 'ACTIVE' ? 'selected' : ''}>Hoạt
                                            động
                                        </option>
                                        <option value="inactive" ${product.status == 'INACTIVE' ? 'selected' : ''}>Không
                                            hoạt động
                                        </option>
                                        <option value="out_of_stock" ${product.status == 'OUT_OF_STOCK' ? 'selected' : ''}>
                                            Hết hàng
                                        </option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="category_id">Danh mục <span class="required">*</span></label>
                                    <select id="category_id" name="category_id" class="form-control" required>
                                        <option value="">-- Chọn danh mục --</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}" ${product.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="checkbox-group">
                                    <input type="checkbox" id="is_bestseller" name="is_bestseller"
                                           value="1" ${product.bestseller ? 'checked' : ''}>
                                    <label for="is_bestseller">Sản phẩm bán chạy</label>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-dollar-sign"></i> Giá & Kho hàng</h3>

                                <div class="form-group">
                                    <label for="price">Giá bán (VNĐ) <span class="required">*</span></label>
                                    <input type="number" id="price" name="price" class="form-control"
                                           value="<fmt:formatNumber value='${product.price}' pattern='0'/>" required>
                                </div>

                                <div class="form-group">
                                    <label for="sale_price">Giá khuyến mãi (VNĐ)</label>
                                    <input type="number" id="sale_price" name="sale_price" class="form-control"
                                           value="<fmt:formatNumber value='${product.salePrice}' pattern='0'/>">
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label for="sku">Mã SKU</label>
                                        <input type="text" id="sku" name="sku" class="form-control"
                                               value="${product.sku}">
                                    </div>

                                    <div class="form-group">
                                        <label for="stock_quantity">Số lượng tồn kho</label>
                                        <input type="number" id="stock_quantity" name="stock_quantity"
                                               class="form-control" value="${product.stockQuantity}">
                                    </div>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-tags"></i> Phân loại sản phẩm</h3>
                                <div class="variant-manager">
                                    <div class="variant-toolbar">
                                        <button type="button" class="btn btn-success btn-sm variant-add-btn" onclick="openVariantEditor()">
                                            <i class="fas fa-plus"></i> Thêm phân loại mới
                                        </button>
                                    </div>

                                    <div class="variant-table-wrap">
                                        <table class="variant-table">
                                            <thead>
                                            <tr>
                                                <th>Tên phân loại</th>
                                                <th>Giá gốc</th>
                                                <th>Tồn kho</th>
                                                <th>Thao tác</th>
                                            </tr>
                                            </thead>
                                            <tbody id="variantsContainer">
                                            <c:forEach var="v" items="${variants}">
                                                <tr class="variant-list-item">
                                                    <td class="variant-list-name">${v.variantName}</td>
                                                    <td class="variant-price">
                                                        <fmt:formatNumber value="${v.price}" pattern="#,###"/> đ
                                                    </td>
                                                    <td class="variant-stock">${v.stockQuantity}</td>
                                                    <td>
                                                        <div class="variant-list-actions">
                                                            <button type="button" class="variant-icon-btn"
                                                                    onclick="openVariantEditor(this.closest('.variant-list-item'))"
                                                                    title="Chỉnh sửa">
                                                                <i class="fas fa-pen"></i>
                                                            </button>
                                                            <button type="button" class="variant-icon-btn danger"
                                                                    onclick="removeVariantItem(this)" title="Xóa">
                                                                <i class="fas fa-trash"></i>
                                                            </button>
                                                        </div>
                                                        <input type="hidden" name="variantIds" value="${v.id}">
                                                        <input type="hidden" name="variantNames" value="${v.variantName}">
                                                        <input type="hidden" name="variantPrices" value="<fmt:formatNumber value='${v.price}' pattern='#' groupingUsed='false'/>">
                                                        <input type="hidden" name="variantSalePrices" value="0">
                                                        <input type="hidden" name="variantStocks" value="${v.stockQuantity}">
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                        <div class="variant-empty" id="variantEmptyState">
                                            Chưa có phân loại nào. Nếu bỏ trống, sản phẩm sẽ bán theo giá cơ bản.
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="form-section">
                                <h3><i class="fas fa-image"></i> Hình ảnh sản phẩm</h3>

                                <div class="form-group">
                                    <label>Hình ảnh chính hiện tại</label>
                                    <div style="margin-bottom: 15px;">
                                        <c:choose>
                                            <c:when test="${empty product.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/assets/images/no-image.jpg"
                                                     alt="${product.name}"
                                                     style="width: 100%; border-radius: 8px; border: 1px solid #ddd; object-fit: contain; height: 200px;">
                                            </c:when>
                                            <c:when test="${product.imageUrl.startsWith('http')}">
                                                <img src="${product.imageUrl}"
                                                     alt="${product.name}"
                                                     style="width: 100%; border-radius: 8px; border: 1px solid #ddd; object-fit: contain; height: 200px;">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/${product.imageUrl}"
                                                     alt="${product.name}"
                                                     style="width: 100%; border-radius: 8px; border: 1px solid #ddd; object-fit: contain; height: 200px;">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <label for="image_url">Thay đổi ảnh chính</label>
                                    <div class="image-upload" onclick="document.getElementById('image_url').click()"
                                         style="padding: 15px;">
                                        <i class="fas fa-cloud-upload-alt" style="font-size: 24px;"></i>
                                        <p style="margin: 5px 0;">Chọn ảnh mới để thay thế</p>
                                    </div>
                                    <input type="file" id="image_url" name="image_url" accept="image/*"
                                           style="display: none;">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-outline">
                            <i class="fas fa-times"></i> Hủy bỏ
                        </a>

                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </main>
</div>

<div id="variantModal" class="variant-modal modal-hidden">
    <div class="variant-modal-overlay" onclick="closeVariantEditor()"></div>
    <div class="variant-modal-content">
        <div class="variant-modal-header">
            <h3 id="variantEditorTitle">Thêm phân loại mới</h3>
            <button type="button" class="variant-modal-close" onclick="closeVariantEditor()">&times;</button>
        </div>
        <div class="variant-modal-body">
            <p class="variant-modal-help">
                Thêm/sửa các quy cách đóng gói (VD: Hộp 10 gói, Gói 100g...). Nếu bỏ trống, sản phẩm sẽ bán theo giá cơ bản.
            </p>
            <div class="variant-editor-grid">
                <div class="form-group">
                    <label>Tên phân loại</label>
                    <input type="text" id="variantNameInput" class="form-control"
                           placeholder="VD: Hộp 10 gói, Gói 100g">
                </div>
                <div class="form-group">
                    <label>Giá gốc</label>
                    <input type="number" id="variantPriceInput" class="form-control"
                           placeholder="VD: 120000" min="0">
                </div>
                <div class="form-group">
                    <label>Tồn kho</label>
                    <input type="number" id="variantStockInput" class="form-control"
                           placeholder="VD: 20" min="0">
                </div>
            </div>
        </div>
        <div class="variant-modal-footer">
            <button type="button" class="btn btn-outline btn-sm" onclick="closeVariantEditor()">Hủy</button>
            <button type="button" class="btn btn-primary btn-sm" onclick="saveVariant()">Lưu phân loại</button>
        </div>
    </div>
</div>

<script>
    let editingVariantItem = null;

    document.addEventListener('DOMContentLoaded', updateVariantEmptyState);

    function validateForm() {
        const mainPriceInput = document.getElementById('price');
        const mainSalePriceInput = document.getElementById('sale_price');

        const mainPrice = parseFloat(mainPriceInput.value) || 0;
        const mainSalePrice = parseFloat(mainSalePriceInput.value) || 0;

        if (mainSalePrice > mainPrice) {
            alert('Lỗi: Giá khuyến mãi của sản phẩm chính không được lớn hơn giá gốc!');
            mainSalePriceInput.focus();
            return false;
        }

        return true;
    }

    function openVariantEditor(item) {
        editingVariantItem = item || null;
        document.getElementById('variantEditorTitle').innerText = editingVariantItem ? 'Chỉnh sửa phân loại' : 'Thêm phân loại mới';

        if (editingVariantItem) {
            document.getElementById('variantNameInput').value = editingVariantItem.querySelector('input[name="variantNames"]').value;
            document.getElementById('variantPriceInput').value = editingVariantItem.querySelector('input[name="variantPrices"]').value;
            document.getElementById('variantStockInput').value = editingVariantItem.querySelector('input[name="variantStocks"]').value;
        } else {
            clearVariantEditor();
        }

        document.getElementById('variantModal').classList.remove('modal-hidden');
        document.getElementById('variantNameInput').focus();
    }

    function closeVariantEditor() {
        document.getElementById('variantModal').classList.add('modal-hidden');
        editingVariantItem = null;
        clearVariantEditor();
    }

    function clearVariantEditor() {
        document.getElementById('variantNameInput').value = '';
        document.getElementById('variantPriceInput').value = '';
        document.getElementById('variantStockInput').value = '';
    }

    function saveVariant() {
        const name = document.getElementById('variantNameInput').value.trim();
        const price = document.getElementById('variantPriceInput').value || '0';
        const stock = document.getElementById('variantStockInput').value || '0';

        if (!name) {
            alert('Vui lòng nhập tên phân loại.');
            document.getElementById('variantNameInput').focus();
            return;
        }

        if (editingVariantItem) {
            updateVariantItem(editingVariantItem, name, price, stock);
        } else {
            const item = document.createElement('tr');
            item.className = 'variant-list-item';
            document.getElementById('variantsContainer').appendChild(item);
            updateVariantItem(item, name, price, stock, '0');
        }

        updateVariantEmptyState();
        closeVariantEditor();
    }

    function updateVariantItem(item, name, price, stock, variantId) {
        const currentVariantId = variantId || item.querySelector('input[name="variantIds"]')?.value || '0';
        item.innerHTML = `
            <td class="variant-list-name"></td>
            <td class="variant-price"></td>
            <td class="variant-stock"></td>
            <td>
                <div class="variant-list-actions">
                    <button type="button" class="variant-icon-btn" onclick="openVariantEditor(this.closest('.variant-list-item'))" title="Chỉnh sửa">
                        <i class="fas fa-pen"></i>
                    </button>
                    <button type="button" class="variant-icon-btn danger" onclick="removeVariantItem(this)" title="Xóa">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
                <input type="hidden" name="variantIds">
                <input type="hidden" name="variantNames">
                <input type="hidden" name="variantPrices">
                <input type="hidden" name="variantSalePrices">
                <input type="hidden" name="variantStocks">
            </td>
        `;
        item.querySelector('.variant-list-name').innerText = name;
        item.querySelector('.variant-price').innerText = formatVariantMoney(price);
        item.querySelector('.variant-stock').innerText = stock;
        item.querySelector('input[name="variantIds"]').value = currentVariantId;
        item.querySelector('input[name="variantNames"]').value = name;
        item.querySelector('input[name="variantPrices"]').value = price;
        item.querySelector('input[name="variantSalePrices"]').value = '0';
        item.querySelector('input[name="variantStocks"]').value = stock;
    }

    function removeVariantItem(button) {
        button.closest('.variant-list-item').remove();
        updateVariantEmptyState();
    }

    function updateVariantEmptyState() {
        const hasVariant = document.querySelectorAll('.variant-list-item').length > 0;
        document.getElementById('variantEmptyState').style.display = hasVariant ? 'none' : 'block';
    }

    function formatVariantMoney(value) {
        return Number(value || 0).toLocaleString('vi-VN') + ' đ';
    }
</script>

</body>
</html>
