<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Tin Người Dùng - Mộc Trà</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body class="user-dashboard-page">
<jsp:include page="common/header.jsp"></jsp:include>
<div class="container">

    <jsp:include page="common/user-sidebar.jsp">
        <jsp:param name="activePage" value="tai-khoan"/>
    </jsp:include>

    <main class="main-content">
        <h2 class="section-title">Thông tin người dùng</h2>

        <%-- Hiển thị thông báo --%>
        <c:if test="${not empty sessionScope.msg}">
            <div class="alert alert-${sessionScope.msgType}"
                 style="padding: 15px; margin-bottom: 20px; border-radius: 4px;
                         background-color: ${sessionScope.msgType == 'success' ? '#d4edda' : '#f8d7da'};
                         color: ${sessionScope.msgType == 'success' ? '#155724' : '#721c24'};">
                    ${sessionScope.msg}
            </div>
            <c:remove var="msg" scope="session"/>
        </c:if>

        <form action="tai-khoan-cua-toi" method="post" class="profile-form" style="margin-bottom: 40px; border-bottom: 1px solid #eee; padding-bottom: 20px;">
            <input type="hidden" name="action" value="update_info">

            <div class="form-row">
                <div class="input-group">
                    <input type="text" id="firstname" name="firstname"
                           value="${sessionScope.user.firstName}" placeholder=" " required>
                    <label for="firstname">Tên</label>
                </div>

                <div class="input-group">
                    <input type="text" id="lastname" name="lastname"
                           value="${sessionScope.user.lastName}" placeholder=" " required>
                    <label for="lastname">Họ</label>
                </div>
            </div>

            <div class="form-row">
                <div class="input-group">
                    <%-- Sửa type="date" để tránh lỗi định dạng --%>
                    <input type="date" id="dob" name="dob"
                           value="${sessionScope.user.dateOfBirth != null ? sessionScope.user.dateOfBirth.toLocalDate() : ''}">
                    <label for="dob">Ngày Sinh</label>
                </div>

                <div class="input-group">
                    <select id="gender" name="gender">
                        <option value="" disabled selected hidden>Chọn giới tính</option>
                        <%-- Value để chữ thường cho khớp database --%>
                        <option value="male" ${sessionScope.user.gender == 'MALE' ? 'selected' : ''}>Nam</option>
                        <option value="female" ${sessionScope.user.gender == 'FEMALE' ? 'selected' : ''}>Nữ</option>
                        <option value="other" ${sessionScope.user.gender == 'OTHER' ? 'selected' : ''}>Khác</option>
                    </select>
                    <i class="fa-solid fa-chevron-down select-arrow"></i>
                </div>
            </div>

            <h3 class="section-subtitle" style="margin-top: 30px;">Thông tin liên hệ</h3>

            <div class="form-row">
                <div class="input-group">
                    <input type="email" id="email" name="email"
                           value="${sessionScope.user.email}" readonly style="background-color: #f5f5f5;">
                    <label for="email">Email</label>
                </div>

                <div class="input-group phone-group">
                    <div class="phone-prefix">
                        <span>SDT</span> <i class="fa-solid fa-chevron-down"></i>
                    </div>
                    <input type="tel" id="phone" name="phone" placeholder=" "
                           value="${sessionScope.user.phone}">
                    <label for="phone">Số điện thoại</label>
                </div>
            </div>

            <div class="form-actions" style="margin-top: 20px;">
                <button type="submit" class="btn-save-changes">Lưu Thông Tin</button>
            </div>
        </form>

        <h3 class="section-subtitle">Đổi mật khẩu</h3>
        <form action="change-password" method="post" class="profile-form">
            <input type="hidden" name="action" value="change_password">

            <p style="font-size: 13px; color: #666; margin-bottom: 15px;">
                *Vui lòng nhập mật khẩu cũ để xác thực thay đổi
            </p>

            <div class="form-row password-row">
                <div class="input-group">
                    <input type="password" id="oldPassword" name="oldPassword" placeholder=" " required>
                    <label for="oldPassword">Mật khẩu cũ</label>
                </div>

                <div class="input-group">
                    <input type="password" id="newPassword" name="newPassword" placeholder=" " required>
                    <label for="newPassword">Mật khẩu mới</label>
                </div>

                <div class="input-group">
                    <input type="password" id="confirmNewPassword" name="confirmNewPassword" placeholder=" " required>
                    <label for="confirmNewPassword">Xác nhận mật khẩu mới</label>
                </div>
            </div>

            <div class="form-actions" style="margin-top: 30px;">
                <button type="submit" class="btn-save-changes" style="background-color: #e67e22;">Cập Nhật Mật Khẩu</button>
            </div>
        </form>
    </main>

</div>
<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>
</html>