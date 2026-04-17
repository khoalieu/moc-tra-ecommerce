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
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String inputOtp = request.getParameter("otp");
        String sessionOtp = (String) session.getAttribute("OTP_CODE");
        String newEmail = (String) session.getAttribute("NEW_EMAIL");

        if (sessionOtp != null && sessionOtp.equals(inputOtp)) {
            UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
            boolean isUpdated = userDAO.updateEmail(currentUser.getId(), newEmail);

            if (isUpdated) {
                currentUser.setEmail(newEmail);
                session.setAttribute("user", currentUser);
                session.removeAttribute("OTP_CODE");
                session.removeAttribute("NEW_EMAIL");
                session.removeAttribute("OTP_PURPOSE");

                session.setAttribute("msg", "Xác thực thành công! Email của bạn đã được cập nhật.");
                session.setAttribute("msgType", "success");
                response.sendRedirect(request.getContextPath() + "/tai-khoan-cua-toi");

            } else {
                request.setAttribute("message", "Có lỗi xảy ra khi cập nhật hệ thống. Vui lòng thử lại!");
                request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
            }

        } else {
            request.setAttribute("message", "Mã OTP không chính xác. Vui lòng kiểm tra lại!");
            request.getRequestDispatcher("/auth/verify-otp.jsp").forward(request, response);
        }
    }
}