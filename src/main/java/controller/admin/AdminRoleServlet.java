package controller.admin;

import dao.DAOFactory;
import dao.PermissionDAO;
import dao.RoleDAO;
import model.rbac.Permission;
import model.rbac.Role;
import model.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {"/admin/roles", "/admin/roles/detail"})
public class AdminRoleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;
        if (me == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String path = request.getServletPath();
        RoleDAO roleDAO = DAOFactory.getInstance().getRoleDAO();

        if ("/admin/roles".equals(path)) {
            List<Role> roles = roleDAO.getAllRoles();
            for (Role r : roles) {
                r.setDescription(String.valueOf(roleDAO.countUsersByRoleId(r.getId())));
            }
            request.setAttribute("roles", roles);
            request.getRequestDispatcher("/admin/admin-roles.jsp").forward(request, response);
            return;
        }

        if ("/admin/roles/detail".equals(path)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) { response.sendRedirect(request.getContextPath() + "/admin/roles"); return; }

            Role role = roleDAO.getRoleById(id);
            if (role == null) { response.sendError(404); return; }

            List<Permission> rolePerms = roleDAO.getPermissionsByRoleId(id);
            PermissionDAO permDAO = DAOFactory.getInstance().getPermissionDAO();
            Map<String, List<Permission>> allGrouped = permDAO.getAllPermissionsGrouped();

            request.setAttribute("role", role);
            request.setAttribute("rolePermissions", rolePerms.stream().map(Permission::getId).collect(Collectors.toSet()));
            request.setAttribute("allPermissionsGrouped", allGrouped);
            request.setAttribute("userCount", roleDAO.countUsersByRoleId(id));
            request.getRequestDispatcher("/admin/admin-role-detail.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User me = (session != null) ? (User) session.getAttribute("user") : null;
        if (me == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

        String path = request.getServletPath();
        String action = request.getParameter("action");
        RoleDAO roleDAO = DAOFactory.getInstance().getRoleDAO();

        if ("/admin/roles".equals(path)) {
            if ("create".equalsIgnoreCase(action)) {
                String name = trimOrNull(request.getParameter("name"));
                String displayName = trimOrNull(request.getParameter("displayName"));
                String description = trimOrNull(request.getParameter("description"));

                if (name == null || displayName == null) {
                    session.setAttribute("errorMsg", "Tên và Tên hiển thị không được để trống!");
                    response.sendRedirect(request.getContextPath() + "/admin/roles");
                    return;
                }

                Role role = new Role();
                role.setName(name);
                role.setDisplayName(displayName);
                role.setDescription(description);

                boolean ok = roleDAO.createRole(role);
                session.setAttribute(ok ? "successMsg" : "errorMsg",
                        ok ? "Tạo vai trò thành công!" : "Tạo vai trò thất bại! Tên có thể đã tồn tại.");
                response.sendRedirect(request.getContextPath() + "/admin/roles");
                return;
            }

            if ("update".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"));
                String displayName = trimOrNull(request.getParameter("displayName"));
                String description = trimOrNull(request.getParameter("description"));

                Role role = new Role();
                role.setId(id);
                role.setDisplayName(displayName != null ? displayName : "");
                role.setDescription(description);

                boolean ok = roleDAO.updateRole(role);
                session.setAttribute(ok ? "successMsg" : "errorMsg",
                        ok ? "Cập nhật vai trò thành công!" : "Cập nhật thất bại!");
                response.sendRedirect(request.getContextPath() + "/admin/roles");
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"));
                boolean ok = roleDAO.deleteRole(id);
                if (!ok) {
                    session.setAttribute("errorMsg", "Không thể xóa! Role đang được gán cho user hoặc là role hệ thống.");
                } else {
                    session.setAttribute("successMsg", "Xóa vai trò thành công!");
                }
                response.sendRedirect(request.getContextPath() + "/admin/roles");
                return;
            }
        }

        if ("/admin/roles/detail".equals(path)) {
            if ("save-permissions".equalsIgnoreCase(action)) {
                int roleId = parseInt(request.getParameter("roleId"));

                String[] pidArr = request.getParameterValues("permissionIds");
                List<Integer> permissionIds = pidArr == null ? List.of() :
                        Arrays.stream(pidArr)
                              .map(s -> { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } })
                              .filter(i -> i > 0)
                              .collect(Collectors.toList());

                boolean ok = roleDAO.updateRolePermissions(roleId, permissionIds);
                session.setAttribute(ok ? "successMsg" : "errorMsg",
                        ok ? "Lưu phân quyền thành công!" : "Lưu phân quyền thất bại!");
                response.sendRedirect(request.getContextPath() + "/admin/roles/detail?id=" + roleId);
                return;
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/roles");
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
