package controller.auth;

import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet(name = "RegisterServlet", value = "/signup")
public class RegisterServlet extends HttpServlet {
    private static final String PHONE_REGEX = "^(03|05|07|08|09|01[2|6|8|9])\\d{8}$";
    private static final String USERNAME_REGEX = "^[a-zA-Z0-9]{6,}$";
    private static final String EMAIL_REGEX = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$";
    private static final String PASSWORD_REGEX = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        UserDAO dao = new UserDAO();

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String userParam = request.getParameter("username");
        String phoneParam = request.getParameter("phone");
        String passParam = request.getParameter("password");
        String rePassParam = request.getParameter("confirmPassword");

        if (userParam == null || userParam.trim().isEmpty() ||
                phoneParam == null || phoneParam.trim().isEmpty() ||
                passParam == null || passParam.isEmpty() ||
                rePassParam == null || rePassParam.isEmpty()) {

            request.setAttribute("username", userParam != null ? userParam : "");
            request.setAttribute("phone", phoneParam != null ? phoneParam : "");

            request.setAttribute("errorMessage", "Vui lòng nhập đầy đủ tất cả thông tin!");
            request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
            return;
        }

        String user = request.getParameter("username").trim();
        String phone = request.getParameter("phone").trim();
        String pass = request.getParameter("password");
        String rePass = request.getParameter("confirmPassword");

        String error = null;

        if (user.contains(" ") || !Pattern.matches(USERNAME_REGEX, user)) {
            error = "Tên đăng nhập phải từ 6 ký tự trở lên, không chứa dấu cách hoặc ký tự đặc biệt!";
        }
        else if (!Pattern.matches("^[0-9]{10}$", phone)) {
            error = "Số điện thoại không hợp lệ (phải gồm 10 chữ số)!";
        }else if (!Pattern.matches(PHONE_REGEX, phone)) {
            error = "Số điện thoại không đúng định dạng nhà mạng VIỆT NAM!";
        }else if (!dao.isValidCarrier(phone)){
            error = "Đầu số nhà mạng không tồn tại!";
        }else if (!Pattern.matches(PASSWORD_REGEX, pass)) {
            error = "Mật khẩu phải từ 6 ký tự trở lên, bao gồm cả CHỮ và SỐ!";
        }
        else if (!pass.equals(rePass)) {
            error = "Mật khẩu xác nhận không khớp!";
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);
            request.setAttribute("username", user);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
            return;
        }
        String validationError = dao.checkUserExistDetailed(user, phone);
        if (validationError != null) {
            request.setAttribute("errorMessage", validationError);
            request.setAttribute("username", user);
            request.setAttribute("phone", phone);
            request.getRequestDispatcher("/auth/signup.jsp").forward(request, response);
        } else {
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            HttpSession session = request.getSession();
            session.setAttribute("temp_username", user);
            session.setAttribute("temp_password", pass);
            session.setAttribute("temp_phone", phone);
            session.setAttribute("otp_code", otp);
            System.out.println(">>> MÃ OTP CỦA BẠN LÀ: " + otp);
            request.setAttribute("otp_display", otp);
            request.getRequestDispatcher("/auth/verify-soft-otp.jsp").forward(request,response);
        }
    }
}
