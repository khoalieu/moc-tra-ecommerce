<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng #${order.orderNumber}</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${ctx}assets/css/base.css">
    <link rel="stylesheet" href="${ctx}assets/css/components.css">
    <link rel="stylesheet" href="${ctx}admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}admin/assets/css/admin-order-detail.css">
</head>
<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="orders"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Chi tiết đơn hàng</h1>
            </div>
            <div class="header-right">
                <a href="admin/orders" class="view-site-btn"
                   style="background: white; color: #333; border: 1px solid #ddd;">
                    <i class="fa-solid fa-arrow-left"></i> Quay lại
                </a>
            </div>
        </header>

        <div class="admin-content">
            <div class="order-detail-header">
                <div class="order-meta">
                    <h2>Đơn hàng #${order.orderNumber}</h2>
                    <span>Đặt ngày: <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>

                    <c:choose>
                        <c:when test="${order.status == 'PENDING'}"><span
                                class="status-badge status-pending">Chờ xử lý</span></c:when>
                        <c:when test="${order.status == 'SHIPPING'}"><span
                                class="status-badge status-pending" style="background: #e3f2fd; color: #1565c0;">Đang giao</span></c:when>
                        <c:when test="${order.status == 'COMPLETED'}"><span
                                class="status-badge status-active">Hoàn tất</span></c:when>
                        <c:when test="${order.status == 'CANCELLED'}"><span
                                class="status-badge status-inactive">Đã hủy</span></c:when>
                        <c:when test="${order.status == 'DELIVERY_FAILED'}"><span
                                class="status-badge status-inactive">Giao thất bại</span></c:when>
                    </c:choose>
                </div>

                <div class="order-actions-top">
                    <button class="btn-sm btn-info" onclick="window.print()"
                            style="cursor: pointer; padding: 10px 15px;">
                        <i class="fa-solid fa-print"></i> In hóa đơn
                    </button>

                    <c:if test="${order.status == 'PENDING'}">
                        <button class="btn-sm btn-danger" onclick="openCancelModal()"
                                style="cursor: pointer; padding: 10px 15px;">
                            <i class="fa-solid fa-ban"></i> Hủy đơn
                        </button>
                        <button class="btn-sm btn-success" onclick="updateSingleStatus(${order.id}, 'completed')"
                                style="cursor: pointer; padding: 10px 15px;">
                            <i class="fa-solid fa-check"></i> Hoàn tất
                        </button>
                    </c:if>
                    
                    <c:if test="${order.status == 'SHIPPING'}">
                        <button class="btn-sm btn-danger" onclick="updateSingleStatus(${order.id}, 'delivery_failed')"
                                style="cursor: pointer; padding: 10px 15px;">
                            <i class="fa-solid fa-triangle-exclamation"></i> Giao thất bại
                        </button>
                        <button class="btn-sm btn-success" onclick="updateSingleStatus(${order.id}, 'completed')"
                                style="cursor: pointer; padding: 10px 15px;">
                            <i class="fa-solid fa-check-double"></i> Giao thành công
                        </button>
                    </c:if>
                </div>
            </div>

            <div class="detail-grid">
                <div class="left-column">
                    <div class="detail-card">
                        <h3 class="card-title">Sản phẩm đã đặt</h3>
                        <form action="admin-edit-order" method="post" id="adminUpdateQtyForm">
                            <input type="hidden" name="action" value="update-all-quantities">
                            <input type="hidden" name="orderId" value="${order.id}">
                        <table class="order-items-table">
                            <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Đơn giá</th>
                                <th style="width: 80px; text-align: center;">SL</th>
                                <th style="text-align: right;">Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="item" items="${order.items}">
                                <tr>
                                    <td>
                                        <div class="item-info-cell">
                                            <c:set var="resolvedItemImg" value="${(not empty item.product.imageUrl and item.product.imageUrl.startsWith('http')) ? item.product.imageUrl : pageContext.request.contextPath.concat('/').concat(not empty item.product.imageUrl ? item.product.imageUrl : 'assets/images/no-image.jpg')}"/>
                                            <img src="${resolvedItemImg}" class="item-thumb" alt="${item.product.name}"
                                                 onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/no-image.jpg';">
                                            <div class="item-text">
                                                <h4>${item.product.name}</h4>
                                                <c:if test="${not empty item.variant}">
                                                    <div style="font-size: 0.85rem; color: #666; margin-top: 4px;">
                                                        Phân loại: ${item.variant.variantName}
                                                    </div>
                                                </c:if>
                                                <p>ID: #${item.productId}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="admin-item-price-stack">
                                            <div class="admin-item-original-price">
                                                Giá gốc:
                                                <fmt:formatNumber value="${item.originalPrice}" pattern="#,###"/>đ
                                            </div>
                                            <div class="admin-item-promo-discount">
                                                Khuyến mãi:
                                                <c:choose>
                                                    <c:when test="${item.discountAmount > 0}">
                                                        -<fmt:formatNumber value="${item.discountAmount}" pattern="#,###"/>đ
                                                    </c:when>
                                                    <c:otherwise>0đ</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="text-align: center;">
                                        <c:choose>
                                            <c:when test="${order.status == 'PENDING'}">
                                                <input type="hidden" name="orderItemIds" value="${item.id}">

                                                <input type="number"
                                                       name="qty_${item.id}"
                                                       value="${item.quantity}"
                                                       min="0"
                                                       class="admin-qty-input"
                                                       onchange="showUpdateBtn()">
                                            </c:when>

                                            <c:otherwise>
                                                <strong>${item.quantity}</strong>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="admin-item-line-total">
                                        <fmt:formatNumber value="${item.price * item.quantity}" pattern="#,###"/>đ
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                        </form>
                        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee;">
                            <div class="order-summary-row" style="display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; font-size: 14px;">
                                <span>Tạm tính</span>
                                <span style="font-weight: 600; color: #333;">
                                    <fmt:formatNumber value="${order.subtotalAmount}" pattern="#,###"/>đ
                                </span>
                            </div>
                            <div class="order-summary-row" style="display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; font-size: 14px;">
                                <span>Phí vận chuyển</span>
                                <span style="font-weight: 600; color: #333;">
                                    <fmt:formatNumber value="${order.shippingFee}" pattern="#,###"/>đ
                                </span>
                            </div>
                            <c:if test="${order.couponDiscountAmount > 0}">
                                <div class="order-summary-row order-summary-row--discount" style="display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; font-size: 14px;">
                                    <span>
                                        Giảm mã ưu đãi
                                        <c:if test="${not empty order.couponCode}">(${order.couponCode})</c:if>
                                    </span>
                                    <span style="font-weight: 600; color: #d32f2f;">
                                        -<fmt:formatNumber value="${order.couponDiscountAmount}" pattern="#,###"/>đ
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${order.vipDiscountAmount > 0}">
                                <div class="order-summary-row order-summary-row--discount" style="display: flex; justify-content: space-between; margin-bottom: 10px; color: #666; font-size: 14px;">
                                    <span>Giảm voucher VIP</span>
                                    <span style="font-weight: 600; color: #d32f2f;">
                                        -<fmt:formatNumber value="${order.vipDiscountAmount}" pattern="#,###"/>đ
                                    </span>
                                </div>
                            </c:if>
                            <div class="order-summary-row total" style="display: flex; justify-content: space-between; margin-top: 15px; padding-top: 15px; border-top: 1px solid #eee; color: #107e84; font-size: 18px; font-weight: 700;">
                                <span>Tổng cộng</span>
                                <span>
                                    <fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ
                                </span>
                            </div>
                        </div>
                    </div>
                    <div id="updateBtnContainer" style="display: none; margin-top: 15px; border-top: 1px dashed #ddd; padding-top: 15px;">
                        <button type="submit"
                                form="adminUpdateQtyForm"
                                style="width: 100%; padding: 12px; background: #107e84; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; transition: 0.3s; display: flex; align-items: center; justify-content: center; gap: 8px;">
                            <i class="fa-solid fa-save"></i>
                            Xác nhận thay đổi số lượng
                        </button>
                    </div>
                </div>

                <div class="right-column">
                    <div class="detail-card">
                        <h3 class="card-title">Khách hàng</h3>
                        <div class="info-row">
                            <div class="info-value"
                                 style="line-height: 1.6; white-space: pre-line;">${order.notes}</div>
                        </div>
                    </div>

                    <div class="detail-card">
                        <h3 class="card-title">Thanh toán</h3>
                        <div class="info-row">
                            <span class="info-label">Phương thức</span>
                            <div class="info-value"><strong>${order.paymentMethod}</strong></div>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Trạng thái</span>
                            <div class="info-value" style="margin-top: 5px;">
                                <c:if test="${order.paymentStatus == 'PAID'}">
                                    <span class="status-badge status-active">Đã thanh toán</span>
                                </c:if>
                                <c:if test="${order.paymentStatus == 'PENDING'}">
                                    <span class="status-badge status-pending"
                                          style="color: #856404; background: #fff3cd;">Chưa thanh toán</span>
                                </c:if>
                                <c:if test="${order.paymentStatus == 'REFUNDED'}">
                                    <span class="status-badge status-inactive">Đã hoàn tiền</span>
                                </c:if>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not empty refund}">
                        <div class="detail-card refund-detail-card">
                            <h3 class="card-title">
                                <i class="fa-solid fa-money-bill-transfer" style="margin-right: 6px;"></i>Yêu cầu hoàn tiền
                            </h3>

                            <div class="info-row">
                                <span class="info-label">Trạng thái</span>
                                <div class="info-value">
                                    <c:choose>
                                        <c:when test="${refund.status == 'pending_info'}">
                                            <span class="status-badge status-pending">Chờ khách bổ sung</span>
                                        </c:when>
                                        <c:when test="${refund.status == 'pending'}">
                                            <span class="status-badge status-pending">Chờ xử lý</span>
                                        </c:when>
                                        <c:when test="${refund.status == 'refunded'}">
                                            <span class="status-badge status-active">Đã hoàn tiền</span>
                                        </c:when>
                                        <c:when test="${refund.status == 'rejected'}">
                                            <span class="status-badge status-inactive">Từ chối</span>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Số tiền</span>
                                <div class="info-value">
                                    <strong style="color:#d32f2f;"><fmt:formatNumber value="${refund.amount}" pattern="#,###"/>đ</strong>
                                </div>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Lý do</span>
                                <div class="info-value">${refund.reason}</div>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Nhận tiền</span>
                                <div class="info-value" style="line-height:1.6;">
                                    <c:choose>
                                        <c:when test="${refund.status == 'pending_info'}">
                                            <span class="text-muted">Chưa có thông tin nhận tiền</span>
                                        </c:when>
                                        <c:otherwise>
                                            <strong>Ngân hàng</strong><br>
                                            Chủ TK: ${refund.accountHolder}<br>
                                            <c:if test="${not empty refund.accountNumber}">
                                                STK/SĐT: ${refund.accountNumber}
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <c:if test="${not empty refund.qrImageUrl}">
                                <div class="info-row">
                                    <span class="info-label">QR</span>
                                    <div class="info-value">
                                        <button type="button" class="refund-detail-qr-button"
                                                onclick="openRefundQrModal('${refund.qrImageUrl}', '#${order.orderNumber}')">
                                            <img src="${refund.qrImageUrl}" alt="QR hoàn tiền">
                                        </button>
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty refund.note}">
                                <div class="info-row">
                                    <span class="info-label">Ghi chú khách</span>
                                    <div class="info-value">${refund.note}</div>
                                </div>
                            </c:if>

                            <c:if test="${refund.status == 'pending'}">
                                <form action="admin/refunds" method="post" class="refund-detail-form">
                                    <input type="hidden" name="refundId" value="${refund.id}">
                                    <textarea name="adminNote" rows="3" placeholder="Ghi chú xử lý cho yêu cầu hoàn tiền" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;box-sizing:border-box;resize:vertical;margin-bottom:10px;"></textarea>
                                    <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                        <button type="submit" name="action" value="mark_refunded"
                                                onclick="return confirm('Xác nhận đã hoàn tiền thủ công?')"
                                                style="padding:10px 14px;border:none;border-radius:6px;background:#28a745;color:#fff;font-weight:600;cursor:pointer;">
                                            Đã hoàn tiền
                                        </button>
                                        <button type="submit" name="action" value="reject"
                                                onclick="return confirm('Từ chối yêu cầu hoàn tiền này?')"
                                                style="padding:10px 14px;border:none;border-radius:6px;background:#dc3545;color:#fff;font-weight:600;cursor:pointer;">
                                            Từ chối
                                        </button>
                                    </div>
                                </form>
                            </c:if>

                            <c:if test="${refund.status != 'pending' && not empty refund.adminNote}">
                                <div class="info-row">
                                    <span class="info-label">Ghi chú admin</span>
                                    <div class="info-value">${refund.adminNote}</div>
                                </div>
                            </c:if>
                        </div>
                    </c:if>

                    <div class="detail-card">
                        <h3 class="card-title"><i class="fa-solid fa-truck-fast" style="margin-right: 6px;"></i>Giao hàng (GHN)</h3>

                        <c:if test="${order.status == 'PENDING'}">
                            <div style="margin-bottom: 14px; padding: 12px 14px; background: #fff8e1; border-radius: 8px; font-size: 13px; color: #856404; border: 1px solid #ffeeba;">
                                <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>
                                Đơn hàng đang chờ xử lý. Tạo vận đơn GHN để bắt đầu giao hàng.
                            </div>
                            <button onclick="openGHNModal()"
                                    style="width:100%; padding:11px 16px; background:#107e84; color:#fff; border:none; border-radius:8px; cursor:pointer; font-size:14px; font-weight:600; display:flex; align-items:center; justify-content:center; gap:8px;">
                                <i class="fa-solid fa-truck-fast"></i> Tạo vận đơn GHN
                            </button>
                        </c:if>

                        <c:if test="${order.status == 'SHIPPING'}">
                            <div class="info-row">
                                <span class="info-label">Trạng thái giao</span>
                                <div class="info-value">
                                    <span class="status-badge" style="background: #e3f2fd; color: #1565c0;">
                                        <i class="fa-solid fa-truck" style="margin-right: 4px;"></i> Đang giao hàng
                                    </span>
                                </div>
                            </div>
                            <c:if test="${not empty order.shippingProvider}">
                                <div class="info-row">
                                    <span class="info-label">Đơn vị vận chuyển</span>
                                    <div class="info-value">
                                        <strong style="color:#107e84;">${order.shippingProvider}</strong>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${not empty order.trackingCode}">
                                <div class="info-row">
                                    <span class="info-label">Mã vận đơn</span>
                                    <div class="info-value">
                                        <code style="background: #e8f5e9; padding: 5px 12px; border-radius: 6px; font-weight: 700; letter-spacing: 1px; color:#107e84; font-size:15px;">${order.trackingCode}</code>
                                    </div>
                                </div>
                                <div class="info-row">
                                    <span class="info-label">Theo dõi đơn</span>
                                    <div class="info-value">
                                        <a href="https://donhang.ghn.vn/?order_code=${order.trackingCode}" target="_blank"
                                           style="display:inline-flex; align-items:center; gap:6px; color:#107e84; font-weight:600; font-size:13px; text-decoration:none; padding:6px 12px; background:#f0fafa; border:1px solid #b2dfdb; border-radius:6px;">
                                            <i class="fa-solid fa-external-link-alt"></i> Tra cứu trên GHN
                                        </a>
                                    </div>
                                </div>
                            </c:if>
                        </c:if>

                        <c:if test="${order.status == 'DELIVERY_FAILED'}">
                            <div class="info-row">
                                <span class="info-label">Trạng thái giao</span>
                                <div class="info-value">
                                    <span class="status-badge status-inactive">
                                        <i class="fa-solid fa-xmark" style="margin-right: 4px;"></i> Giao thất bại
                                    </span>
                                </div>
                            </div>
                            <c:if test="${not empty order.trackingCode}">
                                <div class="info-row">
                                    <span class="info-label">Mã vận đơn GHN</span>
                                    <div class="info-value">
                                        <code style="background: #f5f5f5; padding: 4px 10px; border-radius: 4px; font-weight: 600;">${order.trackingCode}</code>
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${not empty order.cancelReason}">
                                <div class="info-row">
                                    <span class="info-label">Lý do</span>
                                    <div class="info-value" style="color: #c0392b;">
                                        <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>${order.cancelReason}
                                    </div>
                                </div>
                            </c:if>
                        </c:if>

                        <c:if test="${order.status == 'CANCELLED'}">
                            <div class="info-row">
                                <span class="info-label">Trạng thái</span>
                                <div class="info-value">
                                    <span class="status-badge status-inactive">
                                        <i class="fa-solid fa-ban" style="margin-right: 4px;"></i> Đã hủy
                                    </span>
                                </div>
                            </div>
                            <c:if test="${not empty order.cancelReason}">
                                <div class="info-row">
                                    <span class="info-label">Lý do hủy</span>
                                    <div class="info-value" style="color: #c0392b; line-height: 1.5;">
                                        <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>${order.cancelReason}
                                    </div>
                                </div>
                            </c:if>
                            <c:if test="${empty order.cancelReason}">
                                <div class="info-row">
                                    <span class="info-label">Lý do hủy</span>
                                    <div class="info-value" style="color: #999; font-style: italic;">
                                        Không có lý do được ghi nhận
                                    </div>
                                </div>
                            </c:if>
                        </c:if>

                        <c:if test="${order.status == 'COMPLETED'}">
                            <div class="info-row">
                                <span class="info-label">Trạng thái giao</span>
                                <div class="info-value">
                                    <span class="status-badge status-active">
                                        <i class="fa-solid fa-check-circle" style="margin-right: 4px;"></i> Giao thành công
                                    </span>
                                </div>
                            </div>
                            <c:if test="${not empty order.trackingCode}">
                                <div class="info-row">
                                    <span class="info-label">Mã vận đơn GHN</span>
                                    <div class="info-value">
                                        <code style="background: #e8f5e9; padding: 5px 12px; border-radius: 6px; font-weight: 700; color:#107e84;">${order.trackingCode}</code>
                                    </div>
                                </div>
                            </c:if>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<div id="refundQrModal" class="refund-detail-qr-modal" onclick="closeRefundQrModal(event)">
    <div class="refund-detail-qr-modal-content">
        <div class="refund-detail-qr-modal-header">
            <h3>QR hoàn tiền <span id="refundQrOrderNumber"></span></h3>
            <button type="button" onclick="closeRefundQrModal()" aria-label="Đóng">&times;</button>
        </div>
        <div class="refund-detail-qr-modal-body">
            <img id="refundQrModalImg" src="" alt="QR hoàn tiền">
        </div>
    </div>
</div>

<div id="cancelModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center;">
    <div style="background:#fff; border-radius:12px; padding:28px 32px; width:480px; max-width:90%; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
        <h3 style="margin:0 0 6px 0; font-size:18px; color:#333;">
            <i class="fa-solid fa-ban" style="color:#e74c3c; margin-right:8px;"></i>Hủy đơn hàng
        </h3>
        <p style="margin:0 0 18px 0; color:#666; font-size:14px;">Đơn hàng <strong>#${order.orderNumber}</strong></p>

        <label style="font-weight:600; font-size:14px; color:#333; display:block; margin-bottom:6px;">Chọn lý do hủy <span style="color:red;">*</span></label>
        <select id="cancelReasonSelect" style="width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:6px; font-size:14px; margin-bottom:12px; cursor:pointer;" onchange="toggleAdminOtherReason()">
            <option value="">-- Chọn lý do --</option>
            <option value="Khách yêu cầu hủy">Khách yêu cầu hủy</option>
            <option value="Hết hàng">Hết hàng</option>
            <option value="Sai thông tin đơn hàng">Sai thông tin đơn hàng</option>
            <option value="Không liên lạc được khách">Không liên lạc được khách</option>
            <option value="Đơn trùng lặp">Đơn trùng lặp</option>
            <option value="other">Lý do khác...</option>
        </select>

        <textarea id="cancelReasonOther" rows="3" placeholder="Nhập lý do khác..." style="display:none; width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:6px; font-size:14px; margin-bottom:12px; resize:vertical; box-sizing:border-box;"></textarea>

        <div style="display:flex; gap:10px; justify-content:flex-end; margin-top:8px;">
            <button onclick="closeCancelModal()" style="padding:10px 20px; border:1px solid #ddd; background:#fff; border-radius:6px; cursor:pointer; font-size:14px; color:#666;">
                Đóng
            </button>
            <button id="btnConfirmCancel" onclick="confirmCancelOrder()" style="padding:10px 20px; border:none; background:#e74c3c; color:#fff; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600;">
                <i class="fa-solid fa-ban"></i> Xác nhận hủy
            </button>
        </div>
    </div>
</div>

<div id="ghnModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center;">
    <div style="background:#fff; border-radius:12px; padding:28px 32px; width:520px; max-width:92%; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
        <h3 style="margin:0 0 6px 0; font-size:18px; color:#107e84;">
            <i class="fa-solid fa-truck-fast" style="margin-right:8px;"></i>Tạo vận đơn GHN
        </h3>
        <p style="margin:0 0 14px 0; color:#666; font-size:14px;">Đơn hàng <strong>#${order.orderNumber}</strong></p>

        <div style="background:#e8f5e9; border:1px solid #c8e6c9; border-radius:8px; padding:14px; margin-bottom:16px; font-size:13px; color:#2e7d32; line-height:1.8;">
            <i class="fa-solid fa-location-dot"></i>
            <strong>Địa chỉ giao hàng:</strong><br>
            <span style="color:#333;">${order.notes}</span>
        </div>

        <div style="background:#fff8e1; border:1px solid #ffe082; border-radius:8px; padding:12px 14px; margin-bottom:16px; font-size:13px; color:#e65100; line-height:1.6;">
            <i class="fa-solid fa-circle-info"></i>
            Hệ thống sẽ tự động lấy mã địa chỉ GHN từ thông tin khách hàng đã nhập khi đặt hàng.
            Nhấn <strong>"Tạo vận đơn GHN"</strong> để gửi đơn cho đơn vị vận chuyển.
        </div>

        <div id="ghnResultBox" style="display:none; padding:14px; border-radius:8px; margin-bottom:16px; font-size:14px; line-height:1.7;"></div>

        <div style="display:flex; gap:10px; justify-content:flex-end;">
            <button onclick="closeGHNModal()" style="padding:10px 20px; border:1px solid #ddd; background:#fff; border-radius:6px; cursor:pointer; font-size:14px; color:#666;">
                Đóng
            </button>
            <button id="btnCreateGHN" onclick="createGHNOrder()"
                    style="padding:10px 22px; border:none; background:#107e84; color:#fff; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600;">
                <i class="fa-solid fa-truck-fast"></i> Tạo vận đơn GHN
            </button>
        </div>
    </div>
</div>

<script>
    function openRefundQrModal(src, orderNumber) {
        document.getElementById('refundQrModalImg').src = src;
        document.getElementById('refundQrOrderNumber').textContent = orderNumber || '';
        document.getElementById('refundQrModal').classList.add('active');
    }

    function closeRefundQrModal(event) {
        if (event && event.target !== document.getElementById('refundQrModal')) {
            return;
        }

        document.getElementById('refundQrModal').classList.remove('active');
        document.getElementById('refundQrModalImg').src = '';
    }

    function updateSingleStatus(orderId, status) {
        if (!confirm("Xác nhận thay đổi trạng thái?")) return;
        const params = new URLSearchParams();
        params.append('action', 'single');
        params.append('orderId', orderId);
        params.append('status', status);
        fetch('admin/order/update', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) location.reload();
            else alert("Lỗi cập nhật!");
        });
    }

    /* === Modal hủy đơn === */
    function openCancelModal() {
        document.getElementById('cancelModal').style.display = 'flex';
    }
    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
        document.getElementById('cancelReasonSelect').value = '';
        document.getElementById('cancelReasonOther').style.display = 'none';
        document.getElementById('cancelReasonOther').value = '';
    }
    function toggleAdminOtherReason() {
        const select = document.getElementById('cancelReasonSelect');
        const textarea = document.getElementById('cancelReasonOther');
        if (select.value === 'other') {
            textarea.style.display = 'block';
        } else {
            textarea.style.display = 'none';
            textarea.value = '';
        }
    }
    function confirmCancelOrder() {
        const select = document.getElementById('cancelReasonSelect');
        let reason = select.value;
        if (!reason) { alert('Vui lòng chọn lý do hủy!'); return; }
        if (reason === 'other') {
            reason = document.getElementById('cancelReasonOther').value.trim();
            if (!reason) { alert('Vui lòng nhập lý do hủy!'); return; }
        }
        const btn = document.getElementById('btnConfirmCancel');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
        const params = new URLSearchParams();
        params.append('action', 'cancel_with_reason');
        params.append('orderId', '${order.id}');
        params.append('cancelReason', reason);
        fetch('admin/order/update', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) { alert('Đã hủy đơn hàng thành công!'); location.reload(); }
            else {
                alert('Lỗi: Không thể hủy đơn hàng!');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-ban"></i> Xác nhận hủy';
            }
        }).catch(() => {
            alert('Lỗi kết nối server!');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-ban"></i> Xác nhận hủy';
        });
    }

    /* === Modal tạo vận đơn GHN === */
    function openGHNModal() {
        document.getElementById('ghnModal').style.display = 'flex';
        document.getElementById('ghnResultBox').style.display = 'none';
    }

    function closeGHNModal() {
        document.getElementById('ghnModal').style.display = 'none';
    }

    function createGHNOrder() {
        const btn = document.getElementById('btnCreateGHN');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang tạo...';

        const params = new URLSearchParams();
        params.append('orderId', '${order.id}');

        fetch('admin/order/ghn-create', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        })
        .then(res => res.json())
        .then(data => {
            const box = document.getElementById('ghnResultBox');
            box.style.display = 'block';
            if (data.success) {
                box.style.background = '#e8f5e9';
                box.style.border = '1px solid #c8e6c9';
                box.style.color = '#2e7d32';
                box.innerHTML =
                    '<strong><i class="fa-solid fa-check-circle"></i> ' + data.message + '</strong><br>' +
                    '🚚 Mã vận đơn GHN: <strong>' + data.orderCode + '</strong><br>' +
                    '📅 Dự kiến giao: ' + (data.expectedDelivery || 'Đang cập nhật') + '<br>' +
                    '💰 Phí GHN: ' + Number(data.totalFee).toLocaleString('vi-VN') + 'đ<br>' +
                    '<a href="' + data.trackingUrl + '" target="_blank" style="color:#107e84; font-weight:600; margin-top:6px; display:inline-block;">' +
                        '<i class="fa-solid fa-external-link-alt"></i> Tra cứu trên GHN' +
                    '</a>';
                setTimeout(() => { closeGHNModal(); location.reload(); }, 3000);
            } else {
                box.style.background = '#ffebee';
                box.style.border = '1px solid #ffcdd2';
                box.style.color = '#c62828';
                box.innerHTML = '<i class="fa-solid fa-circle-xmark"></i> ' + data.message;
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-truck-fast"></i> Tạo vận đơn GHN';
            }
        })
        .catch(() => {
            alert('Lỗi kết nối server!');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-truck-fast"></i> Tạo vận đơn GHN';
        });
    }

    function showUpdateBtn() {
        const container = document.getElementById('updateBtnContainer');
        if (container) {
            container.style.display = 'block';
            // Hiệu ứng nhẹ để Admin chú ý
            container.classList.add('fade-in');
        }
    }
</script>

</body>
</html>

