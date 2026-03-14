<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Mộc Trà</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>
<main>
    <section class="checkout-page">
        <div class="container">
            <h1 class="checkout-title">Thanh toán</h1>

            <form class="checkout-form" action="thanh-toan" method="post">

                <input type="hidden" id="hiddenSubtotal" value="${subtotal}">

                <div class="checkout-layout">
                    <div class="checkout-left">
                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Thông tin giao hàng</h2>

                            <div class="address-book-box">
                                <h3 style="font-size: 16px; margin-bottom: 15px; color: #333;">Sổ địa chỉ</h3>

                                <div class="address-list">
                                    <c:forEach var="addr" items="${addresses}">
                                        <label class="address-option">
                                            <input type="radio" name="selectedAddress" value="${addr.id}" ${addr.isDefault ? 'checked' : ''}>
                                            <div class="address-content">
                                                <strong class="address-label">${addr.label}</strong>
                                                <div class="address-detail">
                                                    <span>${addr.fullName} - ${addr.phoneNumber}</span><br>
                                                    <span>${addr.streetAddress}, ${addr.ward}, ${addr.province}</span>
                                                </div>
                                                <c:if test="${addr.isDefault}">
                                                    <span class="badge-default">Mặc định</span>
                                                </c:if>
                                            </div>
                                        </label>
                                    </c:forEach>

                                    <label class="address-option">
                                        <input type="radio" name="selectedAddress" value="new" ${empty addresses ? 'checked' : ''}>
                                        <div class="address-content">
                                            <strong class="address-label">Giao đến địa chỉ khác</strong>
                                            <div class="address-detail">
                                                <span>Nhập thông tin địa chỉ mới bên dưới...</span>
                                            </div>
                                        </div>
                                    </label>
                                </div>
                            </div>

                            <div class="manual-address">
                                <div class="form-row form-row--2">
                                    <div class="form-field">
                                        <label for="fullName">Họ và tên <span class="required">*</span></label>
                                        <input type="text" id="fullName" name="fullName" placeholder="Nguyễn Văn A">
                                    </div>
                                    <div class="form-field">
                                        <label for="phoneNumber">Số điện thoại <span class="required">*</span></label>
                                        <input type="tel" id="phoneNumber" name="phoneNumber" placeholder="0888 531 015">
                                    </div>
                                </div>

                                <div class="form-row form-row--3">
                                    <div class="form-field">
                                        <label for="province">Tỉnh / Thành phố</label>
                                        <select id="province" name="province">
                                            <option value="">-- Chọn tỉnh / thành --</option>
                                            <option value="Hồ Chí Minh">Hồ Chí Minh</option>
                                            <option value="Hà Nội">Hà Nội</option>
                                        </select>
                                    </div>
                                    <div class="form-field">
                                        <label for="ward">Phường / Xã</label>
                                        <select id="ward" name="ward">
                                            <option value="">-- Chọn phường / xã --</option>
                                            <option value="Phường 1">Phường 1</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-field">
                                        <label for="addressLine">Địa chỉ cụ thể <span class="required">*</span></label>
                                        <input type="text" id="addressLine" name="addressLine" placeholder="Số nhà, tên đường, tòa nhà...">
                                    </div>
                                </div>
                            </div>

                            <div class="form-row form-row--inline">
                                <label class="checkbox-field">
                                    <input type="checkbox" id="shareLocation" name="shareLocation" value="true">
                                    <span>Chia sẻ vị trí hiện tại của tôi để định vị địa chỉ chính xác hơn</span>
                                </label>
                            </div>

                            <div class="form-row">
                                <div class="form-field">
                                    <label for="note">Ghi chú khi giao hàng</label>
                                    <textarea id="note" name="note" rows="3" placeholder="Ví dụ: Gọi trước khi giao, giao giờ hành chính,..."></textarea>
                                </div>
                            </div>

                            <div class="checkout-card">
                                <h2 class="checkout-card__title">Phương thức giao hàng</h2>

                                <div class="shipping-methods">
                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="standard" data-price="20000" checked>
                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Tiêu chuẩn</span>
                                                <span class="shipping-option__price">+ 20.000đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 3-5 ngày làm việc.</div>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="express" data-price="35000">
                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Nhanh</span>
                                                <span class="shipping-option__price">+ 35.000đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 1-2 ngày làm việc.</div>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="instant" data-price="60000">
                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Hỏa tốc</span>
                                                <span class="shipping-option__price">+ 60.000đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 2-4 giờ (nội thành).</div>
                                        </div>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="checkout-right">
                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Đơn hàng của bạn</h2>

                            <div class="order-items">
                                <c:forEach var="item" items="${sessionScope.cart.items}">
                                    <div class="order-item">
                                        <div class="order-item__thumb">
                                            <img src="${item.product.imageUrl}" alt="${item.product.name}">
                                        </div>
                                        <div class="order-item__info">
                                            <div class="order-item__name">${item.product.name}</div>
                                            <div class="order-item__meta">Số lượng: ${item.quantity}</div>
                                        </div>
                                        <div class="order-item__price">
                                            <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="order-summary">
                                <div class="order-summary__row">
                                    <span>Tạm tính</span>
                                    <span>
                                            <fmt:formatNumber value="${subtotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </span>
                                </div>
                                <div class="order-summary__row">
                                    <span>Phí vận chuyển</span>
                                    <span id="shippingFeeDisplay">
                                            <fmt:formatNumber value="${shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </span>
                                </div>
                                <div class="order-summary__row order-summary__row--total">
                                    <span>Tổng cộng</span>
                                    <span id="totalAmountDisplay">
                                            <fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </span>
                                </div>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Phương thức thanh toán</h2>
                            <div class="payment-methods">
                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="momo" checked>
                                    <div class="payment-option__content">
                                        <span class="payment-option__name"><i class="fa-solid fa-mobile-screen"></i> Ví MoMo</span>
                                        <p class="payment-option__desc">Sau khi đặt hàng, hệ thống sẽ hiển thị QR / số điện thoại để bạn thanh toán bằng MoMo.</p>
                                    </div>
                                </label>
                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="cod">
                                    <div class="payment-option__content">
                                        <span class="payment-option__name"><i class="fa-solid fa-box"></i> Thanh toán khi nhận hàng (COD)</span>
                                        <p class="payment-option__desc">Bạn thanh toán trực tiếp cho shipper khi nhận hàng.</p>
                                    </div>
                                </label>
                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="bank">
                                    <div class="payment-option__content">
                                        <span class="payment-option__name"><i class="fa-solid fa-building-columns"></i> Chuyển khoản ngân hàng</span>
                                        <p class="payment-option__desc">Thông tin số tài khoản và nội dung chuyển khoản sẽ được hiển thị sau khi đặt hàng thành công.</p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <div class="checkout-submit">
                            <button type="submit" class="btn btn-primary checkout-submit__btn" id="btnSubmitOrder">
                                Thanh toán <span id="btnTotalDisplay"><fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                            </button>
                            <p class="checkout-submit__note">
                                Bằng cách nhấn "Thanh toán", bạn đồng ý với
                                <a href="dieu-khoan-dich-vu.jsp">Điều khoản dịch vụ</a> của Mộc Trà.
                            </p>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </section>
</main>

<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const addressRadios = document.querySelectorAll('input[name="selectedAddress"]');
        const manualAddressForm = document.querySelector(".manual-address");
        const manualInputs = manualAddressForm.querySelectorAll("input, textarea, select");

        function updateFormState() {
            const selected = document.querySelector('input[name="selectedAddress"]:checked');
            if (selected && selected.value === "new") {
                manualAddressForm.classList.remove("disabled");
                manualInputs.forEach(input => input.disabled = false);
                const firstInput = manualAddressForm.querySelector('input');
                if(firstInput) firstInput.focus();
            } else {
                manualAddressForm.classList.add("disabled");
                manualInputs.forEach(input => input.disabled = true);
            }
        }
        addressRadios.forEach(radio => {
            radio.addEventListener("change", updateFormState);
        });
        updateFormState();
        const shippingRadios = document.querySelectorAll('input[name="shippingMethod"]');
        const subtotal = parseFloat(document.getElementById('hiddenSubtotal').value);
        const shippingFeeDisplay = document.getElementById('shippingFeeDisplay');
        const totalAmountDisplay = document.getElementById('totalAmountDisplay');
        const btnTotalDisplay = document.getElementById('btnTotalDisplay');

        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
        }

        function updateTotal() {
            const selectedShip = document.querySelector('input[name="shippingMethod"]:checked');
            const shipPrice = parseFloat(selectedShip.getAttribute('data-price'));

            const newTotal = subtotal + shipPrice;

            shippingFeeDisplay.innerText = formatCurrency(shipPrice);
            totalAmountDisplay.innerText = formatCurrency(newTotal);
            btnTotalDisplay.innerText = formatCurrency(newTotal);
        }

        shippingRadios.forEach(radio => {
            radio.addEventListener("change", updateTotal);
        });
    });
</script>
</html>