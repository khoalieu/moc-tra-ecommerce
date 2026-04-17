<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
    <div class="profile-card">
        <div class="profile-header">
            <div class="avatar-circle">
                <%-- Lấy ký tự đầu tiên của tên, nếu không có thì hiện 'U' --%>
                ${not empty sessionScope.user.username ? sessionScope.user.username.charAt(0) : 'U'}
            </div>
            <div class="email">${sessionScope.user.email}</div>
        </div>

        <div class="profile-body">
            <button class="btn-shopping" onclick="window.location.href='san-pham'">Tiếp tục mua sắm</button>
        </div>
    </div>

    <nav class="side-menu">
        <ul>
            <%-- Mục 1: Tổng quan (Dashboard) --%>
            <li class="${param.activePage == 'tong-quan' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/user-dashboard"><i class="fa-solid fa-house"></i> Tổng quan</a>
            </li>

            <%-- Mục 2: Tài khoản (Profile) --%>
            <li class="${param.activePage == 'tai-khoan' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/tai-khoan-cua-toi"><i class="fa-regular fa-user"></i> Tài khoản của tôi</a>
            </li>

            <%-- Mục 3: Địa chỉ (Address) --%>
            <li class="${param.activePage == 'dia-chi' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/dia-chi-nguoi-dung"><i class="fa-solid fa-location-dot"></i> Địa chỉ</a>
            </li>

            <%-- Mục 4: Đơn hàng (Orders) --%>
            <li class="${param.activePage == 'don-hang' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/don-hang"><i class="fa-solid fa-cart-shopping"></i> Đơn hàng của tôi</a>
            </li>

            <li class="${param.activePage == 'yeu-thich' ? 'active' : ''}">
                <a href="${pageContext.request.contextPath}/san-pham-yeu-thich">
                    <i class="fa-solid fa-heart"></i> Sản phẩm yêu thích
                </a>
            </li>

            <%-- Mục 5: Đăng xuất --%>
            <li>
                <a href="${pageContext.request.contextPath}/logout" style="color: #dc3545;"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
            </li>
        </ul>
    </nav>
</aside>