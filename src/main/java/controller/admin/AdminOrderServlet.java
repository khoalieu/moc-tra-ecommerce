package controller.admin;

import dao.OrderDAO;
import model.order.Order;
import model.enums.OrderStatus;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderServlet", urlPatterns = {"/admin/orders", "/admin/order/detail", "/admin/order/update"})
public class AdminOrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        if (path.contains("/detail")) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                Order order = orderDAO.getOrderById(Integer.parseInt(idStr));
                request.setAttribute("order", order);
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

            String status = request.getParameter("status");
            String timeFilter = request.getParameter("time");
            String sort = request.getParameter("sort");

            List<Order> list = orderDAO.getAllOrders(page, 10, search, status, timeFilter, sort);
            int totalOrders = orderDAO.countAllOrders(search, status, timeFilter);
            int totalPages = (int) Math.ceil((double) totalOrders / 10);

            request.setAttribute("orders", list);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("totalOrders", totalOrders);
            request.setAttribute("search", search);
            request.setAttribute("status", status);
            request.setAttribute("time", timeFilter);
            request.setAttribute("sort", sort);

            request.getRequestDispatcher("/admin/admin-orders.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String statusStr = request.getParameter("status");

        try {
            OrderStatus newStatus = OrderStatus.valueOf(statusStr.toUpperCase());

            if ("bulk".equals(action)) {
                String idsParam = request.getParameter("orderIds");
                if (idsParam != null && !idsParam.isEmpty()) {
                    String[] ids = idsParam.split(",");
                    for (String idStr : ids) {
                        orderDAO.updateOrderStatus(Integer.parseInt(idStr), newStatus);
                    }
                }
            } else {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                orderDAO.updateOrderStatus(orderId, newStatus);
            }

            response.setStatus(200);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }
}