<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<aside class="blog-sidebar">

    <!-- SEARCH -->
    <div class="sidebar-widget">
        <h3>Tìm Kiếm Bài Viết</h3>
        <form action="${pageContext.request.contextPath}/blog" method="get">
            <input type="text"
                   name="q"
                   value="${param.q}"
                   placeholder="Nhập từ khóa..."
                   style="width: 100%; padding: 10px;">
        </form>
    </div>

    <!-- CATEGORIES -->
    <div class="sidebar-widget">
        <h3>Danh Mục</h3>
        <ul class="sidebar-list">
            <li>
                <a href="${pageContext.request.contextPath}/blog" class="${mode == 'all' ? 'active' : ''}">Tất Cả</a>
            </li>

            <c:forEach var="c" items="${categories}">
                <li>
                    <a href="${pageContext.request.contextPath}/blog?cat=${c.slug}"
                       class="${c.slug == activeCatSlug ? 'active' : ''}">
                            ${c.name}
                        (<c:out value="${categoryCountMap[c.id]}" default="0" />)
                    </a>
                </li>
            </c:forEach>
        </ul>
    </div>

    <!-- RECENT POSTS -->
    <div class="sidebar-widget">
        <h3>Bài Viết Mới Nhất</h3>

        <c:if test="${empty recentPosts}">
            <p style="margin: 0;">Chưa có bài viết mới.</p>
        </c:if>

        <c:forEach var="r" items="${recentPosts}">
            <div class="recent-post">
                <img src="${empty r.featuredImage ? 'https://placehold.co/70x70' : r.featuredImage}" alt="thumb">
                <div class="recent-post-info">
                    <a href="${pageContext.request.contextPath}/chi-tiet-blog?slug=${r.slug}">${r.title}</a>
                    <span><fmt:formatDate value="${r.createdAtDate}" pattern="dd/MM/yyyy"/></span>
                </div>
            </div>
        </c:forEach>
    </div>

</aside>
