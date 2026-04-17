package controller.auth;

import dao.DAOFactory;
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
        HttpSession session = request.getSession(false);

        if (session == null){
            response.sendRedirect(request.getContextPath()+ "/auth/signup");
            return;
        }
        String sessionOtp = (String) session.getAttribute("otp_code");
        String username = (String) session.getAttribute("temp_username");
        if (sessionOtp != null && sessionOtp.equals(userOtp)) {
            String password = (String) session.getAttribute("temp_password");
            String phone = (String) session.getAttribute("temp_phone");
            String email = (String) session.getAttribute("temp_email");

            UserDAO dao = DAOFactory.getInstance().getUserDAO();
            dao.register(username, password, phone, email);

            session.setAttribute("registration_finished", true);

            session.removeAttribute("temp_username");
            session.removeAttribute("temp_password");
            session.removeAttribute("temp_phone");
            session.removeAttribute("temp_email");
            session.removeAttribute("otp_code");
            session.removeAttribute("otp_display");
            response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        } else {
            request.setAttribute("otp_display", sessionOtp);
            request.setAttribute("message", "Mã OTP không chính xác!");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        }
    }
}
