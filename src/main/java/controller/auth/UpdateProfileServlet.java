package controller.auth;

import controller.utils.EmailService;
import dao.DAOFactory;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.Random;

@WebServlet(name = "UpdateProfileServlet", value = "/auth/update-profile")
public class UpdateProfileServlet extends HttpServlet {
    private final UserDAO userDAO = DAOFactory.getInstance().getUserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("pending_update_user") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            return;
        }
        request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        boolean isGoogleLogin = Boolean.TRUE.equals(session.getAttribute("is_google_login"));
        
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String fullName = lastName + " " + firstName;
        
        String phone = request.getParameter("phoneFromSession");
        if (isGoogleLogin) {
            phone = request.getParameter("phone");
        } else {
            if (phone == null || phone.trim().isEmpty()) {
                phone = (String) session.getAttribute("temp_phone");
            }
        }
        
        String label = request.getParameter("addressLabel");
        if (label == null || label.isEmpty()) {
            label = "Địa chỉ mặc định";
        }
        String emailParam = request.getParameter("email");
        String email = (emailParam != null) ? emailParam.trim() : "";
        String province = request.getParameter("province");
        String district = request.getParameter("district");
        String ward = request.getParameter("ward");
        String addressDetail = request.getParameter("addressDetail");
        String districtId = request.getParameter("districtId");
        String wardCode = request.getParameter("wardCode");
        String username = request.getParameter("username");
        if (username == null || username.trim().isEmpty()) {
            username = (String) session.getAttribute("pending_update_user");
        }
        String password = (String) session.getAttribute("temp_password");

        if (firstName == null || firstName.trim().isEmpty()
                || lastName == null || lastName.trim().isEmpty()
                || province == null || province.trim().isEmpty()
                || district == null || district.trim().isEmpty()
                || ward == null || ward.trim().isEmpty()
                || addressDetail == null || addressDetail.trim().isEmpty()) {
            
            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ các mục bắt buộc!");
            request.setAttribute("temp_firstName", firstName);
            request.setAttribute("temp_lastName", lastName);
            request.setAttribute("temp_phone", phone);
            request.setAttribute("temp_email", email);
            request.setAttribute("temp_province", province);
            request.setAttribute("temp_district", district);
            request.setAttribute("temp_ward", ward);
            request.setAttribute("temp_addressDetail", addressDetail);
            request.setAttribute("temp_addressLabel", label);
            request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
            return;
        }

        if (isGoogleLogin) {
            if (phone == null || phone.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Số điện thoại là bắt buộc đối với tài khoản Google!");
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_phone", phone);
                request.setAttribute("temp_email", email);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
                return;
            }
            if (!java.util.regex.Pattern.matches("^(03|05|07|08|09|01[2|6|8|9])\\d{8}$", phone) || !userDAO.isValidCarrier(phone)) {
                request.setAttribute("errorMessage", "Số điện thoại không hợp lệ hoặc đầu số nhà mạng không tồn tại!");
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_phone", phone);
                request.setAttribute("temp_email", email);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
                return;
            }
            String duplicateError = userDAO.checkUserExistDetailed(null, phone);
            if (duplicateError != null) {
                request.setAttribute("errorMessage", duplicateError);
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_phone", phone);
                request.setAttribute("temp_email", email);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
                return;
            }

            Random rnd = new Random();
            String phoneOtp = String.format("%06d", rnd.nextInt(999999));
            long now = System.currentTimeMillis();

            System.out.println(">>> MÃ OTP XÁC THỰC SĐT GOOGLE CỦA BẠN LÀ: " + phoneOtp);

            session.setAttribute("OTP_CODE", phoneOtp);
            session.setAttribute("OTP_PURPOSE", "VERIFY_GOOGLE_PHONE");
            session.setAttribute("OTP_CREATED_AT", now);
            session.setAttribute("OTP_LAST_SENT_AT", now);
            
            session.setAttribute("TEMP_FIRSTNAME", firstName);
            session.setAttribute("TEMP_LASTNAME", lastName);
            session.setAttribute("TEMP_FULLNAME", fullName);
            session.setAttribute("TEMP_PHONE_ADDR", phone);
            session.setAttribute("TEMP_LABEL", label);
            session.setAttribute("TEMP_PROVINCE", province);
            session.setAttribute("TEMP_DISTRICT", district);
            session.setAttribute("TEMP_WARD", ward);
            session.setAttribute("TEMP_ADDRESS", addressDetail);
            session.setAttribute("TEMP_DISTRICT_ID", districtId);
            session.setAttribute("TEMP_WARD_CODE", wardCode);
            
            request.setAttribute("otp_display", phoneOtp);
            request.setAttribute("resendCooldown", 60);
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            return;
        }

        if (email != null && !email.trim().isEmpty()) {
            String cleanEmail = email.trim();
            if (userDAO.isEmailExists(cleanEmail)) {
                request.setAttribute("errorMessage", "Lỗi: Email này đã được sử dụng...");
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_email", cleanEmail);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
                return;
            }

            Random rnd = new Random();
            String emailOtp = String.format("%06d", rnd.nextInt(999999));
            long now = System.currentTimeMillis();

            String subject = "Ma xac nhan Email dang ky - Moc Tra Shop";
            String emailContent = "Xin chào " + fullName + ",\n\n"
                    + "Bạn vừa yêu cầu thay đổi địa chỉ email cho tài khoản tại hệ thống Mộc Trà Shop.\n"
                    + "Mã OTP xác thực của bạn là: " + emailOtp + "\n\n"
                    + "Lưu ý: Mã này có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.\n\n"
                    + "Trân trọng,\n"
                    + "Đội ngũ Mộc Trà Shop.";

            try {
                // Sử dụng cleanEmail đã được đảm bảo không null và không rỗng
                EmailService.sendEmail(cleanEmail, subject, emailContent);

                session.setAttribute("OTP_CODE", emailOtp);
                session.setAttribute("OTP_PURPOSE", "VERIFY_REGISTER_EMAIL");
                session.setAttribute("OTP_CREATED_AT", now);
                session.setAttribute("OTP_LAST_SENT_AT", now);
                session.setAttribute("TEMP_EMAIL", cleanEmail);
                session.setAttribute("TEMP_FIRSTNAME", firstName);
                session.setAttribute("TEMP_LASTNAME", lastName);
                session.setAttribute("TEMP_FULLNAME", fullName);
                session.setAttribute("TEMP_PHONE_ADDR", phone);
                session.setAttribute("TEMP_LABEL", label);
                session.setAttribute("TEMP_PROVINCE", province);
                session.setAttribute("TEMP_DISTRICT", district);
                session.setAttribute("TEMP_WARD", ward);
                session.setAttribute("TEMP_ADDRESS", addressDetail);
                session.setAttribute("TEMP_DISTRICT_ID", districtId);
                session.setAttribute("TEMP_WARD_CODE", wardCode);

                request.setAttribute("resendCooldown", 60);
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Hệ thống gửi mail gặp sự cố!");
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_email", cleanEmail);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
            }
        } else {
            int districtIdInt = 0;
            if (districtId != null && !districtId.isEmpty()) {
                try {
                    districtIdInt = Integer.parseInt(districtId);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }

            userDAO.register(username, password, phone, null);
            boolean isUserUpdated = userDAO.updateProfileInfo(username, firstName, lastName, null);
            boolean isAddressSaved = userDAO.saveUserAddress(
                    username, fullName, phone, label,
                    province, district, ward, addressDetail,
                    districtIdInt, wardCode
            );

            if (isUserUpdated && isAddressSaved) {
                session.removeAttribute("pending_update_user");
                session.removeAttribute("registration_finished");
                session.removeAttribute("temp_phone");
                session.removeAttribute("temp_username");
                session.removeAttribute("temp_password");
                session.removeAttribute("temp_email");

                session.setAttribute("msg", "Đăng ký thành công! Mời bạn đăng nhập.");
                session.setAttribute("msgType", "success");
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            } else {
                request.setAttribute("errorMessage", "Lỗi hệ thống khi lưu thông tin. Vui lòng thử lại!");
                request.setAttribute("temp_firstName", firstName);
                request.setAttribute("temp_lastName", lastName);
                request.setAttribute("temp_email", email);
                request.setAttribute("temp_province", province);
                request.setAttribute("temp_district", district);
                request.setAttribute("temp_ward", ward);
                request.setAttribute("temp_addressDetail", addressDetail);
                request.setAttribute("temp_addressLabel", label);
                request.getRequestDispatcher("/auth/update-profile.jsp").forward(request, response);
            }
        }
    }
}