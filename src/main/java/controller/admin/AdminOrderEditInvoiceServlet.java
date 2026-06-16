package controller.admin;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.order.Order;
import model.order.OrderItem;
import model.product.Product;
import model.user.User;
import service.SystemLogService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminOrderEditInvoiceServlet", value = "/admin/order-edit-invoice")
public class AdminOrderEditInvoiceServlet extends HttpServlet {

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

        User admin = (User) request.getSession().getAttribute("user");
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String idRaw = request.getParameter("id");
        if (idRaw == null || idRaw.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }
        int orderId;
        try {
            orderId = Integer.parseInt(idRaw);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        if (!canAdminEdit(order)) {
            request.getSession().setAttribute("msg", "Đơn hàng này không còn được phép chỉnh sửa.");
            request.getSession().setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/order/detail?id=" + orderId);
            return;
        }

        List<OrderItem> items = orderDAO.getOrderItems(orderId);
        List<Product> products = productDAO.getAllProducts();

        request.setAttribute("order", order);
        request.setAttribute("items", items);
        request.setAttribute("products", products);

        request.getRequestDispatcher("/admin/admin-edit-order.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        User admin = (User) request.getSession().getAttribute("user");

        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        if (orderIdRaw == null || orderIdRaw.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        int orderId = Integer.parseInt(orderIdRaw);
        Order order = orderDAO.getOrderById(orderId);

        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        if (!canAdminEdit(order)) {
            request.getSession().setAttribute("msg", "Đơn hàng này không còn được phép chỉnh sửa.");
            request.getSession().setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/order/detail?id=" + orderId);
            return;
        }

        String action = request.getParameter("action");

        if ("update-all-quantities".equals(action)) {
            String[] itemIds = request.getParameterValues("orderItemIds");
            if (itemIds != null) {
                for (String itemIdStr : itemIds) {
                    int itemId = Integer.parseInt(itemIdStr);
                    String qtyStr = request.getParameter("qty_" + itemId);
                    int newQty = Integer.parseInt(qtyStr);

                    OrderItem item = orderDAO.getOrderItemById(itemId);
                    if (item != null && newQty >= 1 && newQty != item.getQuantity()) {
                        // Tính độ lệch để gọi tăng/giảm (tận dụng DAO có sẵn của bạn)
                        int diff = Math.abs(newQty - item.getQuantity());
                        for (int i = 0; i < diff; i++) {
                            if (newQty > item.getQuantity()) orderDAO.increaseOrderItemQuantity(itemId);
                            else if (newQty < item.getQuantity()) orderDAO.decreaseOrderItemQuantity(itemId);
                        }
                    }
                }
                request.getSession().setAttribute("msg", "Đã cập nhật toàn bộ số lượng sản phẩm.");
                request.getSession().setAttribute("msgType", "success");
            }
        }

        if ("increase".equals(action) || "decrease".equals(action) || "remove".equals(action)) {
            handleItemQuantityAction(request, admin, orderId, action);
        }

        if ("add".equals(action)) {
            handleAddProduct(request, admin, orderId);
        }

        orderDAO.updateOrderTotal(orderId);

        response.sendRedirect(request.getContextPath() + "/admin/order/detail?id=" + orderId);
    }

    private void handleItemQuantityAction(HttpServletRequest request, User admin, int orderId, String action) {
        String orderItemIdRaw = request.getParameter("orderItemId");
        if (orderItemIdRaw == null || orderItemIdRaw.isEmpty()) {
            return;
        }

        int orderItemId = Integer.parseInt(orderItemIdRaw);

        OrderItem item = orderDAO.getOrderItemById(orderItemId);
        if (item == null || item.getProduct() == null) {
            request.getSession().setAttribute("msg", "Không tìm thấy sản phẩm trong đơn hàng.");
            request.getSession().setAttribute("msgType", "danger");
            return;
        }

        List<OrderItem> currentItems = orderDAO.getOrderItems(orderId);

        if ("increase".equals(action)) {
            orderDAO.increaseOrderItemQuantity(orderItemId);
            log.log(admin.getId(), "Admin tăng số lượng sản phẩm " + item.getProduct().getName() + " trong đơn hàng", "Order", orderId);
            request.getSession().setAttribute("msg", "Đã tăng số lượng sản phẩm.");
            request.getSession().setAttribute("msgType", "success");
            return;
        }

        if ("decrease".equals(action)) {
            if (item.getQuantity() <= 1 && currentItems.size() <= 1) {
                request.getSession().setAttribute("msg", "Đơn hàng phải có ít nhất 1 sản phẩm.");
                request.getSession().setAttribute("msgType", "danger");
                return;
            }

            if (item.getQuantity() > 1) {
                orderDAO.decreaseOrderItemQuantity(orderItemId);
                log.log(admin.getId(), "Admin giảm số lượng sản phẩm " + item.getProduct().getName() + " trong đơn hàng", "Order", orderId);
                request.getSession().setAttribute("msg", "Đã giảm số lượng sản phẩm.");
                request.getSession().setAttribute("msgType", "success");
            } else {
                orderDAO.removeOrderItem(orderItemId);
                log.log(admin.getId(), "Admin xóa sản phẩm " + item.getProduct().getName(), "Order", orderId);
                request.getSession().setAttribute("msg", "Đã xóa sản phẩm khỏi đơn hàng.");
                request.getSession().setAttribute("msgType", "success");
            }
            return;
        }

        if ("remove".equals(action)) {
            if (currentItems.size() <= 1) {
                request.getSession().setAttribute("msg", "Đơn hàng phải có ít nhất 1 sản phẩm.");
                request.getSession().setAttribute("msgType", "danger");
                return;
            }

            orderDAO.removeOrderItem(orderItemId);
            log.log(admin.getId(), "Admin xóa sản phẩm " + item.getProduct().getName() + " khỏi đơn hàng", "Order", orderId);
            request.getSession().setAttribute("msg", "Đã xóa sản phẩm khỏi đơn hàng.");
            request.getSession().setAttribute("msgType", "success");
        }
    }

    private void handleAddProduct(HttpServletRequest request, User admin, int orderId) {
        String productIdRaw = request.getParameter("productId");
        String quantityRaw = request.getParameter("quantity");

        if (productIdRaw == null || productIdRaw.isEmpty()) {
            request.getSession().setAttribute("msg", "Vui lòng chọn sản phẩm cần thêm.");
            request.getSession().setAttribute("msgType", "danger");
            return;
        }

        int productId = Integer.parseInt(productIdRaw);
        int quantity = 1;

        if (quantityRaw != null && !quantityRaw.isEmpty()) {
            quantity = Integer.parseInt(quantityRaw);
        }

        if (quantity <= 0) {
            request.getSession().setAttribute("msg", "Số lượng phải lớn hơn 0.");
            request.getSession().setAttribute("msgType", "danger");
            return;
        }

        Product product = productDAO.getProductById(productId);

        if (product == null) {
            request.getSession().setAttribute("msg", "Không tìm thấy sản phẩm.");
            request.getSession().setAttribute("msgType", "danger");
            return;
        }

        orderDAO.addProductToOrder(orderId, productId, quantity);

        log.log(admin.getId(), "Admin thêm sản phẩm " + product.getName() + " vào đơn hàng", "Order", orderId);
        request.getSession().setAttribute("msg", "Đã thêm sản phẩm vào đơn hàng.");
        request.getSession().setAttribute("msgType", "success");
    }
    private boolean canAdminEdit(Order order) {
        return orderDAO.canAdminEditOrder(order.getId());
    }
}