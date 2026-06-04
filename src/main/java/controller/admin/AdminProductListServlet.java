package controller.admin;
import dao.DAOFactory;
import dao.PromotionDAO;
import model.promotion.Promotion;
import dao.CategoryDAO;
import dao.ProductDAO;
import model.product.Category;
import model.product.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminProductListServlet", urlPatterns = {"/admin/products"})
public class AdminProductListServlet extends HttpServlet {
    private static final int DEFAULT_REORDER_THRESHOLD = 3;
    private static final int DEFAULT_LOW_STOCK_THRESHOLD = 10;

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;
    private PromotionDAO promotionDAO;

    @Override
    public void init() {
        productDAO = DAOFactory.getInstance().getProductDAO();
        categoryDAO = DAOFactory.getInstance().getCategoryDAO();
        promotionDAO = DAOFactory.getInstance().getPromotionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdStr = request.getParameter("categoryId");
        String minPriceStr = request.getParameter("minPrice");
        String maxPriceStr = request.getParameter("maxPrice");
        String sort = request.getParameter("sort");
        String pageStr = request.getParameter("page");
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String stockFilter = request.getParameter("stockFilter");
        String promotionFilter = request.getParameter("promotionFilter");
        String reorderThresholdStr = request.getParameter("reorderThreshold");
        String lowStockThresholdStr = request.getParameter("lowStockThreshold");
        promotionDAO.syncPromotionPrices();

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (Exception e) {
            }
        }

        Double minPrice = parseDouble(minPriceStr);
        Double maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            maxPrice = parseDouble(maxPriceStr);
        }

        int reorderThreshold = parsePositiveInt(reorderThresholdStr, DEFAULT_REORDER_THRESHOLD);
        int lowStockThreshold = parsePositiveInt(lowStockThresholdStr, DEFAULT_LOW_STOCK_THRESHOLD);
        if (lowStockThreshold < reorderThreshold) {
            lowStockThreshold = reorderThreshold;
        }

        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (Exception e) {
            }
        }
        if (keyword != null) {
            keyword = keyword.trim();
            if (keyword.isEmpty()) {
                keyword = null;
            }
        }
        sort = normalizeSort(sort);
        status = normalizeStatus(status);
        stockFilter = normalizeStockFilter(stockFilter);

        Integer promotionId = null;
        String promotionStatus = null;
        if (promotionFilter != null && promotionFilter.startsWith("promo-")) {
            try {
                promotionId = Integer.parseInt(promotionFilter.substring("promo-".length()));
            } catch (Exception ignored) {
                promotionFilter = null;
            }
        } else if ("active".equals(promotionFilter) || "none".equals(promotionFilter)) {
            promotionStatus = promotionFilter;
        } else {
            promotionFilter = null;
        }

        int pageSize = 10;

        List<Category> categoryList = categoryDAO.getAllActiveCategories();
        List<Integer> selectedCategoryIds = resolveSelectedCategoryIds(categoryId, categoryList);

        List<Product> productList = productDAO.getAdminProducts(selectedCategoryIds, promotionId, promotionStatus, stockFilter,
                sort, minPrice, maxPrice, keyword, page, pageSize, status, reorderThreshold, lowStockThreshold);

        int totalProducts = 0;
        try {
            totalProducts = productDAO.countAdminProducts(selectedCategoryIds, promotionId, promotionStatus, stockFilter,
                    minPrice, maxPrice, keyword, status, reorderThreshold, lowStockThreshold);
        } catch (Exception e) {
            e.printStackTrace();
        }

        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        List<Promotion> activePromos = promotionDAO.getAvailablePromotionsForAdmin();
        String filterQuery = buildFilterQuery(categoryId, status, stockFilter, minPriceStr, maxPriceStr, sort, keyword,
                promotionFilter, reorderThreshold, lowStockThreshold);
        request.setAttribute("productList", productList);
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("activePromos", activePromos);

        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.setAttribute("currentCategoryId", categoryId);
        request.setAttribute("currentMinPrice", minPriceStr);
        request.setAttribute("currentMaxPrice", maxPriceStr);
        request.setAttribute("currentSort", sort);
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentStatus", status);
        request.setAttribute("currentStockFilter", stockFilter);
        request.setAttribute("currentPromotionFilter", promotionFilter);
        request.setAttribute("currentReorderThreshold", reorderThreshold);
        request.setAttribute("currentLowStockThreshold", lowStockThreshold);
        request.setAttribute("filterQuery", filterQuery);

        request.getRequestDispatcher("/admin/admin-products.jsp").forward(request, response);
    }

    private Double parseDouble(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            double parsed = Double.parseDouble(value.trim());
            return parsed >= 0 ? parsed : null;
        } catch (Exception e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String normalizeSort(String sort) {
        if ("oldest".equals(sort) || "price-asc".equals(sort) || "price-desc".equals(sort)
                || "stock-asc".equals(sort) || "name-asc".equals(sort)) {
            return sort;
        }
        return "newest";
    }

    private String normalizeStatus(String status) {
        if ("active".equals(status) || "inactive".equals(status) || "out-of-stock".equals(status)) {
            return status;
        }
        return null;
    }

    private String normalizeStockFilter(String stockFilter) {
        if ("in-stock".equals(stockFilter) || "need-reorder".equals(stockFilter)
                || "low-stock".equals(stockFilter) || "out-of-stock".equals(stockFilter)) {
            return stockFilter;
        }
        return null;
    }

    private List<Integer> resolveSelectedCategoryIds(Integer categoryId, List<Category> categoryList) {
        if (categoryId == null) {
            return null;
        }

        List<Integer> ids = new ArrayList<>();
        ids.add(categoryId);
        for (Category category : categoryList) {
            if (category.getParentId() != null && category.getParentId().equals(categoryId)) {
                ids.add(category.getId());
            }
        }
        return ids;
    }

    private String buildFilterQuery(Integer categoryId, String status, String stockFilter, String minPrice, String maxPrice,
                                    String sort, String keyword, String promotionFilter,
                                    int reorderThreshold, int lowStockThreshold) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "categoryId", categoryId);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "stockFilter", stockFilter);
        appendQueryParam(query, "minPrice", minPrice);
        appendQueryParam(query, "maxPrice", maxPrice);
        appendQueryParam(query, "sort", sort);
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "promotionFilter", promotionFilter);
        appendQueryParam(query, "reorderThreshold", reorderThreshold);
        appendQueryParam(query, "lowStockThreshold", lowStockThreshold);
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String key, Object value) {
        if (value == null) {
            return;
        }
        String stringValue = String.valueOf(value);
        if (stringValue.trim().isEmpty()) {
            return;
        }
        query.append("&")
                .append(URLEncoder.encode(key, StandardCharsets.UTF_8))
                .append("=")
                .append(URLEncoder.encode(stringValue, StandardCharsets.UTF_8));
    }
}
