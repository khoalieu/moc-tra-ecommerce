package controller.product;

import dao.CategoryDAO;
import dao.ProductDAO;
import dao.PromotionDAO;
import jakarta.servlet.http.HttpSession;
import model.product.Category;
import model.product.Product;

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
        ProductDAO productDAO = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();

        String categoryParam = request.getParameter("category");
        String sortParam = request.getParameter("sort");
        String pageParam = request.getParameter("page");
        String priceParam = request.getParameter("price");
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

        Integer promotionId = null;
        if (promoParam != null && !promoParam.isEmpty()) {
            try {
                promotionId = Integer.parseInt(promoParam);
            } catch (Exception e) {
            }
        }
        if (searchParam != null) {
            categoryId = null;
            maxPrice = null;
            promotionId = null;
        }

        int pageSize = 12;
        List<Product> products = productDAO.getProducts(categoryId, promotionId, sortParam, maxPrice,  searchParam, page, pageSize, "active");
        int totalProducts = productDAO.countProducts(categoryId, promotionId, maxPrice, searchParam , "active");
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        String categoryName = "Tất Cả Sản Phẩm";

        if (promotionId != null) {
            PromotionDAO promoDAO = new PromotionDAO();
            categoryName = promoDAO.getPromotionName(promotionId);
        } else if (categoryId != null) {
            if (categoryId == 1) {
                categoryName = "Trà Thảo Mộc";
            } else if (categoryId == 2) {
                categoryName = "Nguyên Liệu Trà Sữa";
            }
        }

        List<Category> allCategories = categoryDAO.getAllActiveCategories();
        Map<Integer, Integer> counts = categoryDAO.getCategoryCounts();

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
        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user != null) {
            FavoriteDAO favoriteDAO = new FavoriteDAO();
            Set<Integer> favoriteProductIds = favoriteDAO.getFavoriteProductIds(user.getId());
            request.setAttribute("favoriteProductIds", favoriteProductIds);
        }

        request.setAttribute("parentCategories", parentCategories);
        request.setAttribute("childrenMap", childrenMap);
        request.setAttribute("categoryCountMap", counts);

        request.setAttribute("categoryName", categoryName);
        request.setAttribute("products", products);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);

        request.setAttribute("currentCategory", categoryId);
        request.setAttribute("currentSort", sortParam);
        request.setAttribute("currentPrice", maxPrice);
        request.setAttribute("currentPromotion", promotionId);

        request.setAttribute("currentSearch", searchParam);

        request.getRequestDispatcher("/product/san-pham.jsp").forward(request, response);
    }
}
