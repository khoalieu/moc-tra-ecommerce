package controller.product;

import dao.*;
import model.ReviewDTO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.product.Product;
import model.product.ProductImage;
import model.product.ProductVariant;
import model.user.User;

import java.io.IOException;
import java.util.List;

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
            int purchasedReviewCount = 0;
            int usedReviewCount = 0;
            int remainingReviewCount = 0;

            if (user != null) {
                FavoriteDAO favoriteDAO = DAOFactory.getInstance().getFavoriteDAO();
                isFavorite = favoriteDAO.isFavorite(user.getId(), productId);

                purchasedReviewCount = reviewDAO.countCompletedPurchasedQuantity(user.getId(), productId);
                usedReviewCount = reviewDAO.countReviewsByUserAndProduct(user.getId(), productId);
                remainingReviewCount = purchasedReviewCount - usedReviewCount;

                if (remainingReviewCount < 0) {
                    remainingReviewCount = 0;
                }

                canReview = remainingReviewCount > 0;
            }

            request.setAttribute("isFavorite", isFavorite);
            request.setAttribute("canReview", canReview);
            request.setAttribute("purchasedReviewCount", purchasedReviewCount);
            request.setAttribute("usedReviewCount", usedReviewCount);
            request.setAttribute("remainingReviewCount", remainingReviewCount);

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