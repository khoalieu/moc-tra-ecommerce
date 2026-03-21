<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Nhập</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

    <style>
        .error-message {
            color: #dc3545;
            text-align: center;
            margin-bottom: 10px;
            font-style: italic;
            font-size: 0.9rem;
        }

    </style>
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<div class="login-page">
    <div class="login-box">

        <div class="login-header">
            <div class="login-icon-circle">
                <i class="fa-solid fa-user"></i>
            </div>
            <h2 class="login-title">Chào mừng đến với Mộc trà</h2>
            <p class="login-subtitle">Đăng nhập để thưởng thức trà</p>
        </div>


        <div class="login-content">

            <p class="error-message">${errorMessage}</p>

            <form action="${pageContext.request.contextPath}/login" method="post" autocomplete="on">
                <div class="form-row">
                    <input
                            id="login-username"
                            class="input-username"
                            type="text"
                            name="username"
                            placeholder="Tên đăng nhập"
                            value="${username}"
                            required>
                </div>

                <div class="form-row password-field">
                    <input
                            id="login-password"
                            class="input-password"
                            type="password"
                            name="password"
                            placeholder="Mật khẩu"
                            required>
                    <i class="fa-solid fa-eye toggle-password" toggle="#login-password"></i>
                </div>


                <div class="form-options">
                    <div class="remember">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">Ghi nhớ tôi</label>
                    </div>
                    <a href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a>
                </div>

                <div class="form-row">
                    <button type="submit"  class="btn">Đăng nhập</button>
                </div>
                <div class="social-login">
                    <a href="#" class="social fb"><i class="fa-brands fa-facebook-f"></i></a>
                    <a href="${googleUrl}" class="social gg">
                        <i class="fa-brands fa-google"></i>
                    </a>
                </div>
                <div class="signup">
                    Chưa có tài khoản? <a href="${pageContext.request.contextPath}/signup">Đăng ký</a>
                </div>
            </form>
        </div>

    </div>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

</body>
</html>