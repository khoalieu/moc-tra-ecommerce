package controller.auth;

import controller.utils.EmailService;
import controller.utils.RedirectUtils;
import dao.DAOFactory;
import dao.UserDAO;
import model.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Random;

@WebServlet("/change-email")
public class ChangeEmailServlet extends HttpServlet {
    private static final String EMAIL_REGEX = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$";
    private final UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(RedirectUtils.toLoginWithRedirect(request, "/tai-khoan-cua-toi"));
            return;
        }
        String action = request.getParameter("action");
        long now = System.currentTimeMillis();

        if ("resend_otp".equals(action)) {
            Long lastSentAt = (Long) session.getAttribute("OTP_LAST_SENT_AT");

            if (lastSentAt != null && now - lastSentAt < 60 * 1000) {
                long remainingSeconds = (60 * 1000 - (now - lastSentAt)) / 1000;

                request.setAttribute("message", "Vui lòng đợi " + remainingSeconds + " giây trước khi gửi lại mã OTP.");
                request.setAttribute("resendCooldown", remainingSeconds);
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                return;
            }
        }
        String targetEmail = null;
        if ("change_email".equals(action)) {
            targetEmail = request.getParameter("newEmail");
        } else if ("resend_otp".equals(action)) {
            targetEmail = (String) session.getAttribute("NEW_EMAIL");
        }
        if (targetEmail == null || targetEmail.trim().isEmpty() || !targetEmail.matches(EMAIL_REGEX)) {
            session.setAttribute("msg", "Lỗi: Email không hợp lệ hoặc đã hết phiên làm việc!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            return;
        }

        if (targetEmail.equalsIgnoreCase(user.getEmail())) {
            session.setAttribute("msg", "Email mới không được trùng với email hiện tại!");
            session.setAttribute("msgType", "warning");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            return;
        }

        if (userDAO.isEmailExists(targetEmail)) {
            session.setAttribute("msg", "Lỗi: Email này đã được sử dụng bởi tài khoản khác!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            return;
        }
        if (targetEmail != null && !targetEmail.trim().isEmpty()) {
            String otpCode = generateOTP();
            String subject = "Ma xac nhan doi email - Moc Tra Shop";
            String emailContent = "Xin chào,\n\n"
                    + "Bạn vừa yêu cầu thay đổi địa chỉ email cho tài khoản tại hệ thống Mộc Trà Shop.\n"
                    + "Mã OTP xác thực của bạn là: " + otpCode + "\n\n"
                    + "Lưu ý: Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.\n\n"
                    + "Trân trọng,\n"
                    + "Đội ngũ Mộc Trà Shop.";

            try {
                EmailService.sendEmail(targetEmail, subject, emailContent);
                session.setAttribute("OTP_CODE", otpCode);
                session.setAttribute("NEW_EMAIL", targetEmail);
                session.setAttribute("OTP_PURPOSE", "CHANGE_EMAIL");
                session.setAttribute("OTP_CREATED_AT", now);
                session.setAttribute("OTP_LAST_SENT_AT", now);
                request.setAttribute("resendCooldown", 60);
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            } catch (Exception e) {
                System.err.println("Gửi mail thất bại cho: " + targetEmail);
                e.printStackTrace();
                session.setAttribute("msg", "Hệ thống gửi mail gặp sự cố. Vui lòng thử lại sau!");
                session.setAttribute("msgType", "danger");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
            }

        } else {
            session.setAttribute("msg", "Lỗi: Vui lòng nhập địa chỉ email hợp lệ!");
            session.setAttribute("msgType", "danger");
            response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
        }
    }
    private String generateOTP() {
        Random rnd = new Random();
        int number = rnd.nextInt(999999);
        return String.format("%06d", number);
    }
}
