package controller;

import dao.DAOFactory;
import dao.ReviewDAO;
import model.user.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "SubmitReviewServlet", value = "/submit-review")
public class SubmitReviewServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String productIdRaw = request.getParameter("productId");
        int productId;

        try {
            productId = Integer.parseInt(productIdRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/san-pham");
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            String redirect = URLEncoder.encode(
                    "/chi-tiet-san-pham?id=" + productId + "&tab=review",
                    StandardCharsets.UTF_8.toString()
            );

            response.sendRedirect(request.getContextPath()
                    + "/login?redirect=" + redirect);
            return;
        }

        ReviewDAO reviewDAO = DAOFactory.getInstance().getReviewDAO();

        if (!reviewDAO.canUserReview(user.getId(), productId)) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=not_allowed");
            return;
        }

        String ratingRaw = request.getParameter("rating");
        String comment = request.getParameter("comment");

        int rating;
        try {
            rating = Integer.parseInt(ratingRaw);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=invalid_rating");
            return;
        }

        if (rating < 1 || rating > 5) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=invalid_rating");
            return;
        }

        if (comment == null) {
            comment = "";
        }

        comment = comment.trim();

        if (comment.isEmpty()) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=empty_comment");
            return;
        }

        if (comment.length() > 1000) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=comment_too_long");
            return;
        }

        boolean ok = reviewDAO.addReview(productId, user.getId(), rating, comment);

        if (!ok) {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewError=insert_failed");
            return;
        }

        response.sendRedirect(request.getContextPath()
                + "/chi-tiet-san-pham?id=" + productId
                + "&tab=review&reviewSuccess=1");
    }
}
