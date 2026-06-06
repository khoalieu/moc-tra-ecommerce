
package controller.admin;

import dao.DAOFactory;
import dao.RoleDAO;
import dao.UserDAO;
import model.rbac.Role;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/customer/edit")
public class AdminCustomerEditServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("user") : null;
        if (admin == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }

        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
        User customer = userDAO.getUserDetailById(Integer.parseInt(idParam));
        if (customer == null) {
            response.sendError(404, "Khách hàng không tồn tại");
            return;
        }

        List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
        request.setAttribute("customer", customer);
        request.setAttribute("roles", roles);
        request.getRequestDispatcher("/admin/admin-customer-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String phone = request.getParameter("phone");
            boolean isActive = request.getParameter("isActive") != null;

            int roleId = 0;
            String roleIdStr = request.getParameter("roleId");
            if (roleIdStr != null && !roleIdStr.isBlank()) {
                try { roleId = Integer.parseInt(roleIdStr); } catch (Exception ignored) {}
            }

            UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
            User user = userDAO.getUserDetailById(id);

            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setPhone(phone);
            user.setActive(isActive);
            if (roleId > 0) {
                user.setRoleId(roleId);
            }

            boolean success = userDAO.updateUserByAdmin(user);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/customer/detail?id=" + id + "&msg=success");
                } else {
                List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("customer", user);
                request.setAttribute("roles", roles);
                request.getRequestDispatcher("/admin/admin-customer-edit.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
}