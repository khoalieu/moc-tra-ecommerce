<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Phân quyền: ${role.displayName} - Mộc Trà Admin</title>
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
                <a href="${ctx}/admin/roles" style="color:#6b7280;text-decoration:none;font-size:14px;font-weight:500;">
                    <i class="fas fa-arrow-left"></i> Quay lại
                </a>
                <h1 style="margin-top:6px;">
                    <i class="fas fa-key" style="color:#4f46e5;margin-right:10px;"></i>
                    Phân quyền: ${role.displayName}
                </h1>
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

            <div class="detail-layout">

                <%-- CỘT TRÁI: Thông tin role + Stat --%>
                <div>
                    <div class="rbac-section">
                        <h3>
                            <i class="fas fa-info-circle" style="color:#4f46e5;"></i>
                            Thông tin vai trò
                        </h3>
                        <form action="${ctx}/admin/roles" method="POST">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${role.id}">

                            <div class="form-group">
                                <label>Tên code</label>
                                <input type="text" class="form-control" value="${role.name}" readonly
                                       style="background:#f3f4f6;color:#6b7280;cursor:not-allowed;">
                            </div>

                            <div class="form-group">
                                <label for="detailDisplayName">Tên hiển thị</label>
                                <input type="text" id="detailDisplayName" name="displayName"
                                       class="form-control" value="${role.displayName}">
                            </div>

                            <div class="form-group">
                                <label for="detailDesc">Mô tả</label>
                                <textarea id="detailDesc" name="description"
                                          class="form-control textarea" rows="3">${role.description}</textarea>
                            </div>

                            <button type="submit" class="btn btn-primary" style="width:100%;">
                                <i class="fas fa-save"></i> Lưu thông tin
                            </button>
                        </form>
                    </div>

                    <div class="stat-box">
                        <span class="stat-num">${userCount}</span>
                        <span class="stat-lbl">Người dùng đang sử dụng vai trò này</span>
                    </div>
                </div>

                <%-- CỘT PHẢI: Danh sách quyền hạn --%>
                <div class="rbac-section" style="margin-bottom:0;">
                    <h3>
                        <i class="fas fa-shield-alt" style="color:#4f46e5;"></i>
                        Danh sách quyền hạn
                    </h3>

                    <form action="${ctx}/admin/roles/detail" method="POST" id="permForm">
                        <input type="hidden" name="action" value="save-permissions">
                        <input type="hidden" name="roleId" value="${role.id}">

                        <c:forEach var="entry" items="${allPermissionsGrouped}">
                            <div class="perm-group">
                                <div class="perm-group-header">
                                    <span class="perm-group-title">
                                        <i class="fas fa-folder-open"></i>
                                        ${entry.key}
                                    </span>
                                    <button type="button" class="perm-toggle-all"
                                            onclick="toggleGroup('grp-${entry.key}', this)">
                                        Chọn tất cả
                                    </button>
                                </div>

                                <div class="perm-items" id="grp-${entry.key}">
                                    <c:forEach var="perm" items="${entry.value}">
                                        <c:set var="isChecked" value="${rolePermissions.contains(perm.id)}"/>
                                        <div class="perm-item ${isChecked ? 'checked' : ''}"
                                             onclick="togglePerm(this)">
                                            <input type="checkbox"
                                                   id="perm-${perm.id}"
                                                   name="permissionIds"
                                                   value="${perm.id}"
                                                   ${isChecked ? 'checked' : ''}
                                                   onchange="updateItemStyle(this)">
                                            <label for="perm-${perm.id}" onclick="event.stopPropagation()">
                                                <span class="perm-item-name">${perm.displayName}</span>
                                                <span class="perm-item-code">${perm.name}</span>
                                            </label>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:forEach>

                        <div class="perm-actions-bar">
                            <button type="button" onclick="selectAll(true)" class="btn btn-secondary">
                                <i class="fas fa-check-double"></i> Chọn tất cả
                            </button>
                            <button type="button" onclick="selectAll(false)" class="btn btn-secondary">
                                <i class="fas fa-times"></i> Bỏ chọn tất
                            </button>
                            <button type="submit" class="btn btn-primary" id="btn-save-perms">
                                <i class="fas fa-save"></i> Lưu phân quyền
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </main>
</div>

<script>
    function togglePerm(div) {
        const cb = div.querySelector('input[type="checkbox"]');
        cb.checked = !cb.checked;
        updateItemStyle(cb);
    }

    function updateItemStyle(cb) {
        const item = cb.closest('.perm-item');
        if (item) item.classList.toggle('checked', cb.checked);
    }

    function toggleGroup(groupId, btn) {
        const group = document.getElementById(groupId);
        if (!group) return;
        const cbs = group.querySelectorAll('input[type="checkbox"]');
        const allChecked = Array.from(cbs).every(cb => cb.checked);
        cbs.forEach(cb => {
            cb.checked = !allChecked;
            updateItemStyle(cb);
        });
        btn.textContent = allChecked ? 'Chọn tất cả' : 'Bỏ chọn';
    }

    function selectAll(checked) {
        document.querySelectorAll('#permForm input[type="checkbox"]').forEach(cb => {
            cb.checked = checked;
            updateItemStyle(cb);
        });
    }
</script>
</body>
</html>
