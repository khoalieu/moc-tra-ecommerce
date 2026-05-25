package controller.editor;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import model.enums.UserRole;
import model.user.User;

import java.io.IOException;

@WebFilter(filterName = "EditorAuthFilter", urlPatterns = {"/editor/*"})
public class EditorAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        User user = null;
        if (session != null) {
            user = (User) session.getAttribute("user");
        }
        if (user == null) {
            res.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }
        if (user.getRole() != UserRole.EDITOR) {
            res.sendRedirect(req.getContextPath() + "/errors/403.jsp");
            return;
        }

        chain.doFilter(request, response);
    }
}