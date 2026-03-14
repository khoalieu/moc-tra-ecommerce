<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %> <%-- Thêm thư viện Function --%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Gần Đây - Mộc Trà</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" />
</head>
<body class="user-dashboard-page">
<jsp:include page="common/header.jsp"></jsp:include>
<div class="container">
    <jsp:include page="common/user-sidebar.jsp">
        <jsp:param name="activePage" value="don-hang"/>
    </jsp:include>

    <main class="main-content">
        <div class="orders-header">
            <h2 class="page-title" style="margin-bottom: 0;">Đơn Hàng Gần Đây</h2>
            <div class="orders-filter">
                <button class="filter-btn active" data-status="all">Tất cả</button>
                <button class="filter-btn" data-status="pending">Chờ xử lý</button>
                <button class="filter-btn" data-status="completed">Hoàn thành</button>
                <button class="filter-btn" data-status="cancelled">Đã hủy</button>
            </div>
        </div>

        <div class="orders-list">
            <%-- KIỂM TRA DỮ LIỆU --%>
            <c:if test="${not empty orders}">
                <c:forEach var="o" items="${orders}">

                    <%-- 1. XỬ LÝ TRẠNG THÁI (So sánh với ENUM CHỮ HOA) --%>
                    <c:set var="statusStr" value="${o.status.toString()}" />
                    <c:set var="statusClass" value="status-pending" />
                    <c:set var="statusText" value="Chờ xử lý" />

                    <c:choose>
                        <c:when test="${statusStr == 'COMPLETED'}">
                            <c:set var="statusClass" value="status-completed" />
                            <c:set var="statusText" value="Hoàn thành" />
                        </c:when>
                        <c:when test="${statusStr == 'CANCELLED'}">
                            <c:set var="statusClass" value="status-cancelled" />
                            <c:set var="statusText" value="Đã hủy" />
                        </c:when>
                    </c:choose>

                    <%-- 2. RENDER CARD (Chuyển status về chữ thường cho Javascript filter) --%>
                    <div class="order-card" data-status="${fn:toLowerCase(statusStr)}">
                        <div class="order-card-header">
                            <div>
                                <div class="order-number">Đơn hàng #${o.orderNumber}</div>
                                <div class="order-date">
                                    <i class="fa-regular fa-calendar"></i>
                                        <%-- Format Date (Chỉ chạy được nếu model là Timestamp/Date) --%>
                                    <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy, HH:mm"/>
                                </div>
                            </div>
                            <div class="order-status">
                                <span class="status-badge ${statusClass}">${statusText}</span>

                                    <%-- Xử lý trạng thái thanh toán --%>
                                <c:choose>
                                    <c:when test="${o.paymentStatus.toString() == 'PAID'}">
                                        <span class="status-badge payment-paid">Đã thanh toán</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge payment-pending">Chưa thanh toán</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="order-card-body">
                            <div class="order-items">
                                <c:forEach var="item" items="${o.items}">
                                    <div class="order-item">
                                            <%-- Xử lý ảnh lỗi --%>
                                        <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                             class="item-image" onerror="this.src='assets/images/no-image.png'">
                                        <div class="item-details">
                                            <div class="item-name">${item.product.name}</div>
                                            <div class="item-quantity">Số lượng: ${item.quantity}</div>
                                            <div class="item-price">
                                                <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="order-summary">
                                <div class="summary-row">
                                    <span>Tạm tính:</span>
                                    <span><fmt:formatNumber value="${o.totalAmount - o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                                <div class="summary-row">
                                    <span>Phí vận chuyển:</span>
                                    <span><fmt:formatNumber value="${o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                                <div class="summary-row">
                                    <span>Tổng cộng:</span>
                                    <span style="font-weight: bold; color: #d32f2f;">
                                        <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                            </div>

                            <div class="shipping-address">
                                <strong><i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng:</strong><br>
                                    <%-- Hiển thị ghi chú địa chỉ từ DAO --%>
                                    ${o.notes}
                            </div>

                            <div class="order-footer">
                                <div style="font-size: 13px; color: #666;">
                                    <i class="fa-solid fa-credit-card"></i> Thanh toán:
                                    <strong>${o.paymentMethod == 'cod' ? 'Thanh toán khi nhận hàng (COD)' : o.paymentMethod}</strong>
                                </div>
                                <div class="order-actions">
                                    <a href="hoa-don?id=${o.id}" class="btn-action btn-outline">
                                        <i class="fa-solid fa-eye"></i> Chi tiết
                                    </a>

                                    <c:if test="${statusStr == 'PENDING'}">
                                        <form action="cancel-order" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn hủy đơn này?');">
                                            <input type="hidden" name="orderId" value="${o.id}">
                                            <button type="submit" class="btn-action btn-secondary">
                                                <i class="fa-solid fa-times"></i> Hủy đơn
                                            </button>
                                        </form>
                                    </c:if>

                                    <c:if test="${statusStr == 'COMPLETED' || statusStr == 'CANCELLED'}">
                                        <a href="san-pham" class="btn-action btn-primary">
                                            <i class="fa-solid fa-rotate"></i> Mua lại
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
        </div>

        <%-- Empty State --%>
        <div class="empty-state" style="display: ${empty orders ? 'flex' : 'none'}; flex-direction: column; align-items: center; padding: 40px; text-align: center;">
            <i class="fa-solid fa-cart-shopping" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
            <h3>Chưa có đơn hàng nào</h3>
            <p style="color: #666; margin-bottom: 20px;">Bạn chưa có đơn hàng nào. Hãy bắt đầu mua sắm ngay!</p>
            <a href="san-pham" class="btn-action btn-primary" style="text-decoration: none; padding: 10px 20px;">
                <i class="fa-solid fa-shopping-bag"></i> Mua sắm ngay
            </a>
        </div>
    </main>
</div>

<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const filterBtns = document.querySelectorAll(".filter-btn");
        const orderCards = document.querySelectorAll(".order-card");

        filterBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                filterBtns.forEach(b => b.classList.remove("active"));
                btn.classList.add("active");
                const status = btn.getAttribute("data-status");
                orderCards.forEach(card => {
                    if (status === "all" || card.getAttribute("data-status") === status) {
                        card.style.display = "block";
                    } else {
                        card.style.display = "none";
                    }
                });
            });
        });
    });
</script>
</body>
</html>