<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Danh mục Sản phẩm - Mộc Trà Admin</title>

    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin-add-product.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">

    <style>
        .error-message {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
            display: block;
        }

        .form-control.error {
            border-color: #dc3545;
        }

        .child-category {
            padding-left: 18px;
            opacity: .9;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="categories"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Danh mục Sản phẩm</h1>
            </div>
        </header>

        <div class="admin-content">
            <c:if test="${not empty param.msg}">
                <div class="alert alert-success">
                    <c:choose>
                        <c:when test="${param.msg == 'added'}">Thêm danh mục thành công!</c:when>
                        <c:when test="${param.msg == 'updated'}">Cập nhật danh mục thành công!</c:when>
                        <c:when test="${param.msg == 'deleted'}">Xóa danh mục thành công!</c:when>
                    </c:choose>
                </div>
            </c:if>

            <div class="form-grid">
                <!-- LEFT: ADD -->
                <div class="form-left">
                    <div class="form-section">
                        <h3>Thêm danh mục mới</h3>

                        <form action="${ctx}/admin/categories" method="POST">
                            <input type="hidden" name="action" value="add"/>

                            <div class="form-group">
                                <label for="name">Tên danh mục <span class="required">*</span></label>
                                <input type="text"
                                       id="name"
                                       name="name"
                                       class="form-control ${not empty error ? 'error' : ''}"
                                       value="${inputName}">
                                <c:if test="${not empty error}">
                                    <span class="error-message">${error}</span>
                                </c:if>
                            </div>

                            <div class="form-group">
                                <label for="slug">Slug (URL)</label>
                                <input type="text"
                                       id="slug"
                                       name="slug"
                                       class="form-control"
                                       placeholder="Tự động nếu để trống"
                                       value="${inputSlug}">
                            </div>

                            <div class="form-group">
                                <label for="parent_id">Danh mục cha</label>
                                <select id="parent_id" name="parent_id" class="form-control">
                                    <option value="0">-- (Không có) --</option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${inputParentId == cat.id ? 'selected' : ''}>
                                            <c:out value="${cat.name}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                                <div class="help-text">Dùng để tạo danh mục con.</div>
                            </div>

                            <div class="form-group">
                                <label for="is_active">Trạng thái</label>
                                <select id="is_active" name="is_active" class="form-control">
                                    <option value="true" ${inputIsActive == 'true' || empty inputIsActive ? 'selected' : ''}>
                                        Hiển thị
                                    </option>
                                    <option value="false" ${inputIsActive == 'false' ? 'selected' : ''}>Ẩn</option>
                                </select>
                            </div>

                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-plus"></i> Thêm mới
                            </button>
                        </form>
                    </div>
                </div>

                <!-- RIGHT: LIST -->
                <div class="form-right">
                    <div class="form-section">
                        <h3>Danh sách hiện có</h3>

                        <div class="table-responsive">
                            <table class="category-table">
                                <thead>
                                <tr>
                                    <th>Tên danh mục</th>
                                    <th>Slug</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                                </thead>

                                <tbody>
                                <c:if test="${empty categories}">
                                    <tr>
                                        <td colspan="4" style="text-align:center;">Chưa có danh mục nào</td>
                                    </tr>
                                </c:if>

                                <c:forEach var="cat" items="${categories}">
                                    <tr>
                                        <td>
                                            <strong class="${cat.parentId != null ? 'child-category' : ''}">
                                                <c:out value="${cat.parentId != null ? '--- ' : ''}"/><c:out
                                                    value="${cat.name}"/>
                                            </strong>
                                        </td>
                                        <td><c:out value="${cat.slug}"/></td>
                                        <td>
                                            <span class="badge ${cat.isActive ? 'badge-success' : 'badge-secondary'}">
                                                    ${cat.isActive ? 'Hiển thị' : 'Ẩn'}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="action-buttons">
                                                <a href="${ctx}/admin/categories/edit?id=${cat.id}" class="btn-edit"
                                                   title="Sửa">
                                                    <i class="fa-solid fa-pen-to-square"></i>
                                                </a>

                                                <button class="btn-action delete"
                                                        onclick="deleteCategory(${cat.id}, '${cat.name}')"
                                                        title="Xóa">
                                                    <i class="fas fa-trash"></i>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                </tbody>

                            </table>
                        </div>
                    </div>
                </div>

            </div><!-- /form-grid -->
        </div><!-- /admin-content -->
    </main>
</div>

<script>
    function deleteCategory(id, name) {
        if (confirm('Xác nhận xóa danh mục: ' + name + '?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${ctx}/admin/categories';

            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'id';
            idInput.value = id;
            form.appendChild(idInput);

            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
</body>
</html>
