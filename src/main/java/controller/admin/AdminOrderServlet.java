package controller.admin;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.RefundDAO;
import model.order.Order;
import model.enums.OrderStatus;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.SystemLogService;
import model.user.User;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders", "/admin/order/detail", "/admin/order/update"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
    private final RefundDAO refundDAO = DAOFactory.getInstance().getRefundDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        if (path.contains("/detail")) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Order order = orderDAO.getOrderById(Integer.parseInt(idStr));
                if (order == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/orders");
                    return;
                }
                request.setAttribute("order", order);
                request.setAttribute("refund", refundDAO.getLatestRefundByOrderId(order.getId()));
                request.getRequestDispatcher("/admin/admin-order-detail.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/orders");
            }
        } else {
            int page = 1;
            try { page = Integer.parseInt(request.getParameter("page")); } catch (Exception e) {}

            String search = request.getParameter("search");
            if (search != null) {
                search = search.trim();
                if (search.isEmpty()) {
                    search = null;
                }
            }

            String status = normalizeOrderStatus(request.getParameter("status"));
            String paymentStatus = normalizePaymentStatus(request.getParameter("paymentStatus"));
            String paymentMethod = normalizePaymentMethod(request.getParameter("paymentMethod"));
            String timeFilter = normalizeTimeFilter(request.getParameter("time"));
            String dateFrom = normalizeDate(request.getParameter("dateFrom"));
            String dateTo = normalizeDate(request.getParameter("dateTo"));
            String sort = normalizeSort(request.getParameter("sort"));

            List<Order> list = orderDAO.getAllOrders(page, 10, search, status, paymentStatus, paymentMethod,
                    timeFilter, dateFrom, dateTo, sort);
            int totalOrders = orderDAO.countAllOrders(search, status, paymentStatus, paymentMethod,
                    timeFilter, dateFrom, dateTo);
            int totalPages = (int) Math.ceil((double) totalOrders / 10);
            String filterQuery = buildFilterQuery(search, status, paymentStatus, paymentMethod, timeFilter,
                    dateFrom, dateTo, sort);

            request.setAttribute("orders", list);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("paymentStatus", paymentStatus);
            request.setAttribute("paymentMethod", paymentMethod);
            request.setAttribute("time", timeFilter);
            request.setAttribute("dateFrom", dateFrom);
            request.setAttribute("dateTo", dateTo);
            request.setAttribute("sort", sort);
            request.setAttribute("filterQuery", filterQuery);

            request.getRequestDispatcher("/admin/admin-orders.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String statusStr = request.getParameter("status");
        SystemLogService log = new SystemLogService();
        User admin = (User) request.getSession().getAttribute("user");
        try {
            if ("cancel_with_reason".equals(action)) {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String cancelReason = request.getParameter("cancelReason");
                boolean success = orderDAO.cancelOrder(orderId, cancelReason);
                if (success) {
                    log.log(admin.getId(), "Hủy đơn hàng - Lý do: " + cancelReason, "Order", orderId);
                }
                response.setStatus(success ? 200 : 400);
                return;
            }
            OrderStatus newStatus = OrderStatus.valueOf(statusStr.toUpperCase());
            if ("bulk".equals(action)) {
                String idsParam = request.getParameter("orderIds");
                if (idsParam != null && !idsParam.isEmpty()) {
                    String[] ids = idsParam.split(",");
                    for (String idStr : ids) {
                        int orderID = Integer.parseInt(idStr);
                        orderDAO.updateOrderStatus(orderID, newStatus);
                        log.log(admin.getId(), "Cập nhật trạng thái đơn hàng thành "+newStatus, "Order", orderID);
                    }
                }
            } else {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                orderDAO.updateOrderStatus(orderId, newStatus);
                log.log(admin.getId(), "Cập nhật trạng thái đơn hàng thành "+newStatus, "Order", orderId);
            }
            response.setStatus(200);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }

    private String normalizeOrderStatus(String status) {
        if (status == null || status.isBlank()) {return null;}

        String normalized = status.trim().toUpperCase();
        return ("PENDING".equals(normalized) || "SHIPPING".equals(normalized) || "COMPLETED".equals(normalized)
                || "CANCELLED".equals(normalized) || "DELIVERY_FAILED".equals(normalized))
                ? normalized : null;
    }

    private String normalizePaymentStatus(String paymentStatus) {
        if (paymentStatus == null || paymentStatus.isBlank()) {return null;}

        String normalized = paymentStatus.trim().toUpperCase();
        return ("PENDING".equals(normalized) || "PAID".equals(normalized) || "FAILED".equals(normalized)
                || "EXPIRED".equals(normalized) || "REFUNDED".equals(normalized))
                ? normalized : null;
    }
    private String normalizePaymentMethod(String paymentMethod) {
        if (paymentMethod == null || paymentMethod.isBlank()) {return null;}

        String normalized = paymentMethod.trim().toLowerCase();
        return ("cod".equals(normalized) || "bank".equals(normalized) || "momo".equals(normalized))
                ? normalized : null;
    }

    private String normalizeTimeFilter(String timeFilter) {
        if (timeFilter == null || timeFilter.isBlank()) {
            return null;
        }

        String normalized = timeFilter.trim().toLowerCase();
        return ("today".equals(normalized) || "last_7_days".equals(normalized)
                || "last_30_days".equals(normalized) || "custom".equals(normalized))
                ? normalized : null;
    }
    private String normalizeSort(String sort) {
        if (sort == null || sort.isBlank()) {return "newest";}

        String normalized = sort.trim().toLowerCase();
        return ("newest".equals(normalized) || "oldest".equals(normalized)
                || "price_desc".equals(normalized) || "price_asc".equals(normalized))
                ? normalized
                : "newest";
    }
    private String normalizeDate(String date) {
        if (date == null || date.isBlank()) {return null;}

        String normalized = date.trim();
        return normalized.matches("\\d{4}-\\d{2}-\\d{2}") ? normalized : null;
    }

    private String buildFilterQuery(String search, String status, String paymentStatus, String paymentMethod,
                                    String timeFilter, String dateFrom, String dateTo, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "search", search);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "paymentStatus", paymentStatus);
        appendQueryParam(query, "paymentMethod", paymentMethod);
        appendQueryParam(query, "time", timeFilter);
        appendQueryParam(query, "dateFrom", dateFrom);
        appendQueryParam(query, "dateTo", dateTo);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String name, String value) {
        if (value == null || value.isBlank()) {return;}
        query.append('&')
                .append(URLEncoder.encode(name, StandardCharsets.UTF_8))
                .append('=')
                .append(URLEncoder.encode(value, StandardCharsets.UTF_8));
    }
}
