<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Xác nhận mã OTP</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/otp.css"/>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw=="
          crossorigin="anonymous" referrerpolicy="no-referrer" />
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
                <p class="login-subtitle">
                    Nhập mã OTP đã được gửi tới email của bạn.
                </p>
                <div style="margin-top: 10px; font-weight: 600; color: #333; background: #f0f2f5; padding: 5px 15px; border-radius: 20px; display: inline-block;">
                    <c:out value="${sessionScope.RESET_EMAIL.replaceAll('(?<=.{3}).(?=.*@)', '*')}" />
                </div>
            </div>

            <div class="login-content">
                <c:if test="${not empty requestScope.otp_display and sessionScope.OTP_PURPOSE != 'FORGOT'}">
                    <div id="otp-auto-fill" class="otp-demo-container animate-pulse">
                        <p style="margin: 0; color: #856404;">Mã xác thực của bạn là:</p>
                        <strong id="source-code">${requestScope.otp_display}</strong>
                        <span class="quick-fill-hint">
                            <i class="fa-solid fa-hand-pointer"></i> Chạm vào đây để điền nhanh
                        </span>
                    </div>
                </c:if>
                <form id="otpForm"
                      action="${pageContext.request.contextPath}/${sessionScope.OTP_PURPOSE == 'CHANGE_EMAIL' ? 'verify-change-email-otp' : (sessionScope.OTP_PURPOSE == 'FORGOT' ? 'verify-otp' : 'verify-register-otp')}"
                      method="post"
                      autocomplete="off">
                    <div class="otp-input-group">
                        <input type="text" maxlength="1" class="otp-input" data-id="1">
                        <input type="text" maxlength="1" class="otp-input" data-id="2">
                        <input type="text" maxlength="1" class="otp-input" data-id="3">
                        <input type="text" maxlength="1" class="otp-input" data-id="4">
                        <input type="text" maxlength="1" class="otp-input" data-id="5">
                        <input type="text" maxlength="1" class="otp-input" data-id="6">
                    </div>

                    <input type="hidden" name="otp" id="otpHiddenInput">

                    <p class="reset-message" style="color:red; margin:8px 0;">
                        <c:out value="${message}" />
                    </p>

                    <div class="form-row">
                        <button type="submit" class="btn">Xác nhận</button>
                    </div>
                </form>

                <div class="auth-extra-links">
                    <c:choose>
                        <c:when test="${sessionScope.OTP_PURPOSE == 'CHANGE_EMAIL'}">
                            <form action="${pageContext.request.contextPath}/change-email" method="post" style="display:inline;">
                                <input type="hidden" name="action" value="resend_otp">
                                <button type="submit" class="link-button">Gửi lại mã OTP</button>
                            </form>
                            <a href="${pageContext.request.contextPath}/tai-khoan-cua-toi">Hủy đổi email</a>
                        </c:when>
                        <c:otherwise>
                            <div class="resend-section" style="margin-bottom: 15px;">
                                <p style="font-size: 0.9em; color: #666; margin-bottom: 5px;">Bạn chưa nhận được mã?</p>
                                <form action="${pageContext.request.contextPath}/forgot-password" method="post" style="display:inline;">
                                    <input type="hidden" name="action" value="resend">
                                    <button type="submit" class="link-button" style="font-weight: bold; color: #007bff; border: none; background: none; cursor: pointer; text-decoration: underline;">
                                        <i class="fa-solid fa-rotate-right"></i> Gửi lại mã OTP
                                    </button>
                                </form>
                            </div>

                            <hr style="border: 0; border-top: 1px solid #eee; margin: 15px 0;">

                            <div class="change-email-section">
                                <p style="font-size: 0.9em; color: #666; margin-bottom: 5px;">Nhập nhầm địa chỉ email?</p>
                                <a href="${pageContext.request.contextPath}/forgot-password" class="back-link" style="font-size: 0.95em; color: #dc3545; text-decoration: none; font-weight: 500;">
                                    <i class="fa-solid fa-pen-to-square"></i> Thay đổi email khác
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
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
        const autofill = document.getElementById('otp-auto-fill');

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
                const val = e.target.value;
                input.value = val.replace(/[^0-9]/g, '').slice(-1);

                if (input.value && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
                updateHiddenInput();
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace') {
                    if (input.value === '' && index > 0) {
                        inputs[index - 1].focus();
                    }
                }
                if (e.key === 'ArrowLeft' && index > 0) {
                    e.preventDefault();
                    inputs[index - 1].focus();
                }
                if (e.key === 'ArrowRight' && index < inputs.length - 1) {
                    e.preventDefault();
                    inputs[index + 1].focus();
                }
            });

            input.addEventListener('click', () => {
                input.select();
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