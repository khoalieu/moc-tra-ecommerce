<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${empty sessionScope.temp_email}">
    <c:redirect url="/auth/signup.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Xác nhận mã OTP</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/otp.css"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
          crossorigin="anonymous" referrerpolicy="no-referrer"/>
</head>

<body>
<jsp:include page="/common/header.jsp"></jsp:include>

<main>
    <div class="login-page otp-page">
        <div class="login-box">
            <div class="login-header">
                <div class="login-icon-circle">
                    <i class="fa-solid fa-key"></i>
                </div>
                <h2 class="login-title">Xác nhận mã OTP</h2>

                <c:if test="${not empty requestScope.otp_display and sessionScope.OTP_PURPOSE != 'FORGOT'}">
                    <div id="otp-auto-fill" class="otp-demo-container animate-pulse">
                        <p style="margin: 0; color: #856404;">Mã xác thực của bạn là:</p>
                        <strong id="source-code">${requestScope.otp_display}</strong>
                        <span class="quick-fill-hint">
                            <i class="fa-solid fa-hand-pointer"></i> Chạm vào đây để điền nhanh
                        </span>
                    </div>
                </c:if>

                <p class="login-subtitle">
                    Nhập mã OTP đã được gửi tới email của bạn.
                </p>
            </div>

            <div class="login-content">
                <!-- Verify OTP -->
                <form id="otpForm"
                      action="${pageContext.request.contextPath}/verify-register-otp" method="post" autocomplete="off">
                    <div class="otp-input-group">
                        <label>
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="1">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="2">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="3">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="4">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="5">
                            <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="6">
                        </label>
                    </div>

                    <input type="hidden" name="otp" id="otpHiddenInput">

                    <p class="reset-message" style="color:red; margin:8px 0;">
                        <c:out value="${message}"/>
                    </p>

                    <div class="form-row">
                        <button type="submit" class="btn">Xác nhận</button>
                    </div>
                </form>

                <div class="auth-extra-links">
                    <!-- Resend OTP -->
                    <form action="${pageContext.request.contextPath}/forgot-password" method="post"
                          style="display:inline;">
                        <input type="hidden" name="action" value="resend">
                        <button type="submit" class="link-button">Gửi lại mã OTP</button>
                    </form>

                    <a href="${pageContext.request.contextPath}/forgot-password">Thay đổi email</a>
                </div>

            </div>
        </div>
    </div>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const inputs = document.querySelectorAll('.otp-input');
        const hiddenInput = document.getElementById('otpHiddenInput');
        const autofill = document.getElementById('otp-auto-fill')

        function updateHiddenInput() {
            let code = '';
            inputs.forEach(i => code += (i.value || ''));
            hiddenInput.value = code;
        }

        if (autofill) {
            autofill.addEventListener('click', function() {
                const sourceElement = document.getElementById('source-code');
                if (sourceElement){
                    const codeText = sourceElement.textContent.trim();
                    inputs.forEach((input, index) => {
                        input.value = codeText[index] || '';
                        input.style.backgroundColor = "#e8f5e9";
                    });
                    updateHiddenInput();
                    document.querySelector('.btn').focus();
                }
            });
        }

        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                input.value = input.value.replace(/[^0-9]/g, '');

                if (e.inputType === 'insertFromPaste' && input.value.length > 1) {
                    const chars = input.value.split('');
                    input.value = chars[0];
                    let nextIndex = index + 1;
                    for (let i = 1; i < chars.length && nextIndex < inputs.length; i++, nextIndex++) {
                        inputs[nextIndex].value = chars[i].replace(/[^0-9]/g, '');
                    }
                }

                if (input.value && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                    inputs[index + 1].select();
                }
                updateHiddenInput();
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace') {
                    if (input.value === '' && index > 0) {
                        inputs[index - 1].focus();
                        inputs[index - 1].value = '';
                        e.preventDefault();
                        updateHiddenInput();
                    }
                }
                if (e.key === 'ArrowLeft' && index > 0) inputs[index - 1].focus();
                if (e.key === 'ArrowRight' && index < inputs.length - 1) inputs[index + 1].focus();
            });
        });
    });

    document.getElementById('otpForm').addEventListener('submit', function (e) {
        const inputs = document.querySelectorAll('.otp-input');
        let code = '';
        inputs.forEach(i => code += (i.value || ''));

        if (code.length !== 6) {
            alert('Vui lòng nhập đủ 6 số OTP');
            e.preventDefault();
            return;
        }
        document.getElementById('otpHiddenInput').value = code;
    });
</script>
</body>
</html>
