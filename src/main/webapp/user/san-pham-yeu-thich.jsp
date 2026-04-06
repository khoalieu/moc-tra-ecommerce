<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sản phẩm yêu thích - Mộc Trà</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <style>
    .favorites-container {
      background: #fff;
      border-radius: 12px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      overflow: hidden;
      border: 1px solid #f0f0f0;
    }

    .favorites-filters {
      background: #fff;
      padding: 25px;
      border-radius: 12px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      margin-bottom: 25px;
      border: 1px solid #f0f0f0;
    }

    .favorites-filters .filters-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 20px;
    }

    .favorites-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }

    .favorites-table th {
      background: #f8f9fa;
      padding: 15px 12px;
      text-align: left;
      font-weight: 600;
      color: #333;
      border-bottom: 1px solid #eee;
      white-space: nowrap;
    }

    .favorites-table td {
      padding: 15px 12px;
      border-bottom: 1px solid #f0f0f0;
      vertical-align: middle;
    }

    .favorites-table tr:hover {
      background: #fafafa;
    }

    .favorite-image-thumb {
      width: 60px;
      height: 60px;
      object-fit: cover;
      border-radius: 8px;
    }

    .favorite-name {
      font-weight: 600;
      color: #333;
      margin-bottom: 4px;
    }

    .favorite-desc {
      font-size: 12px;
      color: #666;
    }

    .favorite-price-main {
      font-weight: 600;
      color: #107e84;
    }

    .favorite-price-old {
      font-size: 12px;
      color: #999;
      text-decoration: line-through;
    }

    .favorite-discount {
      font-weight: 600;
      color: #dc3545;
    }

    .favorite-discount.none {
      color: #888;
      font-weight: 500;
    }

    .favorite-actions {
      display: flex;
      gap: 8px;
      justify-content: center;
    }

    .favorite-actions .btn-action {
      padding: 8px 10px;
      border: none;
      background: #f8f9fa;
      color: #666;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-size: 12px;
      width: 34px;
      height: 34px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      text-decoration: none;
    }

    .favorite-actions .btn-action:hover {
      background: #107e84;
      color: white;
    }

    .empty-favorites {
      text-align: center;
      padding: 50px 20px;
      color: #666;
    }

    .empty-favorites i {
      font-size: 54px;
      color: #ddd;
      margin-bottom: 15px;
    }
  </style>
</head>
<body class="user-dashboard-page">

<jsp:include page="/common/header.jsp"></jsp:include>

<div class="container">
  <jsp:include page="/common/user-sidebar.jsp">
    <jsp:param name="activePage" value="yeu-thich"/>
  </jsp:include>

  <main class="main-content">
    <div class="orders-header">
      <h2 class="page-title" style="margin-bottom: 0;">Sản phẩm yêu thích</h2>
    </div>

    <form action="${pageContext.request.contextPath}/san-pham-yeu-thich" method="get" class="favorites-filters">
      <div class="filters-grid">
        <div class="filter-group">
          <label for="category-filter">Danh mục</label>
          <select name="categoryId" id="category-filter" class="form-select" onchange="this.form.submit()">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="cat" items="${categoryList}">
              <option value="${cat.id}" ${currentCategoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
            </c:forEach>
          </select>
        </div>

        <div class="filter-group">
          <label for="price-filter">Khoảng giá</label>
          <select name="maxPrice" id="price-filter" class="form-select" onchange="this.form.submit()">
            <option value="">Tất cả giá</option>
            <option value="50000" ${currentMaxPrice == '50000' ? 'selected' : ''}>Dưới 50.000₫</option>
            <option value="100000" ${currentMaxPrice == '100000' ? 'selected' : ''}>Dưới 100.000₫</option>
            <option value="200000" ${currentMaxPrice == '200000' ? 'selected' : ''}>Dưới 200.000₫</option>
            <option value="500000" ${currentMaxPrice == '500000' ? 'selected' : ''}>Dưới 500.000₫</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="sort-filter">Sắp xếp</label>
          <select name="sort" id="sort-filter" class="form-select" onchange="this.form.submit()">
            <option value="newest" ${currentSort == 'newest' ? 'selected' : ''}>Yêu thích mới nhất</option>
            <option value="oldest" ${currentSort == 'oldest' ? 'selected' : ''}>Yêu thích lâu nhất</option>
            <option value="price-asc" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá thấp đến cao</option>
            <option value="price-desc" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá cao đến thấp</option>
            <option value="name-asc" ${currentSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
          </select>
        </div>
      </div>
    </form>

    <div class="favorites-container">
      <div class="table-header">
        <div class="products-count">Tổng cộng: <strong>${totalProducts} sản phẩm</strong></div>
      </div>

      <c:choose>
        <c:when test="${not empty favoriteList}">
          <div class="table-responsive">
            <table class="favorites-table">
              <thead>
              <tr>
                <th style="width: 90px;">Hình ảnh</th>
                <th>Tên sản phẩm</th>
                <th style="width: 140px;">Giá bán</th>
                <th style="width: 180px;">Mức giảm sau khuyến mãi</th>
                <th style="width: 90px; text-align: center;">Chi tiết</th>
              </tr>
              </thead>
              <tbody>
              <c:forEach var="p" items="${favoriteList}">
                <tr>
                  <td>
                    <img src="${p.imageUrl}" alt="${p.name}" class="favorite-image-thumb">
                  </td>
                  <td>
                    <div class="favorite-name">${p.name}</div>
                    <div class="favorite-desc">${p.shortDescription}</div>
                  </td>
                  <td>
                    <div class="favorite-price-main">
                      <fmt:formatNumber value="${p.salePrice > 0 && p.salePrice < p.price ? p.salePrice : p.price}" pattern="#,###"/>₫
                    </div>
                    <c:if test="${p.salePrice > 0 && p.salePrice < p.price}">
                      <div class="favorite-price-old">
                        <fmt:formatNumber value="${p.price}" pattern="#,###"/>₫
                      </div>
                    </c:if>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${p.salePrice > 0 && p.salePrice < p.price}">
                                                <span class="favorite-discount">
                                                    Giảm <fmt:formatNumber value="${p.price - p.salePrice}" pattern="#,###"/>₫
                                                    (<fmt:formatNumber value="${(p.price - p.salePrice) / p.price * 100}" maxFractionDigits="0"/>%)
                                                </span>
                      </c:when>
                      <c:otherwise>
                        <span class="favorite-discount none">Không có</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <div class="favorite-actions">
                      <a href="${pageContext.request.contextPath}/chi-tiet-san-pham?id=${p.id}" class="btn-action" title="Xem chi tiết">
                        <i class="fa-solid fa-eye"></i>
                      </a>
                    </div>
                  </td>
                </tr>
              </c:forEach>
              </tbody>
            </table>
          </div>
        </c:when>

        <c:otherwise>
          <div class="empty-favorites">
            <i class="fa-regular fa-heart"></i>
            <h3>Chưa có sản phẩm yêu thích</h3>
            <p>Danh sách yêu thích của bạn hiện đang trống.</p>
            <a href="${pageContext.request.contextPath}/san-pham" class="btn-action"
               style="display: inline-flex; width: auto; padding: 10px 18px; margin-top: 15px;">
              Đi mua sắm
            </a>
          </div>
        </c:otherwise>
      </c:choose>

      <div class="pagination-container">
        <div class="pagination-info">
          Trang <strong>${currentPage}</strong> / <strong>${totalPages}</strong>
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
            <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${prevPage < 1 ? 1 : prevPage}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
               class="page-btn ${currentPage <= windowSize ? 'disabled' : ''}">
              &laquo;
            </a>

            <c:forEach begin="${startPage}" end="${endPage}" var="i">
              <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${i}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
                 class="page-btn ${currentPage == i ? 'active' : ''}">
                  ${i}
              </a>
            </c:forEach>

            <a href="${pageContext.request.contextPath}/san-pham-yeu-thich?page=${nextPage > totalPages ? totalPages : nextPage}&categoryId=${currentCategoryId}&maxPrice=${currentMaxPrice}&sort=${currentSort}"
               class="page-btn ${currentPage + windowSize > totalPages ? 'disabled' : ''}">
              &raquo;
            </a>
          </div>
        </c:if>
      </div>
    </div>
  </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
  <i class="fa-solid fa-chevron-up"></i>
</button>

</body>
</html>