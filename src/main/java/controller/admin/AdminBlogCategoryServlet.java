package controller.admin;
import dao.BlogCategoryDAO;
import model.blog.BlogCategory;
import model.user.User;
import model.enums.UserRole;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(urlPatterns = {
        "/admin/blog-categories",
        "/admin/blog-categories/edit"
})
public class AdminBlogCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        String path = request.getServletPath();
        BlogCategoryDAO dao = new BlogCategoryDAO();

        if ("/admin/blog-categories".equals(path)) {
            request.setAttribute("categories", dao.getAllCategories());
            request.getRequestDispatcher("/admin/admin-blog-categories.jsp").forward(request, response);
            return;
        }

        if ("/admin/blog-categories/edit".equals(path)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/blog-categories");
                return;
            }

            BlogCategory category = dao.getCategoryById(id);
            if (category == null) {
                response.sendError(404);
                return;
            }

            request.setAttribute("category", category);
            request.setAttribute("categories", dao.getAllCategories());
            request.getRequestDispatcher("/admin/admin-edit-category-blog.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/blog-categories");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        request.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        BlogCategoryDAO dao = new BlogCategoryDAO();

        if ("/admin/blog-categories".equals(path)) {
            String action = request.getParameter("action");

            if ("add".equalsIgnoreCase(action)) {
                String name = trimOrNull(request.getParameter("name"));
                String slugInput = trimOrNull(request.getParameter("slug"));
                String description = trimOrNull(request.getParameter("description"));
                String isActiveStr = request.getParameter("is_active");

                if (name == null) {
                    request.setAttribute("error", "Vui lòng nhập tên danh mục.");
                    request.setAttribute("categories", dao.getAllCategories());
                    request.getRequestDispatcher("/admin/admin-blog-categories.jsp").forward(request, response);
                    return;
                }

                String finalSlug = (slugInput == null) ? slugify(name) : slugify(slugInput);
                finalSlug = ensureUniqueSlug(dao, finalSlug, null);

                BlogCategory c = new BlogCategory();
                c.setName(name);
                c.setSlug(finalSlug);
                c.setDescription(description);
                c.setIsActive("true".equals(isActiveStr));

                int ok = dao.insertCategory(c);
                response.sendRedirect(request.getContextPath() + "/admin/blog-categories?msg=added");
                return;
            }

            if ("delete".equalsIgnoreCase(action)) {
                int id = parseInt(request.getParameter("id"));
                if (id > 0) dao.deleteCategory(id);
                response.sendRedirect(request.getContextPath() + "/admin/blog-categories?msg=deleted");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/admin/blog-categories");
            return;
        }

        if ("/admin/blog-categories/edit".equals(path)) {
            int id = parseInt(request.getParameter("id"));
            if (id <= 0) { response.sendRedirect(request.getContextPath() + "/admin/blog-categories"); return; }

            BlogCategory old = dao.getCategoryById(id);
            if (old == null) { response.sendError(404); return; }

            String name = trimOrNull(request.getParameter("name"));
            String slugInput = trimOrNull(request.getParameter("slug"));
            String description = trimOrNull(request.getParameter("description"));
            String isActiveStr = request.getParameter("is_active");

            if (name == null) {
                request.setAttribute("error", "Vui lòng nhập tên danh mục.");
                request.setAttribute("category", old);
                request.setAttribute("categories", dao.getAllCategories());
                request.getRequestDispatcher("/admin/admin-edit-category-blog.jsp").forward(request, response);
                return;
            }

            String finalSlug = (slugInput == null) ? slugify(name) : slugify(slugInput);
            finalSlug = ensureUniqueSlug(dao, finalSlug, id);

            BlogCategory updated = new BlogCategory();
            updated.setId(id);
            updated.setName(name);
            updated.setSlug(finalSlug);
            updated.setDescription(description);
            updated.setIsActive("true".equals(isActiveStr));

            dao.updateCategory(updated);
            response.sendRedirect(request.getContextPath() + "/admin/blog-categories?msg=updated");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/blog-categories");
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1; }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String ensureUniqueSlug(BlogCategoryDAO dao, String base, Integer excludeId) {
        if (base == null || base.isEmpty()) base = "category";

        String candidate = base;
        int i = 2;

        while (excludeId == null
                ? dao.slugExists(candidate)
                : dao.slugExistsExceptId(candidate, excludeId)) {
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
        if (u.getRole() == null || !(u.getRole() == UserRole.ADMIN || u.getRole() == UserRole.EDITOR)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return u;
    }
}

