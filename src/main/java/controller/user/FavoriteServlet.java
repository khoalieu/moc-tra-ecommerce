package controller.user;

import dao.CategoryDAO;
import dao.DAOFactory;
import dao.FavoriteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.product.Category;
import model.product.Product;
import model.user.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "FavoriteServlet", value = "/san-pham-yeu-thich")
public class FavoriteServlet extends HttpServlet {

    private FavoriteDAO favoriteDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        DAOFactory factory = DAOFactory.getInstance();
        favoriteDAO = factory.getFavoriteDAO();
        categoryDAO = factory.getCategoryDAO();
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        response.setContentType("application/json;charset=UTF-8");

        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng đăng nhập\"}");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {
                case "toggle":
                    handleToggle(request, response, user);
                    break;
                case "remove":
                    handleRemove(request, response, user);
                    break;
                case "bulk-remove":
                    handleBulkRemove(request, response, user);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"success\":false,\"message\":\"Action không hợp lệ\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Có lỗi xảy ra khi xử lý yêu thích\"}");
        }
    }

    private void handleToggle(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String productIdStr = request.getParameter("productId");
        int productId = Integer.parseInt(productIdStr);

        boolean isFavorite = favoriteDAO.isFavorite(user.getId(), productId);
        boolean ok;

        if (isFavorite) {
            ok = favoriteDAO.removeFavorite(user.getId(), productId);
            if (ok) {
                response.getWriter().write("{\"success\":true,\"favorited\":false,\"message\":\"Đã xóa khỏi yêu thích\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Xóa khỏi yêu thích thất bại\"}");
            }
        } else {
            ok = favoriteDAO.addFavorite(user.getId(), productId);
            if (ok) {
                response.getWriter().write("{\"success\":true,\"favorited\":true,\"message\":\"Đã thêm sản phẩm yêu thích\"}");
            } else {
                response.getWriter().write("{\"success\":false,\"message\":\"Thêm sản phẩm yêu thích thất bại\"}");
            }
        }
    }

    private void handleRemove(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String productIdStr = request.getParameter("productId");
        int productId = Integer.parseInt(productIdStr);

        boolean ok = favoriteDAO.removeFavorite(user.getId(), productId);
        if (ok) {
            response.getWriter().write("{\"success\":true,\"message\":\"Đã xóa sản phẩm khỏi danh sách yêu thích\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Xóa sản phẩm thất bại\"}");
        }
    }

    private void handleBulkRemove(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        String ids = request.getParameter("productIds");
        if (ids == null || ids.trim().isEmpty()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Chưa chọn sản phẩm nào\"}");
            return;
        }

        List<Integer> productIds = new ArrayList<>();
        for (String s : ids.split(",")) {
            try {
                productIds.add(Integer.parseInt(s.trim()));
            } catch (Exception ignored) {
            }
        }

        boolean ok = favoriteDAO.removeFavorites(user.getId(), productIds);
        if (ok) {
            response.getWriter().write("{\"success\":true,\"message\":\"Đã xóa các sản phẩm đã chọn khỏi yêu thích\"}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Xóa danh sách yêu thích thất bại\"}");
        }
    }
}