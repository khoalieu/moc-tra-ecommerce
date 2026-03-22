package controller.auth;

import controller.utils.EmailService;
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String action = request.getParameter("action");
        String targetEmail = "";
        if ("change_email".equals(action)) {
            targetEmail = request.getParameter("newEmail");
        } else if ("resend_otp".equals(action)) {
            targetEmail = (String) session.getAttribute("NEW_EMAIL");
        }
        if (targetEmail != null && !targetEmail.trim().isEmpty()) {
            String otpCode = generateOTP();
            String subject = "Ma xac nhan doi email - Moc Tra Shop";
            String emailContent = "Xin chào,\n\n"
                    + "Bạn vừa yêu cầu thay đổi địa chỉ email cho tài khoản tại hệ thống Mộc Trà Shop.\n"
                    + "Mã OTP xác thực của bạn là: " + otpCode + "\n\n"
                    + "Lưu ý: Mã này có hiệu lực trong thời gian ngắn. Vui lòng không chia sẻ mã này cho bất kỳ ai.\n\n"
                    + "Trân trọng,\n"
                    + "Đội ngũ Mộc Trà Shop.";

            try {
                EmailService.sendEmail(targetEmail, subject, emailContent);
                session.setAttribute("OTP_CODE", otpCode);
                session.setAttribute("NEW_EMAIL", targetEmail);
                session.setAttribute("OTP_PURPOSE", "CHANGE_EMAIL");
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);

            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("msg", "Lỗi: Không thể gửi email. Vui lòng kiểm tra lại địa chỉ email hoặc thử lại sau!");
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