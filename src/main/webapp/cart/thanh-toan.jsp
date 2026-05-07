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

            <form class="checkout-form" action="thanh-toan" method="post">
                <input type="hidden" name="action" id="formAction" value="checkout">
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
                                            <input type="radio" name="selectedAddress" value="${addr.id}"
                                                ${(param.selectedAddress == addr.id || (empty param.selectedAddress && addr.isDefault)) ? 'checked' : ''}>
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
                                        <input type="text" id="fullName" name="fullName" value="${param.fullName}" data-required required>
                                    </div>
                                    <div class="form-field">
                                        <label for="phoneNumber">Số điện thoại <span class="required">*</span></label>
                                        <input type="tel" id="phoneNumber" name="phoneNumber" value="${param.phoneNumber}" data-required required>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-field">
                                        <label for="addressLine">Địa chỉ cụ thể <span class="required">*</span></label>
                                        <input type="text" id="addressLine" name="addressLine" value="${param.addressLine}" placeholder="Số nhà, tên đường, tòa nhà..." data-required required>
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
                                    <textarea id="note" name="note" rows="3" placeholder="...">${param.note}</textarea>
                                </div>
                            </div>
                        </div>

                        <!-- VIP Voucher Section -->
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

                                        <div id="vipDiscountInfo" style="margin-top: 15px; padding: 12px; background: #fff9c4; border-radius: 6px; border-left: 4px solid #ffd54f; display: none;">
                                            <p style="margin: 0; font-size: 0.95rem; color: #333;">
                                                <strong>Giảm giá VIP:</strong>
                                                <span id="vipDiscountDisplay" style="color: #ff6f00; font-weight: bold;">0đ</span>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <div class="checkout-card">

                            <div class="checkout-card">
                                <h2 class="checkout-card__title">Phương thức giao hàng</h2>

                                <div class="shipping-methods">
                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="standard"
                                               data-price="0" checked>
                                        <div>
                                            <div class="shipping-option__top">
                                                <span class="shipping-option__name">Tiêu chuẩn</span>
                                                <span class="shipping-option__price">+ 0đ</span>
                                            </div>
                                            <div class="shipping-option__desc">Giao trong 3-5 ngày làm việc.</div>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="express" data-price="15000">
                                        <div class="shipping-option__top">
                                            <span class="shipping-option__name">Nhanh</span>
                                            <span class="shipping-option__price">+ 15.000đ</span>
                                        </div>
                                    </label>

                                    <label class="shipping-option">
                                        <input type="radio" name="shippingMethod" value="instant" data-price="30000">
                                        <div class="shipping-option__top">
                                            <span class="shipping-option__name">Hỏa tốc</span>
                                            <span class="shipping-option__price">+ 30.000đ</span>
                                        </div>
                                    </label>
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
                                                <fmt:formatNumber value="${item.originalUnitPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                x ${item.quantity}
                                                =
                                                <fmt:formatNumber value="${item.totalOriginalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>

                                            <div style="font-size: 0.85rem; color: #2e7d32; font-weight: 600;">
                                                Khuyến mãi:
                                                <c:choose>
                                                    <c:when test="${item.totalDiscount > 0}">
                                                        -
                                                        <fmt:formatNumber value="${item.totalDiscount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        0đ
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div style="font-size: 1rem; color: #d9534f; font-weight: bold; margin-top: 4px;">
                                                <fmt:formatNumber value="${item.totalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="order-summary">
                                <div class="order-summary__row">
                                    <span>Tạm tính</span>
                                    <span><fmt:formatNumber value="${subtotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>

                                <div class="order-summary__row">
                                    <span>Phí vận chuyển (vùng)</span>
                                    <span><fmt:formatNumber value="${baseProvinceFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>

                                <c:set var="extraFee" value="0"/>
                                <c:choose>
                                    <c:when test="${param.shippingMethod == 'express'}"><c:set var="extraFee" value="15000"/></c:when>
                                    <c:when test="${param.shippingMethod == 'instant'}"><c:set var="extraFee" value="30000"/></c:when>
                                </c:choose>

                                <div class="order-summary__row" id="extraFeeRow" style="display: none;">
                                    <span>Phí dịch vụ cộng thêm</span>
                                    <span style="color: #2e7d32;" id="extraFeeValue"></span>
                                </div>

                                <div class="order-summary__row order-summary__row--total">
                                    <span>Tổng cộng</span>
                                    <span style="color: #d32f2f; font-weight: bold; font-size: 1.2rem;">
                                        <fmt:formatNumber value="${subtotal + baseProvinceFee + extraFee - (vipDiscount != null ? vipDiscount : 0)}"
                                                          type="currency" currencySymbol="đ" maxFractionDigits="0"/>
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
                                        <span class="payment-option__name"><i class="fa-solid fa-box"></i> Thanh toán khi nhận hàng (COD)</span>
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
                            <button type="submit" class="btn btn-primary checkout-submit__btn"
                                    onclick="document.getElementById('formAction').value='checkout';"
                                    id="btnSubmitOrder">
                                Thanh toán
                                <span id="btnTotalDisplay">
                                    <fmt:formatNumber value="${subtotal + baseProvinceFee + extraFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </button>
                            <p class="checkout-submit__note">
                                Bằng cách nhấn "Thanh toán", bạn đồng ý với
                                <a href="${pageContext.request.contextPath}/dieu-khoan-dich-vu">Điều khoản dịch vụ</a> của Mộc Trà.
                            </p>
                        </div>
                    </div>
                </div>
                    <c:forEach var="item" items="${checkoutItems}">
                    <input type="hidden" name="selectedItems" value="${item.variantId}">
                    </c:forEach>
            </form>
        </div>
    </section>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const addressRadios = document.querySelectorAll('input[name="selectedAddress"]');
        const manualAddressForm = document.querySelector(".manual-address");
        const manualInputs = manualAddressForm.querySelectorAll("input, textarea, select");
        const provinceSelect = document.getElementById("province");
        const wardSelect = document.getElementById("ward");

        const shippingRadios = document.querySelectorAll('input[name="shippingMethod"]');
        const subtotal = parseFloat(document.getElementById('hiddenSubtotal').value) || 0;
        const shippingFeeDisplay = document.getElementById('shippingFeeDisplay');
        const totalAmountDisplay = document.getElementById('totalAmountDisplay');
        const btnTotalDisplay = document.getElementById('btnTotalDisplay');

        const applyVipCheckbox = document.getElementById('applyVipVoucher');
        const vipVoucherOptions = document.getElementById('vipVoucherOptions');
        const selectedVoucherSelect = document.getElementById('selectedVoucher');
        const vipDiscountInfo = document.getElementById('vipDiscountInfo');
        const vipDiscountDisplay = document.getElementById('vipDiscountDisplay');

        const DATA_URL = "${pageContext.request.contextPath}/assets/data/openapi.json";
        let provincesData = [];

        function formatCurrency(amount) {
            return new Intl.NumberFormat('vi-VN', {
                style: 'currency',
                currency: 'VND'
            }).format(amount);
        }

        function getSelectedShippingPrice() {
            const selectedShip = document.querySelector('input[name="shippingMethod"]:checked');
            return selectedShip ? parseFloat(selectedShip.getAttribute('data-price')) || 0 : 0;
        }

        const vipDiscountRow = document.getElementById('vipDiscountRow');
        const vipDiscountAmount = document.getElementById('vipDiscountAmount');

        function getVipDiscountAmount() {
            if (!applyVipCheckbox || !applyVipCheckbox.checked || !selectedVoucherSelect || !selectedVoucherSelect.value) {
                return 0;
            }

            const option = selectedVoucherSelect.options[selectedVoucherSelect.selectedIndex];
            const discountType = option.getAttribute('data-type');
            const discountValue = parseFloat(option.getAttribute('data-discount')) || 0;

            let discount = 0;
            if (discountType === 'PERCENT') {
                discount = subtotal * discountValue / 100;
            } else if (discountType === 'FIXED_AMOUNT') {
                discount = discountValue;
            }

            if (discount > subtotal) {
                discount = subtotal;
            }

            return discount;
        }

        // Thêm sự kiện lắng nghe cho các radio ship
        document.querySelectorAll('input[name="shippingMethod"]').forEach(radio => {
            radio.addEventListener('change', updateTotal);
        });

        document.getElementById('btnSubmitOrder').addEventListener('click', function() {
            if (this.form.checkValidity()) {
                this.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Đang xử lý...';
                this.style.pointerEvents = 'none';
                this.style.opacity = '0.7';
            }
        });

        function updateTotal() {
            const baseProvinceFee = parseFloat("${baseProvinceFee}") || 0;
            const subtotal = parseFloat(document.getElementById('hiddenSubtotal').value) || 0;
            const selectedShip = document.querySelector('input[name="shippingMethod"]:checked');
            const extraFee = parseFloat(selectedShip.getAttribute('data-price')) || 0;

            const totalShipping = baseProvinceFee + extraFee;
            const finalTotal = subtotal + totalShipping;

            // 1. Cập nhật số tiền trên nút bấm
            document.getElementById('btnTotalDisplay').innerText = formatCurrency(finalTotal);

            // 2. Cập nhật Phí dịch vụ cộng thêm ở phần Tóm tắt (Summary)
            const extraFeeRow = document.getElementById('extraFeeRow');
            const extraFeeValue = document.getElementById('extraFeeValue');
            if (extraFee > 0) {
                extraFeeRow.style.display = 'flex';
                extraFeeValue.innerText = '+ ' + formatCurrency(extraFee);
            } else {
                extraFeeRow.style.display = 'none';
            }

            // 3. Cập nhật Tổng cộng cuối cùng ở phần Tóm tắt
            const totalAmountSpan = document.querySelector('.order-summary__row--total span:last-child');
            if (totalAmountSpan) {
                totalAmountSpan.innerText = formatCurrency(finalTotal);
            }
        }

        function updateFormState() {
            const selected = document.querySelector('input[name="selectedAddress"]:checked');
            const isNew = (selected && selected.value === "new");

            if (isNew) {
                manualAddressForm.classList.remove("disabled");
                manualInputs.forEach(input => {
                    input.disabled = false;
                    // Nếu input có đánh dấu data-required thì bật required lên
                    if (input.hasAttribute('data-required')) {
                        input.required = true;
                    }
                });
            } else {
                manualAddressForm.classList.add("disabled");
                manualInputs.forEach(input => {
                    input.disabled = true;
                    // Khi chọn địa chỉ có sẵn, phải TẮT required đi thì mới Submit được
                    input.required = false;
                });
            }
        }

        async function loadData() {
            try {
                const response = await fetch(DATA_URL);
                provincesData = await response.json();
                provincesData.forEach(p => {
                    const option = document.createElement("option");
                    option.value = p.name;
                    option.dataset.code = p.code;
                    option.textContent = p.name;
                    // GIỮ LẠI TỈNH CŨ
                    if (p.name === "${param.province}") option.selected = true;
                    provinceSelect.appendChild(option);
                });

                // NẾU CÓ TỈNH CŨ THÌ LOAD TIẾP PHƯỜNG CŨ
                if (provinceSelect.value !== "") {
                    provinceSelect.dispatchEvent(new Event('change'));
                    setTimeout(() => {
                        wardSelect.value = "${param.ward}";
                        // Kích hoạt lại trạng thái disabled nếu cần
                        updateFormState();
                    }, 200);
                }
            } catch (error) {
                console.error("Lỗi khi tải dữ liệu địa giới:", error);
            }
        }

        addressRadios.forEach(radio => {
            radio.addEventListener("change", updateFormState);
        });
        shippingRadios.forEach(radio => {
            radio.addEventListener("change", updateTotal);
        });

        provinceSelect.addEventListener("change", function () {
            wardSelect.innerHTML = '<option value="">-- Chọn phường / xã --</option>';
            wardSelect.disabled = true;

            const selectedOption = this.options[this.selectedIndex];
            const provinceCode = parseInt(selectedOption.dataset.code);

            if (!provinceCode) return;
            const selectedProvince = provincesData.find(p => p.code === provinceCode);

            if (selectedProvince && selectedProvince.wards && selectedProvince.wards.length > 0) {
                selectedProvince.wards.forEach(w => {
                    const option = document.createElement("option");
                    option.value = w.name;
                    option.textContent = w.name;
                    wardSelect.appendChild(option);
                });
                const selectedRadio = document.querySelector('input[name="selectedAddress"]:checked');
                if (selectedRadio && selectedRadio.value === "new") {
                    wardSelect.disabled = false;
                }
            }
        });

        if (applyVipCheckbox) {
            applyVipCheckbox.addEventListener('change', function () {
                if (this.checked) {
                    vipVoucherOptions.style.display = 'block';
                } else {
                    vipVoucherOptions.style.display = 'none';
                    selectedVoucherSelect.value = '';
                }
                updateTotal();
            });
        }

        if (selectedVoucherSelect) {
            selectedVoucherSelect.addEventListener('change', updateTotal);
        }

        updateFormState();
        updateTotal();
        loadData();
    });
</script>
</html>