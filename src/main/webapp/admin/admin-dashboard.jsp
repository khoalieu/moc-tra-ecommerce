<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
</head>
<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Dashboard</h1>
            </div>

            <div class="header-right">
                <div class="header-search">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh...">
                </div>

                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">

            <div class="admin-widgets">
                <div class="widget">
                    <div class="widget-header">
                        <h3>Đơn hàng gần đây</h3>
                        <a href="admin/orders" class="widget-link">Xem tất cả</a>
                    </div>
                    <div class="widget-content">
                        <div class="item-list">
                            <c:forEach var="o" items="${recentOrders}">
                                <div class="list-item">
                                    <div class="item-info">
                                        <a href="admin/order/detail?id=${o.id}" class="item-title"
                                           style="text-decoration: none;">
                                            #${o.orderNumber}
                                        </a>
                                        <div class="item-subtitle">
                                                ${o.notes.contains('-') ? o.notes.split('-')[0] : 'Khách lẻ'}
                                        </div>
                                        <small style="color: #999; font-size: 11px;">
                                            <fmt:formatDate value="${o.createdAt}" pattern="dd/MM HH:mm"/>
                                        </small>
                                    </div>
                                    <div class="item-details">
                                        <div class="item-amount">
                                            <fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/>₫
                                        </div>

                                        <c:choose>
                                            <c:when test="${o.status == 'PENDING'}">
                                                <span class="status-badge status-pending">Chờ xử lý</span>
                                            </c:when>
                                            <c:when test="${o.status == 'COMPLETED'}">
                                                <span class="status-badge status-active">Hoàn tất</span>
                                            </c:when>
                                            <c:when test="${o.status == 'CANCELLED'}">
                                                <span class="status-badge status-inactive">Đã hủy</span>
                                            </c:when>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty recentOrders}">
                                <div style="padding: 30px; text-align: center; color: #999;">
                                    <i class="fas fa-box-open" style="font-size: 30px; margin-bottom: 10px;"></i>
                                    <p>Chưa có đơn hàng nào.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

            </div>

            <div class="quick-actions">
                <h3>Thao tác nhanh</h3>
                <div class="actions-grid">
                    <a href="admin/product/add" class="action-card">
                        <i class="fas fa-plus-circle"></i>
                        <span>Thêm sản phẩm mới</span>
                    </a>

                    <a href="admin/orders" class="action-card">
                        <i class="fas fa-shopping-cart"></i>
                        <span>Xử lý đơn hàng</span>
                    </a>

                    <a href="admin/customers" class="action-card">
                        <i class="fas fa-users"></i>
                        <span>Quản lý khách hàng</span>
                    </a>

                    <a href="admin/blog/add" class="action-card">
                        <i class="fas fa-pen-nib"></i>
                        <span>Viết bài blog</span>
                    </a>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>