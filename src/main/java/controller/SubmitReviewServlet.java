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

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

        String productIdRaw = request.getParameter("productId");
        int productId;

        try {
            productId = Integer.parseInt(productIdRaw);
        } catch (Exception e) {
            if (isAjax) {
                sendJsonError(response, "Sản phẩm không hợp lệ.");
            } else {
                response.sendRedirect(request.getContextPath() + "/san-pham");
            }
            return;
        }

        HttpSession session = request.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        if (user == null) {
            if (isAjax) {
                sendJsonError(response, "Vui lòng đăng nhập để đánh giá.");
            } else {
                String redirect = URLEncoder.encode(
                        "/chi-tiet-san-pham?id=" + productId + "&tab=review",
                        StandardCharsets.UTF_8.toString()
                );
                response.sendRedirect(request.getContextPath() + "/login?redirect=" + redirect);
            }
            return;
        }

        ReviewDAO reviewDAO = DAOFactory.getInstance().getReviewDAO();

        if (!reviewDAO.canUserReview(user.getId(), productId)) {
            if (isAjax) {
                sendJsonError(response, "Bạn chưa còn lượt đánh giá cho sản phẩm này. Chỉ khách đã mua sản phẩm và đơn hàng đã hoàn tất mới được đánh giá.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=not_allowed");
            }
            return;
        }

        String ratingRaw = request.getParameter("rating");
        String comment = request.getParameter("comment");

        int rating;
        try {
            rating = Integer.parseInt(ratingRaw);
        } catch (Exception e) {
            if (isAjax) {
                sendJsonError(response, "Vui lòng chọn số sao đánh giá hợp lệ.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=invalid_rating");
            }
            return;
        }

        if (rating < 1 || rating > 5) {
            if (isAjax) {
                sendJsonError(response, "Vui lòng chọn số sao đánh giá hợp lệ.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=invalid_rating");
            }
            return;
        }

        if (comment == null) {
            comment = "";
        }

        comment = comment.trim();

        if (comment.isEmpty()) {
            if (isAjax) {
                sendJsonError(response, "Vui lòng nhập nội dung nhận xét.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=empty_comment");
            }
            return;
        }

        if (comment.length() > 1000) {
            if (isAjax) {
                sendJsonError(response, "Nội dung đánh giá quá dài, tối đa 1000 ký tự.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=comment_too_long");
            }
            return;
        }

        boolean ok = reviewDAO.addReview(productId, user.getId(), rating, comment);

        if (!ok) {
            if (isAjax) {
                sendJsonError(response, "Gửi đánh giá thất bại. Vui lòng thử lại.");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/chi-tiet-san-pham?id=" + productId
                        + "&tab=review&reviewError=insert_failed");
            }
            return;
        }

        int remainingReviewCount = reviewDAO.getRemainingReviewCount(user.getId(), productId);
        boolean canReview = remainingReviewCount > 0;

        if (isAjax) {
            String avatar = user.getAvatar();
            if (avatar == null || avatar.trim().isEmpty()) {
                avatar = "assets/images/useravata.png";
            } else if (!avatar.startsWith("http")) {
                avatar = request.getContextPath() + "/" + avatar;
            }
            String formattedDate = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
            sendJson(response, true, "Gửi đánh giá thành công.", user.getUsername(), avatar, rating, comment, formattedDate, remainingReviewCount, canReview);
        } else {
            response.sendRedirect(request.getContextPath()
                    + "/chi-tiet-san-pham?id=" + productId
                    + "&tab=review&reviewSuccess=1");
        }
    }

    private void sendJson(HttpServletResponse response, boolean success, String message, String userName, String userAvatar, int rating, String comment, String createdAt, int remainingReviewCount, boolean canReview) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"success\":").append(success).append(",");
        sb.append("\"message\":\"").append(escapeJson(message)).append("\"");
        if (success) {
            sb.append(",");
            sb.append("\"userName\":\"").append(escapeJson(userName)).append("\",");
            sb.append("\"userAvatar\":\"").append(escapeJson(userAvatar)).append("\",");
            sb.append("\"rating\":").append(rating).append(",");
            sb.append("\"comment\":\"").append(escapeJson(comment)).append("\",");
            sb.append("\"createdAt\":\"").append(escapeJson(createdAt)).append("\",");
            sb.append("\"remainingReviewCount\":").append(remainingReviewCount).append(",");
            sb.append("\"canReview\":").append(canReview);
        }
        sb.append("}");
        response.getWriter().write(sb.toString());
    }

    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
    }

    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
