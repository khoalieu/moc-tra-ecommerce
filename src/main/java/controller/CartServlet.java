package controller;

import dao.CartDAO;
import dao.DAOFactory;
import dao.ProductDAO;
import dao.ProductVariantDAO; // Thêm import này
import model.cart.Cart;
import model.cart.CartItem;
import model.product.Product;
import model.product.ProductVariant; // Thêm import này
import model.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "CartServlet", value = "/gio-hang")
public class CartServlet extends HttpServlet {

    private final ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();
    private final ProductVariantDAO variantDAO = DAOFactory.getInstance().getProductVariantDAO();
    private final CartDAO cartDAO = DAOFactory.getInstance().getCartDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        request.setAttribute("cart", cart);
        request.getRequestDispatcher("/cart/gio-hang.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Cart cart = (Cart) session.getAttribute("cart");
        if (cart == null) {
            cart = new Cart();
            session.setAttribute("cart", cart);
        }
        User user = (User) session.getAttribute("user");
        boolean isLoggedIn = (user != null);

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");
        String variantIdStr = request.getParameter("variantId");

        try {
            int productId = (productIdStr != null && !productIdStr.isEmpty()) ? Integer.parseInt(productIdStr) : 0;
            int variantId = (variantIdStr != null && !variantIdStr.isEmpty()) ? Integer.parseInt(variantIdStr) : 0;

            if ("add".equals(action)) {
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(request.getParameter("quantity"));
                } catch (NumberFormatException ignored) {}

                Product product = productDAO.getProductById(productId);
                ProductVariant variant = variantDAO.getVariantById(variantId);
                if (product != null && variant != null) {
                    int currentInCart = (cart.getItems().stream()
                            .filter(i -> i.getVariantId() == variantId)
                            .findFirst().map(CartItem::getQuantity).orElse(0));

                    if (currentInCart + quantity > variant.getStockQuantity()) {
                        session.setAttribute("errorMsg", "Phân loại " + variant.getVariantName() + " chỉ còn " + variant.getStockQuantity() + " sản phẩm!");
                    } else {
                        cart.add(product, variant, quantity);

                        if (isLoggedIn) {
                            cartDAO.addToCart(user.getId(), productId, variantId, quantity);
                        }
                        session.setAttribute("successMsg", "Đã thêm vào giỏ hàng!");
                    }
                }
            }
            else if ("update".equals(action)) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                ProductVariant variant = variantDAO.getVariantById(variantId);

                if (variant != null && quantity > variant.getStockQuantity()) {
                    session.setAttribute("errorMsg", "Số lượng vượt quá tồn kho của phân loại này!");
                } else {
                    cart.update(variantId, quantity);

                    if (isLoggedIn) {
                        if (quantity > 0) {
                            cartDAO.updateQuantity(user.getId(), variantId, quantity);
                        } else {
                            cartDAO.removeProduct(user.getId(), variantId);
                        }
                    }
                }
            }
            else if ("remove".equals(action)) {
                cart.remove(variantId);
                if (isLoggedIn) {
                    cartDAO.removeProduct(user.getId(), variantId);
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        String referer = request.getHeader("referer");
        if (referer != null && !referer.contains("login") && !referer.contains("register")) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/gio-hang");
        }
    }
}