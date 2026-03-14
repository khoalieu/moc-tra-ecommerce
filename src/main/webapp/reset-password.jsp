<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đặt mật khẩu mới</title>

    <link rel="stylesheet" href="assets/css/main.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
          crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>

<body>
<jsp:include page="common/header.jsp"></jsp:include>

<main>
    <div class="login-page reset-password-page">
        <div class="login-box">
            <div class="login-header">
                <div class="login-icon-circle">
                    <i class="fa-solid fa-lock"></i>
                </div>
                <h2 class="login-title">Đặt mật khẩu mới</h2>
                <p class="login-subtitle">
                    Tạo mật khẩu mới cho tài khoản của bạn.
                </p>
            </div>

            <div class="login-content">
                <form id="resetForm" action="reset-password" method="post" autocomplete="off">
                    <div class="form-row">
                        <input
                                id="new-password"
                                class="input-password"
                                type="password"
                                name="newPassword"
                                placeholder="Mật khẩu mới"
                                required>
                    </div>

                    <div class="form-row">
                        <input
                                id="confirm-password"
                                class="input-confirm"
                                type="password"
                                name="confirmPassword"
                                placeholder="Xác nhận mật khẩu mới"
                                required>
                    </div>

                    <p class="reset-message" id="resetMessage" style="color:red; margin:8px 0;">
                        <c:out value="${message}" />
                    </p>

                    <div class="form-row">
                        <button type="submit" class="btn">Lưu mật khẩu mới</button>
                    </div>

                    <div class="auth-extra-links">
                        <a href="login.jsp">Quay lại đăng nhập</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script src="assets/js/main.js"></script>
</body>
</html>
