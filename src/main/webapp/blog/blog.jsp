<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trà Thảo Mộc & Trà Sữa DIY</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<main class="main-content">
    <section class="page-header">
        <div class="container">
            <h1>Công Thức & Blog</h1>
            <p>Khám phá các bí kíp pha chế và kiến thức về trà</p>
        </div>
    </section>

    <section class="blog-page-content">
        <div class="container">
            <div class="blog-detail-layout">
                <%--   search + bar + recent--%>
                <jsp:include page="/common/blog-sidebar.jsp"></jsp:include>

                <div class="blog-post-content">
                    <div class="blog-grid">

                        <c:if test="${empty blogs}">
                            <p style="text-align:center; width:100%;">${emptyMessage}</p>
                        </c:if>


                        <c:forEach var="b" items="${blogs}">
                            <div class="blog-card">
                                <img src="${b.featuredImage}" alt=""/>
                                <h3>${b.title}</h3>

                                <div class="blog-card-meta">
                                    <span class="meta-item">
                                        <i class="fa-solid fa-eye"></i>
                                        <span>${b.viewsCount} Lượt xem</span>
                                    </span>

                                    <span class="meta-item">
                                        <i class="fa-solid fa-calendar"></i>
                                        <span><fmt:formatDate value="${b.createdAtDate}" pattern="dd/MM/yyyy"/></span>
                                    </span>

                                    <span class="meta-item">
                                        <i class="fa-solid fa-user"></i>
                                        <span>Admin</span>
                                    </span>
                                </div>
                                <p>${empty b.excerpt ? '(Chưa có mô tả)' : b.excerpt}</p>

                                <a href="${pageContext.request.contextPath}/chi-tiet-blog?slug=${b.slug}">Đọc Thêm</a>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <c:if test="${totalPages > 1}">
                <c:set var="windowSize" value="6" />
                <c:set var="currentBlock" value="${(currentPage - 1) div windowSize}" />
                <c:set var="startPage" value="${currentBlock * windowSize + 1}" />
                <c:set var="endPage" value="${startPage + windowSize - 1}" />

                <c:if test="${endPage > totalPages}">
                    <c:set var="endPage" value="${totalPages}" />
                </c:if>

                <c:set var="prevPage" value="${currentPage - windowSize}" />
                <c:set var="nextPage" value="${currentPage + windowSize}" />

                <div class="pagination">
                    <c:choose>
                        <c:when test="${mode == 'search'}">
                            <a href="?page=${prevPage < 1 ? 1 : prevPage}&q=${q}"
                               class="${currentPage <= windowSize ? 'disabled' : ''}">
                                &laquo;
                            </a>

                            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                <a href="?page=${i}&q=${q}"
                                   class="${currentPage == i ? 'active' : ''}">
                                        ${i}
                                </a>
                            </c:forEach>

                            <a href="?page=${nextPage > totalPages ? totalPages : nextPage}&q=${q}"
                               class="${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                                &raquo;
                            </a>
                        </c:when>

                        <c:when test="${mode == 'cat'}">
                            <a href="?page=${prevPage < 1 ? 1 : prevPage}&cat=${cat}"
                               class="${currentPage <= windowSize ? 'disabled' : ''}">
                                &laquo;
                            </a>

                            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                <a href="?page=${i}&cat=${cat}"
                                   class="${currentPage == i ? 'active' : ''}">
                                        ${i}
                                </a>
                            </c:forEach>

                            <a href="?page=${nextPage > totalPages ? totalPages : nextPage}&cat=${cat}"
                               class="${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                                &raquo;
                            </a>
                        </c:when>

                        <c:otherwise>
                            <a href="?page=${prevPage < 1 ? 1 : prevPage}"
                               class="${currentPage <= windowSize ? 'disabled' : ''}">
                                &laquo;
                            </a>

                            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                                <a href="?page=${i}"
                                   class="${currentPage == i ? 'active' : ''}">
                                        ${i}
                                </a>
                             </c:forEach>

                            <a href="?page=${nextPage > totalPages ? totalPages : nextPage}"
                               class="${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                                &raquo;
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>

        </div>
    </section>
</main>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>
</html>