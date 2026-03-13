package controller.admin;
import dao.PromotionDAO;
import model.Promotion;
import dao.CategoryDAO;
import dao.ProductDAO;
import model.Category;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminProductListServlet", urlPatterns = {"/admin/products"})
public class AdminProductListServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;
    private PromotionDAO promotionDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
        promotionDAO = new PromotionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdStr = request.getParameter("categoryId");
        String maxPriceStr = request.getParameter("maxPrice");
        String sort = request.getParameter("sort");
        String pageStr = request.getParameter("page");
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (Exception e) {
            }
        }

        Double maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            if (maxPriceStr.equals("50000")) maxPrice = 50000.0;
            else if (maxPriceStr.equals("100000")) maxPrice = 100000.0;
            else if (maxPriceStr.equals("200000")) maxPrice = 200000.0;
        }

        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (Exception e) {
            }
        }

        int pageSize = 10;

        List<Product> productList = productDAO.getProducts(categoryId, null, sort, maxPrice, page, pageSize, status);

        int totalProducts = 0;
        try {
            totalProducts = productDAO.countProducts(categoryId, null, maxPrice, status);
        } catch (Exception e) {
            e.printStackTrace();
        }

        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        List<Category> categoryList = categoryDAO.getAllCategories();

        List<Promotion> activePromos = promotionDAO.getActivePromotions();

        request.setAttribute("productList", productList);
        request.setAttribute("categoryList", categoryList);
        request.setAttribute("activePromos", activePromos);

        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.setAttribute("currentCategoryId", categoryId);
        request.setAttribute("currentMaxPrice", maxPriceStr);
        request.setAttribute("currentSort", sort);
        request.setAttribute("currentKeyword", keyword);
        request.setAttribute("currentStatus", status);

        request.getRequestDispatcher("/admin/admin-products.jsp").forward(request, response);
    }
}