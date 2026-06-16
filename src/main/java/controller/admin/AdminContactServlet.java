package controller.admin;

import controller.utils.EmailService;
import dao.ContactDAO;
import dao.DAOFactory;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.contact.Contact;
import model.user.User;
import service.SystemLogService;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {
        "/admin/contacts",
        "/admin/contacts/view",
        "/admin/contacts/reply",
        "/admin/contacts/resolve",
        "/admin/contacts/delete"
})
public class AdminContactServlet extends HttpServlet {
    private final ContactDAO contactDAO = DAOFactory.getInstance().getContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("summary".equals(request.getParameter("action"))) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"unreadCount\":" + contactDAO.countUnreadContacts() + "}");
            return;
        }

        if ("/admin/contacts/view".equals(path)) {
            showDetail(request, response);
            return;
        }

        String status = normalizeStatus(request.getParameter("status"));
        String search = trim(request.getParameter("search"));
        int page = parsePage(request.getParameter("page"));
        int pageSize = 10;

        List<Contact> contacts = contactDAO.getContacts(status, search, page, pageSize);
        int totalContacts = contactDAO.countContacts(status, search);
        int totalPages = (int) Math.ceil((double) totalContacts / pageSize);

        request.setAttribute("contactsList", contacts);
        request.setAttribute("status", status);
        request.setAttribute("search", search);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalContacts", totalContacts);
        request.getRequestDispatcher("/admin/admin-contacts.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/admin/contacts/reply".equals(path)) {
            reply(request, response);
        } else if ("/admin/contacts/resolve".equals(path)) {
            resolve(request, response);
        } else if ("/admin/contacts/delete".equals(path)) {
            delete(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void showDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseId(request.getParameter("id"));
        Contact contact = contactDAO.getContactById(id);
        if (contact == null) {
            setMessage(request.getSession(), "Không tìm thấy liên hệ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/contacts");
            return;
        }

        if ("UNREAD".equalsIgnoreCase(contact.getStatus())) {
            contactDAO.markRead(id);
            contact.setStatus("READ");
        }

        request.setAttribute("contact", contact);
        request.getRequestDispatcher("/admin/admin-contact-detail.jsp").forward(request, response);
    }

    private void reply(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        int id = parseId(request.getParameter("id"));
        String adminReply = trim(request.getParameter("adminReply"));
        Contact contact = contactDAO.getContactById(id);

        if (contact == null || adminReply == null || adminReply.isBlank()) {
            setMessage(session, "Vui lòng nhập nội dung phản hồi hợp lệ.", "danger");
            response.sendRedirect(request.getContextPath() + "/admin/contacts/view?id=" + id);
            return;
        }

        try {
            String subject = "Phản hồi liên hệ từ Mộc Trà: " + contact.getSubject();
            String body = "Xin chào " + contact.getName() + ",\n\n"
                    + adminReply + "\n\n"
                    + "------------------------------\n"
                    + "Nội dung bạn đã gửi:\n"
                    + contact.getMessage() + "\n\n"
                    + "Mộc Trà";
            EmailService.sendEmail(contact.getEmail(), subject, body);

            User admin = (User) session.getAttribute("user");
            Integer adminId = admin != null ? admin.getId() : null;
            boolean updated = contactDAO.reply(id, adminReply, adminId);
            if (updated) {
                if (adminId != null) {
                    new SystemLogService().log(adminId, "Trả lời liên hệ khách hàng", "Contact", id);
                }
                setMessage(session, "Đã gửi phản hồi cho khách hàng.", "success");
            } else {
                setMessage(session, "Email đã gửi nhưng không thể lưu phản hồi.", "warning");
            }
        } catch (MessagingException e) {
            System.err.println("Khong the gui email phan hoi lien he #" + id + ": " + e.getMessage());
            setMessage(session, "Không thể gửi email phản hồi. Vui lòng kiểm tra cấu hình email.", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/admin/contacts/view?id=" + id);
    }

    private void resolve(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        int id = parseId(request.getParameter("id"));
        boolean success = contactDAO.resolve(id);
        setMessage(session, success ? "Đã đánh dấu liên hệ là đã xử lý." : "Không thể cập nhật liên hệ.",
                success ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/contacts");
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        int id = parseId(request.getParameter("id"));
        boolean success = contactDAO.delete(id);
        setMessage(session, success ? "Đã xóa liên hệ." : "Không thể xóa liên hệ.",
                success ? "success" : "danger");
        response.sendRedirect(request.getContextPath() + "/admin/contacts");
    }

    private int parsePage(String pageParam) {
        try {
            return Math.max(1, Integer.parseInt(pageParam));
        } catch (Exception e) {
            return 1;
        }
    }

    private int parseId(String idParam) {
        try {
            return Integer.parseInt(idParam);
        } catch (Exception e) {
            return 0;
        }
    }

    private String normalizeStatus(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }
        String normalized = status.trim().toUpperCase();
        return ("UNREAD".equals(normalized) || "READ".equals(normalized)
                || "REPLIED".equals(normalized) || "RESOLVED".equals(normalized))
                ? normalized
                : null;
    }

    private String trim(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private void setMessage(HttpSession session, String message, String type) {
        session.setAttribute("flashMsg", message);
        session.setAttribute("flashType", type);
    }
}
