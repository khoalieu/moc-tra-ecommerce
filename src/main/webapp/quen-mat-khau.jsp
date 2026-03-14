<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Quên Mật Khẩu</title>

    <link rel="stylesheet" href="assets/css/main.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
          crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>

<body>
<jsp:include page="common/header.jsp"></jsp:include>

<main>
    <div class="login-page forgot-password-page">
        <div class="login-box">
            <div class="login-header">
                <div class="login-icon-circle">
                    <i class="fa-solid fa-unlock-keyhole"></i>
                </div>
                <h2 class="login-title">Quên mật khẩu</h2>
                <p class="login-subtitle">
                    Nhập email bạn đã đăng ký để nhận liên kết
                </p>
            </div>

            <div class="login-content">
                <form action="forgot-password" method="post" autocomplete="on">
                    <div class="form-row">
                        <input
                                id="forgot-email"
                                class="input-email"
                                type="email"
                                name="email"
                                placeholder="Email đã đăng ký"
                                aria-label="Email đã đăng ký"
                                required>
                    </div>

                    <!-- message lỗi màu đỏ -->
                    <p class="reset-message" style="color:red; margin:8px 0;">
                        <c:out value="${message}" />
                    </p>

                    <div class="form-row">
                        <button type="submit" class="btn">Gửi mã OTP</button>
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
