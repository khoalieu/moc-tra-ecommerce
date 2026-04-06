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
      border: 1px solid #eee;
    }

    .favorite-name {
      font-weight: 600;
      color: #333;
      margin-bottom: 4px;
    }

    .favorite-desc {
      font-size: 12px;
      color: #666;
      line-height: 1.5;
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

    .favorite-actions .btn-action.danger:hover {
      background: #dc3545;
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

    .mock-badge {
      display: inline-block;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 12px;
      background: #fff3cd;
      color: #856404;
      margin-left: 10px;
      font-weight: 600;
    }

    @media (max-width: 768px) {
      .favorites-table {
        font-size: 13px;
      }

      .favorites-table th,
      .favorites-table td {
        padding: 12px 8px;
      }

      .favorite-image-thumb {
        width: 50px;
        height: 50px;
      }
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
      <h2 class="page-title" style="margin-bottom: 0;">
        Sản phẩm yêu thích
        <span class="mock-badge">Mock UI</span>
      </h2>
    </div>

    <!-- Bộ lọc giả lập -->
    <form action="#" method="get" class="favorites-filters">
      <div class="filters-grid">
        <div class="filter-group">
          <label for="category-filter">Danh mục</label>
          <select name="categoryId" id="category-filter" class="form-select">
            <option value="">Tất cả danh mục</option>
            <option value="1">Trà Thảo Mộc</option>
            <option value="2">Nguyên Liệu Trà Sữa</option>
            <option value="3">Trân Châu</option>
            <option value="4">Syrup</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="price-filter">Khoảng giá</label>
          <select name="maxPrice" id="price-filter" class="form-select">
            <option value="">Tất cả giá</option>
            <option value="50000">Dưới 50.000₫</option>
            <option value="100000">Dưới 100.000₫</option>
            <option value="200000">Dưới 200.000₫</option>
            <option value="500000">Dưới 500.000₫</option>
          </select>
        </div>

        <div class="filter-group">
          <label for="sort-filter">Sắp xếp</label>
          <select name="sort" id="sort-filter" class="form-select">
            <option value="newest">Yêu thích mới nhất</option>
            <option value="oldest">Yêu thích lâu nhất</option>
            <option value="price-asc">Giá thấp đến cao</option>
            <option value="price-desc">Giá cao đến thấp</option>
            <option value="name-asc">Tên A-Z</option>
          </select>
        </div>
      </div>
    </form>

    <div class="favorites-container">
      <div class="table-header">
        <div class="products-count">Tổng cộng: <strong>3 sản phẩm</strong></div>
      </div>

      <div class="table-responsive">
        <table class="favorites-table">
          <thead>
          <tr>
            <th style="width: 90px;">Hình ảnh</th>
            <th>Tên sản phẩm</th>
            <th style="width: 140px;">Giá bán</th>
            <th style="width: 180px;">Mức giảm sau khuyến mãi</th>
            <th style="width: 120px; text-align: center;">Hành động</th>
          </tr>
          </thead>
          <tbody>
          <tr>
            <td>
              <img src="${pageContext.request.contextPath}/assets/images/product-1.jpg"
                   alt="Trà Hoa Cúc Mật Ong"
                   class="favorite-image-thumb"
                   onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
            </td>
            <td>
              <div class="favorite-name">Trà Hoa Cúc Mật Ong</div>
              <div class="favorite-desc">Hương vị thanh nhẹ, thích hợp dùng buổi tối và thư giãn.</div>
            </td>
            <td>
              <div class="favorite-price-main">89.000₫</div>
              <div class="favorite-price-old">110.000₫</div>
            </td>
            <td>
              <span class="favorite-discount">Giảm 21.000₫ (19%)</span>
            </td>
            <td>
              <div class="favorite-actions">
                <a href="#" class="btn-action" title="Xem chi tiết">
                  <i class="fa-solid fa-eye"></i>
                </a>
                <button type="button" class="btn-action danger" title="Xóa khỏi danh sách">
                  <i class="fa-solid fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>

          <tr>
            <td>
              <img src="${pageContext.request.contextPath}/assets/images/product-2.jpg"
                   alt="Bột Sữa Pha Trà Sữa"
                   class="favorite-image-thumb"
                   onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
            </td>
            <td>
              <div class="favorite-name">Bột Sữa Pha Trà Sữa</div>
              <div class="favorite-desc">Nguyên liệu nền phổ biến để pha chế trà sữa tại nhà.</div>
            </td>
            <td>
              <div class="favorite-price-main">65.000₫</div>
            </td>
            <td>
              <span class="favorite-discount none">Không có</span>
            </td>
            <td>
              <div class="favorite-actions">
                <a href="#" class="btn-action" title="Xem chi tiết">
                  <i class="fa-solid fa-eye"></i>
                </a>
                <button type="button" class="btn-action danger" title="Xóa khỏi danh sách">
                  <i class="fa-solid fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>

          <tr>
            <td>
              <img src="${pageContext.request.contextPath}/assets/images/product-3.jpg"
                   alt="Trân Châu Đen"
                   class="favorite-image-thumb"
                   onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
            </td>
            <td>
              <div class="favorite-name">Trân Châu Đen</div>
              <div class="favorite-desc">Dẻo mềm, phù hợp dùng với trà sữa truyền thống.</div>
            </td>
            <td>
              <div class="favorite-price-main">45.000₫</div>
              <div class="favorite-price-old">55.000₫</div>
            </td>
            <td>
              <span class="favorite-discount">Giảm 10.000₫ (18%)</span>
            </td>
            <td>
              <div class="favorite-actions">
                <a href="#" class="btn-action" title="Xem chi tiết">
                  <i class="fa-solid fa-eye"></i>
                </a>
                <button type="button" class="btn-action danger" title="Xóa khỏi danh sách">
                  <i class="fa-solid fa-trash"></i>
                </button>
              </div>
            </td>
          </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination-container">
        <div class="pagination-info">
          Trang <strong>1</strong> / <strong>3</strong>
        </div>

        <div class="pagination">
          <a href="#" class="page-btn disabled">&laquo;</a>
          <a href="#" class="page-btn active">1</a>
          <a href="#" class="page-btn">2</a>
          <a href="#" class="page-btn">3</a>
          <a href="#" class="page-btn">&raquo;</a>
        </div>
      </div>
    </div>

    <%--
    Nếu muốn test trạng thái rỗng thì comment block favorites-container ở trên
    và mở block dưới ra.

    <div class="favorites-container">
        <div class="empty-favorites">
            <i class="fa-regular fa-heart"></i>
            <h3>Chưa có sản phẩm yêu thích</h3>
            <p>Danh sách yêu thích của bạn hiện đang trống.</p>
            <a href="${pageContext.request.contextPath}/san-pham" class="btn-action"
               style="display: inline-flex; width: auto; padding: 10px 18px; margin-top: 15px;">
                Đi mua sắm
            </a>
        </div>
    </div>
    --%>
  </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
  <i class="fa-solid fa-chevron-up"></i>
</button>

</body>
</html>