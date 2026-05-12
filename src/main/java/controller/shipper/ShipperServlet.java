package controller.shipper;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.ProductVariantDAO;
import model.order.Order;
import model.order.OrderItem;
import model.user.User;
import model.enums.OrderStatus;
import model.enums.UserRole;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ShipperServlet", urlPatterns = {"/shipper/dashboard", "/shipper/update-status"})
public class ShipperServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ProductVariantDAO variantDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = DAOFactory.getInstance().getOrderDAO();
        variantDAO = DAOFactory.getInstance().getProductVariantDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User shipper = checkAuthorization(request, response);
        if (shipper == null) return;

        String path = request.getServletPath();

        if ("/shipper/dashboard".equals(path)) {
            List<Order> assignedOrders = orderDAO.getOrdersForShipper(shipper.getId());

            request.setAttribute("orders", assignedOrders);
            request.getRequestDispatcher("/shipper/shipper-dashboard.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User shipper = checkAuthorization(request, response);
        if (shipper == null) return;

        String path = request.getServletPath();

        if ("/shipper/update-status".equals(path)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String statusParam = request.getParameter("status");
                Order order = orderDAO.getOrderById(orderId);
                if (order == null || order.getShipperId() != shipper.getId()) {
                    request.getSession().setAttribute("msg", "Lỗi: Không tìm thấy đơn hàng hoặc bạn không có quyền!");
                    response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
                    return;
                }

                if ("completed".equals(statusParam)) {
                    orderDAO.updateOrderStatus(orderId, OrderStatus.COMPLETED);
                    request.getSession().setAttribute("msg", "Tuyệt vời! Đã cập nhật giao thành công đơn #" + order.getOrderNumber());

                } else if ("delivery_failed".equals(statusParam)) {
                    String cancelReason = request.getParameter("cancelReason");
                    if ("other".equals(cancelReason)) {
                        cancelReason = request.getParameter("otherReason");
                    }
                    orderDAO.updateOrderCancelReason(orderId, OrderStatus.CANCELLED, cancelReason);

                    List<OrderItem> items = order.getItems();
                    if (items != null) {
                        for (OrderItem item : items) {
                            variantDAO.increaseStock(item.getVariantId(), item.getQuantity());
                        }
                    }

                    request.getSession().setAttribute("msg", "Đã ghi nhận giao thất bại đơn #" + order.getOrderNumber());
                }

            } catch (Exception e) {
                e.printStackTrace();
                request.getSession().setAttribute("msg", "Lỗi hệ thống: Không thể cập nhật đơn hàng.");
            }
            response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
        }
    }

    private User checkAuthorization(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        User user = (User) session.getAttribute("user");
        if (user.getRole() == null || !user.getRole().name().equalsIgnoreCase("SHIPPER")) {
            response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
            return null;
        }
        return user;
    }
}