package controller.admin;

import dao.*;
import model.blog.BlogPost;
import model.user.User;
import model.enums.BlogStatus;
import model.enums.UserRole;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(urlPatterns = {
        "/admin/blog/add",
        "/admin/blog/edit",
        "/admin/blog/delete",
        "/admin/blog/status-update",
        "/admin/blog/change-status"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2L * 1024 * 1024,
        maxRequestSize = 5L * 1024 * 1024
)
public class AdminBlogManageServlet extends HttpServlet {

    private static final DateTimeFormatter DT_LOCAL =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        String path = request.getServletPath();

        if ("/admin/blog/add".equals(path)) {
            doGetAdd(request, response);
            return;
        }

        if ("/admin/blog/edit".equals(path)) {
            doGetEdit(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/blog");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        request.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();

        switch (path) {
            case "/admin/blog/add":
                doPostAdd(request, response, me);
                return;
            case "/admin/blog/edit":
                doPostEdit(request, response, me);
                return;
            case "/admin/blog/delete":
                doPostDelete(request, response);
                return;
            case "/admin/blog/status-update":
            case "/admin/blog/change-status":
                doPostStatusUpdate(request, response);
                return;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/blog");
        }
    }

    private void doGetAdd(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        BlogCategoryDAO catDAO = DAOFactory.getInstance().getBlogCategoryDAO();
        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();

        request.setAttribute("allCategories", catDAO.getAllCategories());
        request.setAttribute("allAuthors", userDAO.getAllAdminUsers());

        request.getRequestDispatcher("/admin/admin-blog-add.jsp").forward(request, response);
    }

    private void doPostAdd(HttpServletRequest request, HttpServletResponse response, User me)
            throws ServletException, IOException {

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();

        String title   = trimOrNull(request.getParameter("title"));
        String slugInp = trimOrNull(request.getParameter("slug"));
        String excerpt = trimOrNull(request.getParameter("excerpt"));
        String content = trimOrNull(request.getParameter("content"));

        String statusStr   = request.getParameter("status");
        String categoryStr = request.getParameter("category_id");
        String authorStr   = request.getParameter("author_id");
        String metaTitle   = trimOrNull(request.getParameter("meta_title"));
        String metaDesc    = trimOrNull(request.getParameter("meta_description"));
        String createdAtStr = request.getParameter("created_at");

        if (title == null)   { request.setAttribute("error", "Vui lòng nhập Tiêu đề.");   doGetAdd(request,response); return; }
        if (excerpt == null) { request.setAttribute("error", "Vui lòng nhập Excerpt.");   doGetAdd(request,response); return; }
        if (content == null) { request.setAttribute("error", "Vui lòng nhập Nội dung.");  doGetAdd(request,response); return; }
        if (statusStr == null || statusStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Trạng thái."); doGetAdd(request,response); return;
        }
        if (categoryStr == null || categoryStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Danh mục."); doGetAdd(request,response); return;
        }

        BlogStatus st;
        try { st = BlogStatus.valueOf(statusStr.toUpperCase()); }
        catch (Exception e) { request.setAttribute("error", "Trạng thái không hợp lệ."); doGetAdd(request,response); return; }

        Integer categoryId;
        try { categoryId = Integer.parseInt(categoryStr); }
        catch (Exception e) { request.setAttribute("error", "Danh mục không hợp lệ."); doGetAdd(request,response); return; }

        Integer authorId = null;
        try { if (authorStr != null && !authorStr.isEmpty()) authorId = Integer.parseInt(authorStr); }
        catch (Exception ignored) {}
        if (authorId == null) authorId = me.getId(); // default theo người đang login

        LocalDateTime createdAt = null;
        if (createdAtStr != null && !createdAtStr.trim().isEmpty()) {
            try {
                createdAt = LocalDateTime.parse(createdAtStr, DT_LOCAL);
                if (createdAt.isAfter(LocalDateTime.now())) {
                    request.setAttribute("error", "Ngày xuất bản phải <= hiện tại.");
                    doGetAdd(request, response);
                    return;
                }
            } catch (Exception e) {
                request.setAttribute("error", "Ngày xuất bản không hợp lệ.");
                doGetAdd(request, response);
                return;
            }
        }

        String rawForSlug = (slugInp == null) ? title : slugInp;
        String finalSlug = ensureUniqueSlug(postDAO, rawForSlug, null);

        String uploadedPath;
        try {
            Part imgPart = request.getPart("featured_image");
            uploadedPath = saveBlogImage(imgPart, true);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("error", ex.getMessage());
            doGetAdd(request, response);
            return;
        }

        BlogPost p = new BlogPost();
        p.setTitle(title);
        p.setSlug(finalSlug);
        p.setExcerpt(excerpt);
        p.setContent(content);
        p.setAuthorId(authorId);
        p.setCategoryId(categoryId);
        p.setStatus(st);
        p.setMetaTitle(metaTitle);
        p.setMetaDescription(metaDesc);
        p.setFeaturedImage(uploadedPath);

        int newId = postDAO.insertForAdmin(p, createdAt);
        if (newId <= 0) {
            request.setAttribute("error", "Thêm bài viết thất bại.");
            doGetAdd(request, response);
            return;
        }

        boolean preview = "preview".equalsIgnoreCase(request.getParameter("action"));
        if (preview) response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + newId);
        else response.sendRedirect(request.getContextPath() + "/admin/blog");
    }

    private void doGetEdit(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = parseInt(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/admin/blog"); return; }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogPost post = postDAO.getByIdForAdmin(id);
        if (post == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        request.setAttribute("post", post);
        request.setAttribute("allCategories", DAOFactory.getInstance().getBlogCategoryDAO().getAllCategories());
        request.setAttribute("allAuthors", DAOFactory.getInstance().getUserDAO().getAllAdminUsers());

        request.getRequestDispatcher("/admin/admin-blog-edit.jsp").forward(request, response);
    }

    private void doPostEdit(HttpServletRequest request, HttpServletResponse response, User me)
            throws ServletException, IOException {

        int id = parseInt(request.getParameter("id"));
        if (id <= 0) { response.sendRedirect(request.getContextPath() + "/admin/blog"); return; }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogPost old = postDAO.getByIdForAdmin(id);
        if (old == null) { response.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        String title   = trimOrNull(request.getParameter("title"));
        String slugInp = trimOrNull(request.getParameter("slug"));
        String excerpt = trimOrNull(request.getParameter("excerpt"));
        String content = trimOrNull(request.getParameter("content"));

        String statusStr   = request.getParameter("status");
        String categoryStr = request.getParameter("category_id");
        String authorStr   = request.getParameter("author_id");
        String metaTitle   = trimOrNull(request.getParameter("meta_title"));
        String metaDesc    = trimOrNull(request.getParameter("meta_description"));

        if (title == null)   { request.setAttribute("error", "Vui lòng nhập Tiêu đề.");   doGetEdit(request,response); return; }
        if (excerpt == null) { request.setAttribute("error", "Vui lòng nhập Excerpt.");   doGetEdit(request,response); return; }
        if (content == null) { request.setAttribute("error", "Vui lòng nhập Nội dung.");  doGetEdit(request,response); return; }
        if (statusStr == null || statusStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Trạng thái."); doGetEdit(request,response); return;
        }
        if (categoryStr == null || categoryStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Danh mục."); doGetEdit(request,response); return;
        }

        BlogStatus st;
        try { st = BlogStatus.valueOf(statusStr.toUpperCase()); }
        catch (Exception e) { request.setAttribute("error", "Trạng thái không hợp lệ."); doGetEdit(request,response); return; }

        Integer categoryId;
        try { categoryId = Integer.parseInt(categoryStr); }
        catch (Exception e) { request.setAttribute("error", "Danh mục không hợp lệ."); doGetEdit(request,response); return; }

        Integer authorId = null;
        try { if (authorStr != null && !authorStr.isEmpty()) authorId = Integer.parseInt(authorStr); }
        catch (Exception ignored) {}
        if (authorId == null) authorId = old.getAuthorId();

        String rawForSlug = (slugInp == null) ? title : slugInp;
        String finalSlug = ensureUniqueSlug(postDAO, rawForSlug, id);

        String uploadedPath = null;
        try {
            Part imgPart = request.getPart("featured_image");
            uploadedPath = saveBlogImage(imgPart, false);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("error", ex.getMessage());
            doGetEdit(request, response);
            return;
        }

        boolean keepOldImage = (uploadedPath == null);
        String imagePath = keepOldImage ? old.getFeaturedImage() : uploadedPath;

        BlogPost updated = new BlogPost();
        updated.setId(id);
        updated.setTitle(title);
        updated.setSlug(finalSlug);
        updated.setExcerpt(excerpt);
        updated.setContent(content);
        updated.setAuthorId(authorId);
        updated.setCategoryId(categoryId);
        updated.setStatus(st);
        updated.setMetaTitle(metaTitle);
        updated.setMetaDescription(metaDesc);
        updated.setFeaturedImage(imagePath);

        boolean ok = postDAO.updateForAdmin(updated, keepOldImage);
        if (!ok) {
            request.setAttribute("error", "Cập nhật thất bại");
            doGetEdit(request, response);
            return;
        }

        boolean preview = "preview".equalsIgnoreCase(request.getParameter("action"));
        if (preview) response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + id);
        else response.sendRedirect(request.getContextPath() + "/admin/blog");
    }
    private void doPostDelete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        List<Integer> ids = new ArrayList<>();
        String[] idParams = request.getParameterValues("ids");
        if (idParams != null) {
            for (String s : idParams) {
                try { ids.add(Integer.parseInt(s.trim())); } catch (Exception ignored) {}
            }
        }

        boolean success = DAOFactory.getInstance().getBlogPostDAO().deleteByIds(ids);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/admin/blog?msg=deleted&count=" + ids.size());
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/blog");
        }
    }
    private void doPostStatusUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {

        String stStr = request.getParameter("newStatus");
        if (stStr == null || stStr.isEmpty()) stStr = request.getParameter("status");

        String[] idParams = request.getParameterValues("ids");
        List<Integer> ids = new ArrayList<>();
        if (idParams != null) {
            for (String s : idParams) {
                try { ids.add(Integer.parseInt(s.trim())); } catch (Exception ignored) {}
            }
        }

        BlogStatus newStatus = null;
        try { if (stStr != null) newStatus = BlogStatus.valueOf(stStr.toUpperCase()); }
        catch (Exception ignored) {}

        boolean success = DAOFactory.getInstance().getBlogPostDAO().updateStatusByIds(ids, newStatus);
        if (success) {
            response.sendRedirect(request.getContextPath()
                    + "/admin/blog?msg=status_updated&status=" + stStr + "&count=" + ids.size());
        } else {
            response.sendRedirect(request.getContextPath() + "/admin/blog");
        }
    }

    private int parseInt(String s) { try { return Integer.parseInt(s); } catch (Exception e) { return -1; } }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String ensureUniqueSlug(BlogPostDAO dao, String raw, Integer excludeId) {
        String base = slugify(raw);
        if (base.isEmpty()) base = "blog";

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

    private String saveBlogImage(Part part, boolean required) {
        try {
            if (part == null || part.getSize() == 0) {
                if (required) throw new IllegalArgumentException("Vui lòng chọn ảnh.");
                return null;
            }

            String relDir = "assets/images/blog";
            String absDir = getServletContext().getRealPath("/" + relDir);
            Files.createDirectories(Paths.get(absDir));

            String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dot = submitted.lastIndexOf('.');
            if (dot >= 0) ext = submitted.substring(dot);

            String fileName = System.currentTimeMillis() + ext;
            Path target = Paths.get(absDir, fileName);

            try (java.io.InputStream in = part.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            return relDir + "/" + fileName;
        } catch (Exception e) {
            throw new IllegalArgumentException("Upload ảnh lỗi.");
        }
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
