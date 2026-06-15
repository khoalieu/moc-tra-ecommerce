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
<body class="cart-page">
<jsp:include page="/common/header.jsp"></jsp:include>
<main class="main-content">
    <section class="checkout-page cart-page-section">
        <div class="container">
            <h1 class="checkout-title">Giỏ hàng của bạn</h1>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert alert-success" style="padding: 10px; background: #d4edda; color: #155724; border-radius: 4px; margin-bottom: 20px;">
                    <i class="fa-solid fa-circle-check"></i> ${sessionScope.successMsg}
                </div>
                <% session.removeAttribute("successMsg"); %>
            </c:if>

            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert alert-danger" style="padding: 10px; background: #f8d7da; color: #721c24; border-radius: 4px; margin-bottom: 20px;">
                    <i class="fa-solid fa-triangle-exclamation"></i> ${sessionScope.errorMsg}
                </div>
                <% session.removeAttribute("errorMsg"); %>
            </c:if>
            <div class="checkout-layout">
                <form id="checkoutForm" action="${pageContext.request.contextPath}/thanh-toan" method="GET">
                    <div class="checkout-left">
                        <div class="checkout-card">
                            <div class="cart-table-scroll">
                            <table class="cart-table">
                                <thead>
                                <tr>
                                    <th style="width: 50px; text-align: center;">
                                        <input type="checkbox" id="selectAll" title="Chọn tất cả">
                                    </th>
                                    <th>Ảnh</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Đơn giá</th>
                                    <th>Khuyến mãi</th>
                                    <th>Số lượng</th>
                                    <th>Thành tiền</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:if test="${empty sessionScope.cart or sessionScope.cart.items.size() == 0}">
                                    <tr><td colspan="8" style="text-align:center; padding: 20px;">Giỏ hàng trống!</td></tr>
                                </c:if>

                                <c:forEach var="item" items="${sessionScope.cart.items}">
                                        <tr class="cart-row" data-id="${item.variantId}">
                                        <td style="text-align: center;">
                                            <input type="checkbox" class="item-checkbox" name="selectedItems"
                                                   value="${item.variantId}"
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
                                            <c:if test="${not empty item.variant}">
                                                <div style="font-size: 0.85rem; color: #666; margin-top: 5px;">
                                                    Phân loại: ${item.variant.variantName}
                                                </div>
                                            </c:if>
                                        </td>

                                        <td>
                                            <fmt:formatNumber value="${item.originalUnitPrice}" pattern="#,###"/>&nbsp;đ
                                        </td>

                                        <td style="color: #2e7d32; font-weight: bold;">
                                            <c:choose>
                                                <c:when test="${item.discountPerItem > 0}">
                                                    -
                                                    <fmt:formatNumber value="${item.totalDiscount}" pattern="#,###"/>&nbsp;đ
                                                </c:when>
                                                <c:otherwise>
                                                    0&nbsp;đ
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td>
                                            <input class="cart-item-quantity" type="number"
                                                   value="${item.quantity}" min="1"
                                                   data-id="${item.variantId}"
                                                   onchange="updateQuantity(this)" style="width: 60px; text-align: center;">
                                        </td>

                                        <td class="item-total-price" data-id="${item.variantId}" style="color: #d9534f; font-weight: bold;">
                                            <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/>&nbsp;đ
                                        </td>
                                        <td>
                                            <a href="javascript:void(0);" onclick="removeItem(${item.variantId})" class="cart-item-remove" title="Xóa sản phẩm"
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
                    </div>

                    <div class="checkout-right">
                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Tóm tắt đơn hàng</h2>
                            <div class="order-summary">
                                <div class="order-summary__row order-summary__row--total">
                                    <span>Tổng cộng (Đã chọn)</span>
                                    <span id="total-selected-price" style="color: #d9534f; font-size: 1.2em; font-weight: bold;">
                                    0 đ
                                </span>
                                </div>
                                <div style="margin-top: 12px; padding: 12px; background: #f8f9fa; border-radius: 8px; font-size: 0.92rem; color: #555;">
                                    <i class="fa-solid fa-ticket"></i>
                                    Mã giảm giá sẽ được chọn hoặc nhập ở bước thanh toán.
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
                </form>
            </div>
        </div>
    </section>
</main>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script>
    let calculateTotal = null;

    document.addEventListener('DOMContentLoaded', function() {
        const selectAllCb = document.getElementById('selectAll');
        const totalDisplay = document.getElementById('total-selected-price');
        const checkoutBtn = document.getElementById('btn-checkout');
        const formatCurrency = (amount) => {
            return new Intl.NumberFormat('vi-VN').format(amount) + '\u00A0đ';
        };
        
        calculateTotal = () => {
            let total = 0;
            let checkedCount = 0;
            const currentItemCbs = document.querySelectorAll('.item-checkbox');

            currentItemCbs.forEach(cb => {
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
                const currentItemCbs = document.querySelectorAll('.item-checkbox');
                currentItemCbs.forEach(cb => cb.checked = this.checked);
                calculateTotal();
            });
        }

        document.addEventListener('change', function(e) {
            if (e.target && e.target.classList.contains('item-checkbox')) {
                const currentItemCbs = document.querySelectorAll('.item-checkbox');
                const allChecked = Array.from(currentItemCbs).every(i => i.checked);
                if (selectAllCb) selectAllCb.checked = allChecked;
                calculateTotal();
            }
        });

        document.querySelectorAll('.cart-item-quantity').forEach(input => {
            input.setAttribute('data-prev-value', input.value);
        });

        calculateTotal();
    });

    function updateQuantity(input) {
        const variantId = input.getAttribute("data-id");
        const quantity = parseInt(input.value);

        if (isNaN(quantity) || quantity < 1) {
            input.value = input.getAttribute('data-prev-value') || "1";
            return;
        }

        const params = new URLSearchParams({
            action: 'update',
            variantId: variantId,
            quantity: quantity
        });

        const prevValue = input.getAttribute('data-prev-value') || "1";

        fetch('${pageContext.request.contextPath}/gio-hang', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    input.setAttribute('data-prev-value', quantity);
                    
                    const cb = document.querySelector('.item-checkbox[value="' + variantId + '"]');
                    if (cb) {
                        cb.setAttribute('data-price', data.itemTotalPrice);
                    }

                    const totalCell = document.querySelector('.item-total-price[data-id="' + variantId + '"]');
                    if (totalCell) {
                        totalCell.innerHTML = new Intl.NumberFormat('vi-VN').format(data.itemTotalPrice) + '&nbsp;đ';
                    }

                    if (window.updateHeaderCartDropdown) {
                        window.updateHeaderCartDropdown(data);
                    }

                    if (calculateTotal) calculateTotal();
                } else {
                    alert(data.message || 'Cập nhật số lượng thất bại.');
                    input.value = prevValue;
                }
            })
            .catch(() => {
                alert('Không thể kết nối đến máy chủ.');
                input.value = prevValue;
            });
    }

    function removeItem(variantId) {
        if (confirm('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?')) {
            const params = new URLSearchParams({
                action: 'remove',
                variantId: variantId
            });

            fetch('${pageContext.request.contextPath}/gio-hang', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params
            })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        const row = document.querySelector('.cart-row[data-id="' + variantId + '"]');
                        if (row) {
                            row.remove();
                        }

                        if (window.updateHeaderCartDropdown) {
                            window.updateHeaderCartDropdown(data);
                        }

                        if (calculateTotal) calculateTotal();

                        const remainingRows = document.querySelectorAll('.cart-row');
                        if (remainingRows.length === 0) {
                            const tbody = document.querySelector('.cart-table tbody');
                            if (tbody) {
                                tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; padding: 20px;">Giỏ hàng trống!</td></tr>';
                            }
                        }
                    } else {
                        alert(data.message || 'Xóa sản phẩm thất bại.');
                    }
                })
                .catch(() => {
                    alert('Không thể kết nối đến máy chủ.');
                });
        }
    }
</script>
</body>
</html>
