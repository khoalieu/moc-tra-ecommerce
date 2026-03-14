<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng - Mộc Trà</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>
<main class="main-content">
    <section class="checkout-page">
        <div class="container">
            <h1 class="checkout-title">Giỏ hàng của bạn</h1>
            <div class="checkout-layout">
                <div class="checkout-left">
                    <div class="checkout-card">
                        <table class="cart-table">
                            <thead>
                            <tr>
                                <th>Ảnh</th>          <%-- Đổi tên cột --%>
                                <th>Tên sản phẩm</th> <%-- Thêm cột mới --%>
                                <th>Đơn giá</th>
                                <th>Số lượng</th>
                                <th>Thành tiền</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:if test="${empty sessionScope.cart or sessionScope.cart.items.size() == 0}">
                                <tr><td colspan="6" style="text-align:center; padding: 20px;">Giỏ hàng trống!</td></tr>
                            </c:if>

                            <c:forEach var="item" items="${sessionScope.cart.items}">
                                <tr>
                                        <%-- Cột 1: Chỉ hiển thị Ảnh --%>
                                    <td style="width: 100px; text-align: center;">
                                        <div class="cart-item-product">
                                            <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                                 style="width: 80px; height: auto; object-fit: cover; border-radius: 4px;">
                                        </div>
                                    </td>

                                        <%-- Cột 2: Hiển thị Tên sản phẩm --%>
                                    <td>
                                        <a href="chi-tiet-san-pham?id=${item.product.id}"
                                           style="font-weight: 500; color: #333; text-decoration: none;">
                                                ${item.product.name}
                                        </a>
                                    </td>

                                        <%-- Cột 3: Đơn giá --%>
                                    <td>
                                        <c:choose>
                                            <c:when test="${item.product.salePrice > 0}">
                                                <fmt:formatNumber value="${item.product.salePrice}" type="currency"/>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${item.product.price}" type="currency"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                        <%-- Cột 4: Số lượng --%>
                                    <td>
                                        <form action="gio-hang" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="productId" value="${item.product.id}">
                                            <input class="cart-item-quantity" type="number" name="quantity"
                                                   value="${item.quantity}" min="1"
                                                   onchange="this.form.submit()" style="width: 60px; text-align: center;">
                                        </form>
                                    </td>

                                        <%-- Cột 5: Thành tiền --%>
                                    <td style="color: #d9534f; font-weight: bold;">
                                        <fmt:formatNumber value="${item.totalPrice}" type="currency"/>
                                    </td>

                                        <%-- Cột 6: Thao tác --%>
                                    <td>
                                        <a href="chi-tiet-san-pham?id=${item.product.id}" title="Xem chi tiết"
                                           style="color: #2196F3; margin-right: 10px; font-size: 1.1rem; text-decoration: none;">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <form action="gio-hang" method="post" style="display:inline;">
                                            <input type="hidden" name="action" value="remove">
                                            <input type="hidden" name="productId" value="${item.product.id}">
                                            <button type="submit" class="cart-item-remove" title="Xóa sản phẩm"
                                                    style="border:none; background:none; cursor:pointer; color:red; font-size: 1.1rem;">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="checkout-right">
                    <div class="checkout-card">
                        <h2 class="checkout-card__title">Tóm tắt đơn hàng</h2>
                        <div class="order-summary">
                            <div class="order-summary__row order-summary__row--total">
                                <span>Tổng cộng</span>
                                <span style="color: #d9534f; font-size: 1.2em; font-weight: bold;">
                                    <fmt:formatNumber value="${sessionScope.cart.totalMoney}" type="currency"/>
                                </span>
                            </div>
                        </div>
                        <div class="checkout-submit">
                            <a href="thanh-toan" class="btn btn-primary checkout-submit__btn">Tiến hành Thanh toán</a>
                            <a href="san-pham" class="continue-shopping-link">
                                <i class="fa-solid fa-arrow-left"></i> Tiếp tục mua sắm
                            </a>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </section>
</main>
<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

</body>
</html>