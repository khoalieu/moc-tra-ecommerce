<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán ngân hàng - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">

    <style>
        .payment-qr-page {
            padding: 50px 0;
            background: #f7f7f7;
            min-height: 70vh;
        }

        .payment-qr-card {
            max-width: 620px;
            margin: 0 auto;
            background: #fff;
            border-radius: 16px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 8px 28px rgba(0,0,0,0.08);
        }

        .payment-info {
            text-align: left;
            margin: 20px auto;
            max-width: 430px;
            background: #fafafa;
            border-radius: 10px;
            padding: 15px;
        }

        .payment-info p {
            margin: 8px 0;
        }

        .qr-box {
            margin: 25px auto;
            padding: 20px;
            border: 1px solid #eee;
            border-radius: 12px;
            display: inline-block;
            background: #fff;
        }

        .qr-box img {
            width: 300px;
            max-width: 100%;
            height: auto;
        }

        .payment-status {
            font-weight: bold;
            color: #f57c00;
            margin-top: 15px;
        }
        .countdown-box {
            margin-top: 15px;
            padding: 12px;
            background: #fff8e1;
            border: 1px solid #ffe0a3;
            border-radius: 8px;
            color: #8a5a00;
            font-weight: 600;
        }

        .countdown-box.expired {
            background: #ffebee;
            border-color: #ffcdd2;
            color: #c62828;
        }

        .qr-box.expired {
            opacity: 0.35;
            pointer-events: none;
        }

        .btn-open-payment {
            display: inline-block;
            margin-top: 15px;
            padding: 12px 20px;
            background: #2e7d32;
            color: #fff;
            border-radius: 8px;
            text-decoration: none;
        }

        .btn-back {
            display: inline-block;
            margin-top: 15px;
            padding: 10px 18px;
            background: #eee;
            color: #333;
            border-radius: 8px;
            text-decoration: none;
        }

        .note {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
    </style>
</head>

<body>
<jsp:include page="/common/header.jsp"></jsp:include>

<main class="payment-qr-page">
    <div class="container">

        <c:if test="${not empty order && not empty payment}">
            <div class="payment-qr-card">

                <c:choose>
                    <c:when test="${payment.provider == 'momo'}">
                        <h1>Thanh toán MoMo</h1>
                        <p class="note">Dùng ứng dụng MoMo để quét mã QR hoặc bấm nút mở trang thanh toán.</p>
                    </c:when>

                    <c:when test="${payment.provider == 'payos'}">
                        <h1>Thanh toán ngân hàng</h1>
                        <p class="note">Quét mã QR bằng app ngân hàng hoặc bấm nút mở trang thanh toán.</p>
                    </c:when>

                    <c:otherwise>
                        <h1>Thanh toán</h1>
                    </c:otherwise>
                </c:choose>

                <div class="payment-info">
                    <p><strong>Mã đơn:</strong> ${order.orderNumber}</p>

                    <p>
                        <strong>Số tiền:</strong>
                        <span style="color:#d32f2f; font-weight:bold;">
                            <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </span>
                    </p>

                    <p><strong>Phương thức:</strong>
                        <c:choose>
                            <c:when test="${payment.provider == 'momo'}">Ví MoMo</c:when>
                            <c:when test="${payment.provider == 'payos'}">Chuyển khoản ngân hàng qua payOS</c:when>
                            <c:otherwise>${payment.paymentMethod}</c:otherwise>
                        </c:choose>
                    </p>

                    <p><strong>Trạng thái:</strong> <span id="paymentStatusText">${order.paymentStatus}</span></p>
                    <c:if test="${not empty payment.expiredAt}">
                        <p>
                            <strong>Thời gian còn lại:</strong>
                            <span id="countdownText">Đang tính...</span>
                        </p>
                    </c:if>
                </div>
                <c:if test="${not empty payment.expiredAt}">
                    <div class="countdown-box" id="countdownBox">
                        Mã QR còn hiệu lực trong:
                        <span id="countdownText">Đang tính...</span>
                    </div>
                </c:if>

                <div class="qr-box" id="qrBox">
                    <img src="${payment.qrCodeUrl}" alt="QR thanh toán">
                </div>

                <c:if test="${not empty payment.payUrl}">
                    <br>
                    <a href="${payment.payUrl}" class="btn-open-payment" target="_blank">
                        Mở trang thanh toán
                    </a>
                </c:if>

                <div class="payment-status" id="waitingText">
                    Đang chờ thanh toán...
                </div>

                <a href="${pageContext.request.contextPath}/hoa-don?id=${order.id}" class="btn-back">
                    Xem hóa đơn
                </a>
            </div>
        </c:if>

        <c:if test="${empty order || empty payment}">
            <div class="payment-qr-card">
                <h1>Không tìm thấy giao dịch thanh toán</h1>
                <a href="${pageContext.request.contextPath}/don-hang" class="btn-back">Về đơn hàng</a>
            </div>
        </c:if>

    </div>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>

<c:if test="${not empty order}">
    <script>
        const expiredAtText = '${payment.expiredAt}';
        const countdownText = document.getElementById('countdownText');
        const countdownBox = document.getElementById('countdownBox');
        const qrBox = document.getElementById('qrBox');
        const waitingText = document.getElementById('waitingText');
        const paymentStatusText = document.getElementById('paymentStatusText');

        let isExpired = false;

        function parseExpiredAt(text) {
            if (!text) return null;

            const normalized = text.replace(' ', 'T');
            const date = new Date(normalized);

            if (isNaN(date.getTime())) {return null;}
            return date;
        }
        const expiredAt = parseExpiredAt(expiredAtText);

        function updateCountdown() {
            if (!expiredAt || !countdownText) {return;}
            const now = new Date();
            const diff = expiredAt.getTime() - now.getTime();

            if (diff <= 0) {
                isExpired = true;
                countdownText.innerText = '00:00';

                if (countdownBox) {countdownBox.classList.add('expired');}
                if (qrBox) {qrBox.classList.add('expired');}
                if (waitingText) {waitingText.innerText = 'Mã thanh toán đã hết hạn. Vui lòng tạo mã mới.';}
                if (paymentStatusText && paymentStatusText.innerText !== 'PAID') {
                    paymentStatusText.innerText = 'EXPIRED';
                }
                return;
            }

            const totalSeconds = Math.floor(diff / 1000);
            const minutes = Math.floor(totalSeconds / 60);
            const seconds = totalSeconds % 60;

            countdownText.innerText =
                String(minutes).padStart(2, '0') + ':' + String(seconds).padStart(2, '0');
        }

        updateCountdown();
        setInterval(updateCountdown, 1000);

        setInterval(async function () {
            try {
                const res = await fetch('${pageContext.request.contextPath}/payment-status?orderId=${order.id}');
                const data = await res.json();

                if (data.paymentStatus === 'PAID') {
                    paymentStatusText.innerText = 'PAID';
                    waitingText.innerText = 'Thanh toán thành công! Đang chuyển về hóa đơn...';

                    setTimeout(function () {
                        window.location.href = '${pageContext.request.contextPath}/hoa-don?id=${order.id}';
                    }, 1200);
                }

                if (data.paymentStatus === 'FAILED') {
                    paymentStatusText.innerText = 'FAILED';
                    waitingText.innerText = 'Thanh toán thất bại. Vui lòng thử lại.';
                }

                if (data.paymentStatus === 'EXPIRED') {
                    paymentStatusText.innerText = 'EXPIRED';
                    waitingText.innerText = 'Mã thanh toán đã hết hạn. Vui lòng tạo mã mới.';
                    if (countdownBox) countdownBox.classList.add('expired');
                    if (qrBox) qrBox.classList.add('expired');
                }

            } catch (e) {
                console.error(e);
            }
        }, 3000);
    </script>
</c:if>

</body>
</html>