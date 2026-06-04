<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Vai trò &amp; Quyền hạn - Mộc Trà Admin</title>
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin-rbac.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="roles"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1><i class="fas fa-shield-alt" style="color:#4f46e5;margin-right:10px;"></i>Quản lý Vai trò &amp; Quyền hạn</h1>
            </div>
        </header>

        <div class="admin-content">

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="rbac-flash success">
                    <i class="fas fa-check-circle"></i> ${sessionScope.successMsg}
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="rbac-flash error">
                    <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <div class="rbac-grid">

                <%-- CỘT TRÁI: Form tạo vai trò mới --%>
                <div>
                    <div class="rbac-section">
                        <h3>
                            <i class="fas fa-plus-circle" style="color:#4f46e5;"></i>
                            Tạo vai trò mới
                        </h3>
                        <form action="${ctx}/admin/roles" method="POST">
                            <input type="hidden" name="action" value="create">

                            <div class="form-group">
                                <label for="roleName">Tên code (viết hoa) <span class="required">*</span></label>
                                <input type="text" id="roleName" name="name" class="form-control"
                                       placeholder="VD: MANAGER" required>
                            </div>

                            <div class="form-group">
                                <label for="roleDisplayName">Tên hiển thị <span class="required">*</span></label>
                                <input type="text" id="roleDisplayName" name="displayName" class="form-control"
                                       placeholder="VD: Quản lý kho" required>
                            </div>

                            <div class="form-group">
                                <label for="roleDesc">Mô tả</label>
                                <textarea id="roleDesc" name="description" class="form-control textarea"
                                          rows="2" placeholder="Mô tả ngắn về vai trò..."></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary" id="btn-create-role">
                                <i class="fas fa-plus"></i> Tạo vai trò
                            </button>
                        </form>
                    </div>
                </div>

                <%-- CỘT PHẢI: Danh sách vai trò --%>
                <div class="rbac-card">
                    <div class="rbac-card-header">
                        <i class="fas fa-users-cog" style="font-size:18px;color:#4f46e5;"></i>
                        <strong>Danh sách vai trò</strong>
                    </div>

                    <c:forEach var="role" items="${roles}">
                        <div class="role-list-item">
                            <div class="role-info">
                                <h4>
                                    ${role.displayName}
                                    <span class="role-badge ${role.isSystem ? 'system' : 'custom'}">
                                        <i class="fas ${role.isSystem ? 'fa-lock' : 'fa-pen'}"></i>
                                        ${role.isSystem ? 'Hệ thống' : 'Tuỳ chỉnh'}
                                    </span>
                                    <span class="user-count-chip">
                                        <i class="fas fa-user"></i> ${role.description}
                                    </span>
                                </h4>
                                <p>${role.name}</p>
                            </div>
                            <div class="role-actions">
                                <a href="${ctx}/admin/roles/detail?id=${role.id}"
                                   class="rbac-btn rbac-btn-primary" title="Quản lý quyền hạn">
                                    <i class="fas fa-key"></i> Phân quyền
                                </a>
                                <c:if test="${!role.isSystem}">
                                    <button class="rbac-btn rbac-btn-danger"
                                            onclick="deleteRole(${role.id}, '${role.displayName}')"
                                            title="Xóa vai trò">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty roles}">
                        <div style="padding:48px;text-align:center;color:#9ca3af;">
                            <i class="fas fa-layer-group" style="font-size:40px;margin-bottom:14px;display:block;"></i>
                            Chưa có vai trò nào được tạo
                        </div>
                    </c:if>
                </div>

            </div>
        </div>
    </main>
</div>

<form id="deleteRoleForm" method="POST" action="${ctx}/admin/roles" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="id" id="deleteRoleId">
</form>

<script>
    function deleteRole(id, name) {
        if (confirm('Xác nhận xóa vai trò "' + name + '"?\nKhông thể xóa nếu đang có người dùng sử dụng.')) {
            document.getElementById('deleteRoleId').value = id;
            document.getElementById('deleteRoleForm').submit();
        }
    }
</script>
</body>
</html>
