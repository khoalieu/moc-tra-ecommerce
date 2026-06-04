<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo của tôi - Demo</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="assets/css/notifications.css">
</head>
<body>
<div class="notification-demo-header">
    <a href="" class="notification-demo-brand">Mộc Trà</a>
    <div class="notification-bell-demo">
        <button class="notification-bell-btn" type="button" aria-label="Thông báo">
            <i class="fa-regular fa-bell"></i>
            <span class="notification-badge">3</span>
        </button>
        <div class="notification-dropdown-demo">
            <div class="notification-dropdown-head">
                <strong>Thông báo mới</strong>
                <a href="user/notifications-demo.jsp">Xem tất cả</a>
            </div>
            <a class="notification-mini-item unread" href="user/notifications-demo.jsp">
                <span class="notification-dot"></span>
                <span>Đơn hàng #MT1024 đã được xác nhận</span>
            </a>
            <a class="notification-mini-item unread" href="user/notifications-demo.jsp">
                <span class="notification-dot"></span>
                <span>Thanh toán online thành công</span>
            </a>
            <a class="notification-mini-item" href="user/notifications-demo.jsp">
                <span class="notification-dot"></span>
                <span>Bạn vừa nhận được voucher mới</span>
            </a>
        </div>
    </div>
</div>

<main class="notification-page">
    <section class="notification-page-head">
        <div>
            <h1>Thông báo của tôi</h1>
            <p>Theo dõi đơn hàng, thanh toán, hoàn tiền và voucher trong tài khoản.</p>
        </div>
        <button class="notification-mark-all-btn" type="button">
            <i class="fa-solid fa-check-double"></i>
            Đánh dấu tất cả đã đọc
        </button>
    </section>

    <section class="notification-list">
        <article class="notification-item unread">
            <div class="notification-icon order">
                <i class="fa-solid fa-box"></i>
            </div>
            <div class="notification-content">
                <div class="notification-row">
                    <h2>Đơn hàng #MT1024 đã được xác nhận</h2>
                    <span>5 phút trước</span>
                </div>
                <p>Shop đã xác nhận đơn hàng của bạn và đang chuẩn bị giao.</p>
                <a href="user/notifications-demo.jsp">Xem chi tiết</a>
            </div>
        </article>

        <article class="notification-item unread">
            <div class="notification-icon payment">
                <i class="fa-solid fa-credit-card"></i>
            </div>
            <div class="notification-content">
                <div class="notification-row">
                    <h2>Thanh toán online thành công</h2>
                    <span>20 phút trước</span>
                </div>
                <p>Hệ thống đã ghi nhận thanh toán cho đơn hàng #MT1024.</p>
                <a href="user/notifications-demo.jsp">Xem hóa đơn</a>
            </div>
        </article>

        <article class="notification-item unread">
            <div class="notification-icon refund">
                <i class="fa-solid fa-rotate-left"></i>
            </div>
            <div class="notification-content">
                <div class="notification-row">
                    <h2>Yêu cầu hoàn tiền đã được tiếp nhận</h2>
                    <span>1 giờ trước</span>
                </div>
                <p>Admin sẽ kiểm tra thông tin nhận tiền và xử lý hoàn tiền thủ công.</p>
                <a href="user/notifications-demo.jsp">Theo dõi yêu cầu</a>
            </div>
        </article>

        <article class="notification-item">
            <div class="notification-icon voucher">
                <i class="fa-solid fa-ticket"></i>
            </div>
            <div class="notification-content">
                <div class="notification-row">
                    <h2>Bạn vừa nhận được voucher mới</h2>
                    <span>Hôm qua</span>
                </div>
                <p>Voucher giảm giá đã được thêm vào tài khoản của bạn.</p>
                <a href="user/notifications-demo.jsp">Xem voucher</a>
            </div>
        </article>
    </section>
</main>
</body>
</html>
