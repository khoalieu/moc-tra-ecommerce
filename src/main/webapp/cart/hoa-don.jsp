<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hóa đơn #${order.orderNumber} - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/invoice-detail.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>

<main>
    <section class="invoice-page">
        <div class="container">
            <c:if test="${not empty order}">
                <div class="invoice-header">
                    <div class="invoice-header-left">
                        <h1 class="invoice-title">Hóa đơn thanh toán</h1>
                        <p class="invoice-subtitle">Cảm ơn bạn đã tin tưởng Mộc Trà.</p>
                    </div>
                    <div class="invoice-header-right">
                        <p><strong>Mã hóa đơn:</strong> ${order.orderNumber}</p>
                        <p><strong>Thời gian đặt:</strong> <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                        <p><strong>Trạng thái:</strong>
                            <span class="status-badge status-${order.status.toString().toLowerCase()}">
                                <c:choose>
                                    <c:when test="${order.status == 'PENDING'}">Chờ xử lý</c:when>
                                    <c:otherwise>${order.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </p>
                    </div>
                </div>

                <div class="invoice-column">
                    <div class="invoice-column"> <div class="checkout-card invoice-card">
                        <h2 class="checkout-card__title">Thông tin giao hàng</h2>
                        <div class="invoice-info">
                            <div class="invoice-address-details">
                                <c:out value="${order.notes}" escapeXml="false" />
                            </div>
                            <hr style="margin: 15px 0; border: 0; border-top: 1px solid #eee;">
                            <c:set var="extraFee" value="0"/>
                            <c:choose>
                                <c:when test="${order.shippingFee >= 60000}"><c:set var="extraFee" value="30000"/></c:when>
                                <c:when test="${order.shippingFee >= 45000}"><c:set var="extraFee" value="15000"/></c:when>
                            </c:choose>

                            <p><strong>Phương thức giao hàng:</strong>
                                <span class="pill pill-shipping">
                                <c:choose>
                                    <c:when test="${extraFee == 30000}">Giao Hỏa Tốc</c:when>
                                    <c:when test="${extraFee == 15000}">Giao Nhanh</c:when>
                                    <c:otherwise>Giao Tiêu Chuẩn</c:otherwise>
                                </c:choose>
                            </span>
                            </p>
                        </div>
                    </div>

                        <div class="checkout-card invoice-card">
                            <h2 class="checkout-card__title">Hình thức thanh toán</h2>
                            <div class="invoice-info">
                                <p>
                                    <strong>Phương thức:</strong>
                                    <span class="invoice-pill invoice-pill-method">
                                        <c:choose>
                                            <c:when test="${order.paymentMethod == 'cod'}">
                                                Thanh toán khi nhận hàng
                                            </c:when>
                                            <c:when test="${order.paymentMethod == 'bank'}">
                                                Chuyển khoản ngân hàng
                                            </c:when>
                                            <c:otherwise>
                                                ${order.paymentMethod}
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </p>

                                <p>
                                    <strong>Trạng thái:</strong>
                                    <c:choose>
                                        <c:when test="${order.paymentStatus == 'PAID'}">
                                            <span class="invoice-pill invoice-pill-paid">
                                                <i class="fa-solid fa-circle-check"></i>
                                                Đã thanh toán
                                            </span>
                                        </c:when>

                                        <c:when test="${order.paymentStatus == 'PENDING'}">
                                            <span class="invoice-pill invoice-pill-pending">
                                                <i class="fa-regular fa-clock"></i>
                                                Chưa thanh toán
                                            </span>
                                        </c:when>

                                        <c:when test="${order.paymentStatus == 'FAILED'}">
                                            <span class="invoice-pill invoice-pill-failed">
                                                <i class="fa-solid fa-triangle-exclamation"></i>
                                                Thanh toán thất bại
                                            </span>
                                        </c:when>

                                        <c:when test="${order.paymentStatus == 'EXPIRED'}">
                                            <span class="invoice-pill invoice-pill-failed">
                                                <i class="fa-solid fa-clock-rotate-left"></i>
                                                Thanh toán hết hạn
                                            </span>
                                        </c:when>

                                        <c:when test="${order.paymentStatus == 'REFUNDED'}">
                                            <span class="invoice-pill invoice-pill-refunded">
                                                <i class="fa-solid fa-rotate-left"></i>
                                                Đã hoàn tiền
                                            </span>
                                        </c:when>

                                        <c:otherwise>
                                            <span class="invoice-pill invoice-pill-pending">
                                                    ${order.paymentStatus}
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </div>

                    <div class="checkout-card invoice-card">
                        <h2 class="checkout-card__title">Danh sách sản phẩm</h2>
                        <div class="invoice-table-wrapper">
                            <table class="invoice-table">
                                <thead>
                                <tr>
                                    <th class="text-left">Hình ảnh</th>
                                    <th class="text-left">Tên Sản phẩm</th>
                                    <th class="text-center">Số lượng</th>
                                    <th class="text-right">Đơn giá</th>
                                    <th class="text-right">Thành tiền</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="item" items="${orderItems}">
                                    <tr>
                                        <td class="text-left">
                                            <c:choose>
                                                <c:when test="${empty item.product.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/assets/images/no-image.jpg" width="50" class="img-rounded">
                                                </c:when>
                                                <c:when test="${item.product.imageUrl.startsWith('http')}">
                                                    <img src="${item.product.imageUrl}" width="50" class="img-rounded">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/${item.product.imageUrl}" width="50" class="img-rounded">
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-left">
                                            <span class="font-medium">${item.product.name}</span>
                                            <c:if test="${not empty item.variant}">
                                                <div class="text-variant">${item.variant.variantName}</div>
                                            </c:if>
                                        </td>
                                        <td class="text-center">${item.quantity}</td>
                                        <td class="text-right">
                                            <c:choose>
                                                <c:when test="${item.originalPrice > item.price}">
                                                    <div style="color: #999; text-decoration: line-through; font-size: 0.85rem;">
                                                        <fmt:formatNumber value="${item.originalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>

                                                    <div style="color: #d9534f; font-weight: 600;">
                                                        <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>

                                                    <div style="color: #2e7d32; font-size: 0.82rem;">
                                                        Giảm
                                                        <fmt:formatNumber value="${item.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>
                                                </c:when>

                                                <c:otherwise>
                                                    <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-right price-highlight">
                                            <fmt:formatNumber value="${item.price * item.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
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
                                    <fmt:formatNumber value="${order.subtotalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>

                            <div class="order-summary__row">
                                <span>Phí vận chuyển</span>
                                <span>
                                    <fmt:formatNumber value="${order.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>

                            <c:if test="${order.couponDiscountAmount > 0}">
                                <div class="order-summary__row">
                                    <span>
                                        Giảm mã ưu đãi
                                        <c:if test="${not empty order.couponCode}">
                                            (${order.couponCode})
                                        </c:if>
                                    </span>
                                    <span style="color: #d32f2f;">
                                        -<fmt:formatNumber value="${order.couponDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                            </c:if>

                            <c:if test="${order.vipDiscountAmount > 0}">
                                <div class="order-summary__row">
                                    <span>Giảm voucher VIP</span>
                                    <span style="color: #d32f2f;">
                                    -<fmt:formatNumber value="${order.vipDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                                </div>
                            </c:if>

                            <div class="order-summary__row order-summary__row--total">
                                <span>Tổng cộng</span>
                                <span class="price-highlight font-large">
                                    <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>
                        </div>

                        <div class="invoice-actions" style="margin-top: 30px; display: flex; gap: 15px; justify-content: flex-end; flex-wrap: wrap;">
                            <a href="${pageContext.request.contextPath}/don-hang" class="btn btn-primary" style="padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 600; display: inline-flex; align-items: center; gap: 8px;">
                                <i class="fa-solid fa-list-check"></i> Theo dõi đơn hàng này
                            </a>
                            <a href="${pageContext.request.contextPath}/san-pham" class="btn" style="padding: 10px 20px; border: 1px solid #ccc; border-radius: 8px; text-decoration: none; font-weight: 600; color: #555; display: inline-flex; align-items: center; gap: 8px; background: #fff;">
                                <i class="fa-solid fa-arrow-left"></i> Tiếp tục mua sắm
                            </a>
                        </div>
                    </div>
                </div> </c:if>
        </div>
    </section>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>
</body>
</html>
