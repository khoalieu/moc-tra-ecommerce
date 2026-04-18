package controller.auth;

import dao.CartDAO;
import dao.DAOFactory;
import dao.UserDAO;
import model.GooglePojo;
import model.cart.Cart;
import model.cart.CartItem;
import model.user.User;
import controller.utils.GoogleUtils;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "LoginGoogleServlet", value = "/login-google")
public class LoginGoogleServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code == null || code.isEmpty()) {
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            return;
        }
        try {
            String accessToken = GoogleUtils.getToken(code);
            GooglePojo googlePojo = GoogleUtils.getUserInfo(accessToken);
            UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
            User user = userDAO.loginWithGoogle(googlePojo);

            if (user != null) {
                if (user.getLockUntil() != null && user.getLockUntil().isAfter(java.time.LocalDateTime.now())) {
                    request.setAttribute("errorMessage", "Tài khoản của bạn hiện đang bị khóa tạm thời. Vui lòng thử lại sau.");
                    request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
                    return;
                }

                HttpSession session = request.getSession();
                session.setAttribute("user", user);

                userDAO.resetFailedAttempts(user.getId());

                CartDAO cartDAO = DAOFactory.getInstance().getCartDAO();
                Cart sessionCart = (Cart) session.getAttribute("cart");
                if (sessionCart != null && !sessionCart.getItems().isEmpty()) {
                    for (CartItem item : sessionCart.getItems()) {
                        cartDAO.addToCart(user.getId(), item.getProduct().getId(), item.getQuantity());
                    }
                }
                Cart userCartFromDB = cartDAO.getCartByUserId(user.getId());
                session.setAttribute("cart", userCartFromDB);

                if (user.getRole() != null && user.getRole().name().equalsIgnoreCase("ADMIN")) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                    return;
                } else {
                    response.sendRedirect(request.getContextPath() + "/index");
                    return;
                }

            } else {
                request.setAttribute("errorMessage", "Tài khoản Email này chưa tồn tại trong hệ thống.");
                request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống khi đăng nhập bằng Google!");
            request.getRequestDispatcher("/auth/login.jsp").forward(request, response);
        }
    }
}
