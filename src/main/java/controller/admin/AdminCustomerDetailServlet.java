package controller.admin;

import dao.*;
import model.order.Order;
import model.user.User;
import model.user.UserAddress;
import model.enums.UserRole;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import model.blog.BlogComment;
import java.util.ArrayList;
import java.util.Collections;
import java.text.DecimalFormat;

import model.product.ProductReview;
import model.user.UserActivityDTO;

@WebServlet("/admin/customer/detail")
public class AdminCustomerDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("user") : null;
        if (admin == null || (admin.getRole() != UserRole.ADMIN && admin.getRole() != UserRole.EDITOR)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);


            UserDAO userDAO = new UserDAO();
            UserAddressDAO addressDAO = new UserAddressDAO();
            OrderDAO orderDAO = new OrderDAO();
            ReviewDAO reviewDAO = new ReviewDAO();
            BlogCommentDAO blogCommentDAO = new BlogCommentDAO();


            User customer = userDAO.getUserDetailById(userId);
            if (customer == null) {
                response.sendError(404, "Khách hàng không tồn tại");
                return;
            }

            List<UserAddress> addresses = addressDAO.getListAddress(userId);
            List<Order> orders = orderDAO.getOrdersByUserId(userId);
            List<ProductReview> reviews = reviewDAO.getReviewsByUserId(userId);
            List<BlogComment> comments = blogCommentDAO.getByUserId(userId);

            List<UserActivityDTO> activities = new ArrayList<>();
            DecimalFormat df = new DecimalFormat("#,###");

            if (orders != null) {
                for (Order o : orders) {
                    String desc = "Đơn hàng #" + o.getOrderNumber() + " - " + df.format(o.getTotalAmount()) + "đ";
                    activities.add(new UserActivityDTO(
                            "fa-shopping-cart",
                            "Đã đặt đơn hàng mới",
                            desc,
                            o.getCreatedAt().toLocalDateTime()
                    ));
                }
            }

            if (reviews != null) {
                for (ProductReview r : reviews) {
                    String desc = r.getProductName() + " - " + r.getRating() + " sao";
                    activities.add(new UserActivityDTO(
                            "fa-star",
                            "Đã đánh giá sản phẩm",
                            desc,
                            r.getCreatedAt()
                    ));
                }
            }


            if (comments != null) {
                for (BlogComment c : comments) {
                    String shortContent = c.getCommentText();
                    if (shortContent.length() > 50) shortContent = shortContent.substring(0, 47) + "...";

                    String desc = "Bài viết: " + c.getPostTitle() + " - \"" + shortContent + "\"";

                    activities.add(new UserActivityDTO(
                            "fa-comment-alt",
                            "Đã bình luận bài viết",
                            desc,
                            c.getCreatedAt()
                    ));
                }
            }

            Collections.sort(activities);

            if (activities.size() > 10) {
                activities = activities.subList(0, 10);
            }


            double totalSpent = 0;
            int completedOrders = 0;
            if (orders != null) {
                for (Order o : orders) {
                    if (o.getStatus().name().equalsIgnoreCase("COMPLETED")) {
                        totalSpent += o.getTotalAmount();
                        completedOrders++;
                    }
                }
            }

            double avgOrderValue = (completedOrders > 0) ? (totalSpent / completedOrders) : 0;

            long monthsActive = 0;
            if (customer.getCreatedAt() != null) {
                monthsActive = ChronoUnit.MONTHS.between(customer.getCreatedAt(), LocalDateTime.now());
                if (monthsActive == 0) monthsActive = 1;
            }

            double purchaseFrequency = (double) (orders != null ? orders.size() : 0) / monthsActive;

            double totalStars = 0;
            if (reviews != null && !reviews.isEmpty()) {
                for (ProductReview r : reviews) {
                    totalStars += r.getRating();
                }
            }
            double avgRating = (reviews != null && !reviews.isEmpty())
                    ? (totalStars / reviews.size())
                    : 0;

            int reviewCount = (reviews != null) ? reviews.size() : 0;
            int commentCount = (comments != null) ? comments.size() : 0;

            VipVoucherDAO vipVoucherDAO = new VipVoucherDAO();

            if (Boolean.TRUE.equals(customer.getIsVip())) {
                request.setAttribute("voucherList", vipVoucherDAO.getAllVouchers());
                request.setAttribute("customerVouchers", vipVoucherDAO.getAssignedVouchersByUser(userId));
            }
            request.setAttribute("customer", customer);
            request.setAttribute("addresses", addresses);
            request.setAttribute("orders", orders);
            request.setAttribute("reviews", reviews);
            request.setAttribute("activities", activities);

            request.setAttribute("totalOrders", (orders != null) ? orders.size() : 0);
            request.setAttribute("totalSpent", totalSpent);
            request.setAttribute("avgOrderValue", avgOrderValue);

            request.setAttribute("monthsActive", monthsActive);
            request.setAttribute("purchaseFrequency", purchaseFrequency);
            request.setAttribute("reviewCount", reviewCount);
            request.setAttribute("commentCount", commentCount);
            request.setAttribute("avgRating", avgRating);

            request.getRequestDispatcher("/admin/admin-customer-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String customerIdStr = request.getParameter("customerId");

        if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }

        int customerId = Integer.parseInt(customerIdStr);

        try {
            VipVoucherDAO vipVoucherDAO = new VipVoucherDAO();

            if ("assignVoucher".equals(action)) {
                String voucherIdStr = request.getParameter("voucherId");
                if (voucherIdStr != null && !voucherIdStr.trim().isEmpty()) {
                    int voucherId = Integer.parseInt(voucherIdStr);

                    if (!vipVoucherDAO.hasVoucherAssigned(customerId, voucherId)) {
                        vipVoucherDAO.addVoucherToUser(customerId, voucherId);
                    }
                }
            } else if ("removeVoucher".equals(action)) {
                String voucherIdStr = request.getParameter("voucherId");
                if (voucherIdStr != null && !voucherIdStr.trim().isEmpty()) {
                    int voucherId = Integer.parseInt(voucherIdStr);
                    vipVoucherDAO.removeVoucherFromUser(customerId, voucherId);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin/customer/detail?id=" + customerId);
    }
}
