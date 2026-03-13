<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Sửa thông tin khách hàng</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin-customer-edit.css">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="customers"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <a href="${pageContext.request.contextPath}/admin/customer/detail?id=${customer.id}"
                   class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <h1 style="margin-left: 15px;">Chỉnh sửa hồ sơ</h1>
            </div>
        </header>

        <div class="admin-content">
            <div class="customer-detail-header">
                <div class="customer-meta">
                    <div class="customer-avatar-large">
                        <c:choose>
                            <c:when test="${not empty customer.avatar}">
                                <img src="${pageContext.request.contextPath}/${customer.avatar}" alt="Avatar"
                                     style="width:100%; height:100%; border-radius:50%; object-fit:cover;">
                            </c:when>
                            <c:otherwise>
                                ${customer.username.substring(0, 2).toUpperCase()}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="customer-info-header">
                        <h2>${customer.username}</h2>
                        <span>${customer.email}</span>
                    </div>
                </div>
            </div>

            <div class="edit-card">
                <div class="form-title">Cập nhật thông tin</div>

                <c:if test="${not empty error}">
                    <div class="alert-error">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form action="edit" method="post">
                    <input type="hidden" name="id" value="${customer.id}">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Họ đệm (Last Name)</label>
                            <input type="text" name="lastName" class="form-control" value="${customer.lastName}"
                                   required placeholder="Nhập họ đệm">
                        </div>
                        <div class="form-group">
                            <label>Tên (First Name)</label>
                            <input type="text" name="firstName" class="form-control" value="${customer.firstName}"
                                   required placeholder="Nhập tên">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Email (Chỉ xem)</label>
                            <input type="email" class="form-control" value="${customer.email}" readonly>
                        </div>
                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="text" name="phone" class="form-control" value="${customer.phone}"
                                   placeholder="Nhập số điện thoại">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Vai trò (Role)</label>
                            <select name="role" class="form-control">
                                <option value="CUSTOMER" ${customer.role == 'CUSTOMER' ? 'selected' : ''}>Khách hàng
                                    (Customer)
                                </option>
                                <option value="EDITOR" ${customer.role == 'EDITOR' ? 'selected' : ''}>Biên tập viên
                                    (Editor)
                                </option>
                                <option value="ADMIN" ${customer.role == 'ADMIN' ? 'selected' : ''}>Quản trị viên
                                    (Admin)
                                </option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Trạng thái hoạt động</label>
                            <div class="switch-wrapper">
                                <label class="switch">
                                    <input type="checkbox" name="isActive" ${customer.isActive ? 'checked' : ''}>
                                    <span class="slider"></span>
                                </label>
                                <span class="status-label">
                                    ${customer.isActive ? 'Đang hoạt động' : 'Đã bị khóa'}
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/admin/customer/detail?id=${customer.id}"
                           class="btn btn-secondary" style="text-decoration: none; padding: 10px 20px;">Hủy bỏ</a>
                        <button type="submit" class="btn-save">
                            <i class="fas fa-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>
</body>
</html>