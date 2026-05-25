<%--
  Created by IntelliJ IDEA.
  User: Hi
  Date: 25/05/2026
  Time: 1:25 SA
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<aside class="admin-sidebar">
    <div class="sidebar-header">
        <div class="admin-logo">
            <img src="${ctx}/assets/images/logoweb.png" alt="Mộc Trà">
            <h2>Mộc Trà Editor</h2>
        </div>
    </div>

    <nav class="admin-nav">
        <ul>
            <li class="nav-item ${param.activePage == 'dashboard' ? 'active' : ''}">
                <a href="${ctx}/editor/dashboard">
                    <i class="fas fa-tachometer-alt"></i>
                    <span>Dashboard</span>
                </a>
            </li>

            <li class="nav-item ${param.activePage == 'blog' ? 'active' : ''}">
                <a href="${ctx}/editor/blog">
                    <i class="fas fa-newspaper"></i>
                    <span>Quản lý bài viết</span>
                </a>
            </li>
        </ul>
    </nav>
</aside>
