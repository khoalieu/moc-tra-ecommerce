<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Ký</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

    <style>
        .error-message {
            color: #dc3545;
            text-align: center;
            margin-bottom: 15px;
            font-style: italic;
            font-weight: 500;
        }
        .input-guide {
            display: block;
            font-size: 0.75rem;
            color: #666;
            margin-bottom: 4px;
            margin-left: 2px;
            font-style: italic;
        }

        .input-guide i {
            margin-right: 4px;
            font-size: 0.7rem;
            color: #888;
        }
        .field-error-text {
            color: #dc3545;
            font-size: 0.75rem;
            display: block;
            margin-top: 4px;
            margin-bottom: 10px;
            margin-left: 2px;
            font-weight: 500;
            font-style: italic;
        }
        .input-error-border {
            border: 1.5px solid #dc3545 !important;
            background-color: #fff8f8 !important;
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
            <h2 class="login-title">Tạo tài khoản Mới</h2>
            <p class="login-subtitle">Tham gia cùng Mộc Trà để trải nghiệm tốt hơn</p>
        </div>


        <div class="login-content">

            <p class="error-message">${errorMessage}</p>

            <form action="${pageContext.request.contextPath}/signup" method="post" autocomplete="on">

                <span class="input-guide"><i class="fa-solid fa-circle-info"></i> Tên đăng nhập: Ít nhất 6 ký tự, không dấu cách.</span>
                <div class="form-row">
                    <input
                            id="signup-username"
                            class="input-username ${not empty usernameError ? 'input-error-border' : ''}"
                            type="text"
                            name="username"
                            title="Tên đăng nhập phải ít nhất 6 ký tự, chỉ gồm chữ cái và số, không có khoảng trắng."
                            pattern="^[a-zA-Z0-9]{6,}$"
                            placeholder="Tên đăng nhập"
                            aria-label="Tên đăng nhập"
                            value="${param.username}"
                            required>
                </div>
                <c:if test="${not empty usernameError}">
                    <span class="field-error-text">${usernameError}</span>
                </c:if>

                <span class="input-guide"><i class="fa-solid fa-circle-info"></i> Số điện thoại: Phải đủ 10 chữ số nhà mạng VN.</span>
                <div class="form-row">
                    <input
                            id="signup-phone"
                            class="input-phone ${not empty phoneError ? 'input-error-border' : ''}"
                            type="tel"
                            name="phone"
                            placeholder="Số điện thoại"
                            pattern="[0-9]{10}"
                            value="${param.phone}"
                            required>
                </div>
                <c:if test="${not empty phoneError}">
                    <span class="field-error-text">${phoneError}</span>
                </c:if>

                <span class="input-guide"><i class="fa-solid fa-circle-info"></i> Mật khẩu: Ít nhất 8 ký tự, gồm cả chữ thường, chữ HOA và số.</span>
                <div class="form-row password-field">
                    <input
                            id="signup-password"
                            class="input-password ${not empty passwordError ? 'input-error-border' : ''}"
                            type="password"
                            name="password"
                            placeholder="Mật khẩu"
                            aria-label="Mật khẩu"
                            pattern="^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$"
                            title="Mật khẩu phải từ 8 ký tự trở lên, bao gồm cả chữ thường, chữ hoa và số."
                            required>
                    <i class="fa-solid fa-eye toggle-password" toggle="#signup-password"></i>
                </div>
                <c:if test="${not empty passwordError}">
                    <span class="field-error-text">${passwordError}</span>
                </c:if>

                <div class="form-row password-field">
                    <input
                            id="signup-confirmPassword"
                            class="input-confirm ${not empty confirmPasswordError ? 'input-error-border' : ''}"
                            type="password"
                            name="confirmPassword"
                            placeholder="Xác nhận mật khẩu"
                            aria-label="Xác nhận mật khẩu"
                            required>
                    <i class="fa-solid fa-eye toggle-password" toggle="#signup-confirmPassword"></i>
                </div>
                <c:if test="${not empty confirmPasswordError}">
                    <span class="field-error-text">${confirmPasswordError}</span>
                </c:if>
                <div class="form-row" style="justify-content:center; margin-bottom: 15px;">
                    <div class="g-recaptcha" data-sitekey="${captchaSiteKey}"></div>
                </div>
                <c:if test="${not empty captchaError}">
                    <span class="field-error-text" style="text-align: center; margin-bottom: 15px;">${captchaError}</span>
                </c:if>
                <div class="form-row">
                    <button type="submit" class="btn">Đăng ký</button>
                </div>

                <div class="signup">
                    Đã có tài khoản?
                    <a href="${pageContext.request.contextPath}/login">Đăng nhập</a> </div>
            </form>
        </div>

    </div>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>


<script>
    const avatarInput = document.getElementById('signup-avatarInput');
    const avatarPreview = document.getElementById('signup-avatarPreview');
    const avatarBox = document.getElementById('signup-avatarBox');

    if (avatarBox && avatarInput) {
        avatarBox.addEventListener('click', () => avatarInput.click()); // mở hộp thoại chọn file
    }

    // cập nhật ảnh đại diện khi chọn file
    function handleAvatarChange(e){
        const file = e.target.files?.[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (ev) => { 
            if (avatarPreview) avatarPreview.src = ev.target.result; 
        };
        reader.readAsDataURL(file);
    }
    if (avatarInput) {
        avatarInput.addEventListener('change', handleAvatarChange);
    }
</script>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
</body>
</html>