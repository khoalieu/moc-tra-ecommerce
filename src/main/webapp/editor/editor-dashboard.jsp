<%--
  Created by IntelliJ IDEA.
  User: Hi
  Date: 25/05/2026
  Time: 1:36 SA
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Editor Dashboard - Mộc Trà</title>
    <base href="${ctx}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">
    <link rel="stylesheet" href="${ctx}/editor/assets/css/editor-admin.css">
    <link rel="stylesheet" href="../editor/assets/css/editor-dashboard.css">
</head>

<body>
<div class="admin-container">

    <jsp:include page="/common/editor-sidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Editor Dashboard</h1>
            </div>
        </header>

        <div class="admin-content">
            <div class="page-header">
                <div class="page-title">
                    <h2>Quản lý nội dung</h2>
                    <p>Truy cập nhanh các chức năng dành cho Editor.</p>
                </div>
            </div>

            <div class="dashboard-grid">
                <a href="${ctx}/editor/blog" class="dashboard-card">
                    <h3><i class="fas fa-newspaper"></i> Quản lý bài viết</h3>
                    <p>Tạo, chỉnh sửa và quản lý bài viết blog.</p>
                </a>
            </div>
        </div>
    </main>
</div>
</body>
</html>
