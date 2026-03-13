
package controller.admin;

import dao.UserDAO;
import model.User;
import model.enums.UserRole;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/customer/edit")
public class AdminCustomerEditServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("user") : null;
        if (admin == null || (admin.getRole() != UserRole.ADMIN && admin.getRole() != UserRole.EDITOR)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/admin/customers");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User customer = userDAO.getUserDetailById(Integer.parseInt(idParam));
        if (customer == null) {
            response.sendError(404, "Khách hàng không tồn tại");
            return;
        }

        request.setAttribute("customer", customer);
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
            String roleStr = request.getParameter("role");
            boolean isActive = request.getParameter("isActive") != null;

            UserDAO userDAO = new UserDAO();
            User user = userDAO.getUserDetailById(id);

            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setPhone(phone);
            user.setRole(UserRole.valueOf(roleStr));
            user.setIsActive(isActive);

            boolean success = userDAO.updateUserByAdmin(user);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/customer/detail?id=" + id + "&msg=success");
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("customer", user);
                request.getRequestDispatcher("/admin/admin-customer-edit.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }
}