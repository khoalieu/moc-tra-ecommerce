<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
                    <c:if test="${p.displayOnSale}">
                        <span class="sale-tag">
                            <c:choose>
                                <c:when test="${not empty p.currentPromotionType and p.currentPromotionType eq 'PERCENT'}">
                                    -<fmt:formatNumber value="${p.currentPromotionValue}" maxFractionDigits="0"/>%
                                </c:when>
                                <c:when test="${not empty p.currentPromotionValue}">
                                    -<fmt:formatNumber value="${p.currentPromotionValue}" pattern="#,###"/>đ
                                </c:when>
                            </c:choose>
                        </span>
                    </c:if>
                </div>

                <h3>${p.name}</h3>

                <p class="price">
                    <fmt:setLocale value="vi_VN"/>

                    <c:choose>
                        <%-- Case 1: Product is on sale --%>
                        <c:when test="${p.displayOnSale}">
                            <span class="new-price" style="display: block; margin-bottom: 4px;">
                                <c:choose>
                                    <c:when test="${p.displayPriceRange}">
                                        <fmt:formatNumber value="${p.displayMinPrice}" type="currency" currencySymbol=""/>đ
                                        -
                                        <fmt:formatNumber value="${p.displayMaxPrice}" type="currency" currencySymbol=""/>đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${p.displayMinPrice}" type="currency" currencySymbol=""/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                            <span class="old-price" style="display: block;">
                                <c:choose>
                                    <c:when test="${p.originalMinPrice != p.originalMaxPrice}">
                                        <fmt:formatNumber value="${p.originalMinPrice}" type="currency" currencySymbol=""/>đ
                                        -
                                        <fmt:formatNumber value="${p.originalMaxPrice}" type="currency" currencySymbol=""/>đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${p.originalMinPrice}" type="currency" currencySymbol=""/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </c:when>

                        <%-- Case 2: No sale, standard price --%>
                        <c:otherwise>
                            <span class="normal-price">
                                <c:choose>
                                    <c:when test="${p.displayPriceRange}">
                                        <fmt:formatNumber value="${p.displayMinPrice}" type="currency" currencySymbol=""/>đ
                                        -
                                        <fmt:formatNumber value="${p.displayMaxPrice}" type="currency" currencySymbol=""/>đ
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${p.displayMinPrice}" type="currency" currencySymbol=""/>đ
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </c:otherwise>
                    </c:choose>
                </p>

                <div class="product-card-actions">
                    <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}" class="cta-button">Xem Chi Tiết</a>

                    <c:if test="${not empty sessionScope.user}">
                        <button type="button"
                                class="favorite-btn ${favoriteProductIds != null && favoriteProductIds.contains(p.id) ? 'active' : ''}"
                                data-product-id="${p.id}"
                                data-favorited="${favoriteProductIds != null && favoriteProductIds.contains(p.id) ? 'true' : 'false'}"
                                title="${favoriteProductIds != null && favoriteProductIds.contains(p.id) ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'}">
                            <i class="fa-solid fa-heart"></i>
                        </button>
                    </c:if>
                </div>
            </div>
        </c:forEach>
    </div>
</section>

<div class="pagination">
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
            <c:url var="prevPageUrl" value="/san-pham">
                <c:param name="page" value="${prevPage < 1 ? 1 : prevPage}"/>
                <c:if test="${currentCategory != null}">
                    <c:param name="category" value="${currentCategory}"/>
                </c:if>
                <c:if test="${not empty currentSort && currentSort != 'default'}">
                    <c:param name="sort" value="${currentSort}"/>
                </c:if>
                <c:if test="${currentPrice != null}">
                    <c:param name="price" value="${currentPrice}"/>
                </c:if>
                <c:if test="${currentMinPrice != null}">
                    <c:param name="minPrice" value="${currentMinPrice}"/>
                </c:if>
                <c:if test="${not empty currentPromotionParam}">
                    <c:param name="promotionId" value="${currentPromotionParam}"/>
                </c:if>
                <c:if test="${not empty currentSearch}">
                    <c:param name="search" value="${currentSearch}"/>
                </c:if>
            </c:url>
            <a href="${prevPageUrl}" class="${currentPage <= windowSize ? 'disabled' : ''}">
                &laquo;
            </a>

            <c:forEach begin="${startPage}" end="${endPage}" var="i">
                <c:url var="pageUrl" value="/san-pham">
                    <c:param name="page" value="${i}"/>
                    <c:if test="${currentCategory != null}">
                        <c:param name="category" value="${currentCategory}"/>
                    </c:if>
                    <c:if test="${not empty currentSort && currentSort != 'default'}">
                        <c:param name="sort" value="${currentSort}"/>
                    </c:if>
                    <c:if test="${currentPrice != null}">
                        <c:param name="price" value="${currentPrice}"/>
                    </c:if>
                    <c:if test="${currentMinPrice != null}">
                        <c:param name="minPrice" value="${currentMinPrice}"/>
                    </c:if>
                    <c:if test="${not empty currentPromotionParam}">
                        <c:param name="promotionId" value="${currentPromotionParam}"/>
                    </c:if>
                    <c:if test="${not empty currentSearch}">
                        <c:param name="search" value="${currentSearch}"/>
                    </c:if>
                </c:url>
                <a href="${pageUrl}" class="${currentPage == i ? 'active' : ''}">
                    ${i}
                </a>
            </c:forEach>

            <c:url var="nextPageUrl" value="/san-pham">
                <c:param name="page" value="${nextPage > totalPages ? totalPages : nextPage}"/>
                <c:if test="${currentCategory != null}">
                    <c:param name="category" value="${currentCategory}"/>
                </c:if>
                <c:if test="${not empty currentSort && currentSort != 'default'}">
                    <c:param name="sort" value="${currentSort}"/>
                </c:if>
                <c:if test="${currentPrice != null}">
                    <c:param name="price" value="${currentPrice}"/>
                </c:if>
                <c:if test="${currentMinPrice != null}">
                    <c:param name="minPrice" value="${currentMinPrice}"/>
                </c:if>
                <c:if test="${not empty currentPromotionParam}">
                    <c:param name="promotionId" value="${currentPromotionParam}"/>
                </c:if>
                <c:if test="${not empty currentSearch}">
                    <c:param name="search" value="${currentSearch}"/>
                </c:if>
            </c:url>
            <a href="${nextPageUrl}" class="${currentPage + windowSize > totalPages ? 'disabled' : ''}">
                &raquo;
            </a>
        </div>
    </c:if>
</div>
