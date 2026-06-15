<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} - Mộc Trà</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>

<main class="main-content">
    <div class="container">
        <div style="margin-bottom: 20px; color: #666;">
            <a href="${pageContext.request.contextPath}/index">Trang chủ</a> /
            <a href="${pageContext.request.contextPath}/san-pham?category=${product.categoryId}">Sản phẩm</a> /
            <span>${product.name}</span>
        </div>
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="alert alert-success" style="padding: 10px; background: #d4edda; color: #155724; border-radius: 4px; margin-bottom: 20px;">
                <i class="fa-solid fa-circle-check"></i> ${sessionScope.successMsg}
            </div>
            <% session.removeAttribute("successMsg"); %>
        </c:if>

        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger" style="padding: 10px; background: #f8d7da; color: #721c24; border-radius: 4px; margin-bottom: 20px;">
                <i class="fa-solid fa-triangle-exclamation"></i> ${sessionScope.errorMsg}
            </div>
            <% session.removeAttribute("errorMsg"); %>
        </c:if>

        <section class="product-detail-layout">
            <div class="product-gallery">
                <c:choose>
                    <c:when test="${empty product.imageUrl}">
                        <c:set var="resolvedProductImg" value="${pageContext.request.contextPath}/assets/images/no-image.jpg"/>
                    </c:when>
                    <c:when test="${product.imageUrl.startsWith('http')}">
                        <c:set var="resolvedProductImg" value="${product.imageUrl}"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="resolvedProductImg" value="${pageContext.request.contextPath}/${product.imageUrl}"/>
                    </c:otherwise>
                </c:choose>
                <div class="main-image">
                    <img id="mainImg" src="${resolvedProductImg}" alt="${product.name}">
                </div>
                <div class="thumbnail-images">
                    <img src="${resolvedProductImg}" alt="Main Thumbnail" class="active" onclick="changeImage(this)">
                    <c:forEach var="img" items="${gallery}">
                        <c:choose>
                            <c:when test="${empty img.imageUrl}">
                                <c:set var="resolvedGalleryImg" value="${pageContext.request.contextPath}/assets/images/no-image.jpg"/>
                            </c:when>
                            <c:when test="${img.imageUrl.startsWith('http')}">
                                <c:set var="resolvedGalleryImg" value="${img.imageUrl}"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="resolvedGalleryImg" value="${pageContext.request.contextPath}/${img.imageUrl}"/>
                            </c:otherwise>
                        </c:choose>
                        <img src="${resolvedGalleryImg}" alt="${img.altText}" onclick="changeImage(this)">
                    </c:forEach>
                </div>
            </div>

            <div class="product-info">
                <c:set var="initialVariant" value="${not empty variants ? variants[0] : null}" />
                <c:set var="initialPrice" value="${not empty initialVariant ? initialVariant.price : product.originalMinPrice}" />
                <c:set var="initialSalePrice" value="${not empty initialVariant ? initialVariant.salePrice : product.displayMinPrice}" />
                <c:set var="initialOnSale" value="${initialSalePrice > 0 && initialSalePrice < initialPrice}" />

                <c:if test="${product.displayOnSale}">
                    <span class="sale-tag">
                        <c:choose>
                            <c:when test="${product.currentPromotionType eq 'PERCENT'}">
                                -<fmt:formatNumber value="${product.currentPromotionValue}" maxFractionDigits="0"/>%
                            </c:when>
                            <c:when test="${not empty product.currentPromotionValue}">
                                -<fmt:formatNumber value="${product.currentPromotionValue}" pattern="#,###"/>đ
                            </c:when>
                        </c:choose>
                    </span>
                </c:if>

                <h1>${product.name}</h1>
                <p style="color: #666; font-size: 0.9rem;">Mã SP: ${product.sku}</p>

                <div class="price-block">
                    <span id="display-new-price" class="new-price">
                        <c:choose>
                            <c:when test="${initialOnSale}"><fmt:formatNumber value="${initialSalePrice}" pattern="#,###"/>đ</c:when>
                            <c:otherwise><fmt:formatNumber value="${initialPrice}" pattern="#,###"/>đ</c:otherwise>
                        </c:choose>
                    </span>
                        <span id="display-old-price" class="old-price" style="${initialOnSale ? '' : 'display:none;'}">
                        <fmt:formatNumber value="${initialPrice}" pattern="#,###"/>đ
                    </span>
                </div>

                <p class="short-description">${product.shortDescription}</p>

                <form id="addToCartForm" action="gio-hang" method="post" style="margin: 0; padding: 0;">
                    <input type="hidden" name="action" value="add">

                    <input type="hidden" name="productId" value="${product.id}">
                    <c:if test="${not empty variants}">
                        <div class="variant-selector" style="margin-bottom: 20px;">
                            <label style="display: block; margin-bottom: 10px; font-weight: bold; color: #333;">Phân loại:</label>

                            <div class="variant-options" style="display: flex; gap: 15px; flex-wrap: wrap;">
                                <c:forEach var="v" items="${variants}" varStatus="loop">
                                    <label class="variant-item" style="cursor: pointer; display: flex; align-items: center; gap: 5px;">
                                        <input type="radio" name="variantId" value="${v.id}"
                                               data-price="${v.price}"
                                               data-sale="${v.salePrice}"
                                               data-stock="${v.stockQuantity}"
                                            ${loop.first ? 'checked' : ''}
                                               onchange="updateVariantInfo(this)">
                                        <span style="padding: 5px 10px; border: 1px solid #ddd; border-radius: 4px; transition: all 0.2s;">
                                                ${v.variantName}
                                        </span>
                                    </label>
                                </c:forEach>
                            </div>

                            <style>
                                .variant-item input[type="radio"] { display: none; }
                                .variant-item input[type="radio"]:checked + span {
                                    border-color: #4CAF50;
                                    background-color: #e8f5e9;
                                    color: #2e7d32;
                                    font-weight: bold;
                                }
                                .variant-item span:hover { background-color: #f5f5f5; }
                            </style>
                        </div>
                    </c:if>
                    <c:choose>
                        <c:when test="${not empty variants}">
                            <c:set var="initialStock" value="${variants[0].stockQuantity}" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="initialStock" value="${product.totalStockQuantity}" />
                        </c:otherwise>
                    </c:choose>

                    <div class="quantity-selector product-qty-favorite-row">
                        <label for="quantity">Số lượng:</label>
                        <input type="number" id="quantity" name="quantity" value="${initialStock > 0 ? 1 : 0}" min="${initialStock > 0 ? 1 : 0}" max="${initialStock}">

                        <span id="variant-stock" data-default-stock="${initialStock}" style="font-size: 0.8rem; color: #888; margin-left: 10px;">(Còn ${initialStock} sản phẩm)</span>

                        <c:if test="${not empty sessionScope.user}">
                            <button type="button"
                                    class="favorite-btn ${isFavorite ? 'active' : ''}"
                                    data-product-id="${product.id}"
                                    data-favorited="${isFavorite ? 'true' : 'false'}"
                                    title="${isFavorite ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'}">
                                <i class="fa-solid fa-heart"></i>
                            </button>
                        </c:if>
                    </div>

                    <button type="submit" class="cta-button add-to-cart-btn" id="addToCartBtn" ${initialStock <= 0 ? 'disabled' : ''}>
                        <i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ hàng
                    </button>
                </form>
            </div>
        </section>

        <section class="product-description-tabs">
            <div class="tab-headers">
                <button class="tab-link active" data-tab="tab-1">Mô Tả Chi Tiết</button>
                <button class="tab-link" data-tab="tab-2">Thành Phần</button>
                <button class="tab-link" data-tab="tab-3">Hướng Dẫn Sử Dụng</button>
                <button class="tab-link" data-tab="tab-4">Đánh Giá (<span id="reviews-count-badge">${reviews.size()}</span>)</button>
            </div>

            <div id="tab-1" class="tab-content active">
                <h3>Mô Tả Sản Phẩm</h3>
                <p class="preserve-lines">${product.description}</p>
            </div>
            <div id="tab-2" class="tab-content">
                <h3>Thành Phần</h3>
                <p class="preserve-lines">${product.ingredients}</p>
            </div>
            <div id="tab-3" class="tab-content">
                <h3>Hướng Dẫn Sử Dụng</h3>
                <p class="preserve-lines">${product.usageInstructions}</p>
            </div>

            <div id="tab-4" class="tab-content">
                <div class="product-reviews">
                    <h3>Đánh Giá Của Khách Hàng</h3>

                    <c:if test="${param.reviewSuccess == '1'}">
                        <p style="color: #2e7d32; margin-bottom: 15px; font-weight: bold;">
                            Gửi đánh giá thành công.
                        </p>
                    </c:if>

                    <c:if test="${not empty param.reviewError}">
                        <p style="color: #c62828; margin-bottom: 15px; font-weight: bold;">
                            <c:choose>
                                <c:when test="${param.reviewError == 'not_allowed'}">
                                    Bạn chưa còn lượt đánh giá cho sản phẩm này. Chỉ khách đã mua sản phẩm và đơn hàng đã hoàn tất mới được đánh giá.
                                </c:when>
                                <c:when test="${param.reviewError == 'invalid_rating'}">
                                    Vui lòng chọn số sao đánh giá hợp lệ.
                                </c:when>
                                <c:when test="${param.reviewError == 'empty_comment'}">
                                    Vui lòng nhập nội dung nhận xét.
                                </c:when>
                                <c:when test="${param.reviewError == 'comment_too_long'}">
                                    Nội dung đánh giá quá dài, tối đa 1000 ký tự.
                                </c:when>
                                <c:otherwise>
                                    Gửi đánh giá thất bại. Vui lòng thử lại.
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty sessionScope.user}">
                            <c:url var="loginUrl" value="/login">
                                <c:param name="redirect" value="/chi-tiet-san-pham?id=${product.id}&tab=review" />
                            </c:url>

                            <p style="margin-bottom: 30px; color: #777;">
                                Vui lòng
                                <a href="${loginUrl}" style="color: #4CAF50; font-weight: bold;">
                                    đăng nhập
                                </a>
                                để đánh giá sản phẩm.
                            </p>
                        </c:when>

                        <c:when test="${not canReview}">
                            <p style="margin-bottom: 30px; color: #777;">
                                Bạn cần mua sản phẩm này và đơn hàng phải hoàn tất thì mới được đánh giá.
                            </p>
                        </c:when>

                        <c:otherwise>
                            <p style="margin-bottom: 15px; color: #2e7d32;">
                                Bạn còn <b>${remainingReviewCount}</b> lượt đánh giá cho sản phẩm này.
                            </p>

                            <div class="review-form-container">
                                <form action="${pageContext.request.contextPath}/submit-review" method="post" class="review-form">
                                    <input type="hidden" name="productId" value="${product.id}">

                                    <div class="form-group">
                                        <label>Đánh giá của bạn:</label>
                                        <div class="star-rating">
                                            <input type="radio" id="star5" name="rating" value="5" required/>
                                            <label for="star5" title="Tuyệt vời"></label>

                                            <input type="radio" id="star4" name="rating" value="4"/>
                                            <label for="star4" title="Tốt"></label>

                                            <input type="radio" id="star3" name="rating" value="3"/>
                                            <label for="star3" title="Bình thường"></label>

                                            <input type="radio" id="star2" name="rating" value="2"/>
                                            <label for="star2" title="Tệ"></label>

                                            <input type="radio" id="star1" name="rating" value="1"/>
                                            <label for="star1" title="Rất tệ"></label>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label for="review-text">Nhận xét:</label>
                                        <textarea id="review-text"
                                                  name="comment"
                                                  placeholder="Chia sẻ cảm nhận của bạn về sản phẩm..."
                                                  maxlength="1000"
                                                  required></textarea>
                                    </div>

                                    <button type="submit" class="cta-button" style="border: none; cursor: pointer;">
                                        Gửi Đánh Giá
                                    </button>
                                </form>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <div class="review-list">
                        <c:if test="${empty reviews}">
                            <p id="empty-reviews-placeholder" style="font-style: italic; color: #777;">
                                (Chưa có đánh giá nào. Hãy là người đầu tiên!)
                            </p>
                        </c:if>

                        <c:forEach var="r" items="${reviews}">
                            <div class="review-item">
                                <div class="review-avatar">
                                    <c:choose>
                                        <c:when test="${empty r.userAvatar}">
                                            <c:set var="resolvedAvatar" value="${pageContext.request.contextPath}/assets/images/useravata.png"/>
                                        </c:when>
                                        <c:when test="${r.userAvatar.startsWith('http')}">
                                            <c:set var="resolvedAvatar" value="${r.userAvatar}"/>
                                        </c:when>
                                        <c:otherwise>
                                            <c:set var="resolvedAvatar" value="${pageContext.request.contextPath}/${r.userAvatar}"/>
                                        </c:otherwise>
                                    </c:choose>
                                    <img src="${resolvedAvatar}" alt="${r.userName}">
                                </div>
                                <div class="review-content">
                                    <div class="review-author">
                                        <c:out value="${r.userName}" />
                                    </div>

                                    <div class="review-meta">
                                        <div class="star-rating-display">
                                            <c:forEach begin="1" end="${r.rating}">
                                                <i class="fa-solid fa-star"></i>
                                            </c:forEach>

                                            <c:forEach begin="1" end="${5 - r.rating}">
                                                <i class="fa-regular fa-star" style="color: #ddd;"></i>
                                            </c:forEach>
                                        </div>

                                        <span class="review-date">
                                <fmt:parseDate value="${r.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                                <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </span>
                                    </div>

                                    <div class="review-body">
                                        <c:out value="${r.comment}" />
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>
        </section>

        <section class="product-related">
            <h2>Sản Phẩm Liên Quan</h2>
            <div class="product-grid">
                <c:forEach var="rp" items="${relatedProducts}">
                    <div class="product-card">
                        <c:if test="${rp.displayOnSale}">
                            <span class="sale-tag">
                                Giảm giá
                            </span>
                        </c:if>

                        <c:choose>
                            <c:when test="${empty rp.imageUrl}">
                                <c:set var="resolvedRpImg" value="${pageContext.request.contextPath}/assets/images/no-image.jpg"/>
                            </c:when>
                            <c:when test="${rp.imageUrl.startsWith('http')}">
                                <c:set var="resolvedRpImg" value="${rp.imageUrl}"/>
                            </c:when>
                            <c:otherwise>
                                <c:set var="resolvedRpImg" value="${pageContext.request.contextPath}/${rp.imageUrl}"/>
                            </c:otherwise>
                        </c:choose>
                        <img src="${resolvedRpImg}" alt="${rp.name}">
                        <h3>${rp.name}</h3>
                        <p class="price">
                            <c:choose>
                                <c:when test="${rp.displayOnSale}">
                                    <span class="new-price"><fmt:formatNumber value="${rp.displayMinPrice}" pattern="#,###"/>đ<c:if test="${rp.displayPriceRange}"> - <fmt:formatNumber value="${rp.displayMaxPrice}" pattern="#,###"/>đ</c:if></span>
                                    <span class="old-price"><fmt:formatNumber value="${rp.originalMinPrice}" pattern="#,###"/>đ<c:if test="${rp.originalMinPrice != rp.originalMaxPrice}"> - <fmt:formatNumber value="${rp.originalMaxPrice}" pattern="#,###"/>đ</c:if></span>
                                </c:when>
                                <c:otherwise>
                                    <span class="new-price"><fmt:formatNumber value="${rp.displayMinPrice}" pattern="#,###"/>đ<c:if test="${rp.displayPriceRange}"> - <fmt:formatNumber value="${rp.displayMaxPrice}" pattern="#,###"/>đ</c:if></span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${rp.id}" class="cta-button">Xem Chi Tiết</a>
                    </div>
                </c:forEach>
            </div>
        </section>
    </div>
</main>

<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang"><i class="fa-solid fa-chevron-up"></i></button>

<div id="favoriteToast" class="favorite-toast"></div>
<script>
    function changeImage(element) {
        document.getElementById('mainImg').src = element.src;
        document.querySelectorAll('.thumbnail-images img').forEach(img => img.classList.remove('active'));
        element.classList.add('active');
    }

    function showFavoriteToast(message, type) {
        let toast = document.getElementById('favoriteToast');
        const icon = type === 'success'
            ? '<i class="fa-solid fa-circle-check"></i>'
            : '<i class="fa-solid fa-circle-xmark"></i>';

        toast.className = 'favorite-toast ' + type + ' show';
        toast.innerHTML = icon + '<span>' + message + '</span>';

        setTimeout(() => {
            toast.className = 'favorite-toast';
            toast.innerHTML = '';
        }, 2000);
    }

    function bindFavoriteButtons() {
        document.querySelectorAll('.favorite-btn').forEach(btn => {
            btn.addEventListener('click', function () {
                const productId = this.dataset.productId;

                fetch('${pageContext.request.contextPath}/san-pham-yeu-thich', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: new URLSearchParams({
                        action: 'toggle',
                        productId: productId,
                        redirect: window.location.pathname + window.location.search
                    })
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.status === 'LOGIN_REQUIRED' && data.loginUrl) {
                            window.location.href = data.loginUrl;
                            return;
                        }
                        if (data.success) {
                            this.dataset.favorited = data.favorited ? 'true' : 'false';
                            this.title = data.favorited ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích';
                            this.classList.toggle('active', data.favorited);
                            showFavoriteToast(data.message, 'success');
                        } else {
                            showFavoriteToast(data.message, 'error');
                        }
                    })
                    .catch(() => {
                        showFavoriteToast('Thao tác yêu thích thất bại', 'error');
                    });
            });
        });
    }

    function updateVariantInfo(radioElement) {
        const price = parseFloat(radioElement.getAttribute('data-price'));
        const salePrice = parseFloat(radioElement.getAttribute('data-sale'));
        const stock = parseInt(radioElement.getAttribute('data-stock'));

        const newPriceElem = document.getElementById('display-new-price');
        const oldPriceElem = document.getElementById('display-old-price');
        const stockElem = document.getElementById('variant-stock');
        const quantityInput = document.getElementById('quantity');
        const addToCartBtn = document.getElementById('addToCartBtn');

        const formatCurrency = (amount) => new Intl.NumberFormat('vi-VN').format(amount) + "đ";

        if (salePrice > 0 && salePrice < price) {
            newPriceElem.innerText = formatCurrency(salePrice);
            oldPriceElem.innerText = formatCurrency(price);
            oldPriceElem.style.display = 'inline-block';
        } else {
            newPriceElem.innerText = formatCurrency(price);
            oldPriceElem.style.display = 'none';
        }

        const safeStock = Number.isFinite(stock) ? stock : 0;
        stockElem.innerText = "(Còn " + safeStock + " sản phẩm)";
        quantityInput.min = safeStock > 0 ? 1 : 0;
        quantityInput.max = safeStock;

        if (parseInt(quantityInput.value) > safeStock && safeStock > 0) {
            quantityInput.value = safeStock;
        }
        if (safeStock <= 0) {
            quantityInput.value = 0;
            addToCartBtn.disabled = true;
        } else {
            if (parseInt(quantityInput.value) < 1) {
                quantityInput.value = 1;
            }
            addToCartBtn.disabled = false;
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const tabLinks = document.querySelectorAll('.tab-link');
        const tabContents = document.querySelectorAll('.tab-content');

        function openTab(tabId) {
            tabLinks.forEach(item => item.classList.remove('active'));
            tabContents.forEach(item => item.classList.remove('active'));

            const activeButton = document.querySelector('.tab-link[data-tab="' + tabId + '"]');
            const activeContent = document.getElementById(tabId);

            if (activeButton) activeButton.classList.add('active');
            if (activeContent) activeContent.classList.add('active');
        }

        tabLinks.forEach(link => {
            link.addEventListener('click', function() {
                const tabId = this.getAttribute('data-tab');
                openTab(tabId);
            });
        });

        const params = new URLSearchParams(window.location.search);
        if (params.get('tab') === 'review') {
            openTab('tab-4');

            const reviewSection = document.getElementById('tab-4');
            if (reviewSection) {
                reviewSection.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        }

        bindFavoriteButtons();

        const addToCartForm = document.getElementById('addToCartForm');
        if (addToCartForm) {
            addToCartForm.addEventListener('submit', function (e) {
                e.preventDefault();

                const formData = new FormData(this);
                const params = new URLSearchParams();
                for (const pair of formData) {
                    params.append(pair[0], pair[1]);
                }

                fetch('${pageContext.request.contextPath}/gio-hang', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: params
                })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            if (window.updateHeaderCartDropdown) {
                                window.updateHeaderCartDropdown(data);
                            }
                            showFavoriteToast(data.message, 'success');
                        } else {
                            showFavoriteToast(data.message, 'error');
                        }
                    })
                    .catch(() => {
                        showFavoriteToast('Không thể thêm sản phẩm vào giỏ hàng.', 'error');
                    });
            });
        }

        const reviewForm = document.querySelector('.review-form');
        if (reviewForm) {
            reviewForm.addEventListener('submit', function(e) {
                e.preventDefault();

                const submitBtn = reviewForm.querySelector('button[type="submit"]');
                if (submitBtn) submitBtn.disabled = true;

                const formData = new FormData(reviewForm);

                fetch(reviewForm.action, {
                    method: 'POST',
                    headers: {
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: new URLSearchParams(formData)
                })
                .then(res => res.json())
                .then(data => {
                    if (submitBtn) submitBtn.disabled = false;

                    if (data.success) {
                        // Update remaining reviews info
                        const canReviewInfo = reviewForm.previousElementSibling;
                        if (canReviewInfo && canReviewInfo.tagName === 'P') {
                            if (data.remainingReviewCount > 0) {
                                canReviewInfo.innerHTML = 'Bạn còn <b>' + data.remainingReviewCount + '</b> lượt đánh giá cho sản phẩm này.';
                            } else {
                                canReviewInfo.style.display = 'none';
                            }
                        }

                        // Prepend new review
                        const reviewList = document.querySelector('.review-list');
                        if (reviewList) {
                            const placeholder = document.getElementById('empty-reviews-placeholder');
                            if (placeholder) {
                                placeholder.remove();
                            }

                            // Generate star HTML
                            let starsHtml = '';
                            for (let i = 1; i <= data.rating; i++) {
                                starsHtml += '<i class="fa-solid fa-star"></i>';
                            }
                            for (let i = 1; i <= 5 - data.rating; i++) {
                                starsHtml += '<i class="fa-regular fa-star" style="color: #ddd;"></i>';
                            }

                            const reviewItem = document.createElement('div');
                            reviewItem.className = 'review-item';
                            reviewItem.innerHTML = `
                                <div class="review-avatar">
                                    <img src="${data.userAvatar}" alt="${data.userName}">
                                </div>
                                <div class="review-content">
                                    <div class="review-author">${data.userName}</div>
                                    <div class="review-meta">
                                        <div class="star-rating-display">${starsHtml}</div>
                                        <span class="review-date">${data.createdAt}</span>
                                    </div>
                                    <div class="review-body">${data.comment}</div>
                                </div>
                            `;

                            reviewList.insertBefore(reviewItem, reviewList.firstChild);
                        }

                        // Increment reviews badge count
                        const badge = document.getElementById('reviews-count-badge');
                        if (badge) {
                            badge.textContent = parseInt(badge.textContent) + 1;
                        }

                        // Reset form
                        reviewForm.reset();

                        // If no longer can review, hide form
                        if (!data.canReview) {
                            const container = reviewForm.closest('.review-form-container');
                            if (container) {
                                container.innerHTML = '<p style="color: #777;">Cảm ơn bạn đã đánh giá sản phẩm!</p>';
                            }
                        }

                        showFavoriteToast(data.message, 'success');
                    } else {
                        showFavoriteToast(data.message, 'error');
                    }
                })
                .catch(err => {
                    if (submitBtn) submitBtn.disabled = false;
                    console.error(err);
                    showFavoriteToast('Gửi đánh giá thất bại. Vui lòng thử lại.', 'error');
                });
            });
        }

        const defaultCheckedVariant = document.querySelector('input[name="variantId"]:checked');
        if (defaultCheckedVariant) {
            updateVariantInfo(defaultCheckedVariant);
        } else {
            const stockElem = document.getElementById('variant-stock');
            const quantityInput = document.getElementById('quantity');

            if (stockElem && quantityInput) {
                const defaultStock = parseInt(stockElem.getAttribute('data-default-stock'));
                const safeStock = Number.isFinite(defaultStock) ? defaultStock : 0;
                stockElem.innerText = "(Còn " + safeStock + " sản phẩm)";
                quantityInput.max = safeStock;
            }
        }
    });
</script>
</body>
</html>


