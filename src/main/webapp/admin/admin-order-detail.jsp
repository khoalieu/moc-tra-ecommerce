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
                        <c:when test="${order.status == 'COMPLETED'}"><span
                                class="status-badge status-active">Hoàn tất</span></c:when>
                        <c:when test="${order.status == 'CANCELLED'}"><span
                                class="status-badge status-inactive">Đã hủy</span></c:when>
                    </c:choose>
                </div>

                <div class="order-actions-top">
                    <button class="btn-sm btn-info" onclick="window.print()"
                            style="cursor: pointer; padding: 10px 15px;">
                        <i class="fa-solid fa-print"></i> In hóa đơn
                    </button>

                    <c:if test="${order.status == 'PENDING'}">
                        <button class="btn-sm btn-danger" onclick="updateSingleStatus(${order.id}, 'cancelled')"
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
                </div>
            </div>
        </div>
    </main>
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
</script>

</body>
</html>