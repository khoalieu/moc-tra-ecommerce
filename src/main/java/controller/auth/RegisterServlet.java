package controller.auth;

import dao.DAOFactory;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.regex.Pattern;
import controller.utils.CaptchaUtil;

@WebServlet(name = "RegisterServlet", value = "/signup")
public class RegisterServlet extends HttpServlet {
    // PHONE_REGEX is loaded dynamically from UserDAO
    private static final String USERNAME_REGEX = "^[a-zA-Z0-9]{6,}$";
    private static final String EMAIL_REGEX = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$";
    private static final String PASSWORD_REGEX = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{8,}$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.setAttribute("captchaSiteKey", CaptchaUtil.getSiteKey());
        request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserDAO dao = DAOFactory.getInstance().getUserDAO();

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String userParam = request.getParameter("username");
        String phoneParam = request.getParameter("phone");
        String passParam = request.getParameter("password");
        String rePassParam = request.getParameter("confirmPassword");

        String captchaResponse = request.getParameter("g-recaptcha-response");

        boolean hasError = false;

        if (userParam == null || userParam.trim().isEmpty()) {
            request.setAttribute("usernameError", "Vui lòng nhập tên đăng nhập!");
            hasError = true;
        } else {
            String userVal = userParam.trim();
            if (userVal.contains(" ") || !Pattern.matches(USERNAME_REGEX, userVal)) {
                request.setAttribute("usernameError", "Tên đăng nhập phải từ 6 ký tự trở lên, không chứa dấu cách hoặc ký tự đặc biệt!");
                hasError = true;
            }
        }

        if (phoneParam == null || phoneParam.trim().isEmpty()) {
            request.setAttribute("phoneError", "Vui lòng nhập số điện thoại!");
            hasError = true;
        } else {
            String phoneVal = phoneParam.trim();
            if (!Pattern.matches("^[0-9]{10}$", phoneVal)) {
                request.setAttribute("phoneError", "Số điện thoại không hợp lệ (phải gồm 10 chữ số)!");
                hasError = true;
            } else if (!Pattern.matches(UserDAO.PHONE_REGEX, phoneVal)) {
                request.setAttribute("phoneError", "Số điện thoại không đúng định dạng nhà mạng Việt Nam!");
                hasError = true;
            } else if (!dao.isValidCarrier(phoneVal)) {
                request.setAttribute("phoneError", "Đầu số nhà mạng không tồn tại!");
                hasError = true;
            }
        }

        if (passParam == null || passParam.isEmpty()) {
            request.setAttribute("passwordError", "Vui lòng nhập mật khẩu!");
            hasError = true;
        } else if (!Pattern.matches(PASSWORD_REGEX, passParam)) {
            request.setAttribute("passwordError", "Mật khẩu phải từ 8 ký tự trở lên, bao gồm cả chữ thường, chữ HOA và số!");
            hasError = true;
        }

        if (rePassParam == null || rePassParam.isEmpty()) {
            request.setAttribute("confirmPasswordError", "Vui lòng xác nhận mật khẩu!");
            hasError = true;
        } else if (passParam != null && !passParam.equals(rePassParam)) {
            request.setAttribute("confirmPasswordError", "Mật khẩu xác nhận không khớp!");
            hasError = true;
        }

        if (!CaptchaUtil.verify(captchaResponse)) {
            request.setAttribute("captchaError", "Vui lòng xác minh CAPTCHA");
            hasError = true;
        }

        if (hasError) {
            request.setAttribute("username", userParam != null ? userParam : "");
            request.setAttribute("phone", phoneParam != null ? phoneParam : "");
            request.setAttribute("captchaSiteKey", CaptchaUtil.getSiteKey());
            request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
            return;
        }

        String user = userParam.trim();
        String phone = phoneParam.trim();
        String pass = passParam;

        String validationError = dao.checkUserExistDetailed(user, phone);
        if (validationError != null) {
            if (validationError.contains("Tên đăng nhập")) {
                request.setAttribute("usernameError", "Tên đăng nhập đã tồn tại trong hệ thống!");
            }
            if (validationError.contains("Số điện thoại")) {
                request.setAttribute("phoneError", "Số điện thoại đã tồn tại trong hệ thống!");
            }
            request.setAttribute("username", user);
            request.setAttribute("phone", phone);
            request.setAttribute("captchaSiteKey", CaptchaUtil.getSiteKey());
            request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
        } else {
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            HttpSession session = request.getSession();
            session.setAttribute("OTP_PURPOSE", "REGISTER");
            session.setAttribute("temp_username", user);
            session.setAttribute("temp_password", pass);
            session.setAttribute("temp_phone", phone);
            session.setAttribute("OTP_CODE", otp);
            System.out.println(">>> MÃ OTP CỦA BẠN LÀ: " + otp);
            request.setAttribute("otp_display", otp);
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request,response);
        }
    }
}
