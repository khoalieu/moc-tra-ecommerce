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
                            <p><strong>Phương thức:</strong> ${not empty order.paymentMethod ? order.paymentMethod.toUpperCase() : 'COD'}</p>
                            <p><strong>Trạng thái:</strong> ${order.paymentStatus}</p>
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
                                            <img src="${pageContext.request.contextPath}${item.product.imageUrl}" width="50" class="img-rounded">
                                        </td>
                                        <td class="text-left">
                                            <span class="font-medium">${item.product.name}</span>
                                            <c:if test="${not empty item.variant}">
                                                <div class="text-variant">${item.variant.variantName}</div>
                                            </c:if>
                                        </td>
                                        <td class="text-center">${item.quantity}</td>
                                        <td class="text-right">
                                            <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
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
                                <span><fmt:formatNumber value="${order.totalAmount - order.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                            </div>
                            <div class="order-summary__row">
                                <span>Phí vận chuyển</span>
                                <span><fmt:formatNumber value="${order.shippingFee - extraFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                            </div>
                            <c:if test="${extraFee > 0}">
                                <div class="order-summary__row">
                                    <span>Dịch vụ cộng thêm</span>
                                    <span class="text-success">+ <fmt:formatNumber value="${extraFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                            </c:if>
                            <div class="order-summary__row order-summary__row--total">
                                <span>Tổng cộng</span>
                                <span class="price-highlight font-large">
                                    <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>
                        </div>
                    </div>
                </div> </c:if>
        </div>
    </section>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>
</body>
</html>