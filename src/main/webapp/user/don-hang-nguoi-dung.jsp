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
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .alert {
            padding: 15px;
            margin: 15px 0;
            border: 1px solid transparent;
            border-radius: 4px;
            font-family: Arial, sans-serif;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            z-index: 2000;
            justify-content: center;
            align-items: center;
            transition: all 0.3s ease;
        }

        .modal-overlay.active {
            display: flex;
            animation: fadeIn 0.3s ease;
        }

        .modal-content {
            background: #fff;
            padding: 0;
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            animation: slideDown 0.4s ease;
        }

        .modal-header {
            background: #f8f9fa;
            padding: 16px 24px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 1.25rem;
            color: #333;
            font-weight: 600;
        }

        .close-modal {
            font-size: 24px;
            color: #999;
            cursor: pointer;
            transition: color 0.2s;
        }

        .close-modal:hover {
            color: #d32f2f;
        }

        .modal-body {
            padding: 20px 24px;
        }

        .radio-group {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .radio-label {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            padding: 11px 14px;
            border: 1px solid #eee;
            border-radius: 8px;
            transition: all 0.2s ease;
            font-size: 14px;
        }

        .radio-label:hover {
            background-color: #f1f8e9;
            border-color: #8bc34a;
        }

        .radio-label input[type="radio"] {
            width: 16px;
            height: 16px;
            accent-color: #4caf50;
        }

        #otherReasonInput {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-top: 10px;
            resize: none;
            font-family: inherit;
            font-size: 14px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        #otherReasonInput:focus {
            border-color: #4caf50;
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }
        .modal-footer {
            padding: 14px 24px;
            background: #f8f9fa;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            border: none;
            transition: opacity 0.2s;
            font-size: 14px;
        }
        .btn-secondary-modal { background: #e0e0e0; color: #333; }
        .btn-danger { background: #d32f2f; color: #fff; }
        .btn:hover { opacity: 0.88; }
        .order-card-meta {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }
        .order-footer-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
            padding: 15px 20px;
        }

        .order-footer-left {
            font-size: 13px;
            color: #666;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .order-summary-compact {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 20px;
            background: #f8f9fa;
            border-top: 1px solid #f0f0f0;
            flex-wrap: wrap;
            gap: 8px;
        }

        .summary-amount-row {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            font-size: 13px;
            color: #555;
        }

        .summary-amount-row .highlight-total {
            font-weight: 700;
            color: #107e84;
            font-size: 15px;
        }
        .shipping-addr-inline {
            font-size: 12.5px;
            color: #6b7280;
            padding: 10px 20px;
            display: flex;
            align-items: flex-start;
            gap: 7px;
            border-top: 1px solid #f3f4f6;
        }

        .shipping-addr-inline i {
            color: #107e84;
            margin-top: 1px;
            flex-shrink: 0;
        }
    </style>
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
                    <c:set var="tl1" value="done" />

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
                                <div class="timeline-icon">
                                    <i class="fa-solid fa-clipboard-list"></i>
                                </div>
                                <div class="timeline-label">Chờ xác nhận</div>
                            </div>
                            <div class="timeline-step ${tl2}">
                                <div class="timeline-icon">
                                    <i class="fa-solid fa-box-open"></i>
                                </div>
                                <div class="timeline-label">Đang chuẩn bị</div>
                            </div>
                            <div class="timeline-step ${tl3}">
                                <div class="timeline-icon">
                                    <i class="fa-solid fa-truck-fast"></i>
                                </div>
                                <div class="timeline-label">Đang giao hàng</div>
                            </div>
                            <c:choose>
                                <c:when test="${statusStr == 'CANCELLED'}">
                                    <div class="timeline-step cancelled">
                                        <div class="timeline-icon">
                                            <i class="fa-solid fa-ban"></i>
                                        </div>
                                        <div class="timeline-label">Đã hủy</div>
                                    </div>
                                </c:when>
                                <c:when test="${statusStr == 'DELIVERY_FAILED'}">
                                    <div class="timeline-step failed">
                                        <div class="timeline-icon">
                                            <i class="fa-solid fa-triangle-exclamation"></i>
                                        </div>
                                        <div class="timeline-label">Giao thất bại</div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="timeline-step ${tl4}">
                                        <div class="timeline-icon">
                                            <i class="fa-solid fa-circle-check"></i>
                                        </div>
                                        <div class="timeline-label">Hoàn thành</div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${statusStr == 'CANCELLED' && not empty o.cancelReason}">
                            <div class="cancel-reason-banner" style="margin-top: 12px;">
                                <i class="fa-solid fa-circle-info"></i>
                                <div>
                                    <span class="cancel-reason-title">Lý do hủy đơn</span>
                                    <span class="cancel-reason-text">"${o.cancelReason}"</span>
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
                                            <c:choose>
                                                <c:when test="${item.originalPrice > item.price}">
                                                    <div class="item-unit-price" style="color: #999; text-decoration: line-through; font-size: 12px;">
                                                        Giá gốc:
                                                        <fmt:formatNumber value="${item.originalPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>

                                                    <div class="item-unit-price" style="color: #d9534f; font-weight: 600;">
                                                        Đơn giá:
                                                        <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>

                                                    <div class="item-unit-price" style="color: #2e7d32; font-size: 12px;">
                                                        Giảm:
                                                        <fmt:formatNumber value="${item.discountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>
                                                </c:when>

                                                <c:otherwise>
                                                    <div class="item-unit-price">
                                                        Đơn giá:
                                                        <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>

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
                                    <span>
                                        Tạm tính:
                                        <fmt:formatNumber value="${o.subtotalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                    <span>
                                        Phí vận chuyển:
                                        <fmt:formatNumber value="${o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>

                                <c:if test="${o.couponDiscountAmount > 0}">
                                    <span style="color: #d32f2f;">
                                        Giảm mã ưu đãi:
                                        -<fmt:formatNumber value="${o.couponDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </c:if>

                                <c:if test="${o.vipDiscountAmount > 0}">
                                    <span style="color: #d32f2f;">
                                        Giảm voucher VIP:
                                        -<fmt:formatNumber value="${o.vipDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </c:if>

                                <span class="highlight-total">
                                    Tổng:
                                    <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
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
                                <strong>
                                    <c:choose>
                                        <c:when test="${o.paymentMethod == 'cod'}">
                                            Thanh toán khi nhận hàng
                                        </c:when>
                                        <c:when test="${o.paymentMethod == 'bank'}">
                                            Chuyển khoản ngân hàng
                                        </c:when>
                                        <c:when test="${o.paymentMethod == 'momo'}">
                                            Ví MoMo
                                        </c:when>
                                        <c:otherwise>
                                            ${o.paymentMethod}
                                        </c:otherwise>
                                    </c:choose>
                                </strong>                            </div>
                            <div class="order-actions">
                                <a href="${pageContext.request.contextPath}/hoa-don?id=${o.id}" class="btn-action btn-outline">
                                    <i class="fa-solid fa-file-invoice"></i> Xem hóa đơn
                                </a>

                                <c:if test="${statusStr == 'PENDING'}">
                                    <button type="button" class="btn-action btn-secondary" onclick="openCancelModal(${o.id})">
                                        <i class="fa-solid fa-times"></i> Hủy đơn
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

    /* ===== TOGGLE DETAIL PANEL ===== */
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
</script>
</body>
</html>