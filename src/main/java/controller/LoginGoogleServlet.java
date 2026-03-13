package controller;

import dao.UserDAO;
import model.GooglePojo;
import model.User;
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
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }
        try {
            String accessToken = GoogleUtils.getToken(code);
            GooglePojo googlePojo = GoogleUtils.getUserInfo(accessToken);
            UserDAO userDAO = new UserDAO();
            User user = userDAO.loginWithGoogle(googlePojo);
            if (user != null) {
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                response.sendRedirect("index.jsp");
            } else {
                request.setAttribute("errorMessage", "Lỗi đăng nhập Google!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Lỗi hệ thống Google Login!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}