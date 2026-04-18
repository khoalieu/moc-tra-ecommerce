package controller.admin;

import dao.DAOFactory;
import dao.UserDAO;
import model.user.CustomerDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminCustomerServlet", urlPatterns = "/admin/customers")
public class AdminCustomerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        String spending = request.getParameter("spending");
        String orders = request.getParameter("orders");
        String sort = request.getParameter("sort");

        int page = 1;
        int pageSize = 10;
        try {
            if (request.getParameter("page") != null) {
                page = Integer.parseInt(request.getParameter("page"));
            }
        } catch (NumberFormatException e) {
            page = 1;
        }
        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();

        List<CustomerDTO> customers = userDAO.getCustomers(search, status, spending, orders, sort, page, pageSize);
        int totalCustomers = 0;
        List<Integer> allIds = userDAO.getAllCustomerIds(search, status, spending, orders);
        totalCustomers = allIds.size();

        int totalPages = (int) Math.ceil((double) totalCustomers / pageSize);
        request.setAttribute("customers", customers);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("paramSearch", search);
        request.setAttribute("paramStatus", status);
        request.setAttribute("paramSpending", spending);
        request.setAttribute("paramOrders", orders);
        request.setAttribute("paramSort", sort);
        request.getRequestDispatcher("/admin/admin-customers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String idsParam = request.getParameter("ids");
        String isSelectAll = request.getParameter("selectAll");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
        List<Integer> idsToUpdate = new ArrayList<>();
        boolean success = false;
        String message = "";

        try {
            if ("true".equals(isSelectAll)) {
                String search = request.getParameter("search");
                String status = request.getParameter("status");
                String spending = request.getParameter("spending");
                String orders = request.getParameter("orders");
                idsToUpdate = userDAO.getAllCustomerIds(search, status, spending, orders);
            }
            else if (idsParam != null && !idsParam.isEmpty()) {
                String[] idArray = idsParam.split(",");
                for (String idStr : idArray) {
                    try {
                        idsToUpdate.add(Integer.parseInt(idStr.trim()));
                    } catch (NumberFormatException e) {
                    }
                }
            }
            if (!idsToUpdate.isEmpty()) {
                if ("activate".equals(action)) {
                    success = userDAO.updateStatusBulk(idsToUpdate, true);
                    message = "Kích hoạt thành công " + idsToUpdate.size() + " khách hàng.";
                } else if ("deactivate".equals(action)) {
                    success = userDAO.updateStatusBulk(idsToUpdate, false);
                    message = "Vô hiệu hóa thành công " + idsToUpdate.size() + " khách hàng.";
                } else {
                    message = "Hành động không hợp lệ.";
                }
            } else {
                message = "Không tìm thấy khách hàng nào để thực hiện.";
            }
            response.getWriter().write("{" +
                    "\"success\": " + success + "," +
                    "\"count\": " + idsToUpdate.size() + "," +
                    "\"message\": \"" + message + "\"" +
                    "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"Lỗi Server: " + e.getMessage() + "\"}");
        }
    }
}