package controller.auth;

import dao.UserDAO;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "ChangePasswordServlet", value = "/change-password")
public class ChangePasswordServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String oldPass = request.getParameter("oldPassword");
        String newPass = request.getParameter("newPassword");
        String confirmPass = request.getParameter("confirmNewPassword");

        UserDAO dao = new UserDAO();

        if (!dao.checkPassword(user.getId(), oldPass)){
            session.setAttribute("msg", "Mật khẩu cũ không chính xác!");
            session.setAttribute("msgType", "danger");
        }else if (newPass == null || newPass.isEmpty() || !newPass.equals(confirmPass)){
            session.setAttribute("msg", "Mật khẩu mới không khớp hoặc trống!");
            session.setAttribute("msgType", "danger");
        }else if (newPass.length() < 8){
            session.setAttribute("msg", "Mật khẩu phải từ 8 ký tự trở lên!");
            session.setAttribute("msgType", "danger");
        }else {
            boolean isPassUpdated = dao.changePassword(user.getId(), newPass);
            if (isPassUpdated){
                session.setAttribute("msg", "Đổi mật khẩu thành công!");
                session.setAttribute("msgType", "success");
            }else {
                session.setAttribute("msg", "Lỗi hệ thống khi cập nhật mật khẩu");
                session.setAttribute("msgType", "danger");
            }
        }

        response.sendRedirect(request.getContextPath() + "/thong-tin-tai-khoan-nguoi-dung.jsp");
    }
}