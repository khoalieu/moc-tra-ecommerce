<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn #${order.orderNumber} - Mộc Trà</title>

    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" />
</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>

<main>
    <section class="invoice-page">
        <div class="container">
            <c:if test="${not empty order}">
                <div class="invoice-header">
                    <div class="invoice-header-left">
                        <h1 class="invoice-title">Hóa đơn thanh toán</h1>
                        <p class="invoice-subtitle">
                            Cảm ơn bạn đã tin tưởng Mộc Trà. Dưới đây là thông tin chi tiết đơn hàng của bạn.
                        </p>
                    </div>
                    <div class="invoice-header-right">
                        <p><strong>Mã hóa đơn:</strong> <span id="invoiceCode">${order.orderNumber}</span></p>
                        <p><strong>Thời gian đặt:</strong>
                            <span id="invoiceDateTime">
                                <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                        </p>
                        <p><strong>Trạng thái:</strong>
                            <span class="status-badge status-${order.status}">
                                    ${order.status}
                            </span>
                        </p>
                    </div>
                </div>

                <div class="invoice-column">

                    <div class="checkout-card invoice-card">
                        <h2 class="checkout-card__title">Thông tin giao hàng</h2>
                        <div class="invoice-info">
                            <p class="invoice-address" id="shippingAddress">
                                    ${order.notes}
                            </p>

                            <p><strong>Phương thức giao hàng:</strong>
                                <span class="pill pill-shipping">
                                    <c:choose>
                                        <c:when test="${order.shippingFee >= 60000}">Giao Hỏa Tốc</c:when>
                                        <c:when test="${order.shippingFee >= 35000}">Giao Nhanh</c:when>
                                        <c:otherwise>Giao Tiêu Chuẩn</c:otherwise>
                                    </c:choose>
                                </span>
                            </p>
                        </div>
                    </div>

                    <div class="checkout-card invoice-card">
                        <h2 class="checkout-card__title">Hình thức thanh toán</h2>
                        <div class="invoice-info">
                            <p><strong>Phương thức:</strong>
                                <span class="pill pill-payment" id="paymentMethod">
                                    <c:choose>
                                        <c:when test="${order.paymentMethod == 'cod'}">Thanh toán khi nhận hàng (COD)</c:when>
                                        <c:when test="${order.paymentMethod == 'momo'}">Ví MoMo</c:when>
                                        <c:when test="${order.paymentMethod == 'banking'}">Chuyển khoản ngân hàng</c:when>
                                        <c:otherwise>${order.paymentMethod}</c:otherwise>
                                    </c:choose>
                                </span>
                            </p>
                            <p><strong>Trạng thái thanh toán:</strong>
                                <span id="paymentStatus">
                                    <c:choose>
                                        <c:when test="${order.paymentStatus == 'PAID'}">
                                            <span style="color: green; font-weight: bold;">Đã thanh toán</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: orange; font-weight: bold;">Chờ thanh toán</span>
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </p>
                        </div>
                    </div>

                    <div class="checkout-card invoice-card">
                        <h2 class="checkout-card__title">Danh sách sản phẩm</h2>

                        <div class="invoice-table-wrapper">
                            <table class="invoice-table">
                                <thead>
                                <tr>
                                    <th>Hình ảnh</th>
                                    <th>Tên Sản phẩm</th>
                                    <th>Số lượng</th>
                                    <th>Đơn giá</th>
                                    <th>Thành tiền</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="item" items="${order.items}">
                                    <tr>
                                        <td>
                                            <div style="display: flex; align-items: center; gap: 10px;">
                                                <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                                     style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">
                                            </div>
                                        </td>
                                        <td><span class="invoice-product-name">${item.product.name}</span></td>
                                        <td>${item.quantity}</td>
                                        <td>
                                            <fmt:formatNumber value="${item.price}" type="currency"/>
                                        </td>
                                        <td>
                                            <fmt:formatNumber value="${item.price * item.quantity}" type="currency"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>
                            </table>
                        </div>

                        <div class="order-summary invoice-summary">
                            <div class="order-summary__row">
                                <span>Tạm tính</span>
                                <span>
                                    <fmt:formatNumber value="${order.totalAmount - order.shippingFee}" type="currency"/>
                                </span>
                            </div>
                            <div class="order-summary__row">
                                <span>Phí vận chuyển</span>
                                <span id="invoiceShippingFee">
                                    <fmt:formatNumber value="${order.shippingFee}" type="currency"/>
                                </span>
                            </div>
                            <div class="order-summary__row order-summary__row--total">
                                <span>Tổng cộng</span>
                                <span id="invoiceTotal" style="color: #d32f2f; font-size: 1.2rem;">
                                    <fmt:formatNumber value="${order.totalAmount}" type="currency"/>
                                </span>
                            </div>
                        </div>
                    </div>

                    <div class="invoice-actions">
                        <a href="san-pham.jsp" class="btn btn-secondary">
                            Tiếp tục mua sắm
                        </a>
                        <a href="don-hang" class="btn btn-primary">
                            Xem lịch sử đơn hàng
                        </a>
                    </div>
                </div>
            </c:if>

            <c:if test="${empty order}">
                <div style="text-align: center; padding: 50px;">
                    <h2>Không tìm thấy đơn hàng!</h2>
                    <a href="index.jsp" class="btn btn-primary">Về trang chủ</a>
                </div>
            </c:if>
        </div>
    </section>
</main>

<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>
</html>