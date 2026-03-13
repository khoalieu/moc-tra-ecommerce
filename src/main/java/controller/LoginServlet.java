package controller;

import dao.CartDAO;
import dao.UserDAO;
import model.Cart;
import model.CartItem;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if(request.getSession().getAttribute("user") != null){
            response.sendRedirect("index.jsp");
            return;
        }
        String googleLoginUrl = controller.utils.GoogleUtils.getGoogleAuthUrl();
        request.setAttribute("googleUrl", googleLoginUrl);
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String user = request.getParameter("username");
        String pass = request.getParameter("password");
        UserDAO dao = new UserDAO();
        User account = dao.checkLogin(user, pass);

        if (account != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", account);
            CartDAO cartDAO = new CartDAO();
            Cart sessionCart = (Cart) session.getAttribute("cart");
            if (sessionCart != null && sessionCart.getItems().size() > 0) {
                for (CartItem item : sessionCart.getItems()) {
                    cartDAO.addToCart(account.getId(), item.getProduct().getId(), item.getQuantity());
                }
            }
            Cart userCartFromDB = cartDAO.getCartByUserId(account.getId());
            session.setAttribute("cart", userCartFromDB);
            if(account.getRole() != null && account.getRole().name().equalsIgnoreCase("ADMIN")){
                response.sendRedirect("admin/dashboard");
            } else {
                response.sendRedirect("/index");
            }
        } else {
            request.setAttribute("errorMessage", "Sai tên đăng nhập hoặc mật khẩu!");
            request.setAttribute("username", user);
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}