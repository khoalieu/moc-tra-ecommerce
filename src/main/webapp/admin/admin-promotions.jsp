<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Khuyến Mãi - Mộc Trà Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin-promotions.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">
</head>
<body>
<div class="admin-container">
    <aside class="admin-sidebar">
        <jsp:include page="/common/admin-sidebar.jsp">
            <jsp:param name="activePage" value="promotions"/>
        </jsp:include>
        <nav class="admin-nav">
            <ul>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp"><i
                            class="fas fa-tachometer-alt"></i><span>Dashboard</span></a>
                </li>
                <li class="nav-item active">
                    <a href="${pageContext.request.contextPath}/admin/promotions"><i class="fas fa-tags"></i><span>Quản lý Khuyến Mãi</span></a>
                </li>
            </ul>
        </nav>
    </aside>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Chương trình khuyến mãi</h1>
            </div>
            <div class="header-right">
                <button class="btn btn-primary" onclick="openCreateModal()">
                    <i class="fas fa-plus"></i> Tạo chương trình mới
                </button>
            </div>
        </header>

        <div class="admin-content">
            <div class="products-container">
                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th>Ảnh</th>
                            <th>Thông tin chương trình</th>
                            <th>Giảm giá</th>
                            <th>Thời gian</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="p" items="${promotionList}">
                            <fmt:formatNumber value="${p.discountValue}" pattern="#" var="cleanValue"/>

                            <tr>
                                <td>
                                    <img src="${pageContext.request.contextPath}/${p.imageUrl}"
                                         alt="Promo"
                                         style="width: 60px; height: 40px; object-fit: cover; border-radius: 4px;">
                                </td>
                                <td>
                                    <strong>${p.name}</strong><br>
                                    <small style="color: #666;">${p.description}</small>
                                </td>
                                <td>
                                    <c:if test="${p.discountType == 'PERCENT'}">
                                        <span class="badge"
                                              style="background: #e3f2fd; color: #0d47a1;">-${cleanValue}%</span>
                                    </c:if>
                                    <c:if test="${p.discountType == 'FIXED_AMOUNT'}">
                    <span class="badge" style="background: #fff3e0; color: #e65100;">
                        -<fmt:formatNumber value="${p.discountValue}" pattern="#,###"/>₫
                    </span>
                                    </c:if>
                                </td>
                                <td>
                                    <div style="font-size: 0.85rem;">
                                        Start: <span
                                            style="color: green">${fn:replace(p.startDate, 'T', ' ')}</span><br>
                                        End: <span style="color: red">${fn:replace(p.endDate, 'T', ' ')}</span>
                                    </div>
                                </td>
                                <td>
                <span class="status-badge ${p.active ? 'status-active' : 'status-inactive'}">
                        ${p.active ? 'Đang chạy' : 'Đã tắt'}
                </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-action" title="Chỉnh sửa"
                                                onclick="openEditModal(this)"
                                                data-id="${p.id}"
                                                data-name="${p.name}"
                                                data-desc="${p.description}"
                                                data-type="${p.discountType}"
                                                data-value="${cleanValue}"
                                                data-start="${p.startDate}"
                                                data-end="${p.endDate}"
                                                data-image="${p.imageUrl}">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <c:if test="${!p.active}">
                                            <button class="btn-action" title="Kích hoạt"
                                                    onclick="toggleStatus(${p.id}, true)" style="color: green;">
                                                <i class="fas fa-play"></i>
                                            </button>
                                        </c:if>
                                        <c:if test="${p.active}">
                                            <button class="btn-action" title="Tắt chương trình"
                                                    onclick="toggleStatus(${p.id}, false)" style="color: red;">
                                                <i class="fas fa-stop"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<div id="promoModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle">Tạo chương trình khuyến mãi</h3>
            <span class="close-modal" onclick="closeModal()">&times;</span>
        </div>

        <form action="promotions" method="POST" enctype="multipart/form-data" id="promoForm">
            <input type="hidden" name="action" id="formAction" value="create">
            <input type="hidden" name="id" id="promoId" value="">
            <input type="hidden" name="current_image" id="currentImage" value="">

            <div class="modal-body">
                <div class="form-grid-layout">
                    <div class="left-col">
                        <div class="form-group">
                            <label>Tên chương trình <span class="required">*</span></label>
                            <input type="text" name="name" id="pName" class="form-control" required
                                   placeholder="Ví dụ: Sale 8/3">
                        </div>
                        <div class="form-group">
                            <label>Mô tả ngắn</label>
                            <input type="text" name="description" id="pDesc" class="form-control"
                                   placeholder="Mô tả hiển thị bên dưới tên">
                        </div>
                        <div class="form-grid-layout" style="gap: 10px;">
                            <div class="form-group">
                                <label>Loại giảm giá</label>
                                <select name="discount_type" id="pType" class="form-control">
                                    <option value="PERCENT">Phần trăm (%)</option>
                                    <option value="FIXED_AMOUNT">Tiền mặt (VNĐ)</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Giá trị <span class="required">*</span></label>
                                <input type="number" name="discount_value" id="pValue" class="form-control" required
                                       min="1">
                            </div>
                        </div>
                    </div>

                    <div class="right-col">
                        <div class="form-group">
                            <label>Thời gian bắt đầu</label>
                            <input type="datetime-local" name="start_date" id="pStart" class="form-control" required
                                   step="1">
                        </div>
                        <div class="form-group">
                            <label>Thời gian kết thúc</label>
                            <input type="datetime-local" name="end_date" id="pEnd" class="form-control" required
                                   step="1">
                        </div>

                        <div class="form-group">
                            <label>Banner / Ảnh đại diện</label>

                            <div class="image-upload-box"
                                 onclick="document.getElementById('imageInput').click()"
                                 style="
            border: 2px dashed #ddd;
            border-radius: 8px;
            background: #fafafa;
            position: relative;


            height: 200px;
            width: 100%;
            overflow: hidden;

            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
         ">

                                <div class="image-upload-label" id="uploadLabel"
                                     style="pointer-events: none; text-align: center;">
                                    <i class="fas fa-cloud-upload-alt"
                                       style="font-size: 2rem; color: #ccc; margin-bottom: 10px;"></i>
                                    <p style="margin: 0; color: #666;">Nhấn để chọn ảnh</p>
                                </div>

                                <img id="imagePreview" class="image-preview" src="" alt="Preview"
                                     style="

                max-width: 100%;
                max-height: 100%;
                object-fit: contain;
                display: none;
             ">
                            </div>

                            <input type="file" name="image" id="imageInput" style="display: none;" accept="image/*"
                                   onchange="previewImage(this)">
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Hủy</button>
                <button type="submit" class="btn btn-primary" id="btnSubmit">Lưu chương trình</button>
            </div>
        </form>
    </div>
</div>

<script>
    const modal = document.getElementById('promoModal');
    const form = document.getElementById('promoForm');

    function previewImage(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('imagePreview').src = e.target.result;
                document.getElementById('imagePreview').style.display = 'block';
                document.getElementById('uploadLabel').style.display = 'none';
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    function openCreateModal() {
        form.reset(); // Xóa trắng form
        document.getElementById('modalTitle').innerText = "Tạo chương trình mới";
        document.getElementById('formAction').value = "create"; // Action = create
        document.getElementById('btnSubmit').innerText = "Tạo mới";

        // Reset ảnh preview
        document.getElementById('imagePreview').style.display = 'none';
        document.getElementById('uploadLabel').style.display = 'block';

        modal.classList.add('active');
    }

    function openEditModal(btn) {
        const id = btn.getAttribute('data-id');
        const name = btn.getAttribute('data-name');
        const desc = btn.getAttribute('data-desc');
        const type = btn.getAttribute('data-type');
        const value = btn.getAttribute('data-value');
        const start = btn.getAttribute('data-start'); // Định dạng yyyy-MM-ddTHH:mm
        const end = btn.getAttribute('data-end');
        const image = btn.getAttribute('data-image');

        document.getElementById('modalTitle').innerText = "Cập nhật chương trình #" + id;
        document.getElementById('formAction').value = "update"; // Action = update
        document.getElementById('promoId').value = id;

        document.getElementById('pName').value = name;
        document.getElementById('pDesc').value = desc;
        document.getElementById('pType').value = type;
        document.getElementById('pValue').value = value;
        document.getElementById('pStart').value = start;
        document.getElementById('pEnd').value = end;

        document.getElementById('currentImage').value = image;
        if (image) {
            document.getElementById('imagePreview').src = '${pageContext.request.contextPath}/' + image;
            document.getElementById('imagePreview').style.display = 'block';
            document.getElementById('uploadLabel').style.display = 'none';
        }

        document.getElementById('btnSubmit').innerText = "Lưu thay đổi";
        modal.classList.add('active');
    }

    function closeModal() {
        modal.classList.remove('active');
    }

    function toggleStatus(id, status) {
        let msg = status ?
            "Kích hoạt chương trình này?" :
            "CẢNH BÁO: Tắt chương trình này sẽ tự động GỠ BỎ tất cả sản phẩm đang tham gia và reset giá về mức gốc. Bạn có chắc chắn không?";

        if (confirm(msg)) {
            const params = new URLSearchParams();
            params.append('action', 'toggle');
            params.append('id', id);
            params.append('status', status);

            fetch('${pageContext.request.contextPath}/admin/promotions', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: params
            }).then(res => {
                if (res.ok) {
                    alert("Thành công!");
                    location.reload();
                } else {
                    alert("Lỗi server.");
                }
            });
        }
    }
</script>
</body>
</html>