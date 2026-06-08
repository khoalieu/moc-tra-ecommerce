package controller.auth;

import dao.DAOFactory;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.user.User;

import java.io.IOException;

@WebServlet("/verify-change-email-otp")
public class VerifyChangeEmailOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        long now = System.currentTimeMillis();
        if ("resend_otp".equals(action)) {
            Long lastSentAt = (Long) session.getAttribute("OTP_LAST_SENT_AT");
            if (lastSentAt != null && now - lastSentAt < 60 * 1000) {
                long remainingSeconds = (60 * 1000 - (now - lastSentAt)) / 1000;
                request.setAttribute("message", "Vui lòng đợi " + remainingSeconds + " giây.");
                request.setAttribute("resendCooldown", remainingSeconds);
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                return;
            }
        }
        String purpose = (String) session.getAttribute("OTP_PURPOSE");
        User currentUser = (User) session.getAttribute("user");
        if (!"VERIFY_REGISTER_EMAIL".equals(purpose) && currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String inputOtp = request.getParameter("otp");
        String sessionOtp = (String) session.getAttribute("OTP_CODE");
        Long otpCreatedAt = (Long) session.getAttribute("OTP_CREATED_AT");

        if (otpCreatedAt == null || System.currentTimeMillis() - otpCreatedAt > 5 * 60 * 1000) {
            session.removeAttribute("OTP_CODE");
            session.removeAttribute("NEW_EMAIL");
            session.removeAttribute("OTP_PURPOSE");
            session.removeAttribute("OTP_CREATED_AT");
            session.removeAttribute("OTP_LAST_SENT_AT");
            request.setAttribute("message", "Mã OTP đã hết hạn.");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        if (sessionOtp != null && sessionOtp.equals(inputOtp)) {
            UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
            if ("CHANGE_EMAIL".equals(purpose)) {
                String newEmail = (String) session.getAttribute("NEW_EMAIL");
                boolean isUpdated = userDAO.updateEmail(currentUser.getId(), newEmail);
                if (isUpdated) {
                    currentUser.setEmail(newEmail);
                    session.setAttribute("user", currentUser);
                    clearEmailSession(session);
                    session.setAttribute("msg", "Xác thực thành công! Email đã được cập nhật.");
                    session.setAttribute("msgType", "success");
                    response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");
                } else {
                    request.setAttribute("message", "Có lỗi xảy ra khi cập nhật email.");
                    request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                }
            }
            else if ("VERIFY_REGISTER_EMAIL".equals(purpose)) {
                String username = (String) session.getAttribute("pending_update_user");
                String email = (String) session.getAttribute("TEMP_EMAIL");
                String fName = (String) session.getAttribute("TEMP_FIRSTNAME");
                String lName = (String) session.getAttribute("TEMP_LASTNAME");
                String fullName = (String) session.getAttribute("TEMP_FULLNAME");
                String phoneAddr = (String) session.getAttribute("TEMP_PHONE_ADDR");
                String label = (String) session.getAttribute("TEMP_LABEL");
                String prov = (String) session.getAttribute("TEMP_PROVINCE");
                String dist = (String) session.getAttribute("TEMP_DISTRICT");
                String ward = (String) session.getAttribute("TEMP_WARD");
                String addr = (String) session.getAttribute("TEMP_ADDRESS");
                String dIdStr = (String) session.getAttribute("TEMP_DISTRICT_ID");
                String wCode = (String) session.getAttribute("TEMP_WARD_CODE");
                int districtId = (dIdStr != null && !dIdStr.isEmpty()) ? Integer.parseInt(dIdStr) : 0;
                boolean isUserUpdated = userDAO.updateProfileInfo(username, fName, lName, email);
                boolean isAddressSaved = userDAO.saveUserAddress(
                        username, fullName, phoneAddr, label,
                        prov, dist, ward, addr,
                        districtId, wCode
                );

                if (isUserUpdated && isAddressSaved) {
                    clearEmailSession(session);
                    session.removeAttribute("pending_update_user");
                    session.removeAttribute("registration_finished");
                    session.removeAttribute("TEMP_EMAIL");
                    session.removeAttribute("TEMP_FIRSTNAME");
                    session.removeAttribute("TEMP_LASTNAME");
                    session.removeAttribute("TEMP_FULLNAME");
                    session.removeAttribute("TEMP_PHONE_ADDR");
                    session.removeAttribute("TEMP_LABEL");
                    session.removeAttribute("TEMP_PROVINCE");
                    session.removeAttribute("TEMP_DISTRICT");
                    session.removeAttribute("TEMP_WARD");
                    session.removeAttribute("TEMP_ADDRESS");
                    session.removeAttribute("TEMP_DISTRICT_ID");
                    session.removeAttribute("TEMP_WARD_CODE");
                    session.setAttribute("msg", "Đăng ký và xác thực Email thành công! Mời bạn đăng nhập.");
                    session.setAttribute("msgType", "success");
                    response.sendRedirect(request.getContextPath() + "/login");
                } else {
                    request.setAttribute("message", "Lỗi hệ thống khi lưu thông tin. Vui lòng thử lại!");
                    request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
                }
            }
        } else {
            request.setAttribute("message", "Mã OTP không chính xác!");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        }
    }
    private void clearEmailSession(HttpSession session) {
        session.removeAttribute("OTP_CODE");
        session.removeAttribute("NEW_EMAIL");
        session.removeAttribute("OTP_PURPOSE");
        session.removeAttribute("OTP_CREATED_AT");
        session.removeAttribute("OTP_LAST_SENT_AT");
    }
}
