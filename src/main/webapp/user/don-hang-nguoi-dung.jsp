<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Gần Đây - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/my-orders.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="user-dashboard-page">
<jsp:include page="/common/header.jsp"></jsp:include>
<div class="container">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="don-hang"/>
    </jsp:include>

    <main class="main-content">
        <c:if test="${not empty sessionScope.msg}">
            <div class="alert alert-${sessionScope.msgType}">
                    ${sessionScope.msg}
            </div>
            <% session.removeAttribute("msg"); session.removeAttribute("msgType"); %>
        </c:if>

        <div class="orders-header">
            <h2 class="page-title" style="margin-bottom: 0;">Đơn Hàng Gần Đây</h2>
            <div class="orders-filter">
                <button class="filter-btn active" data-status="all">Tất cả</button>
                <button class="filter-btn" data-status="pending">Chờ xử lý</button>
                <button class="filter-btn" data-status="shipping">Đang giao</button>
                <button class="filter-btn" data-status="completed">Hoàn thành</button>
                <button class="filter-btn" data-status="cancelled">Đã hủy</button>
            </div>
        </div>

        <div class="orders-list">
            <c:if test="${not empty orders}">
                <c:forEach var="o" items="${orders}">
                    <c:set var="statusStr" value="${o.status.toString()}" />
                    <c:set var="refund" value="${refundByOrderId[o.id]}" />
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
                        <c:when test="${statusStr == 'SHIPPING'}">
                            <c:set var="statusClass" value="status-shipping" />
                            <c:set var="statusText" value="Đang giao hàng" />
                        </c:when>
                        <c:when test="${statusStr == 'DELIVERY_FAILED'}">
                            <c:set var="statusClass" value="status-delivery-failed" />
                            <c:set var="statusText" value="Giao thất bại" />
                        </c:when>
                    </c:choose>

                    <c:choose>
                        <c:when test="${statusStr == 'PENDING'}">
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="active" />
                            <c:set var="tl3" value="" />
                            <c:set var="tl4" value="" />
                        </c:when>
                        <c:when test="${statusStr == 'SHIPPING'}">
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="done" />
                            <c:set var="tl3" value="active" />
                            <c:set var="tl4" value="" />
                        </c:when>
                        <c:when test="${statusStr == 'COMPLETED'}">
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="done" />
                            <c:set var="tl3" value="done" />
                            <c:set var="tl4" value="done" />
                        </c:when>
                        <c:when test="${statusStr == 'CANCELLED'}">
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="" />
                            <c:set var="tl3" value="" />
                            <c:set var="tl4" value="cancelled" />
                        </c:when>
                        <c:when test="${statusStr == 'DELIVERY_FAILED'}">
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="done" />
                            <c:set var="tl3" value="done" />
                            <c:set var="tl4" value="failed" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="tl1" value="done" />
                            <c:set var="tl2" value="active" />
                            <c:set var="tl3" value="" />
                            <c:set var="tl4" value="" />
                        </c:otherwise>
                    </c:choose>

                    <div class="order-card" data-status="${fn:toLowerCase(statusStr)}">
                        <div class="order-card-header">
                            <div class="order-card-meta">
                                <div class="order-number">
                                    <i class="fa-solid fa-receipt" style="font-size:13px; margin-right:4px;"></i>
                                    Đơn hàng #${o.orderNumber}
                                </div>
                                <div class="order-date">
                                    <i class="fa-regular fa-calendar"></i>
                                    <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy, HH:mm"/>
                                </div>
                            </div>
                            <div class="order-status">
                                <span class="status-badge ${statusClass}">${statusText}</span>
                                <c:choose>
                                    <c:when test="${o.paymentStatus.toString() == 'PAID'}">
                                        <span class="status-badge payment-paid">
                                            <i class="fa-solid fa-check-circle" style="font-size:10px;"></i> Đã thanh toán
                                        </span>
                                    </c:when>

                                    <c:when test="${o.paymentStatus.toString() == 'FAILED'}">
                                        <span class="status-badge payment-pending">
                                            <i class="fa-solid fa-triangle-exclamation" style="font-size:10px;"></i> Thanh toán thất bại
                                        </span>
                                    </c:when>

                                    <c:when test="${o.paymentStatus.toString() == 'EXPIRED'}">
                                        <span class="status-badge payment-pending">
                                            <i class="fa-solid fa-clock-rotate-left" style="font-size:10px;"></i> Thanh toán hết hạn
                                        </span>
                                    </c:when>

                                    <c:otherwise>
                                        <span class="status-badge payment-pending">
                                            <i class="fa-regular fa-clock" style="font-size:10px;"></i> Chưa thanh toán
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="order-timeline">
                            <div class="timeline-step ${tl1}">
                                <div class="timeline-icon"><i class="fa-solid fa-clipboard-list"></i></div>
                                <div class="timeline-label">Chờ xác nhận</div>
                            </div>
                            <div class="timeline-step ${tl2}">
                                <div class="timeline-icon"><i class="fa-solid fa-box-open"></i></div>
                                <div class="timeline-label">Đang chuẩn bị</div>
                            </div>
                            <div class="timeline-step ${tl3}">
                                <div class="timeline-icon"><i class="fa-solid fa-truck-fast"></i></div>
                                <div class="timeline-label">Đang giao hàng</div>
                            </div>
                            <c:choose>
                                <c:when test="${statusStr == 'CANCELLED'}">
                                    <div class="timeline-step cancelled">
                                        <div class="timeline-icon"><i class="fa-solid fa-ban"></i></div>
                                        <div class="timeline-label">Đã hủy</div>
                                    </div>
                                </c:when>
                                <c:when test="${statusStr == 'DELIVERY_FAILED'}">
                                    <div class="timeline-step failed">
                                        <div class="timeline-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                                        <div class="timeline-label">Giao thất bại</div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="timeline-step ${tl4}">
                                        <div class="timeline-icon"><i class="fa-solid fa-circle-check"></i></div>
                                        <div class="timeline-label">Hoàn thành</div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <c:if test="${(statusStr == 'CANCELLED' || statusStr == 'DELIVERY_FAILED') && not empty o.cancelReason}">
                            <div class="cancel-reason-banner">
                                <i class="fa-solid fa-circle-info"></i>
                                <div>
                                    <span class="cancel-reason-title">Lý do hủy đơn</span>
                                    <span class="cancel-reason-text">"${o.cancelReason}"</span>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${not empty refund}">
                            <div class="cancel-reason-banner">
                                <i class="fa-solid fa-money-bill-transfer"></i>
                                <div>
                                    <span class="cancel-reason-title">Yêu cầu hoàn tiền</span>
                                    <span class="cancel-reason-text">
                                        Trạng thái:
                                        <c:choose>
                                            <c:when test="${refund.status == 'pending'}">Đang chờ shop xử lý</c:when>
                                            <c:when test="${refund.status == 'refunded'}">Đã hoàn tiền</c:when>
                                            <c:when test="${refund.status == 'rejected'}">Đã từ chối</c:when>
                                            <c:when test="${refund.status == 'pending_info'}">Chờ bổ sung thông tin nhận tiền</c:when>
                                            <c:otherwise>${refund.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </c:if>

                        <div class="items-preview">
                            <c:forEach var="item" items="${o.items}" varStatus="s">
                                <c:if test="${s.index < 4}">
                                    <div class="preview-thumb-wrap">
                                        <img src="${item.product.imageUrl}"
                                             alt="${item.product.name}"
                                             class="preview-thumb"
                                             title="${item.product.name}"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
                                    </div>
                                </c:if>
                            </c:forEach>
                            <c:if test="${fn:length(o.items) > 4}">
                                <div class="preview-more">+${fn:length(o.items) - 4}</div>
                            </c:if>
                            <div class="items-preview-info">
                                <span class="items-preview-count">${fn:length(o.items)} sản phẩm</span>
                                &nbsp;—&nbsp; Bấm <strong>Xem chi tiết</strong> để xem đầy đủ
                            </div>
                        </div>

                        <div class="order-detail-panel" id="detail-${o.id}">
                            <div class="order-items-panel">
                                <div class="items-panel-header">
                                    <i class="fa-solid fa-list-ul"></i>
                                    Chi tiết sản phẩm
                                </div>
                                <c:forEach var="item" items="${o.items}">
                                    <div class="order-item-row">
                                        <img src="${item.product.imageUrl}"
                                             alt="${item.product.name}"
                                             class="item-thumb"
                                             onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
                                        <div class="item-info-col">
                                            <div class="item-info-name" title="${item.product.name}">${item.product.name}</div>
                                            <c:if test="${not empty item.variant}">
                                                <div class="item-info-qty" style="color: #9ca3af;">
                                                    Phân loại: ${item.variant.variantName}
                                                </div>
                                            </c:if>
                                            <div class="item-info-qty">Số lượng: × ${item.quantity}</div>
                                        </div>
                                        <div class="item-price-col">
                                            <div class="item-unit-price">
                                                Đơn giá: <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>
                                            <div class="item-total-price">
                                                <fmt:formatNumber value="${item.price * item.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                            <div class="shipping-addr-inline">
                                <i class="fa-solid fa-location-dot"></i>
                                <span><strong>Địa chỉ giao hàng:</strong> ${o.notes}</span>
                            </div>
                        </div>

                        <div class="order-summary-compact">
                            <div class="summary-amount-row">
                                <span>Tạm tính: <fmt:formatNumber value="${o.totalAmount - o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                <span>Phí vận chuyển: <fmt:formatNumber value="${o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                <span class="highlight-total">Tổng: <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                            </div>
                            <button class="toggle-detail-btn" id="btn-${o.id}" onclick="toggleDetail(${o.id})">
                                <i class="fa-solid fa-eye" style="font-size:12px;"></i>
                                Xem chi tiết
                                <i class="fa-solid fa-chevron-down chevron-icon"></i>
                            </button>
                        </div>

                        <div class="order-footer-row">
                            <div class="order-footer-left">
                                <i class="fa-solid fa-credit-card"></i>
                                Thanh toán:
                                <strong>${o.paymentMethod == 'cod' ? 'COD (khi nhận hàng)' : o.paymentMethod}</strong>
                            </div>
                            <div class="order-actions">
                                <a href="${pageContext.request.contextPath}/hoa-don?id=${o.id}" class="btn-action btn-outline">
                                    <i class="fa-solid fa-file-invoice"></i> Xem hóa đơn
                                </a>
                                <c:if test="${statusStr == 'PENDING' && o.paymentMethod != 'cod' && (o.paymentStatus.toString() == 'PENDING'
                                            || o.paymentStatus.toString() == 'FAILED' || o.paymentStatus.toString() == 'EXPIRED')}">
                                    <a href="${pageContext.request.contextPath}/thanh-toan-tiep?orderId=${o.id}"
                                       class="btn-action btn-primary">
                                        <i class="fa-solid fa-qrcode"></i> Thanh toán tiếp
                                    </a>
                                </c:if>

                                <c:if test="${statusStr == 'PENDING'}">
                                    <button type="button" class="btn-action btn-secondary" onclick="openCancelModal(${o.id})">
                                        <i class="fa-solid fa-times"></i> Hủy đơn
                                    </button>
                                </c:if>

                                <c:if test="${statusStr == 'CANCELLED' && o.paymentMethod != 'cod' && o.paymentStatus.toString() == 'PAID' && empty refund}">
                                    <button type="button"
                                            class="btn-action btn-primary"
                                            onclick="openRefundModal(${o.id}, '${o.orderNumber}', '${o.totalAmount}')">
                                        <i class="fa-solid fa-money-bill-transfer"></i> Yêu cầu hoàn tiền
                                    </button>
                                </c:if>

                                <c:if test="${statusStr == 'DELIVERY_FAILED' && o.paymentMethod != 'cod' && o.paymentStatus.toString() == 'PAID' && not empty refund && refund.status == 'pending_info'}">
                                    <button type="button"
                                            class="btn-action btn-primary"
                                            onclick="openRefundModal(${o.id}, '${o.orderNumber}', '${o.totalAmount}')">
                                        <i class="fa-solid fa-money-bill-transfer"></i> Bổ sung thông tin hoàn tiền
                                    </button>
                                </c:if>

                                <c:if test="${statusStr == 'COMPLETED' || statusStr == 'CANCELLED'}">
                                    <a href="${pageContext.request.contextPath}/san-pham" class="btn-action btn-primary">
                                        <i class="fa-solid fa-rotate"></i> Mua lại
                                    </a>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
        </div>

        <div class="empty-state" style="display: ${empty orders ? 'flex' : 'none'}; flex-direction: column; align-items: center; padding: 40px; text-align: center;">
            <i class="fa-solid fa-cart-shopping" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
            <h3>Chưa có đơn hàng nào</h3>
            <p style="color: #666; margin-bottom: 20px;">Bạn chưa có đơn hàng nào. Hãy bắt đầu mua sắm ngay!</p>
            <a href="${pageContext.request.contextPath}/san-pham" class="btn-action btn-primary" style="text-decoration: none; padding: 10px 20px;">
                <i class="fa-solid fa-shopping-bag"></i> Mua sắm ngay
            </a>
        </div>

        <div id="cancelModal" class="modal-overlay">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Lý do hủy đơn hàng</h3>
                    <span class="close-modal" onclick="closeCancelModal()">&times;</span>
                </div>
                <form action="${pageContext.request.contextPath}/cancel-order" method="post">
                    <input type="hidden" name="orderId" id="modalOrderId">
                    <div class="modal-body">
                        <div class="radio-group">
                            <label class="radio-label">
                                <input type="radio" name="reasonOpt" value="Đổi ý, không muốn mua nữa" checked onchange="toggleReasonInput(false)">
                                <span>Đổi ý, không muốn mua nữa</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="reasonOpt" value="Tìm thấy giá rẻ hơn ở nơi khác" onchange="toggleReasonInput(false)">
                                <span>Tìm thấy giá rẻ hơn ở nơi khác</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="reasonOpt" value="Thời gian giao hàng quá lâu" onchange="toggleReasonInput(false)">
                                <span>Thời gian giao hàng quá lâu</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="reasonOpt" value="Đặt nhầm sản phẩm" onchange="toggleReasonInput(false)">
                                <span>Đặt nhầm sản phẩm</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" name="reasonOpt" value="other" onchange="toggleReasonInput(true)">
                                <span>Lý do khác...</span>
                            </label>
                        </div>
                        <div id="otherReasonWrapper" style="display: none; margin-top: 14px;">
                            <textarea name="otherReason" id="otherReasonInput" placeholder="Nhập lý do cụ thể..." rows="3"></textarea>
                        </div>
                        <input type="hidden" name="cancelReason" id="finalReason">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary-modal" onclick="closeCancelModal()">Đóng</button>
                        <button type="submit" class="btn btn-danger" onclick="prepareSubmit(event)">
                            <i class="fa-solid fa-ban"></i> Xác nhận hủy
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div id="refundModal" class="modal-overlay refund-modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Yêu cầu hoàn tiền</h3>
                    <span class="close-modal" onclick="closeRefundModal()">&times;</span>
                </div>
                <form action="${pageContext.request.contextPath}/refund-request" method="post" enctype="multipart/form-data"
                      onsubmit="return validateRefundSubmit()">
                    <input type="hidden" name="orderId" id="refundOrderId">
                    <div class="modal-body">
                        <p style="margin-top: 0; color: #555;">
                            Đơn hàng <strong id="refundOrderNumber"></strong> sẽ được shop kiểm tra và hoàn tiền thủ công.
                        </p>

                        <label class="refund-field-label" for="refundReason">Lý do hoàn tiền</label>
                        <textarea name="reason" id="refundReason" rows="3" required></textarea>

                        <label class="refund-field-label" for="receiveMethod">Phương thức nhận tiền</label>
                        <select name="receiveMethod" id="receiveMethod" class="refund-input" required>
                            <option value="bank">Ngân hàng</option>
                            <option value="momo">MoMo</option>
                        </select>

                        <label class="refund-field-label" for="accountHolder">Tên chủ tài khoản</label>
                        <input type="text" name="accountHolder" id="accountHolder" class="refund-input"
                               placeholder="Ví dụ: Nguyễn Văn A" required>

                        <label class="refund-field-label" for="accountNumber">Số tài khoản / Số điện thoại ví</label>
                        <input type="text" name="accountNumber" id="accountNumber" class="refund-input"
                               placeholder="Có thể bỏ trống nếu đã tải ảnh QR">

                        <label class="refund-field-label" for="qrImage">Ảnh QR nhận tiền</label>
                        <label class="refund-file-upload" for="qrImage">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <span id="qrImageText">Chọn ảnh QR</span>
                        </label>
                        <input type="file" name="qrImage" id="qrImage" class="refund-file-input" accept="image/*"
                               onchange="previewRefundQr(this)">

                        <div id="refundQrPreview" class="refund-qr-preview" style="display: none;">
                            <img id="refundQrPreviewImg" src="" alt="Ảnh QR nhận tiền">
                            <button type="button" class="refund-remove-file" onclick="removeRefundQr()">
                                <i class="fa-solid fa-xmark"></i>
                                Bỏ ảnh
                            </button>
                        </div>

                        <label class="refund-field-label" for="refundNote">Ghi chú thêm</label>
                        <textarea name="note" id="refundNote" rows="2"></textarea>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary-modal" onclick="closeRefundModal()">Đóng</button>
                        <button type="submit" class="btn btn-danger">
                            <i class="fa-solid fa-paper-plane"></i> Gửi yêu cầu
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>
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

    function toggleDetail(orderId) {
        const panel = document.getElementById('detail-' + orderId);
        const btn   = document.getElementById('btn-' + orderId);
        if (!panel || !btn) return;
        const isOpen = panel.classList.contains('open');
        if (isOpen) {
            panel.classList.remove('open');
            btn.classList.remove('open');
            btn.innerHTML = '<i class="fa-solid fa-eye" style="font-size:12px;"></i> Xem chi tiết <i class="fa-solid fa-chevron-down chevron-icon"></i>';
        } else {
            panel.classList.add('open');
            btn.classList.add('open');
            btn.innerHTML = '<i class="fa-solid fa-eye-slash" style="font-size:12px;"></i> Ẩn chi tiết <i class="fa-solid fa-chevron-down chevron-icon open"></i>';
        }
    }

    function openCancelModal(orderId) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('cancelModal').classList.add('active');
        document.querySelector('input[name="reasonOpt"][value="Đổi ý, không muốn mua nữa"]').checked = true;
        toggleReasonInput(false);
    }

    function closeCancelModal() {
        document.getElementById('cancelModal').classList.remove('active');
    }

    function toggleReasonInput(isOther) {
        document.getElementById('otherReasonWrapper').style.display = isOther ? 'block' : 'none';
    }

    function prepareSubmit(e) {
        const selectedOpt = document.querySelector('input[name="reasonOpt"]:checked').value;
        let finalReason = selectedOpt;
        if (selectedOpt === 'other') {
            finalReason = document.getElementById('otherReasonInput').value.trim();
            if (finalReason === "") {
                alert("Vui lòng nhập lý do cụ thể!");
                e.preventDefault();
                return;
            }
        }
        document.getElementById('finalReason').value = finalReason;
    }

    document.getElementById('cancelModal').addEventListener('click', function(e) {
        if (e.target === this) closeCancelModal();
    });

    function openRefundModal(orderId, orderNumber) {
        document.getElementById('refundOrderId').value = orderId;
        document.getElementById('refundOrderNumber').textContent = '#' + orderNumber;
        document.getElementById('refundReason').value = '';
        document.getElementById('receiveMethod').value = 'bank';
        document.getElementById('accountHolder').value = '';
        document.getElementById('accountNumber').value = '';
        document.getElementById('qrImage').value = '';
        removeRefundQr();
        document.getElementById('refundNote').value = '';
        document.getElementById('refundModal').classList.add('active');
    }

    function closeRefundModal() {
        document.getElementById('refundModal').classList.remove('active');
    }

    document.getElementById('refundModal').addEventListener('click', function(e) {
        if (e.target === this) closeRefundModal();
    });

    function previewRefundQr(input) {
        const preview = document.getElementById('refundQrPreview');
        const previewImg = document.getElementById('refundQrPreviewImg');
        const fileText = document.getElementById('qrImageText');

        if (!input.files || input.files.length === 0) {
            removeRefundQr();
            return;
        }

        const file = input.files[0];
        if (!file.type || !file.type.startsWith('image/')) {
            alert('Vui lòng chọn file ảnh QR.');
            removeRefundQr();
            return;
        }

        fileText.textContent = file.name;
        const reader = new FileReader();
        reader.onload = function (event) {
            previewImg.src = event.target.result;
            preview.style.display = 'flex';
        };
        reader.readAsDataURL(file);
    }

    function removeRefundQr() {
        const qrInput = document.getElementById('qrImage');
        const preview = document.getElementById('refundQrPreview');
        const previewImg = document.getElementById('refundQrPreviewImg');

        qrInput.value = '';
        previewImg.src = '';
        preview.style.display = 'none';
        document.getElementById('qrImageText').textContent = 'Chọn ảnh QR';
    }

    function validateRefundSubmit() {
        const accountNumber = document.getElementById('accountNumber').value.trim();
        const qrImage = document.getElementById('qrImage');
        const hasQr = qrImage.files && qrImage.files.length > 0;

        if (!accountNumber && !hasQr) {
            alert('Vui lòng nhập số tài khoản/số điện thoại ví hoặc tải ảnh QR.');
            return false;
        }

        return true;
    }
</script>
</body>
</html>
