<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="a" uri="jakarta.tags.core" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm sản phẩm - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
    <link rel="stylesheet" href="admin/assets/css/admin-add-product.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Dropify/0.2.2/css/dropify.min.css">
    <link href="https://unpkg.com/filepond/dist/filepond.css" rel="stylesheet">
    <link href="https://unpkg.com/filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css"
          rel="stylesheet">

    <style>
        .filepond--root {
            font-family: 'Roboto', sans-serif;
        }

        .filepond--panel-root {
            background-color: #f7f9fc;
            border: 1px dashed #ccc;
        }

        .dropify-wrapper {
            border-radius: 8px;
            border: 2px dashed #e5e5e5;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="products"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left"><h1>Thêm sản phẩm mới</h1></div>
            <div class="header-right">
                <a href="admin/admin-products.jsp" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Quay
                    lại</a>
            </div>
        </header>

        <div class="admin-content">
            <c:if test="${not empty error}">
                <div style="color: #721c24; background-color: #f8d7da; padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                    <i class="fas fa-exclamation-triangle"></i> ${error}
                </div>
            </c:if>
            <c:if test="${param.msg eq 'success'}">
                <div style="color: #155724; background-color: #d4edda; padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                    <i class="fas fa-check-circle"></i> Thêm sản phẩm thành công!
                </div>
            </c:if>

            <form class="form-container" action="admin/product/add" method="POST" enctype="multipart/form-data">
                <div class="form-content">
                    <div class="form-grid">
                        <div class="form-left">
                            <div class="form-section">
                                <h3><i class="fas fa-info-circle"></i> Thông tin cơ bản</h3>

                                <div class="form-group">
                                    <label>Tên sản phẩm <span class="required">*</span></label>
                                    <input type="text" name="name" class="form-control" required
                                           placeholder="Nhập tên sản phẩm..." value="${param.name}">
                                </div>

                                <div class="form-group">
                                    <label>Slug (URL)</label>
                                    <input type="text" name="slug" class="form-control"
                                           placeholder="Để trống tự động tạo" value="${param.slug}">
                                </div>

                                <div class="form-group">
                                    <label>Mô tả ngắn</label>
                                    <textarea name="short_description" class="form-control textarea"
                                              rows="3">${param.short_description}</textarea>
                                </div>

                                <div class="form-group">
                                    <label>Mô tả chi tiết</label>
                                    <textarea name="description" class="form-control textarea large"
                                              rows="6">${param.description}</textarea>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-leaf"></i> Thành phần & HDSD</h3>
                                <div class="form-group">
                                    <label>Thành phần</label>
                                    <textarea name="ingredients" class="form-control textarea"
                                              rows="3">${param.ingredients}</textarea>
                                </div>
                                <div class="form-group">
                                    <label>Hướng dẫn sử dụng</label>
                                    <textarea name="usage_instructions" class="form-control textarea"
                                              rows="3">${param.usage_instructions}</textarea>
                                </div>
                            </div>
                        </div>

                        <div class="form-right">
                            <div class="form-section">
                                <h3><i class="fas fa-cog"></i> Phân loại</h3>
                                <div class="form-group">
                                    <label>Trạng thái</label>
                                    <select name="status" class="form-control">
                                        <option value="active" ${param.status == 'active' ? 'selected' : ''}>Hoạt động
                                        </option>
                                        <option value="inactive" ${param.status == 'inactive' ? 'selected' : ''}>Ẩn
                                        </option>
                                        <option value="out_of_stock" ${param.status == 'out_of_stock' ? 'selected' : ''}>
                                            Hết hàng
                                        </option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Danh mục sản phẩm <span class="required">*</span></label>
                                    <select name="category_id" class="form-control" required>
                                        <option value="">-- Chọn danh mục --</option>

                                        <c:forEach var="parent" items="${parentCategories}">
                                            <option value="${parent.id}" ${product.categoryId == parent.id ? 'selected' : ''}
                                                    style="font-weight: bold; background-color: #f0f0f0;">
                                                    ${parent.name}
                                            </option>

                                            <c:if test="${not empty childrenMap[parent.id]}">
                                                <c:forEach var="child" items="${childrenMap[parent.id]}">
                                                    <option value="${child.id}" ${product.categoryId == child.id ? 'selected' : ''}>
                                                        &nbsp;&nbsp;&nbsp;&nbsp;└─ ${child.name}
                                                    </option>
                                                </c:forEach>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="checkbox-group">
                                    <input type="checkbox" id="best" name="is_bestseller"
                                           value="1" ${param.is_bestseller == '1' ? 'checked' : ''}>
                                    <label for="best">Sản phẩm bán chạy</label>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-dollar-sign"></i> Giá & Kho</h3>
                                <div class="form-group">
                                    <label>Giá bán</label>
                                    <input type="number" name="price" class="form-control" required
                                           value="${param.price}">
                                </div>
                                <div class="form-group">
                                    <label>Giá khuyến mãi</label>
                                    <input type="number" name="sale_price" class="form-control"
                                           value="${param.sale_price}">
                                </div>
                                <div class="form-row">
                                    <div class="form-group">
                                        <label>SKU</label>
                                        <input type="text" name="sku" class="form-control" value="${param.sku}">
                                    </div>
                                    <div class="form-group">
                                        <label>Tồn kho</label>
                                        <input type="number" name="stock_quantity" class="form-control"
                                               value="${param.stock_quantity != null ? param.stock_quantity : '0'}">
                                    </div>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fas fa-image"></i> Hình ảnh</h3>

                                <div class="form-group">
                                    <label>Ảnh đại diện <span class="required">*</span></label>
                                    <input type="file" name="image_url" class="dropify" data-height="200"
                                           accept="image/*" required/>
                                </div>

                                <div class="form-group">
                                    <label>Album ảnh phụ</label>
                                    <input type="file" id="gallery" name="gallery[]" multiple data-max-file-size="3MB"/>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-outline" onclick="history.back()">Hủy bỏ</button>
                    <button type="submit" class="btn btn-primary">Thêm sản phẩm</button>
                </div>
            </form>
        </div>
    </main>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Dropify/0.2.2/js/dropify.min.js"></script>
<script src="https://unpkg.com/filepond-plugin-image-preview/dist/filepond-plugin-image-preview.js"></script>
<script src="https://unpkg.com/filepond/dist/filepond.js"></script>

<script>
    $(document).ready(function () {
        // Dropify
        $('.dropify').dropify({
            messages: {'default': 'Kéo thả hoặc click', 'replace': 'Thay thế', 'remove': 'Xóa', 'error': 'Lỗi'}
        });
        // FilePond
        FilePond.registerPlugin(FilePondPluginImagePreview);
        const pond = FilePond.create(document.querySelector('#gallery'), {
            storeAsFile: true,
            allowMultiple: true,
            maxFiles: 10,
            labelIdle: 'Kéo thả ảnh phụ hoặc <span class="filepond--label-action">Chọn file</span>',
            credits: false
        });
    });
</script>
</body>
</html>