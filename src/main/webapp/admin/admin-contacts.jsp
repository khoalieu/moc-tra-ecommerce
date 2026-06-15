<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Liên hệ - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    
    <style>
        .status-badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .status-unread {
            background-color: #fce4e4;
            color: #d9534f;
        }
        .status-read {
            background-color: #e4f0fc;
            color: #0275d8;
        }
        .status-resolved {
            background-color: #e4fce4;
            color: #5cb85c;
        }
        .status-replied {
            background-color: #f0e8ff;
            color: #6f42c1;
        }
        .table-actions .btn-icon {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
            color: #555;
            transition: color 0.3s;
        }
        .table-actions .btn-icon:hover {
            color: #4a6741;
        }
        .table-actions .btn-delete:hover {
            color: #d9534f;
        }
        .admin-contacts-page .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 20px;
        }
        .admin-contacts-page .filter-group,
        .admin-contacts-page .filter-form {
            width: 100%;
        }
        .admin-contacts-page .filter-form {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .admin-contacts-page .form-control {
            height: 42px;
            border: 1px solid #d7ded9;
            border-radius: 8px;
            padding: 0 12px;
            font: inherit;
            background: #fff;
            color: #263238;
        }
        .admin-contacts-page select.form-control {
            min-width: 190px;
        }
        .admin-contacts-page .search-box {
            display: flex;
            align-items: center;
            min-width: 320px;
            flex: 1;
            max-width: 520px;
        }
        .admin-contacts-page .search-box .form-control {
            width: 100%;
            border-radius: 8px 0 0 8px;
        }
        .admin-contacts-page .btn-search {
            height: 42px;
            width: 46px;
            border: 1px solid #107e84;
            border-left: 0;
            border-radius: 0 8px 8px 0;
            background: #107e84;
            color: #fff;
            cursor: pointer;
        }
        .admin-contacts-page .card {
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
            overflow: hidden;
        }
        .admin-contacts-page .card-body {
            padding: 0;
        }
        .admin-contacts-page .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        .admin-contacts-page .admin-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 860px;
        }
        .admin-contacts-page .admin-table th {
            padding: 15px 16px;
            background: #f4f8f7;
            color: #374151;
            text-align: left;
            font-weight: 700;
            border-bottom: 1px solid #e5ece8;
            white-space: nowrap;
        }
        .admin-contacts-page .admin-table td {
            padding: 15px 16px;
            border-bottom: 1px solid #edf1ee;
            color: #344054;
            vertical-align: middle;
        }
        .admin-contacts-page .admin-table tbody tr:hover {
            background: #f8fbfa;
        }
        .admin-contacts-page .admin-table .unread-row {
            background: #fffaf0;
        }
        .admin-contacts-page .table-actions {
            display: flex;
            align-items: center;
            gap: 8px;
            white-space: nowrap;
        }
        .admin-contacts-page .table-actions form {
            display: inline-flex;
            margin: 0;
        }
        .admin-contacts-page .table-actions .btn-icon {
            width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            background: #eef7f7;
            color: #107e84;
            margin-right: 0;
        }
        .admin-contacts-page .table-actions .btn-icon:hover {
            background: #107e84;
            color: #fff;
        }
        .admin-contacts-page .table-actions .btn-delete {
            background: #fff1f0;
            color: #dc3545;
        }
        .admin-contacts-page .table-actions .btn-delete:hover {
            background: #dc3545;
            color: #fff;
        }
        .admin-contacts-page .pagination {
            display: flex;
            gap: 8px;
            align-items: center;
            justify-content: flex-end;
            padding: 16px;
        }
        .admin-contacts-page .page-item {
            min-width: 36px;
            height: 36px;
            padding: 0 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            border: 1px solid #d7ded9;
            color: #107e84;
            text-decoration: none;
            font-weight: 600;
        }
        .admin-contacts-page .page-item.active {
            background: #107e84;
            border-color: #107e84;
            color: #fff;
        }
        @media (max-width: 768px) {
            .admin-contacts-page .search-box {
                min-width: 100%;
            }
        }
    </style>
</head>

<body>

<div class="admin-container admin-contacts-page">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="contacts"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Liên hệ</h1>
            </div>

            <div class="header-right">
                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <div class="content-header">
                <div class="filter-group">
                    <form action="${pageContext.request.contextPath}/admin/contacts" method="GET" class="filter-form">
                        <select name="status" class="form-control" onchange="this.form.submit()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="UNREAD" ${param.status == 'UNREAD' ? 'selected' : ''}>Chưa đọc</option>
                            <option value="READ" ${param.status == 'READ' ? 'selected' : ''}>Đã đọc</option>
                            <option value="REPLIED" ${param.status == 'REPLIED' ? 'selected' : ''}>Đã trả lời</option>
                            <option value="RESOLVED" ${param.status == 'RESOLVED' ? 'selected' : ''}>Đã xử lý</option>
                        </select>
                        <div class="search-box">
                            <input type="text" name="search" placeholder="Tìm theo tên/email/tiêu đề..." value="${param.search}" class="form-control">
                            <button type="submit" class="btn-search"><i class="fas fa-search"></i></button>
                        </div>
                    </form>
                </div>
            </div>

            <c:if test="${not empty sessionScope.flashMsg}">
                <div class="alert alert-${empty sessionScope.flashType ? 'success' : sessionScope.flashType}" style="margin-bottom: 20px; padding: 15px; background: #d4edda; color: #155724; border-radius: 4px;">
                    <i class="fas fa-check-circle"></i> ${sessionScope.flashMsg}
                </div>
                <c:remove var="flashMsg" scope="session"/>
                <c:remove var="flashType" scope="session"/>
            </c:if>

            <div class="card">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Khách hàng</th>
                                    <th>Email</th>
                                    <th>Tiêu đề</th>
                                    <th>Trạng thái</th>
                                    <th>Ngày gửi</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty contactsList}">
                                        <tr>
                                            <td colspan="7" style="text-align:center; padding: 30px; color: #777;">
                                                Chưa có liên hệ nào phù hợp với bộ lọc hiện tại.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="contact" items="${contactsList}">
                                            <tr class="${contact.status == 'UNREAD' ? 'unread-row' : ''}" style="${contact.status == 'UNREAD' ? 'font-weight: 600;' : ''}">
                                                <td>#${contact.id}</td>
                                                <td>${contact.name}</td>
                                                <td>${contact.email}</td>
                                                <td>${contact.subject}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${contact.status == 'UNREAD'}">
                                                            <span class="status-badge status-unread">Chưa đọc</span>
                                                        </c:when>
                                                        <c:when test="${contact.status == 'READ'}">
                                                            <span class="status-badge status-read">Đã đọc</span>
                                                        </c:when>
                                                        <c:when test="${contact.status == 'REPLIED'}">
                                                            <span class="status-badge status-replied">Đã trả lời</span>
                                                        </c:when>
                                                        <c:when test="${contact.status == 'RESOLVED'}">
                                                            <span class="status-badge status-resolved">Đã xử lý</span>
                                                        </c:when>
                                                    </c:choose>
                                                </td>
                                                <td><fmt:formatDate value="${contact.createdAt}" pattern="dd/MM/yyyy HH:mm" /></td>
                                                <td class="table-actions">
                                                    <a href="${pageContext.request.contextPath}/admin/contacts/view?id=${contact.id}" class="btn-icon" title="Xem chi tiết"><i class="fas fa-eye"></i></a>
                                                    
                                                    <c:if test="${contact.status != 'RESOLVED'}">
                                                        <form action="${pageContext.request.contextPath}/admin/contacts/resolve" method="POST" style="display:inline;">
                                                            <input type="hidden" name="id" value="${contact.id}">
                                                            <button type="submit" class="btn-icon" title="Đánh dấu đã xử lý"><i class="fas fa-check-circle"></i></button>
                                                        </form>
                                                    </c:if>

                                                    <form action="${pageContext.request.contextPath}/admin/contacts/delete" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn xóa liên hệ này?');">
                                                        <input type="hidden" name="id" value="${contact.id}">
                                                        <button type="submit" class="btn-icon btn-delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                    
                    <c:if test="${totalPages > 1}">
                        <div class="pagination">
                            <c:forEach begin="1" end="${totalPages}" var="p">
                                <c:choose>
                                    <c:when test="${p == currentPage}">
                                        <span class="page-item active">${p}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="page-item"
                                           href="${pageContext.request.contextPath}/admin/contacts?page=${p}&status=${status}&search=${search}">${p}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </div>

        </div>
    </main>
</div>

</body>
</html>
