
package controller.auth;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Properties;

@WebServlet(urlPatterns = {"/forgot-password", "/verify-otp", "/reset-password"})
public class ForgotPasswordServlet extends HttpServlet {

    private static final long OTP_TTL = 5 * 60_000L;
    private static final long RESEND_COOLDOWN = 2 * 60_000L;
    private static final SecureRandom RNG = new SecureRandom();

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String SMTP_USER = "tavanhuy20052005@gmail.com";
    private static final String SMTP_PASS = "ehzy axfn vlwt bqqy";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();
        String emailParam = req.getParameter("email");
        if ("/verify-otp".equals(path)) {
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
        } else if ("/reset-password".equals(path)) {
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
        } else if ("/forgot-password".equals(path) && emailParam != null && !emailParam.isEmpty()) {
            handleSendOTP(req, resp);
        }else {
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req, resp);
        }
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        String path = req.getServletPath();

        if ("/forgot-password".equals(path)) {
            handleSendOTP(req, resp);
        } else if ("/verify-otp".equals(path)) {
            handleVerifyOTP(req, resp);
        } else if ("/reset-password".equals(path)) {
            handleResetPassword(req, resp);
        }
    }

    private void handleSendOTP(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ss = req.getSession();
        long now = System.currentTimeMillis();
        String action = req.getParameter("action");
        String email = req.getParameter("email");

        if (email == null || email.trim().isEmpty()){
            email = (String) ss.getAttribute("RESET_EMAIL");
        }

        if (email == null || email.trim().isEmpty()){
            req.setAttribute("message", "Vui lòng nhập email");
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req,resp);
            return;
        }

        email = email.trim();
        ss.setAttribute("RESET_EMAIL", email);

        Long lastSend = (Long) ss.getAttribute("OTP_LAST_SEND");
        if (lastSend != null && now - lastSend < RESEND_COOLDOWN) {
            long waitSec = (RESEND_COOLDOWN - (now - lastSend)) / 1000;
            req.setAttribute("message", "Vui lòng đợi " + waitSec + " giây để gửi lại OTP.");
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        Integer userId = dao.findUserIdByEmail(email);
        if (userId == null) {
            req.setAttribute("message", "Email không tồn tại trong hệ thống.");
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req, resp);
            return;
        }

        String otp = String.format("%06d", RNG.nextInt(1_000_000));

        if (!sendOtpMail(email, otp)) {
            req.setAttribute("message", "Gửi OTP thất bại. Vui lòng thử lại.");
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req, resp);
            return;
        }

        ss.setAttribute("otp_code", otp);
        ss.setAttribute("OTP_EXP", now + OTP_TTL);
        ss.setAttribute("OTP_LAST_SEND", now);
        ss.setAttribute("OTP_VERIFIED", false);

        if ("resend".equalsIgnoreCase(action)) {
            req.setAttribute("message", "Đã gửi lại OTP. Vui lòng kiểm tra email.");
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
        } else {
            ss.setAttribute("OTP_PURPOSE", "FORGOT");
            resp.sendRedirect(req.getContextPath() + "/verify-otp");
        }
    }

    private void handleVerifyOTP(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ss = req.getSession(false);
        if (ss == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        String otpInput = req.getParameter("otp");
        String otpSaved = (String) ss.getAttribute("otp_code");
        Long otpExp = (Long) ss.getAttribute("OTP_EXP");
        long now = System.currentTimeMillis();

        if (otpSaved == null || otpExp == null) {
            req.setAttribute("message", "Bạn chưa yêu cầu OTP.");
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req, resp);
            return;
        }

        if (now > otpExp) {
            ss.removeAttribute("otp_code");
            ss.removeAttribute("OTP_EXP");
            req.setAttribute("message", "OTP đã hết hạn. Vui lòng gửi lại.");
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
            return;
        }

        if (otpInput == null) otpInput = "";
        otpInput = otpInput.trim();

        if (otpInput.length() != 6 || !otpInput.equals(otpSaved)) {
            req.setAttribute("message", "OTP không đúng.");
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
            return;
        }

        ss.removeAttribute("otp_code");
        ss.removeAttribute("OTP_EXP");
        ss.removeAttribute("OTP_PURPOSE");
        ss.setAttribute("OTP_VERIFIED", true);

        resp.sendRedirect(req.getContextPath() + "/reset-password");
    }

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession ss = req.getSession(false);
        if (ss == null) {
            resp.sendRedirect(req.getContextPath() + "/forgot-password");
            return;
        }

        Boolean verified = (Boolean) ss.getAttribute("OTP_VERIFIED");
        String email = (String) ss.getAttribute("RESET_EMAIL");

        if (verified == null || !verified || email == null) {
            req.setAttribute("message", "Vui lòng xác nhận OTP trước.");
            req.getRequestDispatcher("/auth/verify-otp.jsp").forward(req, resp);
            return;
        }

        String newPass = req.getParameter("newPassword");
        String confirm = req.getParameter("confirmPassword");

        if (newPass == null || newPass.trim().isEmpty()) {
            req.setAttribute("message", "Mật khẩu không được để trống.");
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        if (!newPass.equals(confirm)) {
            req.setAttribute("message", "Xác nhận mật khẩu không khớp.");
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        if (newPass.length() < 8) {
            req.setAttribute("message", "Mật khẩu phải tối thiểu 8 ký tự.");
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
            return;
        }

        UserDAO dao = new UserDAO();
        Integer userId = dao.findUserIdByEmail(email.trim());
        if (userId == null) {
            req.setAttribute("message", "Email không tồn tại.");
            req.getRequestDispatcher("/auth/quen-mat-khau.jsp").forward(req, resp);
            return;
        }

        boolean ok = dao.changePassword(userId, newPass);

        if (ok){
            dao.resetFailedAttempts(userId);
            ss.removeAttribute("RESET_EMAIL");
            ss.removeAttribute("OTP_VERIFIED");
            ss.removeAttribute("OTP_LAST_SEND");

            req.setAttribute("message", "Đặt lại mật khẩu thành công! Vui longf đăng nhập.");
            req.getRequestDispatcher("/auth/login.jsp").forward(req, resp);
        }else {
            req.setAttribute("message", "Lỗi hệ thống khi cập nhật mật khẩu.");
            req.getRequestDispatcher("/auth/reset-password.jsp").forward(req, resp);
        }
    }

    private boolean sendOtpMail(String toEmail, String otp) {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.host", SMTP_HOST);
            props.put("mail.smtp.port", String.valueOf(SMTP_PORT));

            Session mailSession = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
                }
            });
            Message msg = new MimeMessage(mailSession);
            msg.setFrom(new InternetAddress(SMTP_USER));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            msg.setSubject("Ma OTP khoi phuc mat khau");
            msg.setText("Ma OTP cua ban la: " + otp + "\nHieu luc 5 phut.");
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
