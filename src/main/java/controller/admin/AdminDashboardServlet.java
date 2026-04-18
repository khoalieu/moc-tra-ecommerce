package controller.admin;

import dao.DAOFactory;
import dao.OrderDAO;
import model.order.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    private final OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Order> recentOrders = orderDAO.getRecentOrders(5);
        request.setAttribute("recentOrders", recentOrders);

        request.getRequestDispatcher("/admin/admin-dashboard.jsp").forward(request, response);
    }
}