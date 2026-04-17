package controller;

import dao.OrderDAO;
import model.order.Order;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/cancel-order")
public class CancelOrderServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String reason = request.getParameter("cancelReason");
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.getOrderById(orderId);
            if (order != null && order.getUserId() == user.getId()) {
                boolean success = orderDAO.cancelOrder(orderId, reason);
                if (success) {
                    session.setAttribute("msg", "Đơn hàng đã được hủy thành công!");
                    session.setAttribute("msgType", "success");
                } else {
                    session.setAttribute("msg", "Không thể hủy đơn hàng (Đơn hàng có thể đã được xử lý).");
                    session.setAttribute("msgType", "danger");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg", "Đã có lỗi xảy ra khi hủy đơn.");
            session.setAttribute("msgType", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/don-hang");
    }
}
