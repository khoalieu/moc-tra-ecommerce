package controller;

import dao.CartDAO;
import dao.ProductDAO;
import model.cart.Cart;
import model.cart.CartItem;
import model.product.Product;
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

    private final ProductDAO productDAO = new ProductDAO();
    private final CartDAO cartDAO = new CartDAO();

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

        try {
            int productId = Integer.parseInt(productIdStr);
            if ("add".equals(action)) {
                int quantity = 1;
                try {
                    quantity = Integer.parseInt(request.getParameter("quantity"));
                } catch (NumberFormatException ignored) {}

                Product product = productDAO.getProductById(productId);
                if (product != null) {
                    int currentInCart = (cart.getItems().stream()
                            .filter(i -> i.getProduct().getId() == productId)
                            .findFirst().map(CartItem::getQuantity).orElse(0));
                    if (currentInCart + quantity > product.getStockQuantity()) {
                        session.setAttribute("errorMsg", "Sản phẩm " + product.getName() + " chỉ còn " + product.getStockQuantity() + " món!");
                    } else {
                        cart.add(product, quantity);
                        if (isLoggedIn) {
                            cartDAO.addToCart(user.getId(), productId, quantity);
                        }
                        session.setAttribute("successMsg", "Đã thêm vào giỏ hàng!");
                    }
                }
            }
            else if ("update".equals(action)) {
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                Product product = productDAO.getProductById(productId);
                if (product != null && quantity > product.getStockQuantity()) {
                    session.setAttribute("errorMsg", "Số lượng vượt quá tồn kho!");
                } else {
                    cart.update(productId, quantity);

                    if (isLoggedIn) {
                        if (quantity > 0) {
                            cartDAO.updateQuantity(user.getId(), productId, quantity);
                        } else {
                            cartDAO.removeProduct(user.getId(), productId);
                        }
                    }
                }
            }
            else if ("remove".equals(action)) {
                cart.remove(productId);
                if (isLoggedIn) {
                    cartDAO.removeProduct(user.getId(), productId);
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
