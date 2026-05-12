<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Shipper Dashboard - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/shipper/assets/css/shipper.css">
</head>
<body>

<div class="shipper-header">
    <div><i class="fas fa-motorcycle"></i> Giao Hàng Mộc Trà</div>
    <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Đăng xuất</a>
</div>

<c:if test="${not empty sessionScope.msg}">
    <div style="padding: 10px; background-color: #d4edda; color: #155724; text-align: center;">
            ${sessionScope.msg}
        <c:remove var="msg" scope="session"/>
    </div>
</c:if>

<div class="shipper-container">
    <h3>Đơn hàng cần giao (${orders.size()})</h3>

    <c:if test="${empty orders}">
        <p style="text-align: center; color: #7f8c8d;">Hiện tại bạn không có đơn hàng nào cần giao.</p>
    </c:if>

    <c:forEach items="${orders}" var="order">
        <div class="order-card">
            <div class="order-header">
                <span class="order-id">#${order.orderNumber}</span>
                <c:choose>
                    <c:when test="${order.paymentStatus == 'PAID'}">
                        <span class="payment-status">Đã thanh toán</span>
                    </c:when>
                    <c:otherwise>
                        <span class="payment-status cod">Thu hộ (COD)</span>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="order-body">
                <p><i class="fas fa-user"></i> <strong>${order.customerName}</strong></p>
                <p><i class="fas fa-phone"></i> ${order.customerPhone}</p>
                <p><i class="fas fa-map-marker-alt"></i> ${order.shippingAddress}</p>
                <c:if test="${not empty order.notes}">
                    <p style="color: #e67e22;"><i class="fas fa-comment-dots"></i> Ghi chú: ${order.notes}</p>
                </c:if>
                <p class="total-amount">
                    <i class="fas fa-money-bill-wave"></i> Cần thu:
                    <c:choose>
                        <c:when test="${order.paymentStatus == 'PAID'}">0 VNĐ</c:when>
                        <c:otherwise><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/> VNĐ</c:otherwise>
                    </c:choose>
                </p>
            </div>

            <div class="order-actions">
                <a href="tel:${order.customerPhone}" class="btn btn-call"><i class="fas fa-phone-alt"></i> Gọi</a>
                <button class="btn btn-cancel" onclick="openCancelModal('${order.id}', '${order.orderNumber}')">Hủy đơn</button>
                <form action="${pageContext.request.contextPath}/shipper/update-status" method="POST" style="flex: 1; display: flex;">
                    <input type="hidden" name="orderId" value="${order.id}">
                    <input type="hidden" name="status" value="completed">
                    <button type="submit" class="btn btn-success" onclick="return confirm('Xác nhận đã giao thành công đơn ${order.orderNumber}?')"><i class="fas fa-check"></i> Đã giao</button>
                </form>
            </div>
        </div>
    </c:forEach>
</div>

<div class="modal-overlay" id="cancelModal">
    <div class="modal-content">
        <h3>Báo cáo giao thất bại</h3>
        <p>Mã đơn: <strong id="modalOrderNumber"></strong></p>

        <form action="${pageContext.request.contextPath}/shipper/update-status" method="POST">
            <input type="hidden" name="orderId" id="modalOrderId" value="">
            <input type="hidden" name="status" value="delivery_failed">

            <label for="cancelReason">Chọn lý do:</label>
            <select name="cancelReason" id="cancelReason" onchange="toggleOtherReason()" required>
                <option value="">-- Chọn lý do --</option>
                <option value="Khách không nghe máy">Khách không nghe máy</option>
                <option value="Sai số điện thoại/địa chỉ">Sai số điện thoại/địa chỉ</option>
                <option value="Khách từ chối nhận hàng">Khách từ chối nhận hàng</option>
                <option value="Khách hẹn dời ngày giao">Khách hẹn dời ngày giao</option>
                <option value="other">Lý do khác...</option>
            </select>

            <textarea name="otherReason" id="otherReason" rows="3" placeholder="Nhập lý do khác..." style="display:none;"></textarea>

            <div class="modal-actions">
                <button type="button" class="btn btn-close" onclick="closeCancelModal()">Đóng</button>
                <button type="submit" class="btn btn-cancel">Xác nhận hủy</button>
            </div>
        </form>
    </div>
</div>
<script>
    function openCancelModal(orderId, orderNumber) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('modalOrderNumber').innerText = '#' + orderNumber;
        document.getElementById('cancelModal').style.display = 'flex';
    }

    function closeCancelModal() {
        document.getElementById('cancelModal').style.display = 'none';
        document.getElementById('cancelReason').value = "";
        document.getElementById('otherReason').style.display = 'none';
        document.getElementById('otherReason').value = "";
    }

    function toggleOtherReason() {
        var select = document.getElementById('cancelReason');
        var otherTextarea = document.getElementById('otherReason');
        if (select.value === 'other') {
            otherTextarea.style.display = 'block';
            otherTextarea.setAttribute('required', 'required');
        } else {
            otherTextarea.style.display = 'none';
            otherTextarea.removeAttribute('required');
        }
    }
</script>
</body>
</html>