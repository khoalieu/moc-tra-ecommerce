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
    </style>
</head>

<body>

<div class="admin-container">
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
                <div class="alert alert-success" style="margin-bottom: 20px; padding: 15px; background: #d4edda; color: #155724; border-radius: 4px;">
                    <i class="fas fa-check-circle"></i> ${sessionScope.flashMsg}
                </div>
                <c:remove var="flashMsg" scope="session"/>
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
                                <!-- Dữ liệu mẫu (Mock Data) vì chưa có BE -->
                                <c:choose>
                                    <c:when test="${empty contactsList}">
                                        <!-- Hiển thị dữ liệu mẫu để Admin xem UI -->
                                        <tr class="unread-row" style="font-weight: 600;">
                                            <td>#1001</td>
                                            <td>Nguyễn Văn A</td>
                                            <td>nguyenvana@gmail.com</td>
                                            <td>Sản phẩm bị lỗi đóng gói</td>
                                            <td><span class="status-badge status-unread">Chưa đọc</span></td>
                                            <td>14/06/2026 10:30</td>
                                            <td class="table-actions">
                                                <button class="btn-icon" title="Xem chi tiết"><i class="fas fa-eye"></i></button>
                                                <button class="btn-icon" title="Đánh dấu đã xử lý"><i class="fas fa-check-circle"></i></button>
                                                <button class="btn-icon btn-delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>#1002</td>
                                            <td>Trần Thị B</td>
                                            <td>tranthib@gmail.com</td>
                                            <td>Hỏi về chính sách sỉ trà thảo mộc</td>
                                            <td><span class="status-badge status-resolved">Đã xử lý</span></td>
                                            <td>12/06/2026 15:45</td>
                                            <td class="table-actions">
                                                <button class="btn-icon" title="Xem chi tiết"><i class="fas fa-eye"></i></button>
                                                <button class="btn-icon btn-delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>#1003</td>
                                            <td>Lê Hoàng C</td>
                                            <td>lehoangc@gmail.com</td>
                                            <td>Cửa hàng ở Quận 7 còn mở không?</td>
                                            <td><span class="status-badge status-read">Đã đọc</span></td>
                                            <td>10/06/2026 09:15</td>
                                            <td class="table-actions">
                                                <button class="btn-icon" title="Xem chi tiết"><i class="fas fa-eye"></i></button>
                                                <button class="btn-icon" title="Đánh dấu đã xử lý"><i class="fas fa-check-circle"></i></button>
                                                <button class="btn-icon btn-delete" title="Xóa"><i class="fas fa-trash"></i></button>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <!-- Dữ liệu thực tế từ Backend (Sẽ hoạt động khi làm xong BE) -->
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
                    
                    <!-- Pagination (Mock) -->
                    <div class="pagination">
                        <span class="page-item active">1</span>
                        <a href="#" class="page-item">2</a>
                        <a href="#" class="page-item">3</a>
                        <a href="#" class="page-item"><i class="fas fa-chevron-right"></i></a>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>

</body>
</html>
