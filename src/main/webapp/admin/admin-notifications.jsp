<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông báo - Mộc Trà Admin</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="notifications"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Thông báo</h1>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <div class="page-header">
                <div class="page-title">
                    <h2>Thông báo quản trị</h2>
                    <p>Theo dõi các việc quan trọng cần admin xử lý trong hệ thống.</p>
                </div>

                <c:if test="${unreadCount > 0}">
                    <a class="btn btn-outline" href="admin/notifications?action=markAll">
                        <i class="fas fa-check-double"></i>
                        Đánh dấu tất cả đã đọc
                    </a>
                </c:if>
            </div>

            <section class="admin-notification-list">
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="admin-notification-empty">
                            <i class="far fa-bell"></i>
                            <h3>Chưa có thông báo</h3>
                            <p>Khi có sự kiện cần xử lý, thông báo sẽ hiển thị tại đây.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="notification" items="${notifications}">
                            <article class="admin-notification-item ${!notification.read ? 'unread' : ''}">
                                <div class="admin-notification-icon">
                                    <i class="fas fa-bell"></i>
                                </div>
                                <div class="admin-notification-content">
                                    <div class="admin-notification-row">
                                        <h3>${notification.title}</h3>
                                        <span>
                                            <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </span>
                                    </div>
                                    <p>${notification.message}</p>
                                    <a href="admin/notifications?action=read&id=${notification.id}">
                                        Xem chi tiết
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>

            <c:if test="${currentPage > 1 || hasNextPage}">
                <div class="admin-notification-pagination">
                    <c:if test="${currentPage > 1}">
                        <a href="admin/notifications?page=${currentPage - 1}" class="page-btn">
                            <i class="fas fa-angle-left"></i> Trang trước
                        </a>
                    </c:if>
                    <span class="page-btn active">Trang ${currentPage}</span>
                    <c:if test="${hasNextPage}">
                        <a href="admin/notifications?page=${currentPage + 1}" class="page-btn">
                            Trang sau <i class="fas fa-angle-right"></i>
                        </a>
                    </c:if>
                </div>
            </c:if>
        </div>
    </main>
</div>
</body>
</html>
