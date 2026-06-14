<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<aside class="admin-sidebar">
    <div class="sidebar-header">
        <div class="admin-logo">
            <img src="${ctx}/assets/images/logoweb.png" alt="Mộc Trà">
            <h2>Mộc Trà Admin</h2>
        </div>
    </div>

    <nav class="admin-nav">
        <ul>
            <li class="nav-item ${param.activePage == 'dashboard' ? 'active' : ''}">
                <a href="${ctx}/admin/dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
            </li>

            <c:if test="${sessionScope.user.hasPermission('product.view')}">
                <li class="nav-item ${param.activePage == 'products' ? 'active' : ''}">
                    <a href="${ctx}/admin/products">
                        <i class="fas fa-box"></i>
                        <span>Tất cả Sản phẩm</span>
                    </a>
                </li>

                <li class="nav-item ${param.activePage == 'inventory' ? 'active' : ''}">
                    <a href="${ctx}/admin/inventory">
                        <i class="fas fa-boxes-stacked"></i>
                        <span>Quản lý tồn kho</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('banner.manage')}">
                <li class="nav-item ${param.activePage == 'banners' ? 'active' : ''}">
                    <a href="${ctx}/admin/banner">
                        <i class="fas fa-images"></i>
                        <span>Quản lý Banner</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('category.manage')}">
                <li class="nav-item ${param.activePage == 'categories' ? 'active' : ''}">
                    <a href="${ctx}/admin/categories">
                        <i class="fas fa-sitemap"></i>
                        <span>Danh mục Sản phẩm</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('order.view')}">
                <li class="nav-item ${param.activePage == 'orders' ? 'active' : ''}">
                    <a href="${ctx}/admin/orders">
                        <i class="fas fa-shopping-cart"></i>
                        <span>Đơn hàng</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('order.refund')}">
                <li class="nav-item ${param.activePage == 'refunds' ? 'active' : ''}">
                    <a href="${ctx}/admin/refunds">
                        <i class="fas fa-money-bill-transfer"></i>
                        <span>Hoàn tiền</span>
                    </a>
                </li>
            </c:if>

            <li class="nav-item ${param.activePage == 'notifications' ? 'active' : ''}">
                <a href="${ctx}/admin/notifications" class="admin-notification-nav"
                   data-summary-url="${ctx}/admin/notifications?action=summary">
                    <i class="far fa-bell"></i>
                    <span>Thông báo</span>
                    <span class="badge admin-notification-badge" style="display:none;"></span>
                </a>
            </li>

            <c:if test="${sessionScope.user.hasPermission('customer.view')}">
                <li class="nav-item ${param.activePage == 'customers' ? 'active' : ''}">
                    <a href="${ctx}/admin/customers">
                        <i class="fas fa-users"></i>
                        <span>Khách hàng</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('contact.manage')}">
                <li class="nav-item ${param.activePage == 'contacts' ? 'active' : ''}">
                    <a href="${ctx}/admin/contacts" class="admin-contact-nav"
                       data-summary-url="${ctx}/admin/contacts?action=summary">
                        <i class="fas fa-envelope-open-text"></i>
                        <span>Quản lý Liên hệ</span>
                        <span class="badge admin-contact-badge" style="display:none;"></span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('blog.view')}">
                <li class="nav-item ${param.activePage == 'blog' ? 'active' : ''}">
                    <a href="${ctx}/admin/blog">
                        <i class="fas fa-newspaper"></i>
                        <span>Tất cả Bài viết</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('blog.manage_category')}">
                <li class="nav-item ${param.activePage == 'blog-categories' ? 'active' : ''}">
                    <a href="${ctx}/admin/blog-categories">
                        <i class="fas fa-folder"></i>
                        <span>Danh mục Blog</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('promotion.manage')}">
                <li class="nav-item ${param.activePage == 'promotions' ? 'active' : ''}">
                    <a href="${ctx}/admin/promotions">
                        <i class="fa-solid fa-percent"></i>
                        <span>Quản lý khuyến mãi</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('system.logs')}">
                <li class="nav-item ${param.activePage == 'system-logs' ? 'active' : ''}">
                    <a href="${ctx}/admin/system-logs">
                        <i class="fas fa-history"></i>
                        <span>Nhật ký hệ thống</span>
                    </a>
                </li>
            </c:if>

            <c:if test="${sessionScope.user.hasPermission('role.manage')}">
                <li class="nav-item ${param.activePage == 'roles' ? 'active' : ''}">
                    <a href="${ctx}/admin/roles">
                        <i class="fas fa-shield-alt"></i>
                        <span>Phân quyền RBAC</span>
                    </a>
                </li>
            </c:if>
        </ul>
    </nav>
</aside>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        loadAdminSidebarBadge(".admin-notification-nav", ".admin-notification-badge");
        loadAdminSidebarBadge(".admin-contact-nav", ".admin-contact-badge");

        function loadAdminSidebarBadge(navSelector, badgeSelector) {
            const nav = document.querySelector(navSelector);
            if (!nav) {
                return;
            }

            const badge = nav.querySelector(badgeSelector);
            const summaryUrl = nav.getAttribute("data-summary-url");
            if (!badge || !summaryUrl) {
                return;
            }

            fetch(summaryUrl)
                .then(function (response) {
                    return response.json();
                })
                .then(function (data) {
                    const unreadCount = data && data.unreadCount ? data.unreadCount : 0;
                    if (unreadCount > 0) {
                        badge.innerText = unreadCount;
                        badge.style.display = "inline-block";
                    } else {
                        badge.style.display = "none";
                    }
                })
                .catch(function () {
                    badge.style.display = "none";
                });
        }
    });
</script>
