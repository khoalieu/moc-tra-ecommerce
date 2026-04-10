<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<main class="main-content">
    <section class="checkout-page">
        <div class="container">
            <h1 class="checkout-title">Giỏ hàng của bạn</h1>
            <form id="checkoutForm" action="${pageContext.request.contextPath}/thanh-toan" method="GET">
                <div class="checkout-layout">
                    <div class="checkout-left">
                        <div class="checkout-card">
                            <table class="cart-table">
                                <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">
                                        <input type="checkbox" id="selectAll" title="Chọn tất cả">
                                    </th>
                                    <th>Ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Đơn giá</th>
                                    <th>Số lượng</th>
                                    <th>Thành tiền</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty sessionScope.cart or sessionScope.cart.items.size() == 0}">
                                    <tr><td colspan="7" style="text-align:center; padding: 20px;">Giỏ hàng trống!</td></tr>
                                </c:if>

                                <c:forEach var="item" items="${sessionScope.cart.items}">
                                    <tr>
                                        <td style="text-align: center;">
                                            <input type="checkbox" class="item-checkbox" name="selectedItems"
                                                   value="${item.product.id}"
                                                   data-price="${item.totalPrice}">
                                        </td>

                                        <td style="width: 100px; text-align: center;">
                                            <div class="cart-item-product">
                                                <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                                     style="width: 80px; height: auto; object-fit: cover; border-radius: 4px;">
                                            </div>
                                        </td>

                                        <td>
                                            <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${item.product.id}"
                                               style="font-weight: 500; color: #333; text-decoration: none;">
                                                    ${item.product.name}
                                            </a>
                                        </td>

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

                                        <td>
                                            <input class="cart-item-quantity" type="number"
                                                   value="${item.quantity}" min="1"
                                                   data-id="${item.product.id}"
                                                   onchange="updateQuantity(this)" style="width: 60px; text-align: center;">
                                        </td>

                                        <td style="color: #d9534f; font-weight: bold;">
                                            <fmt:formatNumber value="${item.totalPrice}" type="currency"/>
                                        </td>

                                        <td>
                                            <a href="javascript:void(0);" onclick="removeItem(${item.product.id})" class="cart-item-remove" title="Xóa sản phẩm"
                                               style="color:red; font-size: 1.1rem; text-decoration: none;">
                                                <i class="fa-solid fa-trash"></i>
                                            </a>
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
                                    <span>Tổng cộng (Đã chọn)</span>
                                    <span id="total-selected-price" style="color: #d9534f; font-size: 1.2em; font-weight: bold;">
                                    0 ₫
                                </span>
                                </div>
                            </div>
                            <div class="checkout-submit">
                                <button type="submit" id="btn-checkout" class="btn btn-primary checkout-submit__btn" style="width:100%; border:none; padding:10px; cursor:pointer;" disabled>
                                    Tiến hành Thanh toán
                                </button>
                                <a href="${pageContext.request.contextPath}/san-pham" class="continue-shopping-link" style="display:block; text-align:center; margin-top:15px;">
                                    <i class="fa-solid fa-arrow-left"></i> Tiếp tục mua sắm
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>
</main>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const selectAllCb = document.getElementById('selectAll');
        const itemCbs = document.querySelectorAll('.item-checkbox');
        const totalDisplay = document.getElementById('total-selected-price');
        const checkoutBtn = document.getElementById('btn-checkout');
        const formatCurrency = (amount) => {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
        };
        const calculateTotal = () => {
            let total = 0;
            let checkedCount = 0;

            itemCbs.forEach(cb => {
                if (cb.checked) {
                    total += parseFloat(cb.getAttribute('data-price'));
                    checkedCount++;
                }
            });

            totalDisplay.innerText = formatCurrency(total);
            if (checkedCount > 0) {
                checkoutBtn.disabled = false;
                checkoutBtn.style.opacity = '1';
                checkoutBtn.innerText = 'Tiến hành Thanh toán (' + checkedCount + ')';
            } else {
                checkoutBtn.disabled = true;
                checkoutBtn.style.opacity = '0.5';
                checkoutBtn.innerText = 'Vui lòng chọn sản phẩm';
            }
        };
        if (selectAllCb) {
            selectAllCb.addEventListener('change', function() {
                itemCbs.forEach(cb => cb.checked = this.checked);
                calculateTotal();
            });
        }

        itemCbs.forEach(cb => {
            cb.addEventListener('change', function() {
                const allChecked = Array.from(itemCbs).every(i => i.checked);
                if (selectAllCb) selectAllCb.checked = allChecked;
                calculateTotal();
            });
        });

        calculateTotal();
    });
    function updateQuantity(input) {
        const productId = input.getAttribute("data-id");
        const quantity = input.value;

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/gio-hang';

        form.innerHTML = `
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="productId" value="`+productId+`">
        <input type="hidden" name="quantity" value="`+quantity+`">
    `;
        document.body.appendChild(form);
        form.submit();
    }
    function removeItem(productId) {
        if(confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/gio-hang';

            form.innerHTML = `
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="productId" value="` + productId + `">
            `;
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
</body>
</html>