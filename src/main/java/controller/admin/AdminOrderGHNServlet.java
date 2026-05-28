package controller.admin;

import dao.DAOFactory;
import dao.GHNShippingDAO;
import dao.OrderDAO;
import dao.UserAddressDAO;
import model.order.Order;
import model.user.User;
import model.user.UserAddress;
import service.SystemLogService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "AdminOrderGHNServlet", urlPatterns = {"/admin/order/ghn-create"})
public class AdminOrderGHNServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private UserAddressDAO addressDAO;
    private GHNShippingDAO ghnDAO;
    private SystemLogService logService;

    @Override
    public void init() throws ServletException {
        orderDAO   = DAOFactory.getInstance().getOrderDAO();
        addressDAO = DAOFactory.getInstance().getUserAddressDAO();
        ghnDAO     = new GHNShippingDAO();
        logService = new SystemLogService();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        User admin = (User) request.getSession().getAttribute("user");

        String orderIdStr      = request.getParameter("orderId");
        String districtIdStr   = request.getParameter("toDistrictId");
        String wardCode        = request.getParameter("toWardCode");

        if (orderIdStr == null || orderIdStr.isEmpty()) {
            sendError(response, "Thiếu tham số orderId");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            sendError(response, "orderId không hợp lệ");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            sendError(response, "Không tìm thấy đơn hàng #" + orderId);
            return;
        }

        if (order.getStatus() == null || !order.getStatus().name().equals("PENDING")) {
            sendError(response, "Chỉ có thể tạo vận đơn GHN cho đơn ở trạng thái Chờ xử lý");
            return;
        }

        UserAddress address = null;
        if (order.getShippingAddressId() != null && order.getShippingAddressId() > 0) {
            address = addressDAO.getAddressById(order.getShippingAddressId());
        }
        if (address == null) {
            sendError(response, "Không tìm thấy địa chỉ giao hàng của đơn hàng này");
            return;
        }

        int toDistrictId = 0;
        String toWardCode = "";
        try {
            if (districtIdStr != null && !districtIdStr.isEmpty()) {
                toDistrictId = Integer.parseInt(districtIdStr.trim());
            }
            if (wardCode != null) {
                toWardCode = wardCode.trim();
            }
        } catch (NumberFormatException ignored) {}

        if (toDistrictId == 0 || toWardCode.isEmpty()) {
            sendError(response, "Vui lòng nhập mã Quận/Huyện và Phường/Xã theo GHN để tạo vận đơn");
            return;
        }

        GHNShippingDAO.GHNCreateOrderResult result = ghnDAO.createGHNOrder(order, address, toDistrictId, toWardCode);

        if (result == null || result.orderCode == null || result.orderCode.isEmpty()) {
            sendError(response, "Tạo vận đơn GHN thất bại. Kiểm tra lại cấu hình GHN token/shopId và thông tin địa chỉ.");
            return;
        }

        boolean updated = orderDAO.updateGHNShippingInfo(orderId, result.orderCode);
        if (!updated) {
            sendError(response, "Tạo vận đơn GHN thành công nhưng không thể cập nhật CSDL. Mã vận đơn: " + result.orderCode);
            return;
        }

        if (admin != null) {
            logService.log(admin.getId(), "Tạo vận đơn GHN #" + result.orderCode + " cho đơn hàng", "Order", orderId);
        }
        String json = String.format(
            "{\"success\":true,\"orderCode\":\"%s\",\"expectedDelivery\":\"%s\",\"totalFee\":%d," +
            "\"message\":\"Tạo vận đơn GHN thành công!\",\"trackingUrl\":\"https://donhang.ghn.vn/?order_code=%s\"}",
            result.orderCode, result.expectedDeliveryTime, result.totalFee, result.orderCode
        );
        response.getWriter().write(json);
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write("{\"success\":false,\"message\":\"" + message.replace("\"", "'") + "\"}");
    }
}
