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

                <h1>Thanh toán ngân hàng</h1>
                <p class="note">Quét mã QR bằng app ngân hàng hoặc bấm nút mở trang thanh toán.</p>

                <div class="payment-info">
                    <p><strong>Mã đơn:</strong> ${order.orderNumber}</p>

                    <p>
                        <strong>Số tiền:</strong>
                        <span style="color:#d32f2f; font-weight:bold;">
                            <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </span>
                    </p>

                    <p><strong>Phương thức:</strong> Chuyển khoản ngân hàng qua payOS</p>

                    <p><strong>Trạng thái:</strong> <span id="paymentStatusText">${order.paymentStatus}</span></p>
                </div>

                <div class="qr-box">
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
        setInterval(async function () {
            try {
                const res = await fetch('${pageContext.request.contextPath}/payment-status?orderId=${order.id}');
                const data = await res.json();

                if (data.paymentStatus === 'PAID') {
                    document.getElementById('paymentStatusText').innerText = 'PAID';
                    document.getElementById('waitingText').innerText = 'Thanh toán thành công! Đang chuyển về hóa đơn...';

                    setTimeout(function () {
                        window.location.href = '${pageContext.request.contextPath}/hoa-don?id=${order.id}';
                    }, 1200);
                }

                if (data.paymentStatus === 'FAILED') {
                    document.getElementById('paymentStatusText').innerText = 'FAILED';
                    document.getElementById('waitingText').innerText = 'Thanh toán thất bại. Vui lòng thử lại.';
                }

            } catch (e) {
                console.error(e);
            }
        }, 3000);
    </script>
</c:if>

</body>
</html>