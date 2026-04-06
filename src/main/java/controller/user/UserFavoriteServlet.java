package controller.user;

import dao.CategoryDAO;
import dao.FavoriteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.product.Category;
import model.product.Product;
import model.user.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserFavoriteServlet", value = "/san-pham-yeu-thich")
public class UserFavoriteServlet extends HttpServlet {

    private FavoriteDAO favoriteDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        favoriteDAO = new FavoriteDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }

        String categoryIdStr = request.getParameter("categoryId");
        String maxPriceStr = request.getParameter("maxPrice");
        String sort = request.getParameter("sort");
        String pageStr = request.getParameter("page");

        Integer categoryId = null;
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryIdStr);
            } catch (Exception ignored) {
            }
        }

        Double maxPrice = null;
        if (maxPriceStr != null && !maxPriceStr.isEmpty()) {
            try {
                maxPrice = Double.parseDouble(maxPriceStr);
            } catch (Exception ignored) {
            }
        }

        int page = 1;
        if (pageStr != null && !pageStr.isEmpty()) {
            try {
                page = Integer.parseInt(pageStr);
            } catch (Exception ignored) {
            }
        }

        int pageSize = 10;

        List<Product> favoriteList = favoriteDAO.getFavoriteProducts(
                user.getId(), categoryId, maxPrice, sort, page, pageSize
        );

        int totalProducts = favoriteDAO.countFavoriteProducts(user.getId(), categoryId, maxPrice);
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        List<Category> categoryList = categoryDAO.getAllCategories();

        request.setAttribute("favoriteList", favoriteList);
        request.setAttribute("categoryList", categoryList);

        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);

        request.setAttribute("currentCategoryId", categoryId);
        request.setAttribute("currentMaxPrice", maxPriceStr);
        request.setAttribute("currentSort", sort);

        request.getRequestDispatcher("/user/san-pham-yeu-thich.jsp").forward(request, response);
    }
}