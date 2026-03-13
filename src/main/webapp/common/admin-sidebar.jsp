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

            <li class="nav-item ${param.activePage == 'products' ? 'active' : ''}">
                <a href="${ctx}/admin/products">
                    <i class="fas fa-box"></i>
                    <span>Tất cả Sản phẩm</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'banners' ? 'active' : ''}">
                <a href="${ctx}/admin/banner">
                    <i class="fas fa-images"></i>
                    <span>Quản lý Banner</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'categories' ? 'active' : ''}">
                <a href="${ctx}/admin/categories">
                    <i class="fas fa-sitemap"></i>
                    <span>Danh mục Sản phẩm</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'orders' ? 'active' : ''}">
                <a href="${ctx}/admin/orders">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Đơn hàng</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'customers' ? 'active' : ''}">
                <a href="${ctx}/admin/customers">
                    <i class="fas fa-users"></i>
                    <span>Khách hàng</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'blog' ? 'active' : ''}">
                <a href="${ctx}/admin/blog">
                    <i class="fas fa-newspaper"></i>
                    <span>Tất cả Bài viết</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'blog-categories' ? 'active' : ''}">
                <a href="${ctx}/admin/blog-categories">
                    <i class="fas fa-folder"></i>
                    <span>Danh mục Blog</span>
                </a>
            </li>
            <li class="nav-item ${param.activePage == 'promotions' ? 'active' : ''}">
                <a href="${ctx}/admin/promotions">
                    <i class="fa-solid fa-percent"></i>
                    <span>Quản lý khuyến mãi</span>
                </a>
            </li>
        </ul>
    </nav>
</aside>