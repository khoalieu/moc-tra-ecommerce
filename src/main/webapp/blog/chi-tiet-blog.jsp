<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <title>${not empty post.metaTitle ? post.metaTitle : post.title}</title>
    </title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<main class="main-content">
    <div class="container">

        <div class="blog-detail-layout">
            <%-- search + bar = rêcnt--%>
            <jsp:include page="/common/blog-sidebar.jsp"></jsp:include>

            <article class="blog-post-content">

                <h1><c:out value="${post.title}" /></h1>

                <div class="post-meta">
                    <span>Tác giả: <b>${not empty post.author && (not empty post.author.firstName || not empty post.author.lastName)
                            ? post.author.firstName.concat(' ').concat(post.author.lastName)
                            : (not empty post.author ? post.author.username : 'Admin')}</b>
                    </span>
                    <span>Ngày đăng: <b><fmt:formatDate value="${post.createdAtDate}" pattern="dd/MM/yyyy"/></b></span>
                    <span>
                        Danh mục:
                        <b>
                            <c:out value="${not empty postCategory ? postCategory.name : 'Chưa phân loại'}" />
                        </b>
                    </span>
                    <span>Lượt xem: <b>${post.viewsCount}</b></span>
                </div>

                <div class="post-featured-image">
                    <img src="${post.featuredImage}"
                         alt="<c:out value='${post.title}'/>">
                </div>

                <div class="post-body">
                    <c:if test="${not empty post.excerpt}">
                        <p><i><c:out value="${post.excerpt}" /></i></p>
                    </c:if>

                    <c:out value="${post.content}" escapeXml="false"/>
                </div>

                <div id="comments" class="blog-comments-section">
                    <h2 class="comments-title">Bình luận (${commentsCount})</h2>

                    <c:if test="${not empty commentError}">
                        <p style="color:#c00; margin:10px 0;">${commentError}</p>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty sessionScope.user}">
                            <c:url var="loginUrl" value="/auth/login.jsp">
                                <c:param name="redirect" value="/chi-tiet-blog?slug=${post.slug}&tab=comments" />
                            </c:url>

                            <p style="margin-bottom: 20px;">
                                Vui lòng
                                <a href="${loginUrl}" style="color:#4CAF50; font-weight:bold;">đăng nhập</a>
                                để bình luận.
                            </p>
                        </c:when>

                        <c:otherwise>
                            <div class="comment-form">
                                <form action="${pageContext.request.contextPath}/chi-tiet-blog" method="post">
                                    <input type="hidden" name="slug" value="${post.slug}">

                                    <div class="form-field">
                                        <label for="comment_text">Để lại bình luận của bạn:</label>
                                        <textarea id="comment_text" name="comment_text" rows="4"
                                                  placeholder="Viết bình luận của bạn ở đây..."></textarea>
                                    </div>
                                    <button type="submit" class="cta-button">Gửi bình luận</button>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <div class="comment-list">
                        <c:if test="${empty comments}">
                            <p>Chưa có bình luận nào.</p>
                        </c:if>

                        <c:forEach var="cm" items="${comments}">
                            <c:set var="u" value="${commentUserMap[cm.userId]}" />

                            <div class="comment-item">
                                <div class="comment-avatar">
                                    <img src="${empty u || empty u.avatar ? 'https://placehold.co/60x60/eeeeee/white?text=User' : u.avatar}" alt="Avatar">
                                </div>

                                <div class="comment-content">
                                    <div class="comment-author">
                                            ${not empty u && (not empty u.firstName || not empty u.lastName)? u.firstName.concat(' ').concat(u.lastName) : 'User '.concat(cm.userId)}
                                    </div>
                                    <div class="comment-meta">
                                        <fmt:formatDate value="${cm.createdAtDate}" pattern="dd/MM/yyyy 'lúc' HH:mm"/>
                                    </div>
                                    <p class="comment-body"><c:out value="${cm.commentText}"/></p>
                                </div>

                            </div>
                        </c:forEach>

                    </div>
                </div>

            </article>

        </div> </div> </main>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const params = new URLSearchParams(window.location.search);
        if (params.get('tab') === 'comments') {
            const comments = document.getElementById('comments');
            if (comments) {
                comments.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }
    });
</script>
</body>
</html>