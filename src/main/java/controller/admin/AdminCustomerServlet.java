package controller.admin;

import dao.DAOFactory;
import dao.UserDAO;
import model.user.CustomerDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.user.VipUpdateResult;

import java.sql.Timestamp;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.TemporalAdjusters;

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
        if ("autoUpdateVip".equals(action)) {
            try {
                String thresholdStr = request.getParameter("threshold");
                String periodType = request.getParameter("periodType");

                if (thresholdStr == null || thresholdStr.trim().isEmpty()) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Vui lòng nhập ngưỡng chi tiêu VIP.\"}");
                    return;
                }
                double threshold = Double.parseDouble(thresholdStr);

                if (threshold <= 0) {
                    response.getWriter().write("{\"success\": false, \"message\": \"Ngưỡng chi tiêu phải lớn hơn 0.\"}");
                    return;
                }
                LocalDateTime startDateTime;
                LocalDateTime endDateTime;

                LocalDate today = LocalDate.now();

                if ("week".equals(periodType)) {
                    LocalDate startOfThisWeek = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
                    LocalDate startOfLastWeek = startOfThisWeek.minusWeeks(1);

                    startDateTime = startOfLastWeek.atStartOfDay();
                    endDateTime = startOfThisWeek.atStartOfDay();

                } else if ("month".equals(periodType)) {
                    LocalDate firstDayOfThisMonth = today.withDayOfMonth(1);
                    LocalDate firstDayOfLastMonth = firstDayOfThisMonth.minusMonths(1);

                    startDateTime = firstDayOfLastMonth.atStartOfDay();
                    endDateTime = firstDayOfThisMonth.atStartOfDay();

                } else if ("custom".equals(periodType)) {
                    String startDateStr = request.getParameter("startDate");
                    String endDateStr = request.getParameter("endDate");

                    if (startDateStr == null || startDateStr.trim().isEmpty()
                            || endDateStr == null || endDateStr.trim().isEmpty()) {
                        response.getWriter().write("{\"success\": false, \"message\": \"Vui lòng chọn đầy đủ ngày bắt đầu và ngày kết thúc.\"}");
                        return;
                    }

                    LocalDate startDate = LocalDate.parse(startDateStr);
                    LocalDate endDate = LocalDate.parse(endDateStr);

                    if (endDate.isBefore(startDate)) {
                        response.getWriter().write("{\"success\": false, \"message\": \"Ngày kết thúc không được nhỏ hơn ngày bắt đầu.\"}");
                        return;
                    }

                    startDateTime = startDate.atStartOfDay();
                    endDateTime = endDate.plusDays(1).atStartOfDay();

                } else {
                    response.getWriter().write("{\"success\": false, \"message\": \"Chu kỳ xét VIP không hợp lệ.\"}");
                    return;
                }

                VipUpdateResult result = userDAO.autoUpdateVipBySpending(
                        threshold,
                        Timestamp.valueOf(startDateTime),
                        Timestamp.valueOf(endDateTime)
                );

                message = "Cập nhật VIP tự động thành công. "
                        + "Nâng VIP: " + result.getUpgradedCount()
                        + " khách hàng, hạ thường: " + result.getDowngradedCount()
                        + " khách hàng.";

                response.getWriter().write("{" +
                        "\"success\": true," +
                        "\"upgradedCount\": " + result.getUpgradedCount() + "," +
                        "\"downgradedCount\": " + result.getDowngradedCount() + "," +
                        "\"message\": \"" + message + "\"" +
                        "}");
                return;

            } catch (NumberFormatException e) {
                response.getWriter().write("{\"success\": false, \"message\": \"Ngưỡng chi tiêu không hợp lệ.\"}");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\": false, \"message\": \"Có lỗi xảy ra khi cập nhật VIP tự động.\"}");
                return;
            }
        }

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

                } else if ("upgradeVip".equals(action)) {
                    success = userDAO.updateVipStatusBulk(idsToUpdate, true);
                    message = "Nâng cấp VIP thành công " + idsToUpdate.size() + " khách hàng.";

                } else if ("downgradeVip".equals(action)) {
                    success = userDAO.updateVipStatusBulk(idsToUpdate, false);
                    message = "Hạ xuống khách thường thành công " + idsToUpdate.size() + " khách hàng.";

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