package controller;

import dao.ReviewDAO;
import model.user.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "SubmitReviewServlet", value = "/submit-review")
public class SubmitReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        int productId = Integer.parseInt(request.getParameter("productId"));
        ReviewDAO reviewDAO = new ReviewDAO();

        if (user == null) {
            String redirect = java.net.URLEncoder.encode(
                    "/chi-tiet-san-pham?id=" + productId + "&tab=review",
                    java.nio.charset.StandardCharsets.UTF_8.toString()
            );
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp?redirect=" + redirect);
            return;
        }
    }
}
