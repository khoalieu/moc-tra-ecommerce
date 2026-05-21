package controller.shipper;

import dao.DAOFactory;
import dao.OrderDAO;
import model.order.Order;
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

    @Override
    public void init() throws ServletException {
        orderDAO = DAOFactory.getInstance().getOrderDAO();
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
                boolean success = false;
                if ("shipping".equals(statusParam)) {
                    String shippingProvider = request.getParameter("shippingProvider");
                    String trackingCode = request.getParameter("trackingCode");
                    if (shippingProvider == null || shippingProvider.trim().isEmpty() ||
                            trackingCode == null || trackingCode.trim().isEmpty()) {

                        request.getSession().setAttribute("msg", "Lỗi: Bắt buộc chọn ĐVVC và nhập mã vận đơn khi chuyển sang Đang giao hàng!");
                        response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
                        return;
                    }
                    success = orderDAO.updateShippingInfo(orderId, "shipping", shippingProvider, trackingCode);
                    if (success) {
                        request.getSession().setAttribute("msg", "Đã bàn giao đơn #" + orderId + " cho " + shippingProvider + " - Mã VĐ: " + trackingCode);
                    }

                }
                else if ("completed".equals(statusParam)) {
                    success = orderDAO.shipperCompleteOrder(orderId, shipper.getId());
                    if (success) {
                        request.getSession().setAttribute("msg", "Tuyệt vời! Đã xác nhận giao thành công đơn #" + orderId);
                    }
                }
                else if ("delivery_failed".equals(statusParam)) {
                    String cancelReason = request.getParameter("cancelReason");
                    if ("other".equals(cancelReason)) {
                        cancelReason = request.getParameter("otherReason");
                    }
                    success = orderDAO.shipperFailOrder(orderId, shipper.getId(), cancelReason);
                    if (success) {
                        request.getSession().setAttribute("msg", "Đã báo cáo giao thất bại đơn #" + orderId + " và hoàn lại tồn kho.");
                    }
                }
                if (!success) {
                    request.getSession().setAttribute("msg", "Lỗi thao tác: Đơn hàng không tồn tại, sai trạng thái hoặc bạn không có quyền truy cập!");
                }

            } catch (NumberFormatException e) {
                request.getSession().setAttribute("msg", "Lỗi dữ liệu: Mã đơn hàng không hợp lệ.");
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