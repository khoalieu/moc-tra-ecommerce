package controller.auth;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "VerifyOtpServlet", value = "/verify-register-otp")
public class VerifyOtpServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userOtp = request.getParameter("otp");
        HttpSession session = request.getSession();
        String sessionOtp = (String) session.getAttribute("otp_code");

        if (sessionOtp != null && sessionOtp.equals(userOtp)) {
            String username = (String) session.getAttribute("temp_username");
            String password = (String) session.getAttribute("temp_password");
            String phone = (String) session.getAttribute("temp_phone");

            UserDAO dao = new UserDAO();
            dao.register(username, password, phone);

            session.removeAttribute("temp_username");
            session.removeAttribute("temp_password");
            session.removeAttribute("temp_phone");
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        } else {
            request.setAttribute("errorMessage", "Mã OTP không chính xác hoặc đã hết hạn!");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        }
    }
}
