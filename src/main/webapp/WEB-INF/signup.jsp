<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng Ký</title>
    <link rel="stylesheet" href="assets/css/main.css" />
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
    </style>
</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>
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

                <div class="form-row">
                    <input
                            id="signup-username"
                            class="input-username"
                            type="text"
                            name="username"
                            placeholder="Tên đăng nhập"
                            aria-label="Tên đăng nhập"
                            value="${param.username}"
                            required>
                </div>

                <div class="form-row">
                    <input
                            id="signup-email"
                            class="input-email"
                            type="email"
                            name="email"
                            placeholder="Email"
                            aria-label="Email"
                            value="${param.email}"
                            required>
                </div>

                <div class="form-row">
                    <input
                            id="signup-phone"
                            class="input-phone"
                            type="tel"
                            name="phone"
                            placeholder="Số điện thoại"
                            pattern="[0-9]{10}"
                            value="${param.phone}"
                            required>
                </div>

                <div class="form-row password-field">
                    <input
                            id="signup-password"
                            class="input-password"
                            type="password"
                            name="password"
                            placeholder="Mật khẩu"
                            aria-label="Mật khẩu"
                            required>
                </div>

                <div class="form-row password-field">
                    <input
                            id="signup-confirmPassword"
                            class="input-confirm"
                            type="password"
                            name="confirmPassword"
                            placeholder="Xác nhận mật khẩu"
                            aria-label="Xác nhận mật khẩu"
                            required>
                </div>

                <div class="form-row avatar-row">
                    <label class="avatar-text" for="avatarInput">Avatar</label>

                    <div class="avatar-box" id="signup-avatarBox" role="button" aria-label="Chọn ảnh đại diện">
                        <img id="signup-avatarPreview" src="assets/images/useravata.png" alt="Ảnh đại diện">
                    </div>
                    <input type="file" id="signup-avatarInput" name="avatar" accept="image/*" style="display:none;">
                </div>

                <div class="form-row">
                    <button type="submit" class="btn">Đăng ký</button>
                </div>

                <div class="signup">
                    Đã có tài khoản?
                    <a href="login.jsp">Đăng nhập</a> </div>
            </form>
        </div>

    </div>
</div>

<jsp:include page="common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>


<script>
    const avatarInput = document.getElementById('signup-avatarInput');
    const avatarPreview = document.getElementById('signup-avatarPreview');
    const avatarBox = document.getElementById('signup-avatarBox');

    avatarBox.addEventListener('click', () => avatarInput.click()); // mở hộp thoại chọn file

    // cập nhật ảnh đại diện khi chọn file
    function handleAvatarChange(e){
        const file = e.target.files?.[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (ev) => { avatarPreview.src = ev.target.result; };
        reader.readAsDataURL(file);
    }
    avatarInput.addEventListener('change', handleAvatarChange);
</script>

<script src="assets/js/main.js"></script>

</body>
</html>