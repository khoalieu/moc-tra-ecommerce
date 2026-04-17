<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<div class="top-bar">
    <div class="container">
        <div class="top-bar__left">
            <span>
                <i class="fa-solid fa-envelope"></i> contact@moctra.com
            </span>
            <span>
                <i class="fa-solid fa-phone"></i> 0888 531 015
            </span>
        </div>
        <div class="top-bar__right">
            <i class="fa-brands fa-facebook"></i>
            <i class="fa-brands fa-instagram"></i>
            <i class="fa-brands fa-twitter"></i>
        </div>
    </div>
</div>

<header class="utility-header">
    <div class="header-left">
        <nav class="main-nav">
            <div class="container">
                <ul>
                    <li>
                        <div class="logo">
                            <a href="${pageContext.request.contextPath}/">
                                <img src="${pageContext.request.contextPath}/assets/images/logoweb.png" alt="Tea Shop Logo">
                            </a>
                        </div>
                    </li>

                    <li><a href="${pageContext.request.contextPath}/index">TRANG CHỦ</a></li>

                    <li class="has-dropdown">
                        <a href="${pageContext.request.contextPath}/san-pham">SẢN PHẨM</a>

                        <div class="dropdown-menu">
                            <div class="dropdown-column">
                                <h3>Trà Thảo Mộc</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/san-pham?category=1">Tất cả Trà Thảo Mộc</a></li>
                                </ul>
                            </div>
                            <div class="dropdown-column">
                                <h3>Nguyên Liệu Trà Sữa</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/san-pham?category=2">Nguyên Liệu Pha Chế</a></li>
                                </ul>
                            </div>
                        </div>
                    </li>

                    <li><a href="${pageContext.request.contextPath}/blog">CÔNG THỨC & BLOG</a></li>

                    <li class="has-dropdown">
                        <a href="${pageContext.request.contextPath}/ve-chung-toi">VỀ CHÚNG TÔI</a>

                        <div class="dropdown-menu">
                            <div class="dropdown-column">
                                <h3>Câu Chuyện Về Trà</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/ve-chung-toi">Câu Chuyện Của Chúng Tôi</a></li>
                                    <li><a href="${pageContext.request.contextPath}/tra-thao-moc">Hành Trình Của Những Tách Trà</a></li>
                                    <li><a href="${pageContext.request.contextPath}/tra-sua-nguyen-lieu">Thông Tin Về Trà Sữa Nguyên Liệu</a></li>
                                </ul>
                            </div>

                            <div class="dropdown-column">
                                <h3>Thông Tin Và Chính Sách</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-ban-hang">Chính Sách Bán Hàng</a></li>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-thanh-toan">Chính Sách Thanh Toán</a></li>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-bao-hanh">Chính Sách Bảo Hành</a></li>
                                    <li><a href="${pageContext.request.contextPath}/dieu-khoan-dich-vu">Điều Khoản Dịch Vụ</a></li>
                                </ul>
                            </div>
                        </div>
                    </li>

                    <li><a href="${pageContext.request.contextPath}/khuyen-mai">KHUYẾN MÃI</a></li>
                </ul>
            </div>
        </nav>
    </div>

    <div class="header-right">
        <div class="container">
            <div class="header-right__content">

                <form action="${pageContext.request.contextPath}/san-pham" method="get" class="search-bar">
                    <button type="submit" style="border:none; background:none;">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                    <input type="text" name="search" value="${currentSearch}" placeholder="Bạn muốn tìm gì...">
                </form>
                <div class="cart-container">
                    <%-- 1. Phần hiển thị Text và Icon ) --%>
                    <span class="cart-text">
        <i class="fa-solid fa-cart-shopping"></i>
        <span>
            <a href="${pageContext.request.contextPath}/gio-hang" style="color: inherit; text-decoration: none;">
                Giỏ Hàng (${sessionScope.cart != null ? sessionScope.cart.totalQuantity : 0})
            </a>
        </span>
    </span>

                    <%-- 2. Phần Dropdown xổ xuống --%>
                    <div class="cart-dropdown">
                        <div class="cart-dropdown-header">
                            <h3>Giỏ hàng của bạn</h3>
                        </div>

                        <div class="cart-items" style="max-height: 300px; overflow-y: auto;">
                            <%-- Kiểm tra giỏ hàng trống --%>
                            <c:if test="${sessionScope.cart == null || sessionScope.cart.items.size() == 0}">
                                <p style="padding: 20px; text-align: center; color: #666;">
                                    Giỏ hàng đang trống
                                </p>
                            </c:if>

                            <%-- Duyệt danh sách sản phẩm --%>
                            <c:forEach var="item" items="${sessionScope.cart.items}">
                                <div class="cart-item">
                                    <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                         onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">

                                    <div class="cart-item-info">
                                        <h4>
                                            <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${item.product.id}" style="color: inherit; text-decoration: none;">
                                                    ${item.product.name}
                                            </a>
                                        </h4>
                                        <p class="cart-item-quantity">
                                                ${item.quantity} ×
                                            <span class="cart-item-price">
                                <c:choose>
                                    <c:when test="${item.product.salePrice > 0}">
                                        <fmt:formatNumber value="${item.product.salePrice}" type="currency"/>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${item.product.price}" type="currency"/>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                                        </p>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="cart-dropdown-footer">
                            <%-- Hiển thị Tổng tiền --%>
                            <c:if test="${sessionScope.cart != null && sessionScope.cart.items.size() > 0}">
                                <div class="cart-total">
                                    <span>Tổng tiền:</span>
                                    <span class="total-price">
                        <fmt:formatNumber value="${sessionScope.cart.totalMoney}" type="currency"/>
                    </span>
                                </div>
                            </c:if>

                            <div class="cart-actions">
                                <a href="${pageContext.request.contextPath}/gio-hang" class="btn-view-cart">XEM GIỎ HÀNG</a>
                                <a href="${pageContext.request.contextPath}/thanh-toan" class="btn-checkout">THANH TOÁN</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="user-account">
                    <span class="user-icons">
                        <i class="fa-solid fa-user"></i>
                    </span>

                    <div class="user-dropdown">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <div style="padding: 10px; border-bottom: 1px solid #eee;">
                                    Xin chào, <strong>${sessionScope.user.lastName} ${sessionScope.user.firstName}</strong>
                                </div>
                                <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                    <a href="${pageContext.request.contextPath}/admin/admin-dashboard.jsp">Trang quản trị</a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/tai-khoan-cua-toi">
                                    <i class="fa-regular fa-user" style="margin-right: 8px;"></i>
                                    Tài khoản của tôi
                                </a>

                                <a href="${pageContext.request.contextPath}/don-hang">
                                    <i class="fa-solid fa-bag-shopping" style="margin-right: 8px;"></i>
                                    Đơn mua
                                </a>

                                <a href="${pageContext.request.contextPath}/san-pham-yeu-thich">
                                    <i class="fa-solid fa-heart" style="margin-right: 8px;"></i>
                                    Sản phẩm yêu thích
                                </a>

                                <a href="${pageContext.request.contextPath}/logout" style="color: #dc3545;">
                                    <i class="fa-solid fa-right-from-bracket" style="margin-right: 8px;"></i>
                                    Đăng xuất
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                                <a href="${pageContext.request.contextPath}/signup">Đăng ký</a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </div>
    </div>
</header>