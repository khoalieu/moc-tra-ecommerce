package controller.admin;

import dao.DAOFactory;
import dao.DashboardDAO;
import dao.OrderDAO;
import model.RevenueDTO;
import model.order.Order;
import model.product.TopProductDTO;
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
        DashboardDAO dashboardDAO = DAOFactory.getInstance().getDashboardDAO();
        int topLimit = parseTopLimit(request.getParameter("topLimit"));
        String topMode = normalizeTopMode(request.getParameter("topMode"));
        String topPeriod = normalizeTopPeriod(request.getParameter("topPeriod"));
        String revenuePeriod = normalizeRevenuePeriod(request.getParameter("revenuePeriod"));

        String ajax = request.getParameter("ajax");
        if ("topProducts".equals(ajax)) {
            writeTopProductsJson(response, dashboardDAO.getTopProducts(topLimit, topMode, topPeriod));
            return;
        }
        if ("revenue".equals(ajax)) {
            writeRevenueJson(response, dashboardDAO.getRevenueByPeriod(revenuePeriod));
            return;
        }

        List<Order> recentOrders = orderDAO.getRecentOrders(5);
        request.setAttribute("recentOrders", recentOrders);
        request.setAttribute("topProducts", dashboardDAO.getTopProducts(topLimit, topMode, topPeriod));
        request.setAttribute("newUsersByMonth", dashboardDAO.getNewUsersByMonth());
        request.setAttribute("revenueByMonth", dashboardDAO.getRevenueByPeriod(revenuePeriod));
        request.setAttribute("currentTopLimit", topLimit);
        request.setAttribute("currentTopMode", topMode);
        request.setAttribute("currentTopPeriod", topPeriod);
        request.setAttribute("currentRevenuePeriod", revenuePeriod);

        request.getRequestDispatcher("/admin/admin-dashboard.jsp").forward(request, response);
    }

    private int parseTopLimit(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 5;
        }
        try {
            int parsed = Integer.parseInt(value.trim());
            return Math.max(1, Math.min(parsed, 50));
        } catch (Exception e) {
            return 5;
        }
    }

    private String normalizeTopMode(String value) {
        return "least".equals(value) ? "least" : "best";
    }

    private String normalizeTopPeriod(String value) {
        if ("day".equals(value) || "week".equals(value) || "month".equals(value)
                || "six-months".equals(value) || "year".equals(value)) {
            return value;
        }
        return "all";
    }

    private String normalizeRevenuePeriod(String value) {
        if ("day".equals(value) || "week".equals(value) || "six-months".equals(value) || "year".equals(value)) {
            return value;
        }
        return "month";
    }

    private void writeTopProductsJson(HttpServletResponse response, List<TopProductDTO> products) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < products.size(); i++) {
            TopProductDTO p = products.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"productId\":").append(p.getProductId()).append(",")
                    .append("\"productName\":\"").append(escapeJson(p.getProductName())).append("\",")
                    .append("\"totalSold\":").append(p.getTotalSold())
                    .append("}");
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private void writeRevenueJson(HttpServletResponse response, List<RevenueDTO> revenues) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < revenues.size(); i++) {
            RevenueDTO r = revenues.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"label\":\"").append(escapeJson(r.getLabel())).append("\",")
                    .append("\"revenue\":").append(r.getRevenue())
                    .append("}");
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
