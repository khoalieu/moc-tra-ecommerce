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
import service.SystemLogService;

import java.io.IOException;

@WebServlet(name = "LogoutServlet", value = "/logout")
public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if(user != null){
            SystemLogService log = new SystemLogService();
            log.log(user.getId(), "Đăng xuất", "Auth", null);
            session.invalidate();
        }
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("msg", "Bạn đã đăng xuất thành công!");
        newSession.setAttribute("msgType", "success");
        response.sendRedirect(request.getContextPath()+"/login");
    }
}
