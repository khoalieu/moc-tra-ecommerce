<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
                                <img src="${pageContext.request.contextPath}/assets/images/logoweb.png"
                                     alt="Tea Shop Logo">
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
                                    <li><a href="${pageContext.request.contextPath}/san-pham?category=1">Tất cả Trà Thảo
                                        Mộc</a></li>
                                </ul>
                            </div>
                            <div class="dropdown-column">
                                <h3>Nguyên Liệu Trà Sữa</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/san-pham?category=2">Nguyên Liệu Pha
                                        Chế</a></li>
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
                                    <li><a href="${pageContext.request.contextPath}/ve-chung-toi">Câu Chuyện Của Chúng
                                        Tôi</a></li>
                                    <li><a href="${pageContext.request.contextPath}/tra-thao-moc">Hành Trình Của Những
                                        Tách Trà</a></li>
                                    <li><a href="${pageContext.request.contextPath}/tra-sua-nguyen-lieu">Thông Tin Về
                                        Trà Sữa Nguyên Liệu</a></li>
                                </ul>
                            </div>

                            <div class="dropdown-column">
                                <h3>Thông Tin Và Chính Sách</h3>
                                <ul>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-ban-hang">Chính Sách Bán
                                        Hàng</a></li>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-thanh-toan">Chính Sách
                                        Thanh Toán</a></li>
                                    <li><a href="${pageContext.request.contextPath}/chinh-sach-bao-hanh">Chính Sách Bảo
                                        Hành</a></li>
                                    <li><a href="${pageContext.request.contextPath}/dieu-khoan-dich-vu">Điều Khoản Dịch
                                        Vụ</a></li>
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

                <div class="search-wrapper">
                    <form action="${pageContext.request.contextPath}/san-pham" method="get" class="search-bar" autocomplete="off">
                        <button type="submit" style="border:none; background:none;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </button>

                        <input type="text"
                               id="headerSearchInput"
                               name="search"
                               value="${currentSearch}"
                               placeholder="Bạn muốn tìm gì...">

                        <div id="searchSuggestionBox" class="search-suggestion-box"></div>
                    </form>
                </div>
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
                                            <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${item.product.id}"
                                               style="color: inherit; text-decoration: none;">
                                                    ${item.product.name}
                                            </a>
                                        </h4>

                                        <c:if test="${not empty item.variant}">
                                            <p style="font-size: 0.8rem; color: #888; margin: 2px 0 5px 0;">
                                                Phân loại: ${item.variant.variantName}
                                            </p>
                                        </c:if>
                                        <p class="cart-item-quantity">
                                                ${item.quantity} ×
                                            <span class="cart-item-price">
                                                <fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/> VNĐ
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
                        <fmt:formatNumber value="${sessionScope.cart.totalMoney}" pattern="#,###"/> VNĐ
                    </span>
                                </div>
                            </c:if>

                            <div class="cart-actions">
                                <a href="${pageContext.request.contextPath}/gio-hang" class="btn-view-cart">XEM GIỎ
                                    HÀNG</a>
                                <a href="${pageContext.request.contextPath}/thanh-toan" class="btn-checkout">THANH
                                    TOÁN</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="user-account" style="display: flex; align-items: center; justify-content: center;">
                    <%-- Kiểm tra class an toàn hơn --%>
                    <c:choose>
                        <%-- Nếu có avatar: Ép kích thước TRỰC TIẾP --%>
                        <c:when test="${not empty sessionScope.user and not empty sessionScope.user.avatar}">
                            <div class="avatar-wrapper" style="width: 35px !important; height: 35px !important; border-radius: 50% !important; overflow: hidden !important; border: 2px solid #107e84; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                <img src="${pageContext.request.contextPath}/image/${sessionScope.user.avatar}?t=<%=System.currentTimeMillis()%>"
                                     alt="User Avatar"
                                     style="width: 100% !important; height: 100% !important; object-fit: cover !important; display: block;">
                            </div>
                        </c:when>

                        <%-- Nếu chưa có avatar hoặc chưa đăng nhập --%>
                        <c:otherwise>
                            <span class="user-icons" style="display: flex; align-items: center; justify-content: center; width: 35px; height: 35px; border-radius: 4px; border: 1px solid #ddd; flex-shrink: 0;">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.user}">
                                        <i class="fa-solid fa-user-circle" style="font-size: 20px; color: #e67e22;"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-solid fa-user" style="font-size: 16px;"></i>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </c:otherwise>
                    </c:choose>
                        <c:if test="${not empty sessionScope.user and sessionScope.user.isVip}">
                            <span class="user-vip-badge user-vip-badge--small" style="margin-left: 6px;">
                                <i class="fa-solid fa-crown"></i> VIP
                            </span>
                        </c:if>

                    <div class="user-dropdown">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user}">
                                <div style="padding: 10px; border-bottom: 1px solid #eee;">
                                    <div class="user-vip-inline">
                                        <span>
                                            Xin chào,
                                            <strong>${sessionScope.user.lastName} ${sessionScope.user.firstName}</strong>
                                        </span>

                                        <c:if test="${sessionScope.user.isVip}">
                                            <span class="user-vip-badge user-vip-badge--small">
                                                <i class="fa-solid fa-crown"></i> VIP
                                            </span>
                                        </c:if>
                                    </div>                                </div>
                                <c:if test="${sessionScope.user.role == 'ADMIN'}">
                                    <a href="${pageContext.request.contextPath}/admin/admin-dashboard.jsp">Trang quản trị</a>
                                </c:if>
                                <c:if test="${sessionScope.user.role == 'EDITOR'}">
                                    <a href="${pageContext.request.contextPath}/editor/dashboard">
                                        <i class="fa-solid fa-pen-nib" style="margin-right: 8px;"></i>
                                        Trang quản trị
                                    </a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/tai-khoan-cua-toi">
                                    <i class="fa-regular fa-user" style="margin-right: 8px;"></i>
                                    Tài khoản của tôi
                                </a>

                                <a href="${pageContext.request.contextPath}/don-hang">
                                    <i class="fa-solid fa-bag-shopping" style="margin-right: 8px;"></i>
                                    Đơn mua
                                </a>
                                <a href="${pageContext.request.contextPath}/ma-uu-dai-cua-toi">
                                    <i class="fa-solid fa-ticket" style="margin-right: 8px;"></i>
                                    Mã ưu đãi của tôi
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
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const searchInput = document.getElementById("headerSearchInput");
        const suggestionBox = document.getElementById("searchSuggestionBox");
        const contextPath = "${pageContext.request.contextPath}";

        if (!searchInput || !suggestionBox) {
            return;
        }

        let searchTimer = null;

        searchInput.addEventListener("input", function () {
            const keyword = searchInput.value.trim();

            clearTimeout(searchTimer);

            if (keyword.length < 2) {
                hideSuggestions();
                return;
            }

            searchTimer = setTimeout(function () {
                fetch(contextPath + "/search-suggestions?keyword=" + encodeURIComponent(keyword))
                    .then(function (response) {
                        return response.json();
                    })
                    .then(function (data) {
                        renderSuggestions(data, keyword);
                    })
                    .catch(function () {
                        hideSuggestions();
                    });
            }, 250);
        });

        document.addEventListener("click", function (event) {
            if (!event.target.closest(".search-wrapper")) {
                hideSuggestions();
            }
        });

        searchInput.addEventListener("focus", function () {
            const keyword = searchInput.value.trim();
            if (keyword.length >= 2) {
                searchInput.dispatchEvent(new Event("input"));
            }
        });

        function renderSuggestions(data, keyword) {
            const products = data && data.products ? data.products : [];
            const blog = data ? data.blog : null;

            let html = "";

            if (products.length > 0) {
                html += '<div class="search-suggestion-header">Sản phẩm gợi ý</div>';

                products.forEach(function (product) {
                    const imageUrl = product.imageUrl && product.imageUrl.trim() !== ""
                        ? product.imageUrl
                        : contextPath + "/assets/images/no-image.png";

                    html += '<a class="search-suggestion-item" href="' + contextPath + '/chi-tiet-san-pham?id=' + product.id + '">';
                    html += '<img src="' + escapeHtml(imageUrl) + '" onerror="this.src=\'' + contextPath + '/assets/images/no-image.png\'">';
                    html += '<div class="search-suggestion-info">';
                    html += '<div class="search-suggestion-name">' + escapeHtml(product.name) + '</div>';
                    html += '<div class="search-suggestion-price">' + formatCurrency(product.price) + '</div>';
                    html += '</div>';
                    html += '</a>';
                });
            }

            if (blog) {
                html += '<div class="search-suggestion-header">Bài viết liên quan</div>';

                const blogImage = blog.imageUrl && blog.imageUrl.trim() !== ""
                    ? blog.imageUrl
                    : contextPath + "/assets/images/no-image.png";

                html += '<a class="search-suggestion-item" href="' + contextPath + '/blog/' + encodeURIComponent(blog.slug) + '">';
                html += '<img src="' + escapeHtml(blogImage) + '" onerror="this.src=\'' + contextPath + '/assets/images/no-image.png\'">';
                html += '<div class="search-suggestion-info">';
                html += '<div class="search-suggestion-name">' + escapeHtml(blog.title) + '</div>';
                html += '<div class="search-suggestion-price" style="color:#107e84;">Xem bài viết</div>';
                html += '</div>';
                html += '</a>';
            }

            if (products.length === 0 && !blog) {
                html += '<div class="search-suggestion-empty">Không tìm thấy kết quả phù hợp</div>';
            }

            html += '<a class="search-view-all" href="' + contextPath + '/san-pham?search=' + encodeURIComponent(keyword) + '">Xem tất cả sản phẩm cho "' + escapeHtml(keyword) + '"</a>';

            suggestionBox.innerHTML = html;
            suggestionBox.style.display = "block";
        }

        function hideSuggestions() {
            suggestionBox.style.display = "none";
            suggestionBox.innerHTML = "";
        }

        function formatCurrency(value) {
            if (!value) {
                value = 0;
            }

            return Number(value).toLocaleString("vi-VN") + "₫";
        }

        function escapeHtml(value) {
            if (value === null || value === undefined) {
                return "";
            }

            return String(value)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }
    });
</script>