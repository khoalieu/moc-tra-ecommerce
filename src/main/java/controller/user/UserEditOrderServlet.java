package controller.user;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.enums.OrderStatus;
import model.order.Order;
import model.order.OrderItem;
import model.user.User;
import service.SystemLogService;

import java.io.IOException;
import java.util.List;

@WebServlet(name="UserEditOrderServlet", value="/edit-user-order")
public class UserEditOrderServlet extends HttpServlet {

    private OrderDAO orderDAO;
    private ProductDAO productDAO;
    private SystemLogService log;

    @Override
    public void init() {
        orderDAO = DAOFactory.getInstance().getOrderDAO();
        productDAO = DAOFactory.getInstance().getProductDAO();
        log = new SystemLogService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(idRaw);
            Order order = orderDAO.getOrderById(orderId);

            if (order == null || order.getUserId() != user.getId() || order.getStatus() != OrderStatus.PENDING) {
                response.sendRedirect(request.getContextPath() + "/user/orders");
                return;
            }

            request.setAttribute("order", order);
            request.setAttribute("items", orderDAO.getOrderItems(orderId));
            request.getRequestDispatcher("/user/edit-user-order.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/user/orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        if (orderIdRaw == null || orderIdRaw.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/user/orders");
            return;
        }

        int orderId = Integer.parseInt(orderIdRaw);

        if (!orderDAO.canCustomerEditOrder(orderId, user.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        String orderItemIdRaw = request.getParameter("orderItemId");

        if (orderItemIdRaw == null || orderItemIdRaw.isEmpty()) {
            orderItemIdRaw = request.getParameter("changedItemId");
        }

        if (orderItemIdRaw != null && !orderItemIdRaw.isEmpty()) {
            int orderItemId = Integer.parseInt(orderItemIdRaw);
            OrderItem item = orderDAO.getOrderItemById(orderItemId);

            if (item != null){
                if ("update-quantity".equals(action)) {
                    String newQuantityRaw = request.getParameter("newQuantity");
                    if (newQuantityRaw != null && !newQuantityRaw.isEmpty()) {
                        int newQty = Integer.parseInt(newQuantityRaw);
                        int oldQty = item.getQuantity();

                        if (newQty >= 1 && newQty != oldQty) {
                            if (newQty > oldQty) {
                                int diff = newQty - oldQty;
                                for (int i = 0; i < diff; i++) {
                                    orderDAO.increaseOrderItemQuantity(orderItemId);
                                }
                                log.log(user.getId(), "Admin/User tăng số lượng sản phẩm " + item.getProduct().getName() + " lên " + newQty, "Order", orderId);
                            } else {
                                int diff = oldQty - newQty;
                                for (int i = 0; i < diff; i++) {
                                    orderDAO.decreaseOrderItemQuantity(orderItemId);
                                }
                                log.log(user.getId(), "Admin/User giảm số lượng sản phẩm " + item.getProduct().getName() + " xuống " + newQty, "Order", orderId);
                            }
                            request.getSession().setAttribute("msg", "Đã cập nhật số lượng sản phẩm.");
                            request.getSession().setAttribute("msgType", "success");
                        }
                    }
                }else if ("decrease".equals(action) || "remove".equals(action)) {
                    List<OrderItem> currentItems = orderDAO.getOrderItems(orderId);

                    if (item.getQuantity() <= 1 && (currentItems == null || currentItems.size() <= 1)) {
                        request.getSession().setAttribute("msg", "Đơn hàng phải có ít nhất 1 sản phẩm!");
                        request.getSession().setAttribute("msgType", "danger");
                        response.sendRedirect(request.getContextPath() + "/edit-user-order?id=" + orderId);
                        return;
                    }

                    if (item.getQuantity() > 1) {
                        orderDAO.decreaseOrderItemQuantity(orderItemId);
                        log.log(user.getId(), "Giảm số lượng sản phẩm " + item.getProduct().getName() + " trong đơn hàng", "Order", orderId);
                        request.getSession().setAttribute("msg", "Đã giảm số lượng sản phẩm!");
                    } else {
                        orderDAO.removeOrderItem(orderItemId);
                        log.log(user.getId(), "Xóa sản phẩm " + item.getProduct().getName() + " khỏi đơn hàng", "Order", orderId);
                        request.getSession().setAttribute("msg", "Đã xóa sản phẩm khỏi đơn hàng!");
                    }

                    request.getSession().setAttribute("msgType", "success");
                }else if ("increase".equals(action)) {
                    orderDAO.increaseOrderItemQuantity(orderItemId);
                    log.log(user.getId(), "Tăng số lượng sản phẩm " + item.getProduct().getName() + " trong đơn hàng", "Order", orderId);
                    request.getSession().setAttribute("msg", "Đã tăng số lượng sản phẩm!");
                    request.getSession().setAttribute("msgType", "success");
                }
            }

            orderDAO.updateOrderTotal(orderId);
        }

        response.sendRedirect(request.getContextPath() + "/edit-user-order?id=" + orderId);
    }
}