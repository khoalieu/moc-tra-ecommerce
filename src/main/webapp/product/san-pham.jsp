<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"> <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            <h1>Tất Cả Sản Phẩm</h1>
        </div>
    </section>

    <section class="shop-layout">
        <div class="container">
            <aside class="shop-sidebar">
                <div class="filter-group">
                    <h3>Danh Mục Sản Phẩm</h3>
                    <ul class="category-filter-list">

                        <li class="category-parent ${currentCategory == null && currentPromotion == null && not currentPromotionOnly && empty currentSearch && currentMinPrice == null && currentPrice == null ? 'active' : ''}">
                            <a href="${pageContext.request.contextPath}/san-pham">Tất Cả Sản Phẩm</a>
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
                                    <c:url var="parentCategoryUrl" value="/san-pham">
                                        <c:param name="category" value="${p.id}"/>
                                        <c:if test="${not empty currentPromotionParam}">
                                            <c:param name="promotionId" value="${currentPromotionParam}"/>
                                        </c:if>
                                        <c:if test="${currentPrice != null}">
                                            <c:param name="price" value="${currentPrice}"/>
                                        </c:if>
                                        <c:if test="${currentMinPrice != null}">
                                            <c:param name="minPrice" value="${currentMinPrice}"/>
                                        </c:if>
                                        <c:if test="${not empty currentSearch}">
                                            <c:param name="search" value="${currentSearch}"/>
                                        </c:if>
                                        <c:if test="${currentSort != null}">
                                            <c:param name="sort" value="${currentSort}"/>
                                        </c:if>
                                    </c:url>
                                    <a href="${parentCategoryUrl}">
                                            ${p.name}
                                        (<c:out value="${categoryCountMap[p.id]}" default="0" />)
                                    </a>

                                    <c:if test="${not empty childrenMap[p.id]}">
                                        <ul class="category-child-list">
                                            <c:forEach var="c" items="${childrenMap[p.id]}">

                                                <c:if test="${categoryCountMap[c.id] > 0}">
                                                    <li class="${currentCategory == c.id ? 'active-child' : ''}">
                                                        <c:url var="childCategoryUrl" value="/san-pham">
                                                            <c:param name="category" value="${c.id}"/>
                                                            <c:if test="${not empty currentPromotionParam}">
                                                                <c:param name="promotionId" value="${currentPromotionParam}"/>
                                                            </c:if>
                                                            <c:if test="${currentPrice != null}">
                                                                <c:param name="price" value="${currentPrice}"/>
                                                            </c:if>
                                                            <c:if test="${currentMinPrice != null}">
                                                                <c:param name="minPrice" value="${currentMinPrice}"/>
                                                            </c:if>
                                                            <c:if test="${not empty currentSearch}">
                                                                <c:param name="search" value="${currentSearch}"/>
                                                            </c:if>
                                                            <c:if test="${currentSort != null}">
                                                                <c:param name="sort" value="${currentSort}"/>
                                                            </c:if>
                                                        </c:url>
                                                        <a href="${childCategoryUrl}">
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
                <div style="margin-top: 18px;">
                    <a href="${pageContext.request.contextPath}/san-pham-yeu-thich"
                       style="display: block; padding: 12px 15px; border-radius: 8px; background: #fff; border: 1px solid #eee; font-weight: 600; color: #107e84; text-decoration: none;">
                        <i class="fa-solid fa-heart" style="margin-right: 8px;"></i>
                        Danh sách yêu thích
                    </a>
                </div>
                <div class="filter-group">
                    <h3>Chương Trình Khuyến Mãi</h3>

                    <ul class="category-filter-list">
                        <li class="category-parent ${currentPromotionOnly ? 'active' : ''}">
                            <c:url var="allPromotionUrl" value="/san-pham">
                                <c:param name="promotionId" value="all"/>
                                <c:if test="${currentCategory != null}">
                                    <c:param name="category" value="${currentCategory}"/>
                                </c:if>
                                <c:if test="${currentPrice != null}">
                                    <c:param name="price" value="${currentPrice}"/>
                                </c:if>
                                <c:if test="${currentMinPrice != null}">
                                    <c:param name="minPrice" value="${currentMinPrice}"/>
                                </c:if>
                                <c:if test="${not empty currentSearch}">
                                    <c:param name="search" value="${currentSearch}"/>
                                </c:if>
                                <c:if test="${currentSort != null}">
                                    <c:param name="sort" value="${currentSort}"/>
                                </c:if>
                            </c:url>
                            <a href="${allPromotionUrl}">Tất cả khuyến mãi</a>

                            <c:if test="${not empty activePromotions}">
                                <ul class="category-child-list">
                                    <c:forEach var="promo" items="${activePromotions}">
                                        <li class="${currentPromotion == promo.id ? 'active-child' : ''}">
                                            <c:url var="promotionUrl" value="/san-pham">
                                                <c:param name="promotionId" value="${promo.id}"/>
                                                <c:if test="${currentCategory != null}">
                                                    <c:param name="category" value="${currentCategory}"/>
                                                </c:if>
                                                <c:if test="${currentPrice != null}">
                                                    <c:param name="price" value="${currentPrice}"/>
                                                </c:if>
                                                <c:if test="${currentMinPrice != null}">
                                                    <c:param name="minPrice" value="${currentMinPrice}"/>
                                                </c:if>
                                                <c:if test="${not empty currentSearch}">
                                                    <c:param name="search" value="${currentSearch}"/>
                                                </c:if>
                                                <c:if test="${currentSort != null}">
                                                    <c:param name="sort" value="${currentSort}"/>
                                                </c:if>
                                            </c:url>
                                            <a href="${promotionUrl}">
                                                ${promo.name}
                                            </a>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </c:if>
                        </li>
                    </ul>
                </div>
                <div class="filter-group">
                    <h3>Lọc Theo Khoảng Giá</h3>

                    <div class="price-filter-form">
                        <div class="price-slider-values">
                            <span id="minPriceText"></span>
                            <span id="maxPriceText"></span>
                        </div>

                        <div class="price-range-slider">
                            <input type="range"
                                   id="minPriceRange"
                                   name="minPrice"
                                   min="${minProductPrice}"
                                   max="${maxProductPrice}"
                                   step="5000"
                                   value="${currentMinPrice != null ? currentMinPrice : minProductPrice}">

                            <input type="range"
                                   id="maxPriceRange"
                                   name="price"
                                   min="${minProductPrice}"
                                   max="${maxProductPrice}"
                                   step="5000"
                                   value="${currentPrice != null ? currentPrice : maxProductPrice}">
                        </div>

                        <p class="price-filter-range">
                            Khoảng giá hiện có:
                            <strong><fmt:formatNumber value="${minProductPrice}" pattern="#,###"/>đ</strong>
                            -
                            <strong><fmt:formatNumber value="${maxProductPrice}" pattern="#,###"/>đ</strong>
                        </p>
                    </div>
                    <script>
                        (function () {
                            const minRange = document.getElementById('minPriceRange');
                            const maxRange = document.getElementById('maxPriceRange');
                            const minText = document.getElementById('minPriceText');
                            const maxText = document.getElementById('maxPriceText');
                            const gap = 5000;

                            if (!minRange || !maxRange || !minText || !maxText) return;

                            function formatCurrency(value) {
                                return new Intl.NumberFormat('vi-VN').format(Math.round(Number(value))) + 'đ';
                            }

                            function syncPriceRange(changed) {
                                let minValue = Number(minRange.value);
                                let maxValue = Number(maxRange.value);
                                const minAllowed = Number(minRange.min);
                                const maxAllowed = Number(maxRange.max);
                                const effectiveGap = maxAllowed - minAllowed >= gap ? gap : 0;

                                if (maxValue - minValue < effectiveGap) {
                                    if (changed === 'min') {
                                        minValue = maxValue - effectiveGap;
                                        minRange.value = minValue;
                                    } else {
                                        maxValue = minValue + effectiveGap;
                                        maxRange.value = maxValue;
                                    }
                                }

                                minText.textContent = formatCurrency(minRange.value);
                                maxText.textContent = formatCurrency(maxRange.value);
                            }

                            function applyPriceRange() {
                                const currentUrl = new URL(window.location.href);

                                currentUrl.searchParams.set('minPrice', minRange.value);
                                currentUrl.searchParams.set('price', maxRange.value);
                                currentUrl.searchParams.set('page', '1');

                                if (typeof loadProducts === 'function') {
                                    loadProducts(currentUrl.toString());
                                } else {
                                    window.location.href = currentUrl.toString();
                                }
                            }

                            minRange.addEventListener('input', function () {
                                syncPriceRange('min');
                            });
                            maxRange.addEventListener('input', function () {
                                syncPriceRange('max');
                            });
                            minRange.addEventListener('change', applyPriceRange);
                            maxRange.addEventListener('change', applyPriceRange);
                            syncPriceRange();
                            window.syncPriceRange = syncPriceRange;
                        })();
                    </script>
                </div>
            </aside>

            <div class="shop-grid-wrapper">
                <div class="sort-bar" style="display: flex; align-items: center; justify-content: space-between; gap: 15px; flex-wrap: wrap;">

                    <form action="${pageContext.request.contextPath}/san-pham" method="get"
                          style="display: flex; align-items: center; gap: 8px; flex: 1; max-width: 460px;">

                        <input type="text"
                               name="search"
                               value="${currentSearch}"
                               placeholder="Tìm sản phẩm..."
                               style="flex: 1; padding: 9px 12px; border: 1px solid #ddd; border-radius: 6px; outline: none;">

                        <c:if test="${currentCategory != null}">
                            <input type="hidden" name="category" value="${currentCategory}">
                        </c:if>

                        <c:if test="${currentPrice != null}">
                            <input type="hidden" name="price" value="${currentPrice}">
                        </c:if>

                        <c:if test="${currentMinPrice != null}">
                            <input type="hidden" name="minPrice" value="${currentMinPrice}">
                        </c:if>

                        <c:if test="${not empty currentPromotionParam}">
                            <input type="hidden" name="promotionId" value="${currentPromotionParam}">
                        </c:if>

                        <c:if test="${currentSort != null}">
                            <input type="hidden" name="sort" value="${currentSort}">
                        </c:if>

                        <button type="submit"
                                style="padding: 9px 14px; border: none; border-radius: 6px; background: #107e84; color: white; cursor: pointer;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            Tìm
                        </button>

                    </form>

                    <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                        <label for="sort-by">Sắp xếp theo:</label>
                        <select id="sort-by" class="sort-select" onchange="applyProductSort(this.value);">
                            <option value="default" ${empty currentSort || currentSort == 'default' ? 'selected' : ''}>Mặc định</option>
                            <option value="newest" ${currentSort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="price-asc" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                            <option value="price-desc" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                        </select>

                        <c:if test="${currentCategory != null || not empty currentPromotionParam || currentMinPrice != null || currentPrice != null || not empty currentSearch || (not empty currentSort && currentSort != 'default')}">
                            <a href="${pageContext.request.contextPath}/san-pham" class="clear-filters-link">
                                Xóa bộ lọc
                            </a>
                        </c:if>
                    </div>
                    <script>
                        function applyProductSort(sortValue) {
                            const currentUrl = new URL(window.location.href);

                            if (!sortValue || sortValue === 'default') {
                                currentUrl.searchParams.delete('sort');
                            } else {
                                currentUrl.searchParams.set('sort', sortValue);
                            }

                            currentUrl.searchParams.set('page', '1');
                            if (typeof loadProducts === 'function') {
                                loadProducts(currentUrl.toString());
                            } else {
                                window.location.href = currentUrl.toString();
                            }
                        }
                    </script>
                </div>

                <div id="product-list-container" style="transition: opacity 0.2s ease-in-out;">
                    <jsp:include page="product-grid-partial.jsp" />
                </div>
            </div>
        </div>
    </section>
</main>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<div id="favoriteToast" class="favorite-toast"></div>

<script>
    function showFavoriteToast(message, type) {
        let toast = document.getElementById('favoriteToast');
        if (!toast) {
            toast = document.createElement('div');
            toast.id = 'favoriteToast';
            toast.className = 'favorite-toast';
            document.body.appendChild(toast);
        }

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

                            if (data.favorited) {
                                this.classList.add('active');
                            } else {
                                this.classList.remove('active');
                            }

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

    function loadProducts(url, pushState = true) {
        const container = document.getElementById('product-list-container');
        if (!container) return;

        container.style.opacity = '0.5';

        fetch(url, {
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(res => {
            if (!res.ok) throw new Error('Network response was not ok');
            return res.text();
        })
        .then(html => {
            container.innerHTML = html;
            bindFavoriteButtons();
            if (pushState) {
                history.pushState(null, '', url);
            }
            updateSidebarActiveState(url);
        })
        .catch(err => {
            console.error('Error loading products via AJAX:', err);
            showFavoriteToast('Không thể tải danh sách sản phẩm', 'error');
        })
        .finally(() => {
            container.style.opacity = '1';
        });
    }

    function updateSidebarActiveState(urlStr) {
        const url = new URL(urlStr, window.location.origin);
        const category = url.searchParams.get('category');
        const promotionId = url.searchParams.get('promotionId');
        const search = url.searchParams.get('search');
        const minPrice = url.searchParams.get('minPrice');
        const maxPrice = url.searchParams.get('price');

        // 1. "Tất Cả Sản Phẩm"
        const allProductsLi = document.querySelector('.category-parent a[href$="/san-pham"], .category-parent a[href$="/san-pham/"]');
        const isAllProductsActive = !category && !promotionId && !search && !minPrice && !maxPrice;
        if (allProductsLi) {
            const parentLi = allProductsLi.parentElement;
            if (isAllProductsActive) {
                parentLi.classList.add('active');
            } else {
                parentLi.classList.remove('active');
            }
        }

        // 2 & 3. Categories
        // Reset all category list items
        document.querySelectorAll('.shop-sidebar .category-filter-list li').forEach(li => {
            li.classList.remove('active', 'active-child');
        });

        if (category) {
            // Find child link first
            const childLink = document.querySelector(`.category-child-list a[href*="category=${category}"]`);
            if (childLink) {
                const childLi = childLink.parentElement;
                childLi.classList.add('active-child');
                // Parent li of child list should be active
                const parentLi = childLi.closest('.category-parent');
                if (parentLi) {
                    parentLi.classList.add('active');
                }
            } else {
                // Check if it's a parent category link
                const parentLink = document.querySelector(`.category-filter-list > li > a[href*="category=${category}"]`);
                if (parentLink) {
                    parentLink.parentElement.classList.add('active');
                }
            }
        }

        // 4 & 5. Promotions
        if (promotionId === 'all') {
            const promoAllLink = document.querySelector('.category-filter-list a[href*="promotionId=all"]');
            if (promoAllLink) {
                promoAllLink.parentElement.classList.add('active');
            }
        } else if (promotionId) {
            const promoChildLink = document.querySelector(`.category-child-list a[href*="promotionId=${promotionId}"]`);
            if (promoChildLink) {
                const childLi = promoChildLink.parentElement;
                childLi.classList.add('active-child');
                const parentLi = childLi.closest('.category-parent');
                if (parentLi) {
                    parentLi.classList.add('active');
                }
            }
        }

        // Sync inputs & controls
        const searchInput = document.querySelector('input[name="search"]');
        if (searchInput) {
            searchInput.value = search || '';
        }

        const sortSelect = document.getElementById('sort-by');
        if (sortSelect) {
            sortSelect.value = url.searchParams.get('sort') || 'default';
        }

        const minRange = document.getElementById('minPriceRange');
        const maxRange = document.getElementById('maxPriceRange');
        if (minRange && maxRange) {
            if (minPrice !== null) {
                minRange.value = minPrice;
            } else {
                minRange.value = minRange.min;
            }
            if (maxPrice !== null) {
                maxRange.value = maxPrice;
            } else {
                maxRange.value = maxRange.max;
            }
            if (typeof window.syncPriceRange === 'function') {
                window.syncPriceRange();
            }
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        bindFavoriteButtons();

        // Delegate clicks on product/catalog-related links
        document.addEventListener('click', e => {
            const link = e.target.closest('a');
            if (!link) return;

            const href = link.getAttribute('href');
            if (!href || href.startsWith('#') || href.startsWith('javascript:')) return;

            // We only intercept URLs pointing to /san-pham catalog page, ignoring other links (e.g. details, favorites page)
            try {
                const url = new URL(link.href, window.location.origin);
                if (url.pathname.endsWith('/san-pham') || url.pathname.endsWith('/san-pham/')) {
                    e.preventDefault();
                    loadProducts(link.href);
                }
            } catch (err) {
                // Ignore invalid URLs
            }
        });

        // Intercept search form submission
        const searchForm = document.querySelector('.sort-bar form');
        if (searchForm) {
            searchForm.addEventListener('submit', function (e) {
                e.preventDefault();
                const formData = new FormData(this);
                const params = new URLSearchParams(formData);
                const actionUrl = this.getAttribute('action') || window.location.pathname;
                const url = actionUrl + '?' + params.toString();
                loadProducts(url);
            });
        }
    });

    window.addEventListener('popstate', () => {
        loadProducts(window.location.href, false);
    });
</script>
</body>
</html>
