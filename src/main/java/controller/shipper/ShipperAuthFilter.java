package controller.shipper;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.enums.UserRole;
import model.user.User;
import java.io.IOException;

@WebFilter(filterName = "ShipperAuthFilter", urlPatterns = {"/shipper/*"})
public class ShipperAuthFilter implements Filter {

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
        if (user.getRole() != UserRole.SHIPPER) {
            res.sendRedirect(req.getContextPath() + "/errors/403.jsp");
            return;
        }
        chain.doFilter(request, response);
    }
}
