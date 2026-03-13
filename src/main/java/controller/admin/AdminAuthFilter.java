package controller.admin;

import model.User;
import model.enums.UserRole;
import jakarta.servlet.*;
import jakarta.servlet.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebFilter(filterName = "AdminAuthFilter", urlPatterns = {"/admin/*"})
public class AdminAuthFilter implements Filter {

    public void init(FilterConfig config) throws ServletException {}

    public void destroy() {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws ServletException, IOException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            String message = URLEncoder.encode("Vui lòng đăng nhập quyền Admin", StandardCharsets.UTF_8.toString());
            res.sendRedirect(req.getContextPath() + "/login.jsp?message=" + message);
            return;
        }

        if (user.getRole() != UserRole.ADMIN) {
            res.sendRedirect(req.getContextPath() + "/403.jsp");
            return;
        }

        chain.doFilter(request, response);
    }
}