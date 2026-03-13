package controller.admin;

import dao.CategoryDAO;
import model.Category;
import model.User;
import model.enums.UserRole;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(urlPatterns = {
        "/admin/categories",
        "/admin/categories/edit"
})
public class AdminCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        String path = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        if ("/admin/categories".equals(path)) {
            request.setAttribute("categories", dao.fetchAdminCategoryList());
            request.getRequestDispatcher("/admin/admin-categories.jsp").forward(request, response);
            return;
        }

        if ("/admin/categories/edit".equals(path)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/categories");
                return;
            }

            Category category = dao.fetchById(id);
            if (category == null) {
                response.sendError(404);
                return;
            }

            request.setAttribute("category", category);
            request.setAttribute("categories", dao.fetchAdminCategoryList());
            request.setAttribute("parentOptions", dao.fetchParentOptionsExcluding(id));

            request.getRequestDispatcher("/admin/admin-edit-category.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        request.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        CategoryDAO dao = new CategoryDAO();

        if ("/admin/categories".equals(path)) {
            String action = request.getParameter("action"); // add | delete

            if ("add".equalsIgnoreCase(action)) {
                String name = trimOrNull(request.getParameter("name"));
                String slugInput = trimOrNull(request.getParameter("slug"));
                Integer parentId = parseIntOrNull(request.getParameter("parent_id"));
                String isActiveStr = request.getParameter("is_active");

                if (name == null) {
                    request.setAttribute("error", "Vui lòng nhập tên danh mục.");
                    request.setAttribute("inputName", request.getParameter("name"));
                    request.setAttribute("inputSlug", request.getParameter("slug"));
                    request.setAttribute("inputParentId", parentId);
                    request.setAttribute("inputIsActive", isActiveStr);

                    request.setAttribute("categories", dao.fetchAdminCategoryList());
                    request.getRequestDispatcher("/admin/admin-categories.jsp").forward(request, response);
                    return;
                }

                String finalSlug = (slugInput == null) ? slugify(name) : slugify(slugInput);
                finalSlug = ensureUniqueSlug(dao, finalSlug, null);

                if (parentId != null && parentId <= 0) parentId = null;

                Category c = new Category();
                c.setName(name);
                c.setSlug(finalSlug);
                c.setParentId(parentId);
                c.setIsActive("true".equals(isActiveStr));

                dao.create(c);
                response.sendRedirect(request.getContextPath() + "/admin/categories?msg=added");
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"));
                if (id > 0) dao.removeById(id);
                response.sendRedirect(request.getContextPath() + "/admin/categories?msg=deleted");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        if ("/admin/categories/edit".equals(path)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/categories");
                return;
            }

            Category old = dao.fetchById(id);
            if (old == null) {
                response.sendError(404);
                return;
            }

            String name = trimOrNull(request.getParameter("name"));
            String slugInput = trimOrNull(request.getParameter("slug"));
            Integer parentId = parseIntOrNull(request.getParameter("parent_id"));
            String isActiveStr = request.getParameter("is_active");

            if (name == null) {
                request.setAttribute("error", "Vui lòng nhập tên danh mục.");
                request.setAttribute("category", old);
                request.setAttribute("categories", dao.fetchAdminCategoryList());
                request.setAttribute("parentOptions", dao.fetchParentOptionsExcluding(id));
                request.getRequestDispatcher("/admin/admin-edit-category.jsp").forward(request, response);
                return;
            }

            if (parentId != null && parentId <= 0) parentId = null;
            if (parentId != null && parentId == id) parentId = null;

            String finalSlug = (slugInput == null) ? slugify(name) : slugify(slugInput);
            finalSlug = ensureUniqueSlug(dao, finalSlug, id);

            Category updated = new Category();
            updated.setId(id);
            updated.setName(name);
            updated.setSlug(finalSlug);
            updated.setParentId(parentId);
            updated.setIsActive("true".equals(isActiveStr));

            dao.update(updated);
            response.sendRedirect(request.getContextPath() + "/admin/categories?msg=updated");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); }
        catch (Exception e) { return -1; }
    }

    private Integer parseIntOrNull(String s) {
        try {
            if (s == null) return null;
            s = s.trim();
            if (s.isEmpty()) return null;
            return Integer.parseInt(s);
        } catch (Exception e) {
            return null;
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String ensureUniqueSlug(CategoryDAO dao, String base, Integer excludeId) {
        if (base == null || base.isEmpty()) base = "category";
        String candidate = base;
        int i = 2;

        while (excludeId == null
                ? dao.existsSlug(candidate)
                : dao.existsSlugExceptId(candidate, excludeId)) {
            candidate = base + "-" + (i++);
        }
        return candidate;
    }

    private String slugify(String input) {
        if (input == null) return "";
        String s = input.trim().toLowerCase();
        s = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        s = s.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        s = s.replace("đ", "d");
        s = s.replaceAll("[^a-z0-9]+", "-");
        s = s.replaceAll("(^-+|-+$)", "");
        return s;
    }

    private User requireAdminOrEditor(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !(session.getAttribute("user") instanceof User)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        User u = (User) session.getAttribute("user");
        if (u.getRole() == null || !(u.getRole() == UserRole.ADMIN)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return u;
    }
}
