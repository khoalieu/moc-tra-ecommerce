package controller.auth;

import dao.DAOFactory;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.user.User;

import java.io.IOException;

@WebServlet(name = "VerifyOtpServlet", value = "/verify-register-otp")
public class VerifyOtpServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userOtp = request.getParameter("otp");
        HttpSession session = request.getSession(false);
        if (session == null){
            response.sendRedirect(request.getContextPath()+ "/auth/signup");
            return;
        }
        long now = System.currentTimeMillis();
        Long lastSentAt = (Long) session.getAttribute("OTP_LAST_SENT_AT");
        String action = request.getParameter("action");
        String purpose = (String) session.getAttribute("OTP_PURPOSE");
        if ("resend".equals(action)) {
            if (lastSentAt != null && now - lastSentAt < 60 * 1000) {
                long remainingSeconds = (60 * 1000 - (now - lastSentAt)) / 1000;
                request.setAttribute("message", "Vui lòng đợi " + remainingSeconds + " giây trước khi gửi lại.");
                request.setAttribute("resendCooldown", remainingSeconds);
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                return;
            }else {
                if ("REGISTER".equals(purpose)) {
                    response.sendRedirect(request.getContextPath() + "/signup?action=resend");
                } else {
                    response.sendRedirect(request.getContextPath() + "/change-email?action=resend_otp");
                }
                return;
            }
        }
        String sessionOtp = (String) session.getAttribute("OTP_CODE");
        UserDAO dao = DAOFactory.getInstance().getUserDAO();
        if (sessionOtp != null && sessionOtp.equals(userOtp)) {

            if ("REGISTER".equals(purpose)) {
                String username = (String) session.getAttribute("temp_username");
                String password = (String) session.getAttribute("temp_password");
                String phone = (String) session.getAttribute("temp_phone");
                String email = (String) session.getAttribute("temp_email");
                dao.register(username, password, phone, email);
                session.setAttribute("pending_update_user", username);
                session.setAttribute("registration_finished", true);
                clearRegisterSession(session);
                response.sendRedirect(request.getContextPath() + "/auth/update-profile.jsp");
                return;
            } else if ("CHANGE_EMAIL".equals(purpose)) {
                User currentUser = (User) session.getAttribute("user");
                String newEmail = (String) session.getAttribute("NEW_EMAIL");
                if (currentUser != null && newEmail != null) {
                    boolean isUpdated = dao.updateEmail(currentUser.getId(), newEmail);
                    if (isUpdated) {
                        currentUser.setEmail(newEmail);
                        session.setAttribute("user", currentUser);
                        session.setAttribute("msg", "Cập nhật Email thành công!");
                        session.setAttribute("msgType", "success");
                    }
                }
                clearEmailSession(session);
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                return;
            }
        } else {
            request.setAttribute("otp_display", sessionOtp);
            request.setAttribute("message", "Mã OTP không chính xác!");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        }
    }
    private void clearRegisterSession(HttpSession session) {
        session.removeAttribute("temp_username");
        session.removeAttribute("temp_password");
        session.removeAttribute("temp_email");
        session.removeAttribute("OTP_CODE");
        session.removeAttribute("otp_display");
        session.removeAttribute("OTP_PURPOSE");
    }

    private void clearEmailSession(HttpSession session) {
        session.removeAttribute("OTP_CODE");
        session.removeAttribute("NEW_EMAIL");
        session.removeAttribute("OTP_PURPOSE");
        session.removeAttribute("OTP_CREATED_AT");
        session.removeAttribute("OTP_LAST_SENT_AT");
    }
}
