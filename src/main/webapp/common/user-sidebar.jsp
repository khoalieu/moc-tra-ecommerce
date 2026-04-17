<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<aside class="sidebar">
    <div class="profile-card">
        <div class="profile-header">
            <div class="avatar-container" style="margin-bottom: 15px;">
                <c:choose>
                    <c:when test="${not empty sessionScope.user.avatar}">
                        <img id="sideAvatarPreview"
                            <%-- THÊM CHỮ /image VÀO ĐÂY --%>
                             src="${pageContext.request.contextPath}/image/${sessionScope.user.avatar}?t=<%=System.currentTimeMillis()%>"
                             alt="Avatar"
                             style="width: 80px; height: 80px; border-radius: 50%; object-fit: cover; border: 2px solid #e67e22; display: block; margin: 0 auto;">
                    </c:when>
                    <c:otherwise>
                        <div class="avatar-circle" style="width: 80px; height: 80px; border-radius: 50%; background: #e67e22; color: white; display: flex; align-items: center; justify-content: center; font-size: 28px; font-weight: bold; margin: 0 auto; border: 2px solid #ddd;">
                                ${not empty sessionScope.user.username ? sessionScope.user.username.charAt(0).toString().toUpperCase() : 'U'}
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="email" style="font-size: 0.85em; color: #666; margin-bottom: 15px; word-break: break-all;">
                ${sessionScope.user.email}
            </div>

            <div class="avatar-controls" style="display: flex; gap: 8px; justify-content: center; align-items: center;">

                <label for="sideAvatarInput" class="btn-side-avatar" style="background: #e67e22; color: white; padding: 6px 10px; border-radius: 4px; font-size: 11px; cursor: pointer; display: flex; align-items: center; gap: 4px; transition: 0.3s;">
                    <i class="fa-solid fa-upload"></i> Đổi ảnh
                </label>

                <c:if test="${not empty sessionScope.user.avatar}">
                    <button type="button" onclick="removeSideAvatar()" style="background: #dc3545; color: white; padding: 6px 10px; border: none; border-radius: 4px; font-size: 11px; cursor: pointer; display: flex; align-items: center; gap: 4px; transition: 0.3s;">
                        <i class="fa-solid fa-trash-can"></i> Xóa ảnh
                    </button>
                </c:if>
            </div>

            <form action="${pageContext.request.contextPath}/tai-khoan-cua-toi" method="post" enctype="multipart/form-data" id="sideAvatarForm" style="display: none;">
                <input type="hidden" name="action" value="uploadAvatar">
                <input type="file" id="sideAvatarInput" name="avatar" accept="image/*" onchange="document.getElementById('sideAvatarForm').submit();">
            </form>

            <form action="${pageContext.request.contextPath}/tai-khoan-cua-toi" method="post" id="sideRemoveForm" style="display: none;">
                <input type="hidden" name="action" value="removeAvatar">
            </form>
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
<script>
    function removeSideAvatar() {
        if (confirm('Bạn có chắc chắn muốn xóa ảnh đại diện này không?')) {
            document.getElementById('sideRemoveForm').submit();
        }
    }
</script>