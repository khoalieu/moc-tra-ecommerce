<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="p" value="${post}"/>
<c:set var="cat" value="${category}"/>
<c:set var="au" value="${p.author}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Bài viết - Mộc Trà Admin</title>

    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">

    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin-blog-detail.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">
</head>

<body>
<div class="admin-container">

    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="blog"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Chi tiết Bài viết</h1>
            </div>

            <div class="header-right">
                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <!-- Blog Detail Header -->
            <div class="blog-detail-header">
                <div class="blog-meta">
                    <h2><c:out value="${p.title}"/></h2>

                    <div class="blog-meta-info">
                        <span class="meta-item">
                            <i class="fas fa-user"></i>
                            <strong><c:out value="${empty au ? '---' : au.displayName}"/></strong>
                        </span>

                        <span class="meta-item">
                            <i class="fas fa-folder"></i>
                            <strong><c:out value="${empty cat ? 'Chưa phân loại' : cat.name}"/></strong>
                        </span>

                        <span class="meta-item">
                            <i class="fas fa-calendar"></i>
                            <fmt:formatDate value="${p.createdAtDate}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>

                        <span class="meta-item">
                            <i class="fas fa-eye"></i>
                            <strong><fmt:formatNumber value="${p.viewsCount}" pattern="#,###"/> lượt xem</strong>
                        </span>

                        <span class="meta-item">
                            <c:choose>
                                <c:when test="${p.status.name() == 'PUBLISHED'}">
                                    <span class="status-badge published">Đã xuất bản</span>
                                </c:when>
                                <c:when test="${p.status.name() == 'DRAFT'}">
                                    <span class="status-badge status-pending">Bản nháp</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-cancelled">Lưu trữ</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="blog-actions-top">
                    <a href="${ctx}/admin/blog" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>

                    <a class="btn btn-success" href="${ctx}/admin/blog/edit?id=${p.id}">
                        <i class="fas fa-edit"></i> Chỉnh sửa
                    </a>

                    <form method="post" action="${ctx}/admin/blog/delete" style="display:inline;"
                          onsubmit="return confirm('CẢNH BÁO: Bạn có chắc muốn xóa bài viết này?');">
                        <input type="hidden" name="ids" value="${p.id}">
                        <button class="btn btn-danger" type="submit">
                            <i class="fas fa-trash"></i> Xóa
                        </button>
                    </form>
                </div>
            </div>

            <!-- Detail Grid -->
            <div class="detail-grid">

                <!-- Main Content Column -->
                <div style="display:flex; flex-direction:column; gap:30px;">

                    <!-- Featured Image -->
                    <c:if test="${not empty p.featuredImage}">
                        <div class="detail-card">
                            <h3 class="card-title"><i class="fas fa-image"></i> Ảnh đại diện</h3>

                            <c:set var="img" value="${p.featuredImage}"/>
                            <c:choose>
                                <c:when test="${fn:startsWith(img,'http://') or fn:startsWith(img,'https://')}">
                                    <img src="${img}" alt="Featured" class="featured-image">
                                </c:when>
                                <c:otherwise>
                                    <img src="${ctx}/${img}" alt="Featured" class="featured-image">
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <!-- Excerpt -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-quote-left"></i> Trích đoạn</h3>
                        <div class="excerpt-box">
                            <c:out value="${empty p.excerpt ? '(Chưa có mô tả)' : p.excerpt}"/>
                        </div>
                    </div>

                    <!-- Content -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-file-alt"></i> Nội dung bài viết</h3>
                        <div class="blog-content">
                            <c:out value="${p.content}" escapeXml="false"/>
                        </div>
                    </div>

                    <!-- SEO Information -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-search"></i> Thông tin SEO</h3>

                        <div class="seo-info">
                            <div class="seo-title">
                                Meta Title:
                                <c:out value="${empty p.metaTitle ? p.title : p.metaTitle}"/>
                            </div>
                            <div class="seo-description">
                                Meta Description:
                                <c:out value="${empty p.metaDescription ? p.excerpt : p.metaDescription}"/>
                            </div>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Slug:</span>
                            <span class="info-value"><c:out value="${p.slug}"/></span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Meta Title Length:</span>
                            <span class="info-value"
                                  style="color:#28a745;">${fn:length(empty p.metaTitle ? p.title : p.metaTitle)} ký tự</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Meta Description Length:</span>
                            <span class="info-value"
                                  style="color:#28a745;">${fn:length(empty p.metaDescription ? p.excerpt : p.metaDescription)} ký tự</span>
                        </div>
                    </div>
                </div>

                <!-- Sidebar Column -->
                <div style="display:flex; flex-direction:column; gap:30px;">

                    <!-- Basic Info -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-info-circle"></i> Thông tin cơ bản</h3>

                        <div class="info-row">
                            <span class="info-label">Trạng thái:</span>
                            <span class="info-value">
                                <c:choose>
                                    <c:when test="${p.status.name() == 'PUBLISHED'}">
                                        <span class="status-badge published">Đã xuất bản</span>
                                    </c:when>
                                    <c:when test="${p.status.name() == 'DRAFT'}">
                                        <span class="status-badge status-pending">Bản nháp</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge status-cancelled">Lưu trữ</span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Danh mục:</span>
                            <span class="info-value">
                                <span class="category-badge health">
                                    <c:out value="${empty cat ? 'Chưa phân loại' : cat.name}"/>
                                </span>
                            </span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Ngày tạo:</span>
                            <span class="info-value"><fmt:formatDate value="${p.createdAtDate}"
                                                                     pattern="dd/MM/yyyy HH:mm"/></span>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Cập nhật cuối:</span>
                            <span class="info-value">16/11/2025 14:20</span>
                        </div>
                    </div>

                    <!-- Author Info -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-user-edit"></i> Tác giả</h3>

                        <c:set var="dn" value="${empty au ? 'NA' : au.displayName}"/>
                        <c:set var="init" value="${fn:toUpperCase(fn:substring(dn,0,2))}"/>

                        <div class="author-card">
                            <div class="author-avatar">${init}</div>
                            <div class="author-info">
                                <h4><c:out value="${empty au ? '---' : au.displayName}"/></h4>
                                <p><c:out value="${empty au ? '' : au.email}"/></p>
                                <p style="color:#107e84; font-weight:600;">
                                    Vai trò: <c:out value="${empty au || empty au.role ? '---' : au.role}"/>
                                </p>
                            </div>
                        </div>
                    </div>

                    <!-- Statistics -->
                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-chart-line"></i> Thống kê</h3>
                        <div class="stats-grid">
                            <div class="stat-box">
                                <div class="stat-number"><fmt:formatNumber value="${p.viewsCount}"
                                                                           pattern="#,###"/></div>
                                <div class="stat-label">Lượt xem</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-number">${commentsCount}</div>
                                <div class="stat-label">Bình luận</div>
                            </div>
                            <!-- GIỮ placeholder -->
                            <div class="stat-box">
                                <div class="stat-number">89</div>
                                <div class="stat-label">Lượt thích</div>
                            </div>
                            <div class="stat-box">
                                <div class="stat-number">12</div>
                                <div class="stat-label">Chia sẻ</div>
                            </div>
                        </div>
                    </div>

                    <div class="detail-card">
                        <h3 class="card-title"><i class="fas fa-history"></i> Lịch sử trạng thái</h3>
                        <div class="status-timeline">
                            <div class="timeline-item">
                                <div class="timeline-icon"><i class="fas fa-check"></i></div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Đã xuất bản</div>
                                    <div class="timeline-date">15/11/2025 10:00</div>
                                </div>
                            </div>
                            <div class="timeline-item">
                                <div class="timeline-icon" style="background:#ffc107;"><i class="fas fa-edit"></i></div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Bản nháp</div>
                                    <div class="timeline-date">15/11/2025 09:30</div>
                                </div>
                            </div>
                            <div class="timeline-item">
                                <div class="timeline-icon" style="background:#6c757d;"><i class="fas fa-plus"></i></div>
                                <div class="timeline-content">
                                    <div class="timeline-title">Tạo mới</div>
                                    <div class="timeline-date">15/11/2025 09:00</div>
                                </div>
                            </div>
                        </div>
                    </div>

                </div>
            </div>

            <div class="detail-card full-width-card">
                <h3 class="card-title">
                    <i class="fas fa-comments"></i>
                    Bình luận (${commentsCount} bình luận)
                </h3>

                <c:if test="${param.err == 'empty'}">
                    <p style="color:#c00; margin:10px 0;">Nội dung trả lời không được để trống.</p>
                </c:if>

                <div class="comments-list">
                    <c:if test="${empty comments}">
                        <p>Chưa có bình luận nào.</p>
                    </c:if>

                    <c:forEach var="cm" items="${comments}">
                        <c:set var="u" value="${commentUserMap[cm.userId]}"/>
                        <c:set var="uname" value="${empty u ? ('User ' += cm.userId) : u.displayName}"/>

                        <div class="comment-item">
                            <div class="comment-header">
                                <span class="comment-author">
                                    <i class="fas fa-user-circle"></i>
                                    <c:out value="${uname}"/>
                                </span>
                            </div>

                            <div class="comment-text">
                                <c:out value="${cm.commentText}"/>
                            </div>

                            <div class="comment-date">
                                <i class="far fa-clock"></i>
                                <fmt:formatDate value="${cm.createdAtDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>

                            <div class="comment-actions">
                                <button class="comment-btn approve" type="button"
                                        onclick="replyComment(${p.id}, ${cm.id}, '${fn:escapeXml(uname)}')">
                                    <i class="fas fa-reply"></i> Trả lời
                                </button>

                                <!-- Delete comment -->
                                <form method="post" action="${ctx}/admin/blog/detail" style="display:inline;"
                                      onsubmit="return confirm('Xóa bình luận này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="postId" value="${p.id}">
                                    <input type="hidden" name="commentId" value="${cm.id}">
                                    <button class="comment-btn delete" type="submit">
                                        <i class="fas fa-trash"></i> Xóa
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    function replyComment(postId, commentId, userName) {
        const txt = prompt('Trả lời @' + userName + ':', '');
        if (txt == null) return; // cancel
        const v = (txt || '').trim();
        if (!v) {
            location.href = '${ctx}/admin/blog/detail?id=' + postId + '&err=empty';
            return;
        }

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${ctx}/admin/blog/detail';

        form.innerHTML =
            '<input type="hidden" name="action" value="reply">' +
            '<input type="hidden" name="postId" value="' + postId + '">' +
            '<input type="hidden" name="commentId" value="' + commentId + '">' +
            '<input type="hidden" name="text" value="">';

        form.querySelector('input[name="text"]').value = v;

        document.body.appendChild(form);
        form.submit();
    }
</script>

</body>
</html>
