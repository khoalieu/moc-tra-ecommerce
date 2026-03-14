<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Săn Deal Giá Hời - Mộc Trà</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/promotion.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<jsp:include page="common/header.jsp"></jsp:include>

<main class="main-content">

    <section class="slider-container">
        <c:if test="${not empty activePromotions}">
            <div class="slider-btn slider-prev"><i class="fa-solid fa-chevron-left"></i></div>
            <div class="slider-btn slider-next"><i class="fa-solid fa-chevron-right"></i></div>

            <c:forEach var="promo" items="${activePromotions}" varStatus="status">
                <div class="slide ${status.first ? 'active' : ''}"
                     style="background-image: url('${pageContext.request.contextPath}/${promo.imageUrl}');">

                    <div class="promo-hero__overlay">
                        <h1>${promo.name}</h1>
                        <p>${promo.description}</p>

                        <a href="${pageContext.request.contextPath}/san-pham?promotionId=${promo.id}" class="btn-hero">
                            Xem Ngay
                        </a>
                    </div>
                </div>
            </c:forEach>

            <div class="slider-dots">
                <c:forEach items="${activePromotions}" varStatus="status">
                    <div class="dot ${status.first ? 'active' : ''}" data-index="${status.index}"></div>
                </c:forEach>
            </div>
        </c:if>

        <c:if test="${empty activePromotions}">
            <div style="display: flex; justify-content: center; align-items: center; height: 100%; background: #eee;">
                <h3>Hiện chưa có chương trình khuyến mãi nào.</h3>
            </div>
        </c:if>
    </section>

    <div class="container">
        <c:forEach var="entry" items="${promoMap}">
            <c:set var="promo" value="${entry.key}" />
            <c:set var="productList" value="${entry.value}" />

            <section class="campaign-section" id="promo-${promo.id}">
                <div class="campaign-header">
                    <div class="campaign-header__left">
                        <h2>🎉 ${promo.name}</h2>

                        <div class="campaign-timer">
                            <i class="fa-regular fa-clock"></i>
                            Kết thúc: ${fn:replace(promo.endDate, 'T', ' ')}
                        </div>
                    </div>

                    <div class="campaign-header__right">
                        <a href="${pageContext.request.contextPath}/san-pham?promotionId=${promo.id}" class="btn-view-all">
                            Xem tất cả <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>
                </div>

                <div class="product-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
                    <c:forEach var="p" items="${productList}">
                        <div class="product-card">
                            <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                                <div class="sale-tag" style="position: absolute; top: 10px; right: 10px; background: red; color: white; padding: 5px 10px; border-radius: 5px; font-weight: bold;">
                                    -<fmt:formatNumber value="${((p.price - p.salePrice) / p.price) * 100}" maxFractionDigits="0"/>%
                                </div>
                            </c:if>

                            <div class="product-image">
                                <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}">
                                    <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="${p.name}" style="width: 100%; height: auto;">
                                </a>
                            </div>

                            <div class="product-info" style="padding: 15px;">
                                <h3 style="margin-bottom: 10px; font-size: 1.1rem;">
                                    <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}" style="color: #333; text-decoration: none;">${p.name}</a>
                                </h3>

                                <div class="price-box">
                                    <c:choose>
                                        <c:when test="${p.salePrice > 0 && p.salePrice < p.price}">
                                            <span class="new-price" style="color: #d32f2f; font-weight: bold; font-size: 1.1rem; margin-right: 10px;">
                                                <fmt:formatNumber value="${p.salePrice}" pattern="#,###"/>₫
                                            </span>
                                            <span class="old-price" style="color: #999; text-decoration: line-through; font-size: 0.9rem;">
                                                <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="new-price" style="font-weight: bold; font-size: 1.1rem;">
                                                <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </c:forEach>
    </div>

</main>

<jsp:include page="common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang" style="display: none; position: fixed; bottom: 20px; right: 20px; z-index: 99; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 50%; cursor: pointer;">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // --- SLIDER LOGIC ---
        const slides = document.querySelectorAll('.slide');
        const dots = document.querySelectorAll('.dot');
        const nextBtn = document.querySelector('.slider-next');
        const prevBtn = document.querySelector('.slider-prev');

        if (slides.length === 0) return;

        let currentSlide = 0;
        let slideInterval;

        function showSlide(index) {
            // Xóa class active cũ
            slides.forEach(s => s.classList.remove('active'));
            dots.forEach(d => d.classList.remove('active'));

            // Tính toán index vòng lặp
            if (index >= slides.length) currentSlide = 0;
            else if (index < 0) currentSlide = slides.length - 1;
            else currentSlide = index;

            // Thêm class active mới
            slides[currentSlide].classList.add('active');
            if(dots[currentSlide]) dots[currentSlide].classList.add('active');
        }

        function next() { showSlide(currentSlide + 1); }
        function prev() { showSlide(currentSlide - 1); }

        function startAuto() {
            slideInterval = setInterval(next, 5000); // Tự chuyển sau 5s
        }
        function stopAuto() { clearInterval(slideInterval); }

        // Gán sự kiện click
        if(nextBtn) nextBtn.addEventListener('click', () => { stopAuto(); next(); startAuto(); });
        if(prevBtn) prevBtn.addEventListener('click', () => { stopAuto(); prev(); startAuto(); });

        dots.forEach((dot, idx) => {
            dot.addEventListener('click', () => { stopAuto(); showSlide(idx); startAuto(); });
        });

        // Bắt đầu chạy slider
        startAuto();

        // --- BACK TO TOP LOGIC ---
        const backToTopBtn = document.getElementById("backToTop");
        window.onscroll = function() {
            if (document.body.scrollTop > 300 || document.documentElement.scrollTop > 300) {
                backToTopBtn.style.display = "block";
            } else {
                backToTopBtn.style.display = "none";
            }
        };

        backToTopBtn.addEventListener('click', () => {
            window.scrollTo({top: 0, behavior: 'smooth'});
        });
    });
</script>

</body>
</html>