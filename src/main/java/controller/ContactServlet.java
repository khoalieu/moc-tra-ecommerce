package controller;

import dao.ContactDAO;
import dao.DAOFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.contact.Contact;

import java.io.IOException;

@WebServlet("/lien-he")
public class ContactServlet extends HttpServlet {
    private final ContactDAO contactDAO = DAOFactory.getInstance().getContactDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/contact.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String name = trim(request.getParameter("name"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String subject = trim(request.getParameter("subject"));
        String message = trim(request.getParameter("message"));

        if (isBlank(name) || isBlank(email) || isBlank(subject) || isBlank(message)) {
            session.setAttribute("errorMsg", "Vui lòng nhập đầy đủ họ tên, email, tiêu đề và nội dung liên hệ.");
            response.sendRedirect(request.getContextPath() + "/lien-he");
            return;
        }

        if (!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$")) {
            session.setAttribute("errorMsg", "Email không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/lien-he");
            return;
        }

        Contact contact = new Contact();
        contact.setName(name);
        contact.setEmail(email);
        contact.setPhone(phone);
        contact.setSubject(subject);
        contact.setMessage(message);

        if (contactDAO.create(contact)) {
            session.setAttribute("flashMsg", "Cảm ơn bạn đã liên hệ. Shop sẽ phản hồi qua email trong thời gian sớm nhất.");
        } else {
            session.setAttribute("errorMsg", "Không thể gửi liên hệ lúc này. Vui lòng thử lại sau.");
        }

        response.sendRedirect(request.getContextPath() + "/lien-he");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
