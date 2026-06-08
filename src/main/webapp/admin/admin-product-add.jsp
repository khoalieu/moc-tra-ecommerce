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
    <link rel="stylesheet" href="https://unpkg.com/filepond/dist/filepond.css">
    <link rel="stylesheet" href="https://unpkg.com/filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css">
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

            <!-- IMPORT EXCEL -->
            <div class="import-box">
                <div class="import-left">
                    <div class="import-icon">
                        <i class="fa-regular fa-file-excel"></i>
                    </div>

                    <div>
                        <h3>Import sản phẩm bằng Excel</h3>
                        <p>Tải file mẫu, nhập dữ liệu rồi upload để thêm/cập nhật hàng loạt sản phẩm.</p>
                    </div>
                </div>

                <div class="import-right">
                    <a href="${pageContext.request.contextPath}/admin/products/template"
                       class="import-btn template-btn">
                        <i class="fas fa-download"></i>
                        Tải file mẫu
                    </a>

                    <form action="${pageContext.request.contextPath}/admin/products/import"
                          method="post"
                          enctype="multipart/form-data"
                          class="import-form">

                        <label class="file-upload-box">
                            <i class="fas fa-paperclip"></i>
                            <span id="excelFileName">Chọn file Excel</span>
                            <input type="file"
                                   name="excelFile"
                                   accept=".xlsx"
                                   required
                                   onchange="document.getElementById('excelFileName').innerText = this.files[0].name">
                        </label>

                        <button type="submit" class="import-btn upload-btn">
                            <i class="fas fa-upload"></i>
                            Import
                        </button>
                    </form>
                </div>

                <c:if test="${not empty sessionScope.importMessage}">
                    <div class="import-message">
                            ${sessionScope.importMessage}
                    </div>
                    <c:remove var="importMessage" scope="session"/>
                </c:if>
            </div>

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
                                <h3><i class="fas fa-tags"></i> Phân loại sản phẩm (Tùy chọn)</h3>

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
                                            <tbody id="variantsContainer"></tbody>
                                        </table>
                                        <div class="variant-empty" id="variantEmptyState">
                                            Chưa có phân loại nào. Nếu bỏ trống, sản phẩm sẽ bán theo giá cơ bản.
                                        </div>
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

<div id="variantModal" class="variant-modal modal-hidden">
    <div class="variant-modal-overlay" onclick="closeVariantEditor()"></div>
    <div class="variant-modal-content">
        <div class="variant-modal-header">
            <h3 id="variantEditorTitle">Thêm phân loại mới</h3>
            <button type="button" class="variant-modal-close" onclick="closeVariantEditor()">&times;</button>
        </div>
        <div class="variant-modal-body">
            <p class="variant-modal-help">
                Thêm các quy cách đóng gói (VD: Hộp 10 gói, Gói 100g...). Nếu bỏ trống, sản phẩm sẽ bán theo giá cơ bản.
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

    let editingVariantItem = null;

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
            updateVariantItem(item, name, price, stock);
        }

        updateVariantEmptyState();
        closeVariantEditor();
    }

    function updateVariantItem(item, name, price, stock) {
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
                <input type="hidden" name="variantNames">
                <input type="hidden" name="variantPrices">
                <input type="hidden" name="variantSalePrices">
                <input type="hidden" name="variantStocks">
            </td>
        `;
        item.querySelector('.variant-list-name').innerText = name;
        item.querySelector('.variant-price').innerText = formatVariantMoney(price);
        item.querySelector('.variant-stock').innerText = stock;
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
