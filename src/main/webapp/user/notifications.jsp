<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo của tôi - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/notifications.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="user-dashboard-page">
<jsp:include page="/common/header.jsp"/>

<div class="container notification-account-shell">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="thong-bao"/>
    </jsp:include>

    <main class="notification-page">
        <section class="notification-page-head">
            <div>
                <h1>Thông báo của tôi</h1>
                <p>Theo dõi các cập nhật quan trọng về đơn hàng trong tài khoản.</p>
            </div>

            <c:if test="${unreadCount > 0}">
                <a class="notification-mark-all-btn" href="${pageContext.request.contextPath}/thong-bao?action=markAll">
                    <i class="fa-solid fa-check-double"></i>
                    Đánh dấu tất cả đã đọc
                </a>
            </c:if>
        </section>

        <section class="notification-list">
            <c:choose>
                <c:when test="${empty notifications}">
                    <div class="notification-empty">
                        <i class="fa-regular fa-bell"></i>
                        <h2>Chưa có thông báo</h2>
                        <p>Khi đơn hàng có cập nhật mới, thông báo sẽ hiển thị tại đây.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="notification" items="${notifications}">
                        <c:set var="iconClass" value="order"/>
                        <c:set var="iconName" value="fa-box"/>
                        <c:choose>
                            <c:when test="${fn:startsWith(notification.type, 'payment_')}">
                                <c:set var="iconClass" value="payment"/>
                                <c:set var="iconName" value="fa-credit-card"/>
                            </c:when>
                            <c:when test="${fn:startsWith(notification.type, 'refund_')}">
                                <c:set var="iconClass" value="refund"/>
                                <c:set var="iconName" value="fa-rotate-left"/>
                            </c:when>
                            <c:when test="${fn:startsWith(notification.type, 'account_')}">
                                <c:set var="iconClass" value="account"/>
                                <c:set var="iconName" value="fa-user-gear"/>
                            </c:when>
                            <c:when test="${fn:startsWith(notification.type, 'promotion_')}">
                                <c:set var="iconClass" value="promotion"/>
                                <c:set var="iconName" value="fa-tags"/>
                            </c:when>
                        </c:choose>
                        <article class="notification-item ${!notification.read ? 'unread' : ''}">
                            <div class="notification-icon ${iconClass}">
                                <i class="fa-solid ${iconName}"></i>
                            </div>

                            <div class="notification-content">
                                <div class="notification-row">
                                    <h2>${notification.title}</h2>
                                    <span>
                                        <fmt:formatDate value="${notification.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </span>
                                </div>

                                <p>${notification.message}</p>

                                <a href="${pageContext.request.contextPath}/thong-bao?action=read&id=${notification.id}">
                                    Xem chi tiết
                                </a>
                            </div>
                        </article>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </section>

        <c:if test="${currentPage > 1 || hasNextPage}">
            <nav class="notification-pagination">
                <c:if test="${currentPage > 1}">
                    <a href="${pageContext.request.contextPath}/thong-bao?page=${currentPage - 1}">
                        <i class="fa-solid fa-angle-left"></i> Trang trước
                    </a>
                </c:if>
                <span>Trang ${currentPage}</span>
                <c:if test="${hasNextPage}">
                    <a href="${pageContext.request.contextPath}/thong-bao?page=${currentPage + 1}">
                        Trang sau <i class="fa-solid fa-angle-right"></i>
                    </a>
                </c:if>
            </nav>
        </c:if>
    </main>
</div>

<jsp:include page="/common/footer.jsp"/>
</body>
</html>
