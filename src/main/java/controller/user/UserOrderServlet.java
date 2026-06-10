package controller.user;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.RefundDAO;
import controller.utils.RedirectUtils;
import model.order.Order;
import model.refund.RefundRequest;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@WebServlet(name = "UserOrderServlet", value = "/don-hang")
public class UserOrderServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(RedirectUtils.toLoginWithRedirect(request, "/don-hang"));
            return;
        }
        OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
        List<Order> orders = orderDAO.getOrdersByUserId(user.getId());
        List<Integer> orderIds = new ArrayList<>();
        for (Order order : orders) {
            orderIds.add(order.getId());
        }

        RefundDAO refundDAO = DAOFactory.getInstance().getRefundDAO();
        Map<Integer, RefundRequest> refundByOrderId = refundDAO.getLatestRefundsByUserOrders(user.getId(), orderIds);

        request.setAttribute("orders", orders);
        request.setAttribute("refundByOrderId", refundByOrderId);
        request.getRequestDispatcher("/user/don-hang-nguoi-dung.jsp").forward(request, response);
    }
}
