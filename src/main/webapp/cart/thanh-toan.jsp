<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"
          crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<main>
    <section class="checkout-page">
        <div class="container">
            <h1 class="checkout-title">Thanh toán</h1>

            <c:if test="${not empty errorMessage}">
                <div style="padding: 12px; background: #f8d7da; color: #721c24; border-radius: 8px; margin-bottom: 18px;">
                        ${errorMessage}
                </div>
            </c:if>

            <form class="checkout-form" action="thanh-toan" method="post" id="checkoutForm">
                <input type="hidden" id="hiddenSubtotal" value="${subtotal}">
                <input type="hidden" id="selectedCouponId" name="selectedCouponId">
                <input type="hidden" id="manualCouponCode" name="manualCouponCode">
                <input type="hidden" id="hiddenCouponDiscount" value="0">

                <div class="checkout-layout">
                    <div class="checkout-left">
                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Thông tin giao hàng</h2>

                            <div class="address-book-box">
                                <h3 style="font-size: 16px; margin-bottom: 15px; color: #333;">Sổ địa chỉ</h3>

                                <div class="address-list">
                                    <c:forEach var="addr" items="${addresses}">
                                        <label class="address-option">
                                            <input type="radio"
                                                   name="selectedAddress"
                                                   value="${addr.id}"
                                                   data-province="${addr.province}"
                                                ${addr.isDefault ? 'checked' : ''}>

                                            <div class="address-content">
                                                <strong class="address-label">${addr.label}</strong>
                                                <div class="address-detail">
                                                    <span>${addr.fullName} - ${addr.phoneNumber}</span><br>
                                                    <span>${addr.streetAddress}<c:if test="${not empty addr.ward}">, ${addr.ward}</c:if><c:if test="${not empty addr.district}">, ${addr.district}</c:if>, ${addr.province}</span>
                                                </div>
                                                <c:if test="${addr.isDefault}">
                                                    <span class="badge-default">Mặc định</span>
                                                </c:if>
                                            </div>
                                        </label>
                                    </c:forEach>

                                    <label class="address-option">
                                        <input type="radio"
                                               name="selectedAddress"
                                               value="new"
                                        ${empty addresses ? 'checked' : ''}>

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
                                        <input type="text"
                                               id="fullName"
                                               name="fullName"
                                               placeholder="Nguyễn Văn A"
                                               required
                                               minlength="2"
                                               title="Vui lòng nhập họ tên hợp lệ">
                                    </div>
                                    <div class="form-field">
                                        <label for="phoneNumber">Số điện thoại <span class="required">*</span></label>
                                        <input type="tel"
                                               id="phoneNumber"
                                               name="phoneNumber"
                                               placeholder="0888 531 015"
                                               required
                                               pattern="^(0[3|5|7|8|9])+([0-9]{8})$"
                                               title="Số điện thoại phải bắt đầu bằng 0 và gồm 10 chữ số">
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-field">
                                        <label for="province">Tỉnh / Thành phố <span class="required">*</span></label>
                                        <select id="province" name="province" required>
                                            <option value="">-- Chọn Tỉnh / Thành phố --</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="form-row form-row--2">
                                    <div class="form-field">
                                        <label for="district">Quận / Huyện <span class="required">*</span></label>
                                        <select id="district" name="district" disabled required>
                                            <option value="">-- Chọn Quận / Huyện --</option>
                                        </select>
                                    </div>
                                    <div class="form-field">
                                        <label for="ward">Phường / Xã <span class="required">*</span></label>
                                        <select id="ward" name="ward" disabled required>
                                            <option value="">-- Chọn Phường / Xã --</option>
                                        </select>
                                    </div>
                                </div>

                                <input type="hidden" id="districtId" name="districtId">
                                <input type="hidden" id="wardCode" name="wardCode">

                                <div class="form-row">
                                    <div class="form-field">
                                        <label for="addressLine">Địa chỉ cụ thể <span class="required">*</span></label>
                                        <input type="text"
                                               id="addressLine"
                                               name="addressLine"
                                               placeholder="Số nhà, tên đường, tòa nhà..."
                                               required>
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
                                    <textarea id="note"
                                              name="note"
                                              rows="3"
                                              placeholder="Ví dụ: Gọi trước khi giao, giao giờ hành chính,..."></textarea>
                                </div>
                            </div>
                        </div>

                        <c:if test="${sessionScope.user != null && sessionScope.user.isVip}">
                            <div class="checkout-card vip-voucher-card">
                                <h2 class="checkout-card__title">💎 Voucher Khách Hàng VIP</h2>

                                <div class="vip-voucher-section">
                                    <label class="checkbox-field">
                                        <input type="checkbox" id="applyVipVoucher" name="applyVipVoucher" value="true">
                                        <span style="font-weight: 500;">Áp dụng voucher VIP để giảm giá thêm</span>
                                    </label>

                                    <div id="vipVoucherOptions" style="display: none; margin-top: 15px;">
                                        <div class="form-field">
                                            <label for="selectedVoucher" style="font-weight: 500;">Chọn voucher:</label>
                                            <select id="selectedVoucher" name="selectedVoucher" class="form-control">
                                                <option value="">-- Không áp dụng voucher --</option>
                                                <c:forEach var="voucher" items="${userVipVouchers}">
                                                    <option value="${voucher.id}"
                                                            data-discount="${voucher.discountValue}"
                                                            data-type="${voucher.discountType}">
                                                            ${voucher.code}
                                                        <c:if test="${voucher.discountType == 'PERCENT'}">
                                                            - Giảm ${voucher.discountValue}%
                                                        </c:if>
                                                        <c:if test="${voucher.discountType == 'FIXED_AMOUNT'}">
                                                            - Giảm <fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>đ
                                                        </c:if>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </div>

                                        <div id="vipDiscountInfo"
                                             style="margin-top: 15px; padding: 12px; background: #fff9c4; border-radius: 6px; border-left: 4px solid #ffd54f; display: none;">
                                            <p style="margin: 0; font-size: 0.95rem; color: #333;">
                                                <strong>Giảm giá VIP:</strong>
                                                <span id="vipDiscountDisplay" style="color: #ff6f00; font-weight: bold;">0đ</span>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <div class="checkout-card coupon-checkout-card">
                            <h2 class="checkout-card__title">🎟️ Mã giảm giá</h2>

                            <div class="coupon-checkout-section">
                                <div class="form-field">
                                    <label for="selectedCoupon">Chọn mã đã nhận:</label>

                                    <c:choose>
                                        <c:when test="${not empty userCoupons}">
                                            <select id="selectedCoupon" class="form-control">
                                                <option value="">-- Không áp dụng mã --</option>

                                                <c:forEach var="coupon" items="${userCoupons}">
                                                    <option value="${coupon.id}"
                                                            data-code="${coupon.code}"
                                                            data-type="${coupon.discountType}"
                                                            data-discount="${coupon.discountValue}"
                                                            data-max-discount="${coupon.maxDiscountAmount}"
                                                            data-min-order="${coupon.minOrderAmount}">
                                                            ${coupon.code} -

                                                        <c:if test="${coupon.discountType == 'PERCENT'}">
                                                            Giảm ${coupon.discountValue}%
                                                            <c:if test="${coupon.maxDiscountAmount != null}">
                                                                tối đa <fmt:formatNumber value="${coupon.maxDiscountAmount}" pattern="#,###"/>đ
                                                            </c:if>
                                                        </c:if>

                                                        <c:if test="${coupon.discountType == 'FIXED_AMOUNT'}">
                                                            Giảm <fmt:formatNumber value="${coupon.discountValue}" pattern="#,###"/>đ
                                                        </c:if>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </c:when>

                                        <c:otherwise>
                                            <div style="padding: 12px; background: #f8f9fa; border-radius: 8px; color: #666;">
                                                Bạn chưa có mã ưu đãi nào.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div style="margin: 15px 0; text-align: center; color: #777;">
                                    hoặc
                                </div>

                                <div class="form-field">
                                    <label for="couponCodeInput">Nhập mã giảm giá:</label>

                                    <div style="display: flex; gap: 10px;">
                                        <input type="text"
                                               id="couponCodeInput"
                                               class="form-control"
                                               placeholder="Ví dụ: MOCTRA50"
                                               style="text-transform: uppercase;">

                                        <button type="button"
                                                id="btnApplyCoupon"
                                                class="btn btn-primary"
                                                style="white-space: nowrap; border: none;">
                                            Áp dụng
                                        </button>
                                    </div>
                                </div>

                                <div id="couponCheckoutMessage"
                                     style="display: none; margin-top: 12px; padding: 10px 12px; border-radius: 8px; font-size: 0.92rem;">
                                </div>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <div class="checkout-card">
                                <h2 class="checkout-card__title">Phương thức giao hàng</h2>

                                <div class="shipping-methods">
                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="standard" data-price="0" checked>

                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Tiêu chuẩn</span>
                                                <span class="shipping-option__price">+ 0đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 3-5 ngày làm việc.</div>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="express" data-price="15000">
                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Nhanh</span>
                                                <span class="shipping-option__price">+ 15.000đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 1-2 ngày làm việc.</div>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="instant" data-price="30000">
                                        <div class="shipping-option__content">
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Hỏa tốc</span>
                                                <span class="shipping-option__price">+ 30.000đ</span>
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
                                <c:forEach var="item" items="${requestScope.checkoutItems}">
                                    <div class="order-item">
                                        <div class="order-item__thumb">
                                            <img src="${item.product.imageUrl}" alt="${item.product.name}">
                                        </div>
                                        <div class="order-item__info">
                                            <div class="order-item__name">${item.product.name}</div>
                                            <c:if test="${not empty item.variant}">
                                                <div class="order-item__variant" style="font-size: 0.85em; color: #666; margin-top: 3px;">
                                                    Phân loại: ${item.variant.variantName}
                                                </div>
                                            </c:if>
                                            <div class="order-item__meta" style="margin-top: 5px;">Số lượng: ${item.quantity}</div>
                                        </div>
                                        <div class="order-item__price" style="text-align: right; min-width: 160px;">
                                            <div style="font-size: 0.85rem; color: #666;">
                                                Giá gốc:
                                                <fmt:formatNumber value="${item.originalUnitPrice}" pattern="#,###"/>đ
                                                x ${item.quantity}
                                                =
                                                <fmt:formatNumber value="${item.totalOriginalPrice}" pattern="#,###"/>đ
                                            </div>

                                            <div style="font-size: 0.85rem; color: #2e7d32; font-weight: 600;">
                                                Khuyến mãi:
                                                <c:choose>
                                                    <c:when test="${item.totalDiscount > 0}">
                                                        -
                                                        <fmt:formatNumber value="${item.totalDiscount}" pattern="#,###"/>đ
                                                    </c:when>
                                                    <c:otherwise>
                                                        0đ
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div style="font-size: 1rem; color: #d9534f; font-weight: bold; margin-top: 4px;">
                                                <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/>đ
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="order-summary">
                                <div class="order-summary__row">
                                    <span>Tạm tính</span>
                                    <span>
                                        <fmt:formatNumber value="${subtotal}" pattern="#,###"/>đ
                                    </span>
                                </div>

                                <div class="order-summary__row">
                                    <span>Phí vận chuyển</span>
                                    <span id="shippingFeeDisplay">
                                        <fmt:formatNumber value="${shippingFee}" pattern="#,###"/>đ
                                    </span>
                                </div>

                                <div class="order-summary__row" id="couponDiscountRow" style="display: none;">
                                    <span>Giảm mã ưu đãi</span>
                                    <span id="couponDiscountAmount" style="color: #d32f2f;">-0đ</span>
                                </div>

                                <div class="order-summary__row" id="vipDiscountRow" style="display: none;">
                                    <span>Giảm voucher VIP</span>
                                    <span id="vipDiscountAmount" style="color: #d32f2f;">-0đ</span>
                                </div>

                                <div class="order-summary__row order-summary__row--total">
                                    <span>Tổng cộng</span>
                                    <span id="totalAmountDisplay">
                                        <fmt:formatNumber value="${totalAmount}" pattern="#,###"/>đ
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <h2 class="checkout-card__title">Phương thức thanh toán</h2>
                            <div class="payment-methods">
                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="momo">
                                    <div class="payment-option__content">
                                        <span class="payment-option__name">
                                            <i class="fa-solid fa-wallet"></i> Ví MoMo
                                        </span>
                                        <p class="payment-option__desc">
                                            Thanh toán bằng ví MoMo. Hệ thống sẽ tạo mã QR hoặc link thanh toán.
                                        </p>
                                    </div>
                                </label>

                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="cod">

                                    <div class="payment-option__content">
                                        <span class="payment-option__name">
                                            <i class="fa-solid fa-box"></i> Thanh toán khi nhận hàng (COD)
                                        </span>

                                        <p class="payment-option__desc">Bạn thanh toán trực tiếp cho shipper khi nhận hàng.</p>
                                    </div>
                                </label>
                                <label class="payment-option">
                                    <input type="radio" name="paymentMethod" value="bank">
                                    <div class="payment-option__content">
                                        <span class="payment-option__name">
                                            <i class="fa-solid fa-building-columns"></i> Chuyển khoản ngân hàng
                                        </span>
                                        <p class="payment-option__desc">
                                            Hệ thống sẽ tạo mã QR ngân hàng để bạn thanh toán.
                                        </p>
                                    </div>
                                </label>
                            </div>
                        </div>

                        <div class="checkout-submit">
                            <button type="submit" class="btn btn-primary checkout-submit__btn" id="btnSubmitOrder">
                                Thanh toán
                                <span id="btnTotalDisplay">
                                    <fmt:formatNumber value="${totalAmount}" pattern="#,###"/>đ
                                </span>
                            </button>
                            <p class="checkout-submit__note">
                                Bằng cách nhấn "Thanh toán", bạn đồng ý với
                                <a href="${pageContext.request.contextPath}/dieu-khoan-dich-vu">Điều khoản dịch vụ</a> của Mộc Trà.
                            </p>
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
</body>
<script src="${pageContext.request.contextPath}/assets/js/ghn-address-selector.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const addressRadios    = document.querySelectorAll('input[name="selectedAddress"]');
        const manualAddressForm = document.querySelector(".manual-address");
        const manualInputs     = manualAddressForm ? manualAddressForm.querySelectorAll("input:not([type=hidden]), textarea, select") : [];
        const provinceSelect   = document.getElementById("province");
        const districtSelect   = document.getElementById("district");
        const wardSelect       = document.getElementById("ward");
        const districtIdInput  = document.getElementById("districtId");
        const wardCodeInput    = document.getElementById("wardCode");

        const shippingRadios       = document.querySelectorAll('input[name="shippingMethod"]');
        const subtotal             = parseFloat(document.getElementById('hiddenSubtotal').value) || 0;
        const shippingFeeDisplay   = document.getElementById('shippingFeeDisplay');
        const totalAmountDisplay   = document.getElementById('totalAmountDisplay');
        const btnTotalDisplay      = document.getElementById('btnTotalDisplay');
        const applyVipCheckbox     = document.getElementById('applyVipVoucher');
        const vipVoucherOptions    = document.getElementById('vipVoucherOptions');
        const selectedVoucherSelect = document.getElementById('selectedVoucher');
        const vipDiscountRow       = document.getElementById('vipDiscountRow');
        const vipDiscountAmount    = document.getElementById('vipDiscountAmount');
        const checkoutForm         = document.getElementById("checkoutForm");
        const SHIPPING_API_URL     = "${pageContext.request.contextPath}/api/get-shipping-fee";

        let provinceFee = 0, serviceFee = 0;


        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
        }

        function showCouponCheckoutMessage(message, type) {
            if (!couponCheckoutMessage) {
                return;
            }

            couponCheckoutMessage.innerText = message;
            couponCheckoutMessage.style.display = 'block';

            if (type === 'success') {
                couponCheckoutMessage.style.background = '#d4edda';
                couponCheckoutMessage.style.color = '#155724';
            } else {
                couponCheckoutMessage.style.background = '#f8d7da';
                couponCheckoutMessage.style.color = '#721c24';
            }
        }

        function clearCoupon() {
            if (selectedCouponIdInput) {
                selectedCouponIdInput.value = '';
            }

            if (manualCouponCodeInput) {
                manualCouponCodeInput.value = '';
            }

            if (hiddenCouponDiscount) {
                hiddenCouponDiscount.value = '0';
            }

            if (couponDiscountRow) {
                couponDiscountRow.style.display = 'none';
            }

            if (couponDiscountAmount) {
                couponDiscountAmount.innerText = '-0đ';
            }

            updateTotal();
        }

        function getCouponDiscountAmount() {
            if (!hiddenCouponDiscount) {
                return 0;
            }

            return parseFloat(hiddenCouponDiscount.value) || 0;
        }

        function applyCouponByAjax(couponId, couponCode) {
            let body = "";

            if (couponId) {
                body = "couponId=" + encodeURIComponent(couponId);
            } else if (couponCode) {
                body = "couponCode=" + encodeURIComponent(couponCode);
            }

            fetch("${pageContext.request.contextPath}/ap-dung-ma-giam-gia", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                    "X-Requested-With": "XMLHttpRequest"
                },
                body: body
            })
                .then(function (response) {
                    return response.json();
                })
                .then(function (data) {
                    if (!data.success) {
                        clearCoupon();
                        showCouponCheckoutMessage(data.message || "Mã giảm giá không hợp lệ.", "error");
                        return;
                    }

                    if (selectedCouponIdInput) {
                        selectedCouponIdInput.value = data.couponId || '';
                    }

                    if (manualCouponCodeInput) {
                        manualCouponCodeInput.value = couponCode || '';
                    }

                    if (hiddenCouponDiscount) {
                        hiddenCouponDiscount.value = data.discountAmount || 0;
                    }

                    if (couponDiscountRow) {
                        couponDiscountRow.style.display = 'flex';
                    }

                    if (couponDiscountAmount) {
                        couponDiscountAmount.innerText = '-' + formatCurrency(data.discountAmount || 0);
                    }

                    showCouponCheckoutMessage(data.message || "Áp dụng mã giảm giá thành công.", "success");

                    updateTotal();
                })
                .catch(function () {
                    clearCoupon();
                    showCouponCheckoutMessage("Không thể áp dụng mã giảm giá. Vui lòng thử lại.", "error");
                });
        }

        async function fetchProvinceFee(provinceName) {
            if (!provinceName) { provinceFee = 0; updateTotal(); return; }
            try {
                const res = await fetch(SHIPPING_API_URL + "?province=" + encodeURIComponent(provinceName));
                const data = await res.json();
                provinceFee = parseFloat(data.provinceFee) || 0;
            } catch (e) {
                provinceFee = 30000;
            }
            updateTotal();
        }

        function updateServiceFee() {
            const s = document.querySelector('input[name="shippingMethod"]:checked');
            serviceFee = s ? (parseFloat(s.getAttribute('data-price')) || 0) : 0;
            updateTotal();
        }

        function getVipDiscountAmount() {
            if (!applyVipCheckbox || !applyVipCheckbox.checked || !selectedVoucherSelect || !selectedVoucherSelect.value) return 0;
            const opt = selectedVoucherSelect.options[selectedVoucherSelect.selectedIndex];
            const type = opt.getAttribute('data-type');
            const val  = parseFloat(opt.getAttribute('data-discount')) || 0;
            return Math.min(type === 'PERCENT' ? subtotal * val / 100 : val, subtotal);
        }

        function updateTotal() {
            const vipDiscount = getVipDiscountAmount();
            const totalShipping = provinceFee + serviceFee;
            const newTotal = Math.max(0, subtotal - vipDiscount + totalShipping);

            shippingFeeDisplay.innerText = formatCurrency(totalShipping);
            totalAmountDisplay.innerText = formatCurrency(newTotal);
            btnTotalDisplay.innerText = formatCurrency(newTotal);

            if (vipDiscount > 0) {
                vipDiscountRow.style.display = 'flex';
                vipDiscountAmount.innerText = '-' + formatCurrency(vipDiscount);
            } else {
                vipDiscountRow.style.display = 'none';
            }
        }

        function updateFormState() {
            const selected = document.querySelector('input[name="selectedAddress"]:checked');
            if (!selected) return;

            if (selected.value === "new") {
                manualAddressForm.classList.remove("disabled");
                manualInputs.forEach(input => {
                    if (input.id !== "ward") {
                        input.disabled = false;
                    }
                });

                if (provinceSelect.value !== "") {
                    wardSelect.disabled = false;
                }

                fetchProvinceFee(provinceSelect.value);
            } else {
                manualAddressForm.classList.add("disabled");
                manualInputs.forEach(input => { input.disabled = true; });
                const province = selected.getAttribute('data-province');
                fetchProvinceFee(province);
            }
        }

        // Khởi tạo GHN address selector
        GHNAddressSelector.init({
            provinceEl:   provinceSelect,
            districtEl:   districtSelect,
            wardEl:       wardSelect,
            districtIdEl: districtIdInput,
            wardCodeEl:   wardCodeInput,
            contextPath:  "${pageContext.request.contextPath}",
            onProvinceChange: function(provinceName) {
                fetchProvinceFee(provinceName);
            }
        });

        addressRadios.forEach(r => r.addEventListener("change", updateFormState));
        shippingRadios.forEach(r => r.addEventListener("change", updateServiceFee));

        if (applyVipCheckbox) {
            applyVipCheckbox.addEventListener('change', function () {
                vipVoucherOptions.style.display = this.checked ? 'block' : 'none';
                if (!this.checked && selectedVoucherSelect) selectedVoucherSelect.value = '';
                updateTotal();
            });
        }
        if (selectedVoucherSelect) {
            selectedVoucherSelect.addEventListener('change', updateTotal);
        }

        if (selectedCouponSelect) {
            selectedCouponSelect.addEventListener('change', function () {
                const couponId = this.value;

                if (!couponId) {
                    clearCoupon();
                    return;
                }

                if (couponCodeInput) {
                    couponCodeInput.value = '';
                }

                applyCouponByAjax(couponId, '');
            });
        }

        if (btnApplyCoupon) {
            btnApplyCoupon.addEventListener('click', function () {
                const code = couponCodeInput ? couponCodeInput.value.trim().toUpperCase() : '';

                if (!code) {
                    showCouponCheckoutMessage("Vui lòng nhập mã giảm giá.", "error");
                    return;
                }

                if (couponCodeInput) {
                    couponCodeInput.value = code;
                }

                if (selectedCouponSelect) {
                    selectedCouponSelect.value = '';
                }

                applyCouponByAjax('', code);
            });
        }

        if (checkoutForm) {
            checkoutForm.addEventListener("submit", function (e) {
                const selected = document.querySelector('input[name="selectedAddress"]:checked');
                if (selected && selected.value === "new") {
                    if (!districtIdInput.value || !wardCodeInput.value) {
                        e.preventDefault();
                        alert("Vui lòng chọn đầy đủ Quận/Huyện và Phường/Xã để hệ thống tính phí giao hàng chính xác!");
                        return;
                    }
                }

                const selectedPayment = document.querySelector('input[name="paymentMethod"]:checked');
                if (!selectedPayment) {
                    e.preventDefault();
                    alert("Vui lòng chọn phương thức thanh toán!");
                    return;
                }

                let paymentText = "Thanh toán khi nhận hàng (COD)";
                if (selectedPayment.value === "momo") paymentText = "Ví MoMo";
                else if (selectedPayment.value === "bank") paymentText = "Chuyển khoản ngân hàng";

                const totalText = btnTotalDisplay.innerText.trim();
                if (!confirm("Xác nhận thanh toán đơn hàng?\n\nSố tiền: " + totalText + "\nPhương thức: " + paymentText)) {
                    e.preventDefault();
                }
            });
        }

        updateServiceFee();
        updateFormState();
    });
</script>
</body>
</html>
