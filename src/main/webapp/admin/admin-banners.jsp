<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${mode == 'edit' ? 'Sửa Banner' : 'Thêm Banner'} - Admin</title>

    <c:set var="ctx" value="${pageContext.request.contextPath}"/>

    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin-add-product.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">
    <style>
        .field-error {
            border: 1.5px solid #e74c3c !important;
        }

        .err-text {
            color: #e74c3c;
            font-size: 12px;
            margin-top: 6px;
        }
    </style>
</head>
<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="banners"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>${mode == 'edit' ? 'Sửa Banner' : 'Thêm Banner Mới'}</h1>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/admin/banner" class="view-site-btn">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <form class="form-container"
                  action="${pageContext.request.contextPath}/admin/banner/save"
                  method="POST" enctype="multipart/form-data">

                <input type="hidden" name="mode" value="${mode}">
                <c:if test="${mode == 'edit'}">
                    <input type="hidden" name="id" value="${banner.id}">
                    <input type="hidden" name="old_image_url" value="${banner.imageUrl}">
                </c:if>

                <div class="form-header">
                    <h2>Thông tin Banner</h2>
                    <p>Vị trí hiển thị mặc định: <b>index (home)</b></p>
                </div>

                <div class="form-content">
                    <div class="form-grid">

                        <!-- LEFT -->
                        <div class="form-left">
                            <div class="form-section">
                                <h3><i class="fa-solid fa-pen"></i> Nội dung</h3>

                                <div class="form-group">
                                    <label>Tiêu đề <span class="required">*</span></label>
                                    <input type="text" name="title"
                                           class="form-control ${not empty errors.title ? 'field-error' : ''}"
                                           value="${fn:escapeXml(banner.title)}"
                                           placeholder="VD: Sale Tết - Giảm đến 50%">
                                    <c:if test="${not empty errors.title}">
                                        <div class="err-text">${fn:escapeXml(errors.title)}</div>
                                    </c:if>
                                </div>

                                <div class="form-group">
                                    <label>Mô tả phụ</label>
                                    <textarea name="subtitle" class="form-control textarea" rows="3"
                                              placeholder="VD: Ưu đãi sốc hôm nay...">${fn:escapeXml(banner.subtitle)}</textarea>
                                </div>

                                <div class="form-row" style="display:flex; gap: 20px;">
                                    <div class="form-group" style="flex:1;">
                                        <label>Chữ nút</label>
                                        <input type="text" name="button_text" class="form-control"
                                               value="${fn:escapeXml(banner.buttonText)}"
                                               placeholder="VD: Xem ngay">
                                    </div>

                                    <div class="form-group" style="flex:1;">
                                        <label>Link (tự tạo)</label>
                                        <input type="text" id="button_link_show" class="form-control"
                                               value="${fn:escapeXml(banner.buttonLink)}" readonly>
                                        <input type="hidden" name="button_link" id="button_link"
                                               value="${fn:escapeXml(banner.buttonLink)}">
                                    </div>
                                </div>

                                <div class="form-row" style="display:flex; gap: 20px;">
                                    <div class="form-group" style="flex:1;">
                                        <label>Kiểu link</label>
                                        <select id="linkType" class="form-control" onchange="renderLinkTarget()">
                                            <option value="">-- Không dùng link --</option>
                                            <option value="category">Sản phẩm theo Category</option>
                                            <option value="promotion">Sản phẩm theo Khuyến mãi</option>
                                        </select>
                                    </div>

                                    <div class="form-group" style="flex:1;">
                                        <label>Chọn mục tiêu</label>

                                        <select id="categoryTarget" class="form-control" style="display:none;"
                                                onchange="applyLink()">
                                            <option value="">-- Chọn category --</option>
                                            <c:forEach var="entry" items="${categoryMap}">
                                                <option value="${entry.key}">${entry.value}</option>
                                            </c:forEach>
                                        </select>

                                        <select id="promotionTarget" class="form-control" style="display:none;"
                                                onchange="applyLink()">
                                            <option value="">-- Chọn khuyến mãi --</option>
                                            <c:forEach var="p" items="${promotions}">
                                                <option value="${p.id}">${p.name}</option>
                                            </c:forEach>
                                        </select>

                                        <div class="help-text">Link sẽ trỏ về trang <b>/san-pham</b> theo category hoặc
                                            promotion.
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </div>

                        <div class="form-right">

                            <div class="form-section">
                                <h3><i class="fa-solid fa-image"></i> Ảnh Banner <span class="required">*</span></h3>

                                <div class="form-group">
                                    <div class="image-upload" id="uploadArea"
                                         onclick="document.getElementById('image_url').click()">
                                        <div id="previewContainer">
                                            <c:choose>
                                                <c:when test="${not empty banner.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/${banner.imageUrl}"
                                                         style="max-width: 100%; max-height: 200px; border-radius: 4px; object-fit: cover;">
                                                    <p style="margin-top: 10px; font-size: 12px; color: #107e84;">Nhấp
                                                        để đổi ảnh</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="fa-solid fa-cloud-arrow-up"></i>
                                                    <p>Nhấp để tải lên ảnh banner</p>
                                                    <small>Kích thước gợi ý: 1920x600</small>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <input type="file" id="image_url" name="image_url" accept="image/*"
                                           style="display:none;"
                                           class="${not empty errors.image_url ? 'field-error' : ''}"
                                           onchange="previewImage(this)">
                                    <c:if test="${not empty errors.image_url}">
                                        <div class="err-text">${fn:escapeXml(errors.image_url)}</div>
                                    </c:if>
                                </div>
                            </div>

                            <div class="form-section">
                                <h3><i class="fa-solid fa-gear"></i> Hiển thị</h3>

                                <div class="form-group">
                                    <label>Vị trí hiển thị</label>
                                    <select name="section" class="form-control">
                                        <option value="home" ${empty banner.section || banner.section == 'home' ? 'selected' : ''}>
                                            Index (home)
                                        </option>
                                        <option value="promotion" ${banner.section == 'promotion' ? 'selected' : ''}>
                                            Trang khuyến mãi
                                        </option>
                                        <option value="sidebar" ${banner.section == 'sidebar' ? 'selected' : ''}>
                                            Sidebar
                                        </option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Thứ tự sắp xếp (để trống = mới → cũ)</label>
                                    <input type="number" name="sort_order" min="0"
                                           class="form-control ${not empty errors.sort_order ? 'field-error' : ''}"
                                           value="${empty banner.sortOrder ? '' : banner.sortOrder}">
                                    <c:if test="${not empty errors.sort_order}">
                                        <div class="err-text">${fn:escapeXml(errors.sort_order)}</div>
                                    </c:if>
                                    <div class="help-text">Nếu trùng số thứ tự trong cùng vị trí, banner cũ sẽ về “theo
                                        thời gian”.
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label>Trạng thái</label>
                                    <div class="checkbox-group">
                                        <input type="radio" id="active1" name="is_active" value="1"
                                        ${empty banner.isActive || banner.isActive ? 'checked' : ''}>
                                        <label for="active1" style="margin-right: 15px;">Hiển thị</label>

                                        <input type="radio" id="active0" name="is_active" value="0"
                                        ${banner.isActive != null && !banner.isActive ? 'checked' : ''}>
                                        <label for="active0">Ẩn</label>
                                    </div>
                                </div>

                            </div>
                        </div>

                    </div>
                </div>

                <div class="form-actions">
                    <div class="btn-group">
                        <a href="${pageContext.request.contextPath}/admin/banner" class="btn btn-outline">
                            <i class="fa-solid fa-xmark"></i> Hủy
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu
                        </button>
                    </div>
                </div>

            </form>
        </div>
    </main>
</div>

<script>
    function previewImage(input) {
        const container = document.getElementById('previewContainer');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function (e) {
                container.innerHTML =
                    '<img src="' + e.target.result + '" style="max-width:100%; max-height:200px; border-radius:4px; object-fit:cover;">' +
                    '<p style="margin-top:10px; font-size:12px; color:#107e84;">Nhấp để đổi ảnh</p>';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function renderLinkTarget() {
        const type = document.getElementById('linkType').value;
        const cat = document.getElementById('categoryTarget');
        const pro = document.getElementById('promotionTarget');

        cat.style.display = (type === 'category') ? 'block' : 'none';
        pro.style.display = (type === 'promotion') ? 'block' : 'none';

        applyLink();
    }

    function applyLink() {
        const type = document.getElementById('linkType').value;
        const catId = document.getElementById('categoryTarget').value;
        const promoId = document.getElementById('promotionTarget').value;

        let link = '';
        if (type === 'category' && catId) link = 'san-pham?category=' + catId;
        if (type === 'promotion' && promoId) link = 'san-pham?promotionId=' + promoId;

        document.getElementById('button_link').value = link;
        document.getElementById('button_link_show').value = link;
    }

    (function init() {
        const current = document.getElementById('button_link')?.value || '';
        if (current.includes('promotionId=')) {
            document.getElementById('linkType').value = 'promotion';
            renderLinkTarget();
            const v = current.split('promotionId=')[1];
            if (v) document.getElementById('promotionTarget').value = v;
            applyLink();
        } else if (current.includes('category=')) {
            document.getElementById('linkType').value = 'category';
            renderLinkTarget();
            const v = current.split('category=')[1];
            if (v) document.getElementById('categoryTarget').value = v;
            applyLink();
        }
    })();
</script>

</body>
</html>
