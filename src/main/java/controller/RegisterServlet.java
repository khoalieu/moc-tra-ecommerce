package controller;

import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.util.regex.Pattern;

@WebServlet(name = "RegisterServlet", value = "/signup")
public class RegisterServlet extends HttpServlet {

    private static final String USERNAME_REGEX = "^[a-zA-Z0-9]{6,}$";
    private static final String EMAIL_REGEX = "^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$";
    private static final String PASSWORD_REGEX = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("signup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String user = request.getParameter("username").trim();
        String email = request.getParameter("email").trim();
        String phone = request.getParameter("phone").trim();
        String pass = request.getParameter("password");
        String rePass = request.getParameter("confirmPassword");

        String error = null;

        if (user == null || user.contains(" ") || !Pattern.matches(USERNAME_REGEX, user)) {
            error = "Tên đăng nhập phải từ 6 ký tự trở lên, không chứa dấu cách hoặc ký tự đặc biệt!";
        }
        else if (email == null || !Pattern.matches(EMAIL_REGEX, email)) {
            error = "Email không hợp lệ! (Ví dụ: abc@gmail.com)";
        }
        else if (pass == null || !Pattern.matches(PASSWORD_REGEX, pass)) {
            error = "Mật khẩu phải từ 6 ký tự trở lên, bao gồm cả CHỮ và SỐ!";
        }
        else if (!pass.equals(rePass)) {
            error = "Mật khẩu xác nhận không khớp!";
        }
        if (error != null) {
            request.setAttribute("errorMessage", error);

            request.setAttribute("username", user);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);

            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        UserDAO dao = new UserDAO();
        if (dao.checkUserExist(user, email)) {
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc Email đã tồn tại trong hệ thống!");
            request.setAttribute("username", user);
            request.setAttribute("email", email);
            request.setAttribute("phone", phone);

            request.getRequestDispatcher("signup.jsp").forward(request, response);
        } else {
            String otp = String.format("%06d", new java.util.Random().nextInt(999999));
            HttpSession session = request.getSession();
            session.setAttribute("temp_username", user);
            session.setAttribute("temp_email", email);
            session.setAttribute("temp_password", pass);
            session.setAttribute("temp_phone", phone);
            session.setAttribute("otp_code", otp);
            boolean isSent = controller.utils.EmailUtils.sendOTP(email, otp);
            if (isSent) {
                response.sendRedirect("verify-otp.jsp");
            }
            else {
                request.setAttribute("errorMessage", "email không hợp lệ. Vui lòng thử lại!");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }
        }
    }
}