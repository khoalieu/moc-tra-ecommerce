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
            } else {
                if ("REGISTER".equals(purpose)) {
                    response.sendRedirect(request.getContextPath() + "/signup?action=resend");
                } else if ("VERIFY_GOOGLE_PHONE".equals(purpose)) {
                    java.util.Random rnd = new java.util.Random();
                    String phoneOtp = String.format("%06d", rnd.nextInt(999999));
                    session.setAttribute("OTP_CODE", phoneOtp);
                    session.setAttribute("OTP_LAST_SENT_AT", now);
                    System.out.println(">>> MÃ OTP XÁC THỰC SĐT GOOGLE CỦA BẠN (GỬI LẠI) LÀ: " + phoneOtp);
                    request.setAttribute("otp_display", phoneOtp);
                    request.setAttribute("message", "Đã gửi lại mã OTP mới!");
                    request.setAttribute("resendCooldown", 60);
                    request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
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
                session.setAttribute("pending_update_user", username);
                session.setAttribute("registration_finished", true);
                
                session.removeAttribute("OTP_CODE");
                session.removeAttribute("otp_display");
                session.removeAttribute("OTP_PURPOSE");
                
                response.sendRedirect(request.getContextPath() + "/auth/update-profile.jsp");
                return;
            } else if ("VERIFY_GOOGLE_PHONE".equals(purpose)) {
                String username = (String) session.getAttribute("pending_update_user");
                String fName = (String) session.getAttribute("TEMP_FIRSTNAME");
                String lName = (String) session.getAttribute("TEMP_LASTNAME");
                String fullName = (String) session.getAttribute("TEMP_FULLNAME");
                String phone = (String) session.getAttribute("TEMP_PHONE_ADDR");
                String label = (String) session.getAttribute("TEMP_LABEL");
                String prov = (String) session.getAttribute("TEMP_PROVINCE");
                String dist = (String) session.getAttribute("TEMP_DISTRICT");
                String ward = (String) session.getAttribute("TEMP_WARD");
                String addr = (String) session.getAttribute("TEMP_ADDRESS");
                String dIdStr = (String) session.getAttribute("TEMP_DISTRICT_ID");
                String wCode = (String) session.getAttribute("TEMP_WARD_CODE");

                int districtId = (dIdStr != null && !dIdStr.isEmpty()) ? Integer.parseInt(dIdStr) : 0;
                dao.updateGoogleProfileInfo(username, fName, lName, phone);
                dao.saveUserAddress(username, fullName, phone, label, prov, dist, ward, addr, districtId, wCode);

                User updatedUser = dao.getUserForLogin(username);
                session.setAttribute("user", updatedUser);
                session.removeAttribute("pending_update_user");
                session.removeAttribute("registration_finished");
                session.removeAttribute("is_google_login");
                session.removeAttribute("OTP_CODE");
                session.removeAttribute("OTP_PURPOSE");
                session.removeAttribute("OTP_CREATED_AT");
                session.removeAttribute("OTP_LAST_SENT_AT");
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

                response.sendRedirect(request.getContextPath() + "/index");
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

    private void clearEmailSession(HttpSession session) {
        session.removeAttribute("OTP_CODE");
        session.removeAttribute("NEW_EMAIL");
        session.removeAttribute("OTP_PURPOSE");
        session.removeAttribute("OTP_CREATED_AT");
        session.removeAttribute("OTP_LAST_SENT_AT");
    }
}
