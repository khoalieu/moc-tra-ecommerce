package controller.product;

import dao.*;
import model.ReviewDTO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.product.Product;
import model.product.ProductImage;
import model.product.ProductVariant; // Thêm import này

import java.io.IOException;
import java.util.List;
import dao.FavoriteDAO;
import model.user.User;

@WebServlet("/chi-tiet-san-pham")
public class ProductDetailServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("san-pham");
            return;
        }

        try {
            int productId = Integer.parseInt(idParam);
            ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();
            ProductImageDAO imageDAO = DAOFactory.getInstance().getProductImageDAO();
            ReviewDAO reviewDAO = DAOFactory.getInstance().getReviewDAO();
            ProductVariantDAO variantDAO = DAOFactory.getInstance().getProductVariantDAO();
            Product product = productDAO.getProductById(productId);
            if (product == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại");
                return;
            }

            List<ProductImage> gallery = imageDAO.getImagesByProductId(productId);
            List<ReviewDTO> reviews = reviewDAO.getReviewsByProductId(productId);
            List<Product> relatedProducts = productDAO.getRelatedProducts(product.getCategoryId(), productId);

            List<ProductVariant> variants = variantDAO.getVariantsByProductId(productId);

            HttpSession session = request.getSession(false);
            User user = session != null ? (User) session.getAttribute("user") : null;

            boolean isFavorite = false;
            boolean canReview = false;

            if (user != null) {
                FavoriteDAO favoriteDAO = DAOFactory.getInstance().getFavoriteDAO();
                isFavorite = favoriteDAO.isFavorite(user.getId(), productId);

                canReview = reviewDAO.hasPurchasedProduct(user.getId(), productId);
            }

            request.setAttribute("isFavorite", isFavorite);
            request.setAttribute("canReview", canReview);
            request.setAttribute("product", product);
            request.setAttribute("gallery", gallery);
            request.setAttribute("reviews", reviews);
            request.setAttribute("relatedProducts", relatedProducts);

            request.setAttribute("variants", variants);
            request.setAttribute("pageTitle", "Chi Tiết - " + product.getName());
            request.getRequestDispatcher("/product/chi-tiet-san-pham.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("san-pham");
        }
    }
}