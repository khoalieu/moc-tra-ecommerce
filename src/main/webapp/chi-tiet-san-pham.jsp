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
<jsp:include page="common/header.jsp"></jsp:include>

<main class="main-content">
    <div class="container">
        <div style="margin-bottom: 20px; color: #666;">
            <a href="index.jsp">Trang chủ</a> /
            <a href="san-pham?category=${product.categoryId}">Sản phẩm</a> /
            <span>${product.name}</span>
        </div>

        <section class="product-detail-layout">
            <div class="product-gallery">
                <div class="main-image">
                    <img id="mainImg" src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.name}">
                </div>
                <div class="thumbnail-images">
                    <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="Main Thumbnail" class="active" onclick="changeImage(this)">
                    <c:forEach var="img" items="${gallery}">
                        <img src="${pageContext.request.contextPath}/${img.imageUrl}" alt="${img.altText}" onclick="changeImage(this)">
                    </c:forEach>
                </div>
            </div>

            <div class="product-info">
                <c:if test="${product.salePrice > 0 && product.salePrice < product.price}">
        <span class="sale-tag">
            -<fmt:formatNumber value="${(product.price - product.salePrice) / product.price * 100}" maxFractionDigits="0"/>%
        </span>
                </c:if>

                <h1>${product.name}</h1>
                <p style="color: #666; font-size: 0.9rem;">Mã SP: ${product.sku}</p>

                <div class="price-block">
                    <c:choose>
                        <c:when test="${product.salePrice > 0}">
                            <span class="new-price"><fmt:formatNumber value="${product.salePrice}" pattern="#,###"/> VNĐ</span>
                            <span class="old-price"><fmt:formatNumber value="${product.price}" pattern="#,###"/> VNĐ</span>
                        </c:when>
                        <c:otherwise>
                            <span class="new-price"><fmt:formatNumber value="${product.price}" pattern="#,###"/> VNĐ</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <p class="short-description">${product.shortDescription}</p>

                <form action="gio-hang" method="post" style="margin: 0; padding: 0;">
                    <input type="hidden" name="action" value="add">

                    <input type="hidden" name="productId" value="${product.id}">

                    <div class="quantity-selector">
                        <label for="quantity">Số lượng:</label>
                        <input type="number" id="quantity" name="quantity" value="1" min="1" max="${product.stockQuantity}">

                        <span style="font-size: 0.8rem; color: #888; margin-left: 10px;">
                (Còn ${product.stockQuantity} sản phẩm)
            </span>
                    </div>

                    <button type="submit" class="cta-button add-to-cart-btn">
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
                <button class="tab-link" data-tab="tab-4">Đánh Giá (${reviews.size()})</button>
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

                    <c:if test="${not empty sessionScope.user}">
                        <div class="review-form-container">
                            <form action="submit-review" method="post" class="review-form">
                                <input type="hidden" name="productId" value="${product.id}">

                                <div class="form-group">
                                    <label>Đánh giá của bạn:</label>
                                    <div class="star-rating">
                                        <input type="radio" id="star5" name="rating" value="5" required/><label for="star5" title="Tuyệt vời"></label>
                                        <input type="radio" id="star4" name="rating" value="4"/><label for="star4" title="Tốt"></label>
                                        <input type="radio" id="star3" name="rating" value="3"/><label for="star3" title="Bình thường"></label>
                                        <input type="radio" id="star2" name="rating" value="2"/><label for="star2" title="Tệ"></label>
                                        <input type="radio" id="star1" name="rating" value="1"/><label for="star1" title="Rất tệ"></label>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="review-text">Nhận xét:</label>
                                    <textarea id="review-text" name="comment" placeholder="Chia sẻ cảm nhận của bạn về sản phẩm..."></textarea>
                                </div>

                                <button type="submit" class="cta-button" style="border: none; cursor: pointer;">Gửi Đánh Giá</button>
                            </form>
                        </div>
                    </c:if>

                    <c:if test="${empty sessionScope.user}">
                        <p style="margin-bottom: 30px;">Vui lòng <a href="login.jsp" style="color: #4CAF50; font-weight: bold;">đăng nhập</a> để viết đánh giá.</p>
                    </c:if>

                    <div class="review-list">
                        <c:if test="${empty reviews}">
                            <p style="font-style: italic; color: #777;">(Chưa có đánh giá nào. Hãy là người đầu tiên!)</p>
                        </c:if>

                        <c:forEach var="r" items="${reviews}">
                            <div class="review-item">
                                <div class="review-avatar">
                                    <img src="${pageContext.request.contextPath}/${r.userAvatar}" alt="${r.userName}">
                                </div>
                                <div class="review-content">
                                    <div class="review-author">${r.userName}</div>

                                    <div class="review-meta">
                                        <div class="star-rating-display">
                                            <c:forEach begin="1" end="${r.rating}"><i class="fa-solid fa-star"></i></c:forEach>
                                            <c:forEach begin="1" end="${5 - r.rating}"><i class="fa-regular fa-star" style="color: #ddd;"></i></c:forEach>
                                        </div>
                                        <span class="review-date">
                                            <fmt:parseDate value="${r.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                                            <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                        </span>
                                    </div>

                                    <div class="review-body">
                                            ${r.comment}
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
                        <c:if test="${rp.salePrice > 0 && rp.salePrice < rp.price}">
                            <span class="sale-tag">
                                -<fmt:formatNumber value="${(rp.price - rp.salePrice) / rp.price * 100}" maxFractionDigits="0"/>%
                            </span>
                        </c:if>

                        <img src="${pageContext.request.contextPath}/${rp.imageUrl}" alt="${rp.name}">
                        <h3>${rp.name}</h3>
                        <p class="price">
                            <c:choose>
                                <c:when test="${rp.salePrice > 0}">
                                    <span class="new-price"><fmt:formatNumber value="${rp.salePrice}" pattern="#,###"/> VNĐ</span>
                                    <span class="old-price"><fmt:formatNumber value="${rp.price}" pattern="#,###"/> VNĐ</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="new-price"><fmt:formatNumber value="${rp.price}" pattern="#,###"/> VNĐ</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <a href="chi-tiet-san-pham?id=${rp.id}" class="cta-button">Xem Chi Tiết</a>
                    </div>
                </c:forEach>
            </div>
        </section>
    </div>
</main>

<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang"><i class="fa-solid fa-chevron-up"></i></button>

<script>
    // Tab switching logic
    document.addEventListener('DOMContentLoaded', function() {
        const tabLinks = document.querySelectorAll('.tab-link');
        const tabContents = document.querySelectorAll('.tab-content');

        tabLinks.forEach(link => {
            link.addEventListener('click', function() {
                const tabId = this.getAttribute('data-tab');
                tabLinks.forEach(item => item.classList.remove('active'));
                tabContents.forEach(item => item.classList.remove('active'));
                this.classList.add('active');
                document.getElementById(tabId).classList.add('active');
            });
        });
    });

    function changeImage(element) {
        document.getElementById('mainImg').src = element.src;
        document.querySelectorAll('.thumbnail-images img').forEach(img => img.classList.remove('active'));
        element.classList.add('active');
    }

    function addToCartJS(event) {
        event.preventDefault();
        var qty = document.getElementById('quantity').value;
        var href = event.currentTarget.getAttribute('href');
        window.location.href = href.replace("qty=1", "qty=" + qty);
    }
</script>

</body>
</html>