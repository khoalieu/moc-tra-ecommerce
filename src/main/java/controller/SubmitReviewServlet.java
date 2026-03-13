package controller;

import dao.ReviewDAO;
import model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "SubmitReviewServlet", value = "/submit-review")
public class SubmitReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            ReviewDAO reviewDAO = new ReviewDAO();
            reviewDAO.addReview(productId, user.getId(), rating, comment);
            response.sendRedirect("chi-tiet-san-pham?id=" + productId);
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp");
        }
    }
}