<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết liên hệ - Mộc Trà Admin</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    <style>
        .contact-detail-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 360px;
            gap: 20px;
        }
        .contact-panel {
            background: #fff;
            border-radius: 8px;
            padding: 22px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
        }
        .contact-message-box {
            white-space: pre-wrap;
            line-height: 1.7;
            padding: 16px;
            background: #f8faf9;
            border-radius: 8px;
            border: 1px solid #e5ece8;
            margin-top: 12px;
        }
        .contact-meta-row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 0;
            border-bottom: 1px solid #edf1ee;
        }
        .contact-meta-row span:first-child {
            color: #667;
        }
        .reply-form textarea {
            width: 100%;
            min-height: 180px;
            resize: vertical;
            padding: 12px;
            border: 1px solid #d7ded9;
            border-radius: 8px;
            font: inherit;
        }
        .detail-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 16px;
        }
        .detail-actions form {
            margin: 0;
        }
        .contact-action-btn {
            min-height: 42px;
            padding: 0 16px;
            border-radius: 8px;
            border: 1px solid transparent;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 700;
            font-size: 14px;
            line-height: 1;
            cursor: pointer;
            transition: background-color 0.2s ease, border-color 0.2s ease, color 0.2s ease, box-shadow 0.2s ease;
        }
        .contact-action-btn.primary {
            background: #0d8b8b;
            border-color: #0d8b8b;
            color: #fff;
        }
        .contact-action-btn.primary:hover {
            background: #087676;
            border-color: #087676;
            box-shadow: 0 8px 18px rgba(13, 139, 139, 0.22);
        }
        .contact-action-btn.success {
            background: #fff;
            border-color: #198754;
            color: #198754;
        }
        .contact-action-btn.success:hover {
            background: #198754;
            color: #fff;
            box-shadow: 0 8px 18px rgba(25, 135, 84, 0.18);
        }
        .contact-action-btn.danger {
            background: #fff;
            border-color: #dc3545;
            color: #dc3545;
        }
        .contact-action-btn.danger:hover {
            background: #dc3545;
            color: #fff;
            box-shadow: 0 8px 18px rgba(220, 53, 69, 0.18);
        }
        .status-pill {
            display: inline-block;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
            background: #f0e8ff;
            color: #6f42c1;
        }
        @media (max-width: 960px) {
            .contact-detail-grid {
                grid-template-columns: 1fr;
            }
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
                <h1>Chi tiết liên hệ</h1>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/admin/contacts" class="view-site-btn">
                    <i class="fas fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <c:if test="${not empty sessionScope.flashMsg}">
                <div class="alert alert-${empty sessionScope.flashType ? 'success' : sessionScope.flashType}"
                     style="margin-bottom: 20px; padding: 15px; background: #d4edda; color: #155724; border-radius: 4px;">
                    <i class="fas fa-info-circle"></i> ${sessionScope.flashMsg}
                </div>
                <c:remove var="flashMsg" scope="session"/>
                <c:remove var="flashType" scope="session"/>
            </c:if>

            <div class="contact-detail-grid">
                <section class="contact-panel">
                    <div style="display:flex; justify-content:space-between; gap:12px; align-items:flex-start;">
                        <div>
                            <h2 style="margin:0 0 8px;">${contact.subject}</h2>
                            <p style="margin:0; color:#667;">
                                Gửi lúc <fmt:formatDate value="${contact.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                            </p>
                        </div>
                        <span class="status-pill">${contact.status}</span>
                    </div>

                    <h3 style="margin-top:24px;">Nội dung khách gửi</h3>
                    <div class="contact-message-box">${contact.message}</div>

                    <c:if test="${not empty contact.adminReply}">
                        <h3 style="margin-top:24px;">Phản hồi đã gửi</h3>
                        <div class="contact-message-box">${contact.adminReply}</div>
                        <p style="color:#667; margin-top:8px;">
                            Gửi lúc <fmt:formatDate value="${contact.repliedAt}" pattern="dd/MM/yyyy HH:mm"/>
                            <c:if test="${not empty contact.repliedByName}">
                                bởi ${contact.repliedByName}
                            </c:if>
                        </p>
                    </c:if>

                    <h3 style="margin-top:24px;">Trả lời khách hàng</h3>
                    <form action="${pageContext.request.contextPath}/admin/contacts/reply" method="post" class="reply-form">
                        <input type="hidden" name="id" value="${contact.id}">
                        <textarea name="adminReply" required placeholder="Nhập nội dung phản hồi gửi qua email cho khách...">${contact.adminReply}</textarea>
                        <div class="detail-actions">
                            <button type="submit" class="contact-action-btn primary">
                                <i class="fas fa-paper-plane"></i> Gửi phản hồi qua email
                            </button>
                        </div>
                    </form>
                </section>

                <aside class="contact-panel">
                    <h3 style="margin-top:0;">Thông tin khách hàng</h3>
                    <div class="contact-meta-row">
                        <span>Mã liên hệ</span>
                        <strong>#${contact.id}</strong>
                    </div>
                    <div class="contact-meta-row">
                        <span>Họ tên</span>
                        <strong>${contact.name}</strong>
                    </div>
                    <div class="contact-meta-row">
                        <span>Email</span>
                        <strong>${contact.email}</strong>
                    </div>
                    <div class="contact-meta-row">
                        <span>Số điện thoại</span>
                        <strong>${empty contact.phone ? 'Không có' : contact.phone}</strong>
                    </div>
                    <div class="contact-meta-row">
                        <span>Trạng thái</span>
                        <strong>${contact.status}</strong>
                    </div>

                    <div class="detail-actions">
                        <c:if test="${contact.status != 'RESOLVED'}">
                            <form action="${pageContext.request.contextPath}/admin/contacts/resolve" method="post">
                                <input type="hidden" name="id" value="${contact.id}">
                                <button type="submit" class="contact-action-btn success">
                                    <i class="fas fa-check-circle"></i> Đánh dấu đã xử lý
                                </button>
                            </form>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/admin/contacts/delete" method="post"
                              onsubmit="return confirm('Bạn có chắc muốn xóa liên hệ này?');">
                            <input type="hidden" name="id" value="${contact.id}">
                            <button type="submit" class="contact-action-btn danger">
                                <i class="fas fa-trash"></i> Xóa liên hệ
                            </button>
                        </form>
                    </div>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
