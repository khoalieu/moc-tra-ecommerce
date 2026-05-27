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

<jsp:include page="/common/header.jsp"></jsp:include>

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

    <section class="coupon-section">
        <div class="container">
            <div class="coupon-header">
                <div>
                    <h2>🎟️ Mã giảm giá hôm nay</h2>
                    <p>Lưu mã trước, dùng sau khi thanh toán. Số lượng có hạn.</p>
                </div>
            </div>

            <div id="couponAjaxMessage" class="coupon-alert coupon-alert-hidden"></div>

            <c:choose>
                <c:when test="${not empty couponList}">
                    <div class="coupon-grid">
                        <c:forEach var="coupon" items="${couponList}">
                            <c:set var="claimed" value="${claimedCouponIds.contains(coupon.id)}"/>
                            <c:set var="outOfStock" value="${coupon.claimLimit != null && coupon.currentClaims >= coupon.claimLimit}"/>

                            <div class="coupon-card ${claimed ? 'coupon-card-claimed' : ''}" data-coupon-card="${coupon.id}">
                                <div class="coupon-card-left">
                                    <div class="coupon-discount">
                                        <c:choose>
                                            <c:when test="${coupon.discountType == 'PERCENT'}">
                                                <span>
                                                    <fmt:formatNumber value="${coupon.discountValue}" maxFractionDigits="0"/>%
                                                </span>
                                                <small>GIẢM</small>
                                            </c:when>
                                            <c:otherwise>
                                                <span>
                                                    <fmt:formatNumber value="${coupon.discountValue}" pattern="#,###"/>đ
                                                </span>
                                                <small>GIẢM</small>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <div class="coupon-card-body">
                                    <div class="coupon-title">${coupon.title}</div>

                                    <div class="coupon-code">
                                        Mã: <strong>${coupon.code}</strong>
                                    </div>

                                    <div class="coupon-desc">
                                            ${coupon.description}
                                    </div>

                                    <div class="coupon-condition">
                                        <c:if test="${coupon.minOrderAmount > 0}">
                                            Đơn tối thiểu:
                                            <strong><fmt:formatNumber value="${coupon.minOrderAmount}" pattern="#,###"/>đ</strong>
                                        </c:if>

                                        <c:if test="${coupon.maxDiscountAmount != null}">
                                            <span> | </span>
                                            Giảm tối đa:
                                            <strong><fmt:formatNumber value="${coupon.maxDiscountAmount}" pattern="#,###"/>đ</strong>
                                        </c:if>
                                    </div>

                                    <div class="coupon-meta">
                                        <span>
                                            Đã nhận:
                                            <span class="coupon-claim-count" data-current-claims="${coupon.currentClaims}">
                                                    ${coupon.currentClaims}
                                            </span>
                                            /
                                            <c:choose>
                                                <c:when test="${coupon.claimLimit != null}">
                                                    ${coupon.claimLimit}
                                                </c:when>
                                                <c:otherwise>
                                                    Không giới hạn
                                                </c:otherwise>
                                            </c:choose>
                                        </span>

                                        <span>
                                            HSD: ${fn:replace(coupon.endDate, 'T', ' ')}
                                        </span>
                                    </div>
                                </div>

                                <div class="coupon-card-action">
                                    <c:choose>
                                        <c:when test="${sessionScope.user == null}">
                                            <a href="${pageContext.request.contextPath}/auth/login.jsp"
                                               class="btn-claim-coupon btn-login-coupon">
                                                Đăng nhập để lấy
                                            </a>
                                        </c:when>

                                        <c:when test="${claimed}">
                                            <button type="button" class="btn-claim-coupon btn-claimed" disabled>
                                                Đã nhận
                                            </button>
                                        </c:when>

                                        <c:when test="${outOfStock}">
                                            <button type="button" class="btn-claim-coupon btn-out-stock" disabled>
                                                Hết mã
                                            </button>
                                        </c:when>

                                        <c:otherwise>
                                            <button type="button"
                                                    class="btn-claim-coupon btn-claim-ajax"
                                                    data-coupon-id="${coupon.id}">
                                                Lấy mã
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="coupon-empty">
                        Hiện chưa có mã giảm giá nào.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
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
                                <span class="sale-tag">
                                    <c:choose>
                                        <c:when test="${p.currentPromotionType == 'PERCENT'}">
                                            -<fmt:formatNumber value="${p.currentPromotionValue}" maxFractionDigits="0"/>%
                                        </c:when>
                                        <c:otherwise>
                                            -<fmt:formatNumber value="${p.currentPromotionValue}" pattern="#,###"/>₫
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </c:if>

                            <div class="product-image">
                                <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}">
                                    <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="${p.name}" style="width: 100%; height: auto;">
                                </a>
                            </div>

                            <div class="product-info" style="padding: 15px;">
                                <h3 style="margin-bottom: 10px; font-size: 1.1rem;">
                                    <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}" style="color: #333; text-decoration: none;">
                                            ${p.name}
                                    </a>
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

    <c:if test="${isVipUser && not empty vipPromoMap}">
        <section class="vip-promotions-section">
            <div class="container">
                <div class="vip-header">
                    <h2>⭐ Giảm Thêm Cho Khách Hàng VIP</h2>
                    <p>Những ưu đãi độc quyền dành riêng cho bạn</p>
                </div>

                <c:forEach var="entry" items="${vipPromoMap}">
                    <c:set var="promo" value="${entry.key}" />
                    <c:set var="productList" value="${entry.value}" />

                    <section class="campaign-section vip-campaign" id="promo-vip-${promo.id}">
                        <div class="campaign-header">
                            <div class="campaign-header__left">
                                <h3>✨ ${promo.name}</h3>
                                <div class="campaign-timer">
                                    <i class="fa-regular fa-clock"></i>
                                    Kết thúc: ${fn:replace(promo.endDate, 'T', ' ')}
                                </div>
                            </div>
                            <div class="campaign-header__right">
                                <a href="${pageContext.request.contextPath}/san-pham?promotionId=${promo.id}&type=vip"
                                   class="btn-view-all">
                                    Xem tất cả <i class="fa-solid fa-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <div class="product-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px;">
                            <c:forEach var="p" items="${productList}">
                                <div class="product-card vip-product">
                                    <span class="vip-badge">VIP</span>

                                    <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                                        <span class="sale-tag vip-sale-tag">
                                            <c:choose>
                                                <c:when test="${p.currentPromotionType == 'PERCENT'}">
                                                    -<fmt:formatNumber value="${p.currentPromotionValue}" maxFractionDigits="0"/>%
                                                </c:when>
                                                <c:otherwise>
                                                    -<fmt:formatNumber value="${p.currentPromotionValue}" pattern="#,###"/>₫
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                    </c:if>

                                    <div class="product-image">
                                        <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}">
                                            <img src="${pageContext.request.contextPath}/${p.imageUrl}" alt="${p.name}" style="width: 100%; height: auto;">
                                        </a>
                                    </div>

                                    <div class="product-info" style="padding: 15px;">
                                        <h3 style="margin-bottom: 10px; font-size: 1.1rem;">
                                            <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}"
                                               style="color: #333; text-decoration: none;">
                                                    ${p.name}
                                            </a>
                                        </h3>

                                        <div class="price-box">
                                            <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                                                <span class="new-price" style="color: #d32f2f; font-weight: bold; font-size: 1.1rem; margin-right: 10px;">
                                                    <fmt:formatNumber value="${p.salePrice}" pattern="#,###"/>₫
                                                </span>
                                                <span class="old-price" style="color: #999; text-decoration: line-through; font-size: 0.9rem;">
                                                    <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                                                </span>
                                            </c:if>
                                            <c:if test="${p.salePrice <= 0 || p.salePrice >= p.price}">
                                                <span class="new-price" style="font-weight: bold; font-size: 1.1rem;">
                                                    <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                                                </span>
                                            </c:if>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </section>
                </c:forEach>
            </div>
        </section>
    </c:if>

    <c:if test="${!isVipUser && sessionScope.user != null}">
        <section class="vip-upgrade-banner">
            <div class="container">
                <div class="upgrade-content">
                    <h3>🌟 Nâng cấp thành Khách Hàng VIP</h3>
                    <p>Đạt các tiêu chí để trở thành VIP và nhận những ưu đãi độc quyền!</p>
                </div>
            </div>
        </section>
    </c:if>

</main>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang" style="display: none; position: fixed; bottom: 20px; right: 20px; z-index: 99; padding: 15px; background: #4CAF50; color: white; border: none; border-radius: 50%; cursor: pointer;">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        initSlider();
        initBackToTop();
        initClaimCouponAjax();
    });

    function initSlider() {
        const slides = document.querySelectorAll('.slide');
        const dots = document.querySelectorAll('.dot');
        const nextBtn = document.querySelector('.slider-next');
        const prevBtn = document.querySelector('.slider-prev');

        if (slides.length === 0) {
            return;
        }

        let currentSlide = 0;
        let slideInterval;

        function showSlide(index) {
            slides.forEach(s => s.classList.remove('active'));
            dots.forEach(d => d.classList.remove('active'));

            if (index >= slides.length) {
                currentSlide = 0;
            } else if (index < 0) {
                currentSlide = slides.length - 1;
            } else {
                currentSlide = index;
            }

            slides[currentSlide].classList.add('active');

            if (dots[currentSlide]) {
                dots[currentSlide].classList.add('active');
            }
        }

        function next() {
            showSlide(currentSlide + 1);
        }

        function prev() {
            showSlide(currentSlide - 1);
        }

        function startAuto() {
            slideInterval = setInterval(next, 5000);
        }

        function stopAuto() {
            clearInterval(slideInterval);
        }

        if (nextBtn) {
            nextBtn.addEventListener('click', function () {
                stopAuto();
                next();
                startAuto();
            });
        }

        if (prevBtn) {
            prevBtn.addEventListener('click', function () {
                stopAuto();
                prev();
                startAuto();
            });
        }

        dots.forEach(function (dot, idx) {
            dot.addEventListener('click', function () {
                stopAuto();
                showSlide(idx);
                startAuto();
            });
        });

        startAuto();
    }

    function initBackToTop() {
        const backToTopBtn = document.getElementById("backToTop");

        if (!backToTopBtn) {
            return;
        }

        window.addEventListener("scroll", function () {
            if (document.body.scrollTop > 300 || document.documentElement.scrollTop > 300) {
                backToTopBtn.style.display = "block";
            } else {
                backToTopBtn.style.display = "none";
            }
        });

        backToTopBtn.addEventListener("click", function () {
            window.scrollTo({
                top: 0,
                behavior: "smooth"
            });
        });
    }

    function initClaimCouponAjax() {
        const claimButtons = document.querySelectorAll(".btn-claim-ajax");
        const messageBox = document.getElementById("couponAjaxMessage");

        function showCouponMessage(message, type) {
            if (!messageBox) {
                alert(message);
                return;
            }

            messageBox.textContent = message;
            messageBox.className = "coupon-alert";

            if (type === "success") {
                messageBox.classList.add("coupon-alert-success");
            } else if (type === "warning") {
                messageBox.classList.add("coupon-alert-warning");
            } else {
                messageBox.classList.add("coupon-alert-error");
            }

            messageBox.style.display = "block";

            setTimeout(function () {
                messageBox.style.display = "none";
            }, 3000);
        }

        claimButtons.forEach(function (btn) {
            btn.addEventListener("click", function () {
                const couponId = btn.getAttribute("data-coupon-id");

                if (!couponId) {
                    showCouponMessage("Mã giảm giá không hợp lệ.", "error");
                    return;
                }

                btn.disabled = true;
                btn.textContent = "Đang lấy...";

                fetch("${pageContext.request.contextPath}/nhan-ma-giam-gia", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                        "X-Requested-With": "XMLHttpRequest"
                    },
                    body: "couponId=" + encodeURIComponent(couponId)
                })
                    .then(function (response) {
                        if (!response.ok) {
                            throw new Error("HTTP error");
                        }
                        return response.json();
                    })
                    .then(function (data) {
                        if (data.success) {
                            showCouponMessage(data.message || "Lấy mã giảm giá thành công.", "success");

                            btn.textContent = "Đã nhận";
                            btn.classList.remove("btn-claim-ajax");
                            btn.classList.add("btn-claimed");
                            btn.disabled = true;

                            const card = btn.closest(".coupon-card");
                            if (card) {
                                card.classList.add("coupon-card-claimed");

                                const claimCount = card.querySelector(".coupon-claim-count");
                                if (claimCount) {
                                    const currentClaims = parseInt(claimCount.getAttribute("data-current-claims")) || 0;
                                    const newClaims = currentClaims + 1;

                                    claimCount.textContent = newClaims;
                                    claimCount.setAttribute("data-current-claims", newClaims);
                                }
                            }

                            return;
                        }

                        if (data.status === "LOGIN_REQUIRED") {
                            showCouponMessage(data.message || "Vui lòng đăng nhập để lấy mã giảm giá.", "error");
                            btn.disabled = false;
                            btn.textContent = "Lấy mã";
                            return;
                        }

                        if (data.status === "ALREADY_CLAIMED") {
                            showCouponMessage(data.message || "Bạn đã nhận mã này rồi.", "warning");
                            btn.textContent = "Đã nhận";
                            btn.classList.remove("btn-claim-ajax");
                            btn.classList.add("btn-claimed");
                            btn.disabled = true;

                            const card = btn.closest(".coupon-card");
                            if (card) {
                                card.classList.add("coupon-card-claimed");
                            }
                            return;
                        }

                        if (data.status === "OUT_OF_STOCK") {
                            showCouponMessage(data.message || "Mã giảm giá này đã hết lượt nhận.", "error");
                            btn.textContent = "Hết mã";
                            btn.classList.remove("btn-claim-ajax");
                            btn.classList.add("btn-out-stock");
                            btn.disabled = true;
                            return;
                        }

                        showCouponMessage(data.message || "Có lỗi xảy ra khi lấy mã. Vui lòng thử lại.", "error");
                        btn.disabled = false;
                        btn.textContent = "Lấy mã";
                    })
                    .catch(function () {
                        showCouponMessage("Không thể lấy mã. Vui lòng kiểm tra lại servlet trả JSON.", "error");
                        btn.disabled = false;
                        btn.textContent = "Lấy mã";
                    });
            });
        });
    }
</script>

</body>
</html>