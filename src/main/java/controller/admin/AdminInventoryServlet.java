package controller.admin;

import dao.CategoryDAO;
import dao.DAOFactory;
import dao.ProductVariantDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.product.Category;
import model.product.ProductVariant;
import model.user.User;
import service.SystemLogService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/admin/inventory")
public class AdminInventoryServlet extends HttpServlet {
    private static final int DEFAULT_REORDER_THRESHOLD = 3;
    private static final int DEFAULT_LOW_STOCK_THRESHOLD = 10;

    private ProductVariantDAO variantDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        variantDAO = DAOFactory.getInstance().getProductVariantDAO();
        categoryDAO = DAOFactory.getInstance().getCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = trimToNull(request.getParameter("keyword"));
        String stockFilter = normalizeStockFilter(request.getParameter("stockFilter"));
        String sort = normalizeSort(request.getParameter("sort"));
        Integer categoryId = parseNullableInt(request.getParameter("categoryId"));
        int reorderThreshold = parsePositiveInt(request.getParameter("reorderThreshold"), DEFAULT_REORDER_THRESHOLD);
        int lowStockThreshold = parsePositiveInt(request.getParameter("lowStockThreshold"), DEFAULT_LOW_STOCK_THRESHOLD);
        if (lowStockThreshold < reorderThreshold) {
            lowStockThreshold = reorderThreshold;
        }
        int page = parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 15;

        List<ProductVariant> variants = variantDAO.getInventoryVariants(keyword, categoryId, stockFilter, sort,
                page, pageSize, reorderThreshold, lowStockThreshold);
        int totalVariants = variantDAO.countInventoryVariants(keyword, categoryId, stockFilter,
                reorderThreshold, lowStockThreshold);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalVariants / pageSize));
        List<Category> categories = categoryDAO.getAllActiveCategories();

        request.setAttribute("variants", variants);
        request.setAttribute("categoryList", categories);
        request.setAttribute("totalVariants", totalVariants);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentCategoryId", categoryId);
        request.setAttribute("currentStockFilter", stockFilter);
        request.setAttribute("currentSort", sort);
        request.setAttribute("currentReorderThreshold", reorderThreshold);
        request.setAttribute("currentLowStockThreshold", lowStockThreshold);
        request.setAttribute("filterQuery", buildFilterQuery(keyword, categoryId, stockFilter, sort,
                reorderThreshold, lowStockThreshold));
        request.getRequestDispatcher("/admin/admin-inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] variantIds = request.getParameterValues("variantIds");
        String[] quantityAdds = request.getParameterValues("quantityAdds");
        int updated = 0;
        int skipped = 0;

        if (variantIds != null && quantityAdds != null) {
            for (int i = 0; i < variantIds.length && i < quantityAdds.length; i++) {
                int variantId = parsePositiveInt(variantIds[i], 0);
                int quantityAdd = parsePositiveInt(quantityAdds[i], 0);
                if (variantId > 0 && quantityAdd > 0 && variantDAO.increaseStockById(variantId, quantityAdd)) {
                    updated++;
                } else if (quantityAdd > 0) {
                    skipped++;
                }
            }
        }

        User admin = (User) request.getSession().getAttribute("user");
        Integer adminId = admin != null ? admin.getId() : null;
        new SystemLogService().log(adminId, "Cap nhat ton kho thu cong: " + updated + " bien the", "ProductVariant", null);
        request.getSession().setAttribute("importMessage",
                "Da cong ton kho cho " + updated + " bien the" + (skipped > 0 ? ", bo qua " + skipped + " dong." : "."));
        response.sendRedirect(request.getContextPath() + "/admin/inventory");
    }

    private String normalizeStockFilter(String stockFilter) {
        if ("in-stock".equals(stockFilter) || "need-reorder".equals(stockFilter)
                || "low-stock".equals(stockFilter) || "out-of-stock".equals(stockFilter)) {
            return stockFilter;
        }
        return null;
    }

    private String normalizeSort(String sort) {
        if ("stock-desc".equals(sort) || "name-asc".equals(sort)) {
            return sort;
        }
        return "stock-asc";
    }

    private String trimToNull(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }

    private Integer parseNullableInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = value == null ? defaultValue : Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String buildFilterQuery(String keyword, Integer categoryId, String stockFilter, String sort,
                                    int reorderThreshold, int lowStockThreshold) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "categoryId", categoryId);
        appendQueryParam(query, "stockFilter", stockFilter);
        appendQueryParam(query, "sort", sort);
        appendQueryParam(query, "reorderThreshold", reorderThreshold);
        appendQueryParam(query, "lowStockThreshold", lowStockThreshold);
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String key, Object value) {
        if (value == null || String.valueOf(value).trim().isEmpty()) {
            return;
        }
        query.append("&")
                .append(URLEncoder.encode(key, StandardCharsets.UTF_8))
                .append("=")
                .append(URLEncoder.encode(String.valueOf(value), StandardCharsets.UTF_8));
    }
}
