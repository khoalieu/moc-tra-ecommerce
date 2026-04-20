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
            <form class="form-container" action="${pageContext.request.contextPath}/admin/product/edit" method="POST"
                  enctype="multipart/form-data">

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
                                <h3><i class="fas fa-leaf"></i> Thông tin bổ sung</h3>

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
                                <p style="font-size: 13px; color: #666; margin-bottom: 15px;">Thêm/sửa các quy cách đóng gói (VD: Hộp 10 gói). Nếu bỏ trống, sản phẩm sẽ bán theo giá cơ bản.</p>

                                <div id="variantsContainer">
                                    <c:choose>
                                        <c:when test="${not empty variants}">
                                            <c:forEach var="v" items="${variants}">
                                                <div class="variant-row" style="display: flex; gap: 8px; margin-bottom: 10px; align-items: center;">
                                                    <input type="text" name="variantNames" value="${v.variantName}" placeholder="Tên loại" class="form-control" style="flex: 2;" required>

                                                    <input type="number" name="variantPrices" value="<fmt:formatNumber value='${v.price}' pattern='#' groupingUsed='false'/>" placeholder="Giá gốc" class="form-control" style="flex: 1.5;" min="0">

                                                    <input type="number" name="variantSalePrices" value="<fmt:formatNumber value='${v.salePrice}' pattern='#' groupingUsed='false'/>" placeholder="Giá Sale" class="form-control" style="flex: 1.5;" min="0">

                                                    <input type="number" name="variantStocks" value="${v.stockQuantity}" placeholder="Kho" class="form-control" style="flex: 1;" min="0">

                                                    <button type="button" class="btn btn-danger btn-sm" onclick="removeVariantRow(this)" style="padding: 8px 12px;"><i class="fas fa-trash"></i></button>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="variant-row" style="display: flex; gap: 8px; margin-bottom: 10px; align-items: center;">
                                                <input type="text" name="variantNames" placeholder="Tên loại" class="form-control" style="flex: 2;" required>
                                                <input type="number" name="variantPrices" placeholder="Giá gốc" class="form-control" style="flex: 1.5;" min="0">
                                                <input type="number" name="variantSalePrices" value="0" placeholder="Giá Sale" class="form-control" style="flex: 1.5;" min="0">
                                                <input type="number" name="variantStocks" placeholder="Kho" class="form-control" style="flex: 1;" min="0">
                                                <button type="button" class="btn btn-danger btn-sm" onclick="removeVariantRow(this)" style="padding: 8px 12px;"><i class="fas fa-trash"></i></button>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <button type="button" class="btn btn-success btn-sm mt-2" onclick="addVariantRow()">
                                    <i class="fas fa-plus"></i> Thêm phân loại
                                </button>
                            </div>
                            <div class="form-section">
                                <h3><i class="fas fa-image"></i> Hình ảnh sản phẩm</h3>

                                <div class="form-group">
                                    <label>Hình ảnh chính hiện tại</label>
                                    <div style="margin-bottom: 15px;">
                                        <img src="${pageContext.request.contextPath}/${product.imageUrl}"
                                             alt="${product.name}"
                                             style="width: 100%; border-radius: 8px; border: 1px solid #ddd; object-fit: contain; height: 200px;">
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

<script>
    function addVariantRow() {
        const container = document.getElementById('variantsContainer');
        const rowHTML = `
            <div class="variant-row" style="display: flex; gap: 8px; margin-bottom: 10px; align-items: center;">
                <input type="text" name="variantNames" placeholder="Tên loại (VD: Hộp 10 gói)" class="form-control" style="flex: 2;" required>
                <input type="number" name="variantPrices" placeholder="Giá gốc" class="form-control" style="flex: 1.5;" min="0">
                <input type="number" name="variantSalePrices" value="0" placeholder="Giá Sale" class="form-control" style="flex: 1.5;" min="0">
                <input type="number" name="variantStocks" placeholder="Kho" class="form-control" style="flex: 1;" min="0">
                <button type="button" class="btn btn-danger btn-sm" onclick="removeVariantRow(this)" style="padding: 8px 12px;"><i class="fas fa-trash"></i></button>
            </div>
        `;
        container.insertAdjacentHTML('beforeend', rowHTML);
    }

    function removeVariantRow(button) {
        button.closest('.variant-row').remove();
    }
</script>

</body>
</html>