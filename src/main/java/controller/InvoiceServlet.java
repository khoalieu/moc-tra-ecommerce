package controller;

import dao.DAOFactory;
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

@WebServlet(name = "InvoiceServlet", value = "/hoa-don")
public class InvoiceServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/don-hang");
            return;
        }

        try {
            int orderId = Integer.parseInt(idStr);
            OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();
            Order order = orderDAO.getOrderById(orderId);
            if (order != null && order.getUserId() == user.getId()) {
                request.setAttribute("order", order);
                request.getRequestDispatcher("/cart/hoa-don.jsp").forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/don-hang");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/don-hang");
        }
    }
}
