<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực 2FA - Mộc Trà Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/otp.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .verify-card {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            max-width: 500px;
            margin: 50px auto;
            text-align: center;
        }
        .verify-icon {
            font-size: 48px;
            color: #1a73e8;
            margin-bottom: 20px;
        }
        .verify-title {
            font-size: 24px;
            font-weight: 500;
            color: #333;
            margin-bottom: 10px;
        }
        .verify-desc {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        .otp-input-group {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        .otp-input {
            width: 45px;
            height: 45px;
            font-size: 20px;
            text-align: center;
            border: 1px solid #dadce0;
            border-radius: 4px;
            outline: none;
            transition: border-color 0.2s;
        }
        .otp-input:focus {
            border-color: #1a73e8;
            box-shadow: 0 0 0 2px rgba(26,115,232,0.2);
        }
        .btn-verify {
            background-color: #1a73e8;
            color: white;
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.2s;
        }
        .btn-verify:hover {
            background-color: #1557b0;
        }
        .alert-error {
            background-color: #fce8e6;
            color: #c5221f;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="customers"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>
                <h1 style="margin-left: 15px;">Xác thực hai lớp (2FA)</h1>
            </div>
        </header>

        <div class="admin-content">
            <div class="verify-card">
                <div class="verify-icon">
                    <i class="fas fa-shield-alt"></i>
                </div>
                <h2 class="verify-title">Nhập mã xác thực OTP</h2>
                
                <p class="verify-desc">
                    Để thực hiện thay đổi dữ liệu nhạy cảm, một mã OTP gồm 6 chữ số đã được gửi đến email của bạn: 
                    <strong>${sessionScope.user.email}</strong>. Mã này có hiệu lực trong 5 phút.
                </p>

                <c:if test="${not empty requestScope.otp_display}">
                    <div id="otp-auto-fill" class="otp-demo-container animate-pulse" style="background-color: #fff3cd; color: #856404; padding: 15px; border-radius: 4px; margin-bottom: 20px; border: 1px solid #ffeeba; cursor: pointer; text-align: center;">
                        <p style="margin: 0; font-size: 13px;">Mã xác thực 2FA của bạn là (DEMO):</p>
                        <strong id="source-code" style="font-size: 24px; letter-spacing: 2px;">${requestScope.otp_display}</strong>
                        <span class="quick-fill-hint" style="display: block; font-size: 11px; margin-top: 5px; color: #666;">
                            <i class="fa-solid fa-hand-pointer"></i> Nhấn vào đây để điền nhanh
                        </span>
                    </div>
                </c:if>

                <c:if test="${not empty error}">
                    <div class="alert-error">
                        <i class="fas fa-exclamation-circle"></i> ${error}
                    </div>
                </c:if>

                <form id="otpForm" action="" method="post" autocomplete="off">
                    <input type="hidden" name="id" value="${param.id != null ? param.id : param.customerId}">
                    <input type="hidden" name="customerId" value="${param.customerId != null ? param.customerId : param.id}">
                    <c:if test="${not empty param.action}">
                        <input type="hidden" name="action" value="${param.action}">
                    </c:if>
                    <c:if test="${not empty param.voucherId}">
                        <input type="hidden" name="voucherId" value="${param.voucherId}">
                    </c:if>

                    <div class="otp-input-group">
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="1" required>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="2" required>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="3" required>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="4" required>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="5" required>
                        <input type="text" inputmode="numeric" maxlength="1" class="otp-input" data-id="6" required>
                    </div>

                    <input type="hidden" name="otp" id="otpHiddenInput">

                    <button type="submit" class="btn-verify">Xác nhận & Cập nhật</button>
                </form>
            </div>
        </div>
    </main>
</div>

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
                    document.querySelector('.btn-verify').focus();
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
