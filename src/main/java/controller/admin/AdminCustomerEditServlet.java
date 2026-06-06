package controller.admin;

import dao.DAOFactory;
import dao.RoleDAO;
import dao.UserDAO;
import dao.AuditLogDAO;
import model.rbac.Role;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Objects;
import java.util.Random;

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
        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("user") : null;
        if (admin == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String otpParam = request.getParameter("otp");
            UserDAO userDAO = DAOFactory.getInstance().getUserDAO();
            AuditLogDAO auditLogDAO = DAOFactory.getInstance().getAuditLogDAO();

            // 1. 2FA Verification Stage
            if (otpParam != null && !otpParam.trim().isEmpty()) {
                String sessOtp = (String) session.getAttribute("CUSTOMER_EDIT_OTP_" + id);
                Long expiry = (Long) session.getAttribute("CUSTOMER_EDIT_OTP_EXPIRY_" + id);
                User pendingUser = (User) session.getAttribute("PENDING_CUSTOMER_EDIT_" + id);

                if (pendingUser == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/customers");
                    return;
                }

                if (sessOtp != null && expiry != null && System.currentTimeMillis() <= expiry && sessOtp.equals(otpParam.trim())) {
                    // OTP is valid, perform original customer detail load, update, and audit log
                    User originalUser = userDAO.getUserDetailById(id);
                    boolean success = userDAO.updateUserByAdmin(pendingUser);

                    if (success) {
                        writeCustomerEditAuditLogs(auditLogDAO, admin.getId(), originalUser, pendingUser);

                        // Clear 2FA session variables
                        session.removeAttribute("CUSTOMER_EDIT_OTP_" + id);
                        session.removeAttribute("CUSTOMER_EDIT_OTP_EXPIRY_" + id);
                        session.removeAttribute("PENDING_CUSTOMER_EDIT_" + id);
                        session.removeAttribute("CUSTOMER_EDIT_OTP_DISPLAY_" + id);

                        response.sendRedirect(request.getContextPath() + "/admin/customer/detail?id=" + id + "&msg=success");
                    } else {
                        List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
                        request.setAttribute("error", "Cập nhật thất bại!");
                        request.setAttribute("customer", pendingUser);
                        request.setAttribute("roles", roles);
                        request.getRequestDispatcher("/admin/admin-customer-edit.jsp").forward(request, response);
                    }
                } else {
                    request.setAttribute("error", "Mã OTP không chính xác hoặc đã hết hạn!");
                    String displayOtp = (String) session.getAttribute("CUSTOMER_EDIT_OTP_DISPLAY_" + id);
                    if (displayOtp != null) {
                        request.setAttribute("otp_display", displayOtp);
                    }
                    request.getRequestDispatcher("/admin/verify-2fa.jsp").forward(request, response);
                }
                return;
            }

            // 2. Initial Form Submission Stage
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String phone = request.getParameter("phone");
            boolean isActive = request.getParameter("isActive") != null;

            int roleId = 0;
            String roleIdStr = request.getParameter("roleId");
            if (roleIdStr != null && !roleIdStr.isBlank()) {
                try { roleId = Integer.parseInt(roleIdStr); } catch (Exception ignored) {}
            }

            User originalUser = userDAO.getUserDetailById(id);
            if (originalUser == null) {
                response.sendError(404, "Khách hàng không tồn tại");
                return;
            }

            // Construct pending changes User object
            User pendingUser = new User();
            pendingUser.setId(id);
            pendingUser.setUsername(originalUser.getUsername());
            pendingUser.setEmail(originalUser.getEmail());
            pendingUser.setFirstName(firstName);
            pendingUser.setLastName(lastName);
            pendingUser.setPhone(phone);
            pendingUser.setActive(isActive);
            
            if (roleId > 0) {
                pendingUser.setRoleId(roleId);
                List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
                for (Role r : roles) {
                    if (r.getId() == roleId) {
                        try {
                            pendingUser.setRole(model.enums.UserRole.valueOf(r.getName().toUpperCase()));
                        } catch (Exception e) {
                            pendingUser.setRole(originalUser.getRole());
                        }
                        break;
                    }
                }
            } else {
                pendingUser.setRoleId(originalUser.getRoleId());
                pendingUser.setRole(originalUser.getRole());
            }
            pendingUser.setVip(originalUser.isVip());

            // Check if sensitive fields changed
            boolean phoneChanged = !isEqual(originalUser.getPhone(), phone);
            boolean roleChanged = (roleId > 0 && !Objects.equals(originalUser.getRoleId(), roleId));

            if (phoneChanged || roleChanged) {
                // Generate OTP
                String otp = String.format("%06d", new Random().nextInt(1000000));
                session.setAttribute("CUSTOMER_EDIT_OTP_" + id, otp);
                session.setAttribute("CUSTOMER_EDIT_OTP_EXPIRY_" + id, System.currentTimeMillis() + 5 * 60 * 1000);
                session.setAttribute("PENDING_CUSTOMER_EDIT_" + id, pendingUser);
                session.setAttribute("CUSTOMER_EDIT_OTP_DISPLAY_" + id, otp);

                // Send email to active admin/performer
                try {
                    String subject = "Xác thực 2FA thay đổi thông tin khách hàng - Mộc Trà Admin";
                    String message = "Xin chào " + admin.getDisplayName() + ",\n\n"
                            + "Hệ thống ghi nhận yêu cầu thay đổi thông tin nhạy cảm (Số điện thoại / Quyền truy cập) của khách hàng: " + originalUser.getUsername() + ".\n"
                            + "Mã xác thực OTP 2FA của bạn là: " + otp + "\n"
                            + "Mã OTP này có hiệu lực trong vòng 5 phút.\n\n"
                            + "Vui lòng nhập mã này vào trang xác thực để hoàn tất quá trình.\n\n"
                            + "Trân trọng,\n"
                            + "Đội ngũ kỹ thuật Mộc Trà.";
                    controller.utils.EmailService.sendEmail(admin.getEmail(), subject, message);
                } catch (Exception e) {
                    System.err.println("Lỗi gửi email OTP: " + e.getMessage());
                }

                request.setAttribute("otp_display", otp);
                request.getRequestDispatcher("/admin/verify-2fa.jsp").forward(request, response);
            } else {
                // Perform update directly if no sensitive field is changed
                boolean success = userDAO.updateUserByAdmin(pendingUser);
                if (success) {
                    writeCustomerEditAuditLogs(auditLogDAO, admin.getId(), originalUser, pendingUser);
                    response.sendRedirect(request.getContextPath() + "/admin/customer/detail?id=" + id + "&msg=success");
                } else {
                    List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
                    request.setAttribute("error", "Cập nhật thất bại!");
                    request.setAttribute("customer", pendingUser);
                    request.setAttribute("roles", roles);
                    request.getRequestDispatcher("/admin/admin-customer-edit.jsp").forward(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/customers");
        }
    }

    private boolean isEqual(String s1, String s2) {
        if (s1 == null || s1.trim().isEmpty()) {
            return s2 == null || s2.trim().isEmpty();
        }
        return s1.trim().equals(s2 != null ? s2.trim() : "");
    }

    private void writeCustomerEditAuditLogs(AuditLogDAO dao, int adminId, User oldUser, User newUser) {
        if (!isEqual(oldUser.getFirstName(), newUser.getFirstName())) {
            dao.insert(adminId, oldUser.getId(), "firstName", oldUser.getFirstName(), newUser.getFirstName());
        }
        if (!isEqual(oldUser.getLastName(), newUser.getLastName())) {
            dao.insert(adminId, oldUser.getId(), "lastName", oldUser.getLastName(), newUser.getLastName());
        }
        if (!isEqual(oldUser.getPhone(), newUser.getPhone())) {
            dao.insert(adminId, oldUser.getId(), "phone", oldUser.getPhone(), newUser.getPhone());
        }
        if (!Objects.equals(oldUser.getRoleId(), newUser.getRoleId())) {
            dao.insert(adminId, oldUser.getId(), "roleId",
                    getRoleNameById(oldUser.getRoleId()),
                    getRoleNameById(newUser.getRoleId()));
        }
        if (!Objects.equals(oldUser.isActive(), newUser.isActive())) {
            dao.insert(adminId, oldUser.getId(), "isActive",
                    Boolean.TRUE.equals(oldUser.isActive()) ? "Hoạt động" : "Khóa",
                    Boolean.TRUE.equals(newUser.isActive()) ? "Hoạt động" : "Khóa");
        }
    }

    private String getRoleNameById(Integer roleId) {
        if (roleId == null || roleId <= 0) return "Chưa gán / Khách hàng";
        try {
            List<Role> roles = DAOFactory.getInstance().getRoleDAO().getAllRoles();
            for (Role r : roles) {
                if (r.getId() == roleId) {
                    return r.getDisplayName();
                }
            }
        } catch (Exception ignored) {}
        return "Vai trò ID " + roleId;
    }
}