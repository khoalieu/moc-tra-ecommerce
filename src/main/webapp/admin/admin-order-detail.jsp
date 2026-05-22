<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng #${order.orderNumber}</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
    <link rel="stylesheet" href="admin/assets/css/admin-order-detail.css">
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
                </div>
            </div>

            <div class="detail-grid">
                <div class="left-column">
                    <div class="detail-card">
                        <h3 class="card-title">Sản phẩm đã đặt</h3>
                        <table class="order-items-table">
                            <thead>
                            <tr>
                                <th>Sản phẩm</th>
                                <th>Đơn giá</th>
                                <th>SL</th>
                                <th style="text-align: right;">Thành tiền</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="item" items="${order.items}">
                                <tr>
                                    <td>
                                        <div class="item-info-cell">
                                            <img src="${item.product.imageUrl}" class="item-thumb" alt="">
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
                                    <td><fmt:formatNumber value="${item.price}" pattern="#,###"/>₫</td>
                                    <td>${item.quantity}</td>
                                    <td style="text-align: right; font-weight: 600;">
                                        <fmt:formatNumber value="${item.price * item.quantity}" pattern="#,###"/>₫
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>

                        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee;">
                            <div class="order-summary-row"><span>Tạm tính</span><span><fmt:formatNumber
                                    value="${order.totalAmount - order.shippingFee}" pattern="#,###"/>₫</span></div>
                            <div class="order-summary-row"><span>Phí vận chuyển</span><span><fmt:formatNumber
                                    value="${order.shippingFee}" pattern="#,###"/>₫</span></div>
                            <div class="order-summary-row total" style="color: #107e84;">
                                <span>Tổng cộng</span><span><fmt:formatNumber value="${order.totalAmount}"
                                                                              pattern="#,###"/>₫</span></div>
                        </div>
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
                            </div>
                        </div>
                    </div>

                    <div class="detail-card">
                        <h3 class="card-title"><i class="fa-solid fa-truck-fast" style="margin-right: 6px;"></i>Giao hàng</h3>
                        <c:if test="${not empty order.shipperId && order.shipperId > 0}">
                            <div class="info-row">
                                <span class="info-label">Shipper phụ trách</span>
                                <div class="info-value">
                                    <c:set var="foundShipper" value="false"/>
                                    <c:forEach var="s" items="${shippers}">
                                        <c:if test="${s.id == order.shipperId}">
                                            <div style="display: flex; align-items: center; gap: 8px;">
                                                <div style="width: 32px; height: 32px; border-radius: 50%; background: #107e84; color: white; display: flex; align-items: center; justify-content: center; font-size: 14px; font-weight: 600;">
                                                    <i class="fa-solid fa-user"></i>
                                                </div>
                                                <div>
                                                    <strong>${s.lastName} ${s.firstName}</strong>
                                                    <c:if test="${not empty s.phone}">
                                                        <br><small style="color: #666;"><i class="fa-solid fa-phone" style="font-size: 11px;"></i> ${s.phone}</small>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <c:set var="foundShipper" value="true"/>
                                        </c:if>
                                    </c:forEach>
                                    <c:if test="${!foundShipper}">
                                        <span style="color: #999;">Shipper ID: ${order.shipperId}</span>
                                    </c:if>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${order.status == 'PENDING'}">
                            <div class="info-row" style="margin-top: 12px;">
                                <span class="info-label">
                                    <c:choose>
                                        <c:when test="${not empty order.shipperId && order.shipperId > 0}">Đổi shipper</c:when>
                                        <c:otherwise>Gán shipper</c:otherwise>
                                    </c:choose>
                                </span>
                                <div class="info-value" style="margin-top: 5px;">
                                    <c:choose>
                                        <c:when test="${not empty shippers && shippers.size() > 0}">
                                            <select id="shipperSelect" style="width: 100%; padding: 9px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; background: #fff; cursor: pointer; transition: border-color 0.2s;" onfocus="this.style.borderColor='#107e84'" onblur="this.style.borderColor='#ddd'">
                                                <option value="">-- Chọn shipper --</option>
                                                <c:forEach var="s" items="${shippers}">
                                                    <option value="${s.id}" ${s.id == order.shipperId ? 'selected' : ''}>
                                                        ${s.lastName} ${s.firstName}<c:if test="${not empty s.phone}"> - ${s.phone}</c:if>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                            <button id="btnAssignShipper" class="btn-sm btn-success" onclick="assignShipper()"
                                                    style="cursor: pointer; padding: 9px 16px; margin-top: 10px; width: 100%; font-size: 14px; border: none; border-radius: 6px;">
                                                <i class="fa-solid fa-user-plus"></i> Xác nhận gán
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <p style="color: #e74c3c; font-size: 13px; margin: 0;">
                                                <i class="fa-solid fa-triangle-exclamation"></i>
                                                Chưa có shipper nào trong hệ thống. Vui lòng tạo tài khoản shipper trước.
                                            </p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
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
                                    <div class="info-value"><strong>${order.shippingProvider}</strong></div>
                                </div>
                            </c:if>
                            <c:if test="${not empty order.trackingCode}">
                                <div class="info-row">
                                    <span class="info-label">Mã vận đơn</span>
                                    <div class="info-value">
                                        <code style="background: #f5f5f5; padding: 4px 10px; border-radius: 4px; font-weight: 600; letter-spacing: 0.5px;">${order.trackingCode}</code>
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

                        <c:if test="${order.status == 'PENDING' && (empty order.shipperId || order.shipperId == 0)}">
                            <div style="margin-top: 10px; padding: 10px 14px; background: #fff8e1; border-radius: 6px; font-size: 13px; color: #856404; border: 1px solid #ffeeba;">
                                <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>
                                Đơn hàng này chưa được gán cho shipper. Vui lòng chọn shipper bên trên để bắt đầu xử lý giao hàng.
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
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

<script>
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

        if (!reason) {
            alert('Vui lòng chọn lý do hủy!');
            return;
        }

        if (reason === 'other') {
            reason = document.getElementById('cancelReasonOther').value.trim();
            if (!reason) {
                alert('Vui lòng nhập lý do hủy!');
                return;
            }
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
            if (res.ok) {
                alert('Đã hủy đơn hàng thành công!');
                location.reload();
            } else {
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

    /* === Gán shipper === */
    function assignShipper() {
        const select = document.getElementById('shipperSelect');
        const shipperId = select.value;
        if (!shipperId) {
            alert('Vui lòng chọn shipper!');
            return;
        }

        if (!confirm('Xác nhận gán shipper cho đơn hàng #${order.orderNumber}?')) return;

        const btn = document.getElementById('btnAssignShipper');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';

        const params = new URLSearchParams();
        params.append('action', 'assign_shipper');
        params.append('orderId', '${order.id}');
        params.append('shipperId', shipperId);

        fetch('admin/order/update', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert('Gán shipper thành công!');
                location.reload();
            } else {
                alert('Lỗi: Chỉ gán được cho đơn ở trạng thái "Chờ xử lý"!');
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-user-plus"></i> Xác nhận gán';
            }
        }).catch(() => {
            alert('Lỗi kết nối server!');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-user-plus"></i> Xác nhận gán';
        });
    }
</script>

</body>
</html>