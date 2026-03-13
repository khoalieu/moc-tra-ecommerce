<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"> <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trà Thảo Mộc & Trà Sữa DIY</title>
    <link rel="stylesheet" href="assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>
<main class="main-content">
    <section class="page-header">
        <div class="container">
            <h1>Tất Cả Sản Phẩm</h1>
        </div>
    </section>

    <section class="shop-layout">
        <div class="container">
            <aside class="shop-sidebar">
                <div class="filter-group">
                    <h3>Danh Mục Sản Phẩm</h3>
                    <ul class="category-filter-list">

                        <li class="category-parent ${currentCategory == null ? 'active' : ''}">
                            <a href="san-pham">Tất Cả Sản Phẩm</a>
                        </li>

                        <c:forEach var="p" items="${parentCategories}">
                            <c:if test="${categoryCountMap[p.id] > 0}">

                                <c:set var="isActiveParent" value="${currentCategory == p.id}" />
                                <c:if test="${not isActiveParent}">
                                    <c:forEach var="child" items="${childrenMap[p.id]}">
                                        <c:if test="${currentCategory == child.id}">
                                            <c:set var="isActiveParent" value="true"/>
                                        </c:if>
                                    </c:forEach>
                                </c:if>

                                <li class="category-parent ${isActiveParent ? 'active' : ''}">
                                    <a href="san-pham?category=${p.id}">
                                            ${p.name}
                                        (<c:out value="${categoryCountMap[p.id]}" default="0" />)
                                    </a>

                                    <c:if test="${not empty childrenMap[p.id]}">
                                        <ul class="category-child-list">
                                            <c:forEach var="c" items="${childrenMap[p.id]}">

                                                <c:if test="${categoryCountMap[c.id] > 0}">
                                                    <li class="${currentCategory == c.id ? 'active-child' : ''}">
                                                        <a href="san-pham?category=${c.id}">
                                                                ${c.name}
                                                            (<c:out value="${categoryCountMap[c.id]}" default="0" />)
                                                        </a>
                                                    </li>
                                                </c:if>

                                            </c:forEach>
                                        </ul>
                                    </c:if>
                                </li>
                            </c:if>
                        </c:forEach>

                    </ul>
                </div>
                <div class="filter-group">
                    <h3>Lọc Theo Giá</h3>

                    <input type="range"
                           id="priceRange"
                           min="0" max="500000" step="5000"
                           value="${currentPrice != null ? currentPrice : 500000}"
                           style="width: 100%; cursor: pointer;"
                           oninput="updatePriceLabel(this.value)"
                           onchange="applyPriceFilter(this.value)">

                    <p>
                        Giá: 0 VNĐ — <span id="priceValue" style="font-weight: bold; color: #28a745;">
                            <c:choose>
                                <c:when test="${currentPrice != null}">
                                    <fmt:formatNumber value="${currentPrice}" pattern="#,###"/>
                                </c:when>
                                <c:otherwise>500.000</c:otherwise>
                            </c:choose>
                        </span> VNĐ
                    </p>
                </div>
                <script>
                    function updatePriceLabel(value) {
                        let formattedVal = new Intl.NumberFormat('vi-VN').format(value);
                        document.getElementById('priceValue').innerText = formattedVal;
                    }

                    function applyPriceFilter(value) {
                        let currentUrl = new URL(window.location.href);

                        currentUrl.searchParams.set('price', value);

                        currentUrl.searchParams.set('page', '1');

                        window.location.href = currentUrl.toString();
                    }
                </script>
            </aside>

            <div class="shop-grid-wrapper">
                <div class="sort-bar">
                    <label for="sort-by">Sắp xếp theo:</label>
                    <select id="sort-by" class="sort-select" onchange="location = this.value;">
                        <option value="san-pham?sort=default&category=${currentCategory}" ${currentSort == 'default' ? 'selected' : ''}>Mặc định</option>
                        <option value="san-pham?sort=newest&category=${currentCategory}" ${currentSort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                        <option value="san-pham?sort=price-asc&category=${currentCategory}" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                        <option value="san-pham?sort=price-desc&category=${currentCategory}" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                    </select>
                </div>

                <section class="product-group">

                    <h2 class="group-title">${categoryName}</h2>

                    <div class="product-grid">

                        <c:if test="${products.size() == 0}">
                            <p style="text-align: center; width: 100%; col-span: 3;">
                                Không tìm thấy sản phẩm nào phù hợp!
                            </p>
                        </c:if>

                        <c:forEach var="p" items="${products}">
                            <div class="product-card">
                                <div class="product-image-wrapper">
                                    <img src="${p.imageUrl}" alt="${p.name}">

                                    <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                                        <span class="badge-sale">Giảm giá</span>
                                    </c:if>
                                </div>

                                <h3>${p.name}</h3>

                                <p class="price">
                                    <fmt:setLocale value="vi_VN"/>

                                    <c:choose>
                                        <%-- Case 1: Product is on sale --%>
                                        <c:when test="${p.salePrice > 0 && p.salePrice < p.price}">
                                            <span class="new-price">
                                                <fmt:formatNumber value="${p.salePrice}" type="currency" currencySymbol=""/>₫
                                            </span>
                                            <span class="old-price">
                                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol=""/>₫
                                            </span>
                                        </c:when>

                                        <%-- Case 2: No sale, standard price --%>
                                        <c:otherwise>
                                            <span class="normal-price">
                                                <fmt:formatNumber value="${p.price}" type="currency" currencySymbol=""/>₫
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </p>

                                <a href="chi-tiet-san-pham?id=${p.id}" class="cta-button">Xem Chi Tiết</a>
                            </div>
                        </c:forEach>

                    </div>
                </section>

                <div class="pagination">
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <a href="san-pham?page=${i}&category=${currentCategory}&sort=${currentSort}"
                           class="${currentPage == i ? 'active' : ''}">${i}</a>
                    </c:forEach>
                </div>
            </div>
        </div>
    </section>
</main>
<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

</body>
</html>