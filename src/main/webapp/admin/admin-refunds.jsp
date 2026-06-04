<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý hoàn tiền - Mộc Trà Admin</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
    <link rel="stylesheet" href="admin/assets/css/admin-orders.css">
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="refunds"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Hoàn tiền</h1>
            </div>
        </header>

        <div class="admin-content">
            <c:if test="${not empty sessionScope.msg}">
                <div class="alert alert-${sessionScope.msgType}">
                        ${sessionScope.msg}
                </div>
                <% session.removeAttribute("msg"); session.removeAttribute("msgType"); %>
            </c:if>

            <div class="page-header">
                <div class="page-title">
                    <h2>Yêu cầu hoàn tiền</h2>
                    <p>Admin kiểm tra thông tin nhận tiền và ghi nhận hoàn tiền thủ công.</p>
                </div>
            </div>

            <div class="filters-section">
                <form action="admin/refunds" method="get">
                    <div class="filters-grid">
                        <div class="filter-group">
                            <label>Trạng thái</label>
                            <select name="status" class="form-select" onchange="this.form.submit()">
                                <option value="" ${empty status ? 'selected' : ''}>Tất cả</option>
                                <option value="pending" ${status == 'pending' ? 'selected' : ''}>Chờ xử lý</option>
                                <option value="refunded" ${status == 'refunded' ? 'selected' : ''}>Đã hoàn tiền</option>
                                <option value="rejected" ${status == 'rejected' ? 'selected' : ''}>Từ chối</option>
                            </select>
                        </div>
                    </div>
                </form>
            </div>

            <div class="orders-container">
                <div class="table-header">
                    <div class="orders-count">Tổng cộng: <strong>${totalRefunds}</strong> yêu cầu</div>
                </div>

                <div class="table-responsive">
                    <table class="orders-table refund-table">
                        <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Số tiền</th>
                            <th>Thông tin nhận tiền</th>
                            <th>QR</th>
                            <th>Trạng thái</th>
                            <th>Ngày gửi</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="r" items="${refunds}">
                            <tr>
                                <td>
                                    <a href="admin/order/detail?id=${r.orderId}" class="order-id">#${r.orderNumber}</a>
                                </td>
                                <td>
                                    <div class="customer-info">
                                        <span class="customer-name">${r.customerName}</span>
                                        <span class="customer-phone">${r.customerEmail}</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="order-amount">
                                        <fmt:formatNumber value="${r.amount}" pattern="#,###"/>đ
                                    </div>
                                </td>
                                <td>
                                    <div class="refund-receive-info">
                                        <div><strong>${r.receiveMethod == 'momo' ? 'MoMo' : 'Ngân hàng'}</strong></div>
                                        <div>Chủ TK: ${r.accountHolder}</div>
                                        <c:if test="${not empty r.accountNumber}">
                                            <div>STK/SĐT: ${r.accountNumber}</div>
                                        </c:if>
                                        <div class="refund-reason">Lý do: ${r.reason}</div>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty r.qrImageUrl}">
                                            <button type="button" class="refund-qr-button"
                                                    onclick="openRefundQrModal('${r.qrImageUrl}', '#${r.orderNumber}')">
                                                <img src="${r.qrImageUrl}" alt="QR hoàn tiền" class="refund-qr-thumb">
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">Không có</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status == 'pending'}">
                                            <span class="status-badge status-pending">Chờ xử lý</span>
                                        </c:when>
                                        <c:when test="${r.status == 'refunded'}">
                                            <span class="status-badge status-active">Đã hoàn tiền</span>
                                        </c:when>
                                        <c:when test="${r.status == 'rejected'}">
                                            <span class="status-badge status-inactive">Từ chối</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td>
                                    <c:if test="${r.status == 'pending'}">
                                        <form action="admin/refunds" method="post" class="refund-action-form">
                                            <input type="hidden" name="refundId" value="${r.id}">
                                            <textarea name="adminNote" rows="2" placeholder="Ghi chú admin"></textarea>
                                            <div class="refund-action-buttons">
                                                <button type="submit" name="action" value="mark_refunded" class="btn-bulk btn-bulk-activate"
                                                        onclick="return confirm('Xác nhận đã hoàn tiền thủ công cho yêu cầu này?')">
                                                    Đã hoàn
                                                </button>
                                                <button type="submit" name="action" value="reject" class="btn-bulk btn-bulk-delete"
                                                        onclick="return confirm('Từ chối yêu cầu hoàn tiền này?')">
                                                    Từ chối
                                                </button>
                                            </div>
                                        </form>
                                    </c:if>
                                    <c:if test="${r.status != 'pending'}">
                                        <div class="refund-admin-note">
                                            ${empty r.adminNote ? 'Đã xử lý' : r.adminNote}
                                        </div>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty refunds}">
                            <tr>
                                <td colspan="8" style="text-align:center; color:#777; padding:24px;">
                                    Chưa có yêu cầu hoàn tiền nào.
                                </td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-container">
                    <div class="pagination-info">
                        Trang <strong>${currentPage}</strong> / <strong>${totalPages == 0 ? 1 : totalPages}</strong>
                    </div>
                    <div class="pagination">
                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="admin/refunds?page=${i}&status=${status}" class="page-btn ${currentPage == i ? 'active' : ''}">${i}</a>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<div id="refundQrModal" class="refund-qr-modal" onclick="closeRefundQrModal(event)">
    <div class="refund-qr-modal-content">
        <div class="refund-qr-modal-header">
            <h3>QR hoàn tiền <span id="refundQrOrderNumber"></span></h3>
            <button type="button" onclick="closeRefundQrModal()" aria-label="Đóng">&times;</button>
        </div>
        <div class="refund-qr-modal-body">
            <img id="refundQrModalImg" src="" alt="QR hoàn tiền">
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
</script>
</body>
</html>
