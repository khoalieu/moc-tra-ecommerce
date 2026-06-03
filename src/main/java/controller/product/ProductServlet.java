package controller.product;

import dao.CategoryDAO;
import dao.DAOFactory;
import dao.ProductDAO;
import dao.PromotionDAO;
import jakarta.servlet.http.HttpSession;
import model.product.Category;
import model.product.Product;
import model.promotion.Promotion;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.FavoriteDAO;
import model.user.User;
import java.util.Set;

@WebServlet("/san-pham")
public class ProductServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();
        CategoryDAO categoryDAO = DAOFactory.getInstance().getCategoryDAO();

        PromotionDAO promotionDAO = DAOFactory.getInstance().getPromotionDAO();
        promotionDAO.syncPromotionPrices();

        String categoryParam = request.getParameter("category");
        String sortParam = request.getParameter("sort");
        String pageParam = request.getParameter("page");
        String priceParam = request.getParameter("price");
        String minPriceParam = request.getParameter("minPrice");
        String promoParam = request.getParameter("promotionId");

        String searchParam = request.getParameter("search");
        if (searchParam != null) {
            searchParam = searchParam.trim();
            if (searchParam.isEmpty()) {
                searchParam = null;
            }
        }

        Integer categoryId = null;
        if (categoryParam != null && !categoryParam.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryParam);
            } catch (NumberFormatException e) {
                categoryId = null;
            }
        }

        int page = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (Exception e) {
                page = 1;
            }
        }
        Double maxPrice = null;
        if (priceParam != null && !priceParam.isEmpty()) {
            try {
                maxPrice = Double.parseDouble(priceParam);
            } catch (Exception e) {
                maxPrice = null;
            }
        }
        Double minPrice = null;
        if (minPriceParam != null && !minPriceParam.isEmpty()) {
            try {
                minPrice = Double.parseDouble(minPriceParam);
            } catch (Exception e) {
                minPrice = null;
            }
        }

        boolean promotionOnly = false;
        Integer promotionId = null;
        if ("all".equalsIgnoreCase(promoParam)) {
            promotionOnly = true;
        } else if (promoParam != null && !promoParam.isEmpty()) {
            try {
                promotionId = Integer.parseInt(promoParam);
            } catch (Exception e) {
            }
        }

        List<Category> allCategories = categoryDAO.getAllActiveCategories();
        Map<Integer, Integer> counts = categoryDAO.getCategoryCounts();
        List<Promotion> activePromotions = promotionDAO.getActivePromotions();

        List<Category> parentCategories = new ArrayList<>();
        Map<Integer, List<Category>> childrenMap = new HashMap<>();

        if (allCategories != null) {
            for (Category c : allCategories) {
                if (c.getParentId() == null || c.getParentId() == 0) {
                    parentCategories.add(c);
                } else {
                    childrenMap.putIfAbsent(c.getParentId(), new ArrayList<>());
                    childrenMap.get(c.getParentId()).add(c);

                    int childCount = counts.getOrDefault(c.getId(), 0);
                    int parentCount = counts.getOrDefault(c.getParentId(), 0);
                    counts.put(c.getParentId(), parentCount + childCount);
                }
            }
        }

        List<Integer> selectedCategoryIds = null;
        if (categoryId != null) {
            selectedCategoryIds = new ArrayList<>();
            selectedCategoryIds.add(categoryId);

            List<Category> childCategories = childrenMap.get(categoryId);
            if (childCategories != null) {
                for (Category child : childCategories) {
                    selectedCategoryIds.add(child.getId());
                }
            }
        }

        int pageSize = 12;
        List<Product> products = productDAO.getProducts(selectedCategoryIds, promotionId, promotionOnly, sortParam, minPrice, maxPrice,  searchParam, page, pageSize, "active");
        int totalProducts = productDAO.countProducts(selectedCategoryIds, promotionId, promotionOnly, minPrice, maxPrice, searchParam , "active");
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);
        double[] priceRange = productDAO.getProductPriceRange(selectedCategoryIds, promotionId, promotionOnly, searchParam, "active");

        String categoryName = "Tất Cả Sản Phẩm";

        if (promotionOnly) {
            categoryName = "Tất Cả Khuyến Mãi";
        } else if (promotionId != null) {
            categoryName = promotionDAO.getPromotionName(promotionId);
        } else if (categoryId != null) {
            for (Category category : allCategories) {
                if (category.getId() != null && category.getId().equals(categoryId)) {
                    categoryName = category.getName();
                    break;
                }
            }
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user != null) {
            FavoriteDAO favoriteDAO = DAOFactory.getInstance().getFavoriteDAO();
            Set<Integer> favoriteProductIds = favoriteDAO.getFavoriteProductIds(user.getId());
            request.setAttribute("favoriteProductIds", favoriteProductIds);
        }

        request.setAttribute("parentCategories", parentCategories);
        request.setAttribute("childrenMap", childrenMap);
        request.setAttribute("categoryCountMap", counts);
        request.setAttribute("activePromotions", activePromotions);

        request.setAttribute("categoryName", categoryName);
        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("currentCategory", categoryId);
        request.setAttribute("currentSort", sortParam);
        request.setAttribute("currentMinPrice", minPrice);
        request.setAttribute("currentPrice", maxPrice);
        request.setAttribute("currentPromotion", promotionId);
        request.setAttribute("currentPromotionOnly", promotionOnly);
        request.setAttribute("currentPromotionParam", promotionOnly ? "all" : promotionId);
        request.setAttribute("minProductPrice", priceRange[0]);
        request.setAttribute("maxProductPrice", priceRange[1]);

        request.setAttribute("currentSearch", searchParam);

        request.getRequestDispatcher("/product/san-pham.jsp").forward(request, response);
    }
}
