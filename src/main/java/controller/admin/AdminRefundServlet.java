package controller.admin;

import dao.DAOFactory;
import dao.OrderDAO;
import dao.RefundDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.enums.PaymentStatus;
import model.refund.RefundRequest;
import model.user.User;
import service.EcommerceEmailService;
import service.NotificationService;
import service.SystemLogService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/refunds")
public class AdminRefundServlet extends HttpServlet {
    private final RefundDAO refundDAO = DAOFactory.getInstance().getRefundDAO();
    private final OrderDAO orderDAO = DAOFactory.getInstance().getOrderDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String status = normalizeStatus(request.getParameter("status"));
        int page = parsePage(request.getParameter("page"));
        int pageSize = 10;

        List<RefundRequest> refunds = refundDAO.getRefundRequests(status, page, pageSize);
        int totalRefunds = refundDAO.countRefundRequests(status);
        int totalPages = (int) Math.ceil((double) totalRefunds / pageSize);

        request.setAttribute("refunds", refunds);
        request.setAttribute("status", status);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRefunds", totalRefunds);
        request.getRequestDispatcher("/admin/admin-refunds.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User admin = (User) session.getAttribute("user");

        try {
            int refundId = Integer.parseInt(request.getParameter("refundId"));
            String action = request.getParameter("action");
            String adminNote = trimOrNull(request.getParameter("adminNote"));

            RefundRequest refund = refundDAO.getRefundById(refundId);
            if (refund == null || !"pending".equals(refund.getStatus())) {
                setMessage(session, "Yêu cầu hoàn tiền không hợp lệ hoặc đã được xử lý.", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/refunds");
                return;
            }

            String newStatus;
            if ("mark_refunded".equals(action)) {
                newStatus = "refunded";
            } else if ("reject".equals(action)) {
                newStatus = "rejected";
            } else {
                setMessage(session, "Thao tác xử lý hoàn tiền không hợp lệ.", "danger");
                response.sendRedirect(request.getContextPath() + "/admin/refunds");
                return;
            }

            Integer adminId = admin != null ? admin.getId() : null;
            boolean success = refundDAO.updateRefundStatus(refundId, newStatus, adminNote, adminId);
            if (success && "refunded".equals(newStatus)) {
                orderDAO.updatePaymentStatus(refund.getOrderId(), PaymentStatus.REFUNDED);
            }
            if (success) {
                new NotificationService().notifyRefundStatusChanged(refund, newStatus);
                new EcommerceEmailService().sendRefundResolvedToUser(refund, newStatus);
            }

            if (success) {
                if (adminId != null) {
                    new SystemLogService().log(adminId, "Cập nhật hoàn tiền thành " + newStatus, "Refund", refundId);
                }
                setMessage(session, "Đã cập nhật yêu cầu hoàn tiền.", "success");
            } else {
                setMessage(session, "Không thể cập nhật yêu cầu hoàn tiền.", "danger");
            }
        } catch (Exception e) {
            e.printStackTrace();
            setMessage(session, "Đã có lỗi xảy ra khi xử lý hoàn tiền.", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/admin/refunds");
    }

    private int parsePage(String pageParam) {
        try {
            return Math.max(1, Integer.parseInt(pageParam));
        } catch (Exception e) {
            return 1;
        }
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }

        String normalized = status.trim().toLowerCase();
        return ("pending_info".equals(normalized) || "pending".equals(normalized)
                || "refunded".equals(normalized) || "rejected".equals(normalized))
                ? normalized
                : null;
    }

    private String trimOrNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void setMessage(HttpSession session, String message, String type) {
        session.setAttribute("msg", message);
        session.setAttribute("msgType", type);
    }
}
