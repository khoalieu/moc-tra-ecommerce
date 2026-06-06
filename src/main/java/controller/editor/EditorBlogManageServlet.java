package controller.editor;

import dao.*;
import model.blog.BlogPost;
import model.user.User;
import model.enums.BlogStatus;

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
        "/editor/blog/add",
        "/editor/blog/edit",
        "/editor/blog/delete",
        "/editor/blog/status-update",
        "/editor/blog/change-status"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2L * 1024 * 1024,
        maxRequestSize = 5L * 1024 * 1024
)
public class EditorBlogManageServlet extends HttpServlet {

    private static final DateTimeFormatter DT_LOCAL =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/editor/blog/add".equals(path)) {
            doGetAdd(request, response);
            return;
        }

        if ("/editor/blog/edit".equals(path)) {
            doGetEdit(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/editor/blog");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User me = (User) request.getSession().getAttribute("user");
        String path = request.getServletPath();

        switch (path) {
            case "/editor/blog/add":
                doPostAdd(request, response, me);
                return;
            case "/editor/blog/edit":
                doPostEdit(request, response, me);
                return;
            case "/editor/blog/delete":
                doPostDelete(request, response, me);
                return;
            case "/editor/blog/status-update":
            case "/editor/blog/change-status":
                doPostStatusUpdate(request, response, me);
                return;
            default:
                response.sendRedirect(request.getContextPath() + "/editor/blog");
        }
    }

    private void doGetAdd(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BlogCategoryDAO catDAO = DAOFactory.getInstance().getBlogCategoryDAO();
        request.setAttribute("allCategories", catDAO.getAllCategories());
        request.getRequestDispatcher("/editor/editor-blog-add.jsp").forward(request, response);
    }

    private void doPostAdd(HttpServletRequest request, HttpServletResponse response, User me) throws ServletException, IOException {
        if (!me.hasPermission("blog.create")) {
            response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
            return;
        }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        String title = trimOrNull(request.getParameter("title"));
        String slugInp = trimOrNull(request.getParameter("slug"));
        String excerpt = trimOrNull(request.getParameter("excerpt"));
        String content = trimOrNull(request.getParameter("content"));
        String statusStr = request.getParameter("status");
        String categoryStr = request.getParameter("category_id");
        String metaTitle = trimOrNull(request.getParameter("meta_title"));
        String metaDesc = trimOrNull(request.getParameter("meta_description"));
        String createdAtStr = request.getParameter("created_at");

        if (title == null) {
            request.setAttribute("error", "Vui lòng nhập Tiêu đề.");
            doGetAdd(request, response);
            return;
        }

        if (excerpt == null) {
            request.setAttribute("error", "Vui lòng nhập Excerpt.");
            doGetAdd(request, response);
            return;
        }

        if (content == null) {
            request.setAttribute("error", "Vui lòng nhập Nội dung.");
            doGetAdd(request, response);
            return;
        }

        if (statusStr == null || statusStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Trạng thái.");
            doGetAdd(request, response);
            return;
        }

        if (categoryStr == null || categoryStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Danh mục.");
            doGetAdd(request, response);
            return;
        }

        BlogStatus st;
        try {
            st = BlogStatus.valueOf(statusStr.toUpperCase());
        } catch (Exception e) {
            request.setAttribute("error", "Trạng thái không hợp lệ.");
            doGetAdd(request, response);
            return;
        }

        if (!me.hasPermission("blog.publish")) {
            if (st == BlogStatus.PUBLISHED || st == BlogStatus.ARCHIVED) {
                st = BlogStatus.DRAFT;
            }
        }

        Integer categoryId;
        try {
            categoryId = Integer.parseInt(categoryStr);
        } catch (Exception e) {
            request.setAttribute("error", "Danh mục không hợp lệ.");
            doGetAdd(request, response);
            return;
        }

        Integer authorId = me.getId();
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

        if (preview) {
            response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + newId);
        } else {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
        }
    }

    private void doGetEdit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
            return;
        }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogPost post = postDAO.getByIdForAdmin(id);
        User me = (User) request.getSession().getAttribute("user");
        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/errors/404.jsp");
            return;
        }

        // Ownership/permission check
        if (!me.hasPermission("blog.publish") && !me.hasPermission("blog.edit")) {
            if (me.hasPermission("blog.edit_own")) {
                if (post.getAuthorId() == null || !post.getAuthorId().equals(me.getId())) {
                    response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
                return;
            }
        }
        request.setAttribute("post", post);
        request.setAttribute("allCategories", DAOFactory.getInstance().getBlogCategoryDAO().getAllCategories());
        request.getRequestDispatcher("/editor/editor-blog-edit.jsp").forward(request, response);
    }

    private void doPostEdit(HttpServletRequest request, HttpServletResponse response, User me) throws ServletException, IOException {
        int id = parseInt(request.getParameter("id"));

        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
            return;
        }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogPost old = postDAO.getByIdForAdmin(id);

        if (old == null) {
            response.sendRedirect(request.getContextPath() + "/errors/404.jsp");
            return;
        }

        // Ownership/permission check
        if (!me.hasPermission("blog.publish") && !me.hasPermission("blog.edit")) {
            if (me.hasPermission("blog.edit_own")) {
                if (old.getAuthorId() == null || !old.getAuthorId().equals(me.getId())) {
                    response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
                    return;
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
                return;
            }
        }

        String title = trimOrNull(request.getParameter("title"));
        String slugInp = trimOrNull(request.getParameter("slug"));
        String excerpt = trimOrNull(request.getParameter("excerpt"));
        String content = trimOrNull(request.getParameter("content"));

        String statusStr = request.getParameter("status");
        String categoryStr = request.getParameter("category_id");
        String metaTitle = trimOrNull(request.getParameter("meta_title"));
        String metaDesc = trimOrNull(request.getParameter("meta_description"));

        if (title == null) {
            request.setAttribute("error", "Vui lòng nhập Tiêu đề.");
            doGetEdit(request, response);
            return;
        }

        if (excerpt == null) {
            request.setAttribute("error", "Vui lòng nhập Excerpt.");
            doGetEdit(request, response);
            return;
        }

        if (content == null) {
            request.setAttribute("error", "Vui lòng nhập Nội dung.");
            doGetEdit(request, response);
            return;
        }

        if (statusStr == null || statusStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Trạng thái.");
            doGetEdit(request, response);
            return;
        }

        if (categoryStr == null || categoryStr.isEmpty()) {
            request.setAttribute("error", "Vui lòng chọn Danh mục.");
            doGetEdit(request, response);
            return;
        }

        BlogStatus st;
        try {
            st = BlogStatus.valueOf(statusStr.toUpperCase());
        } catch (Exception e) {
            request.setAttribute("error", "Trạng thái không hợp lệ.");
            doGetEdit(request, response);
            return;
        }

        if (!me.hasPermission("blog.publish")) {
            if (st == BlogStatus.PUBLISHED || st == BlogStatus.ARCHIVED) {
                st = BlogStatus.DRAFT;
            }
        }

        Integer categoryId;
        try {
            categoryId = Integer.parseInt(categoryStr);
        } catch (Exception e) {
            request.setAttribute("error", "Danh mục không hợp lệ.");
            doGetEdit(request, response);
            return;
        }
        Integer authorId = me.getId();
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
            request.setAttribute("error", "Cập nhật thất bại.");
            doGetEdit(request, response);
            return;
        }

        boolean preview = "preview".equalsIgnoreCase(request.getParameter("action"));

        if (preview) {
            response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + id);
        } else {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
        }
    }

    private void doPostDelete(HttpServletRequest request, HttpServletResponse response, User me) throws IOException {
        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        String[] idParams = request.getParameterValues("ids");
        if (idParams == null || idParams.length == 0) {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
            return;
        }

        List<Integer> idsToHardDelete = new ArrayList<>();
        List<Integer> idsToArchive = new ArrayList<>();
        boolean hasUnauthorized = false;
        boolean hasPublishedOwnBlock = false;

        for (String s : idParams) {
            try {
                int id = Integer.parseInt(s.trim());
                BlogPost post = postDAO.getByIdForAdmin(id);
                if (post == null) continue;

                if (me.hasPermission("blog.delete_all")) {
                    if (post.getStatus() == BlogStatus.PUBLISHED) {
                        idsToArchive.add(id);
                    } else {
                        idsToHardDelete.add(id);
                    }
                } else if (me.hasPermission("blog.delete_own")) {
                    if (post.getAuthorId() != null && post.getAuthorId().equals(me.getId())) {
                        if (post.getStatus() == BlogStatus.DRAFT || post.getStatus() == BlogStatus.PENDING) {
                            idsToHardDelete.add(id);
                        } else if (post.getStatus() == BlogStatus.PUBLISHED) {
                            hasPublishedOwnBlock = true;
                        } else {
                            hasUnauthorized = true;
                        }
                    } else {
                        hasUnauthorized = true;
                    }
                } else {
                    hasUnauthorized = true;
                }
            } catch (Exception ignored) {}
        }

        if (hasPublishedOwnBlock) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Tác giả không được phép xóa bài viết đã xuất bản!");
            return;
        }

        if (hasUnauthorized) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác xóa này!");
            return;
        }

        boolean ok = true;
        if (!idsToHardDelete.isEmpty()) {
            ok = postDAO.deleteByIds(idsToHardDelete);
        }
        if (!idsToArchive.isEmpty()) {
            boolean archiveOk = postDAO.updateStatusByIds(idsToArchive, BlogStatus.ARCHIVED);
            ok = ok && archiveOk;
        }

        if (ok) {
            response.sendRedirect(request.getContextPath() + "/editor/blog?msg=deleted&count=" + (idsToHardDelete.size() + idsToArchive.size()));
        } else {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
        }
    }

    private void doPostStatusUpdate(HttpServletRequest request, HttpServletResponse response, User me) throws IOException {
        if (!me.hasPermission("blog.publish")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thay đổi trạng thái bài viết!");
            return;
        }

        String stStr = request.getParameter("newStatus");
        if (stStr == null || stStr.isEmpty()) {
            stStr = request.getParameter("status");
        }
        String[] idParams = request.getParameterValues("ids");
        List<Integer> ids = new ArrayList<>();
        if (idParams != null) {
            for (String s : idParams) {
                try {
                    ids.add(Integer.parseInt(s.trim()));
                } catch (Exception ignored) {}
            }
        }

        BlogStatus newStatus = null;
        try {
            if (stStr != null) {
                newStatus = BlogStatus.valueOf(stStr.toUpperCase());
            }
        } catch (Exception ignored) {}
        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        List<Integer> allowedIds = new ArrayList<>();
        for (Integer id : ids) {
            BlogPost post = postDAO.getByIdForAdmin(id);
            if (post != null && post.getAuthorId() != null && post.getAuthorId().equals(me.getId())) {
                allowedIds.add(id);
            }
        }
        boolean success = postDAO.updateStatusByIds(allowedIds, newStatus);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/editor/blog?msg=status_updated&status=" + stStr + "&count=" + ids.size());
        } else {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
        }
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1;
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String ensureUniqueSlug(BlogPostDAO dao, String raw, Integer excludeId) {
        String base = slugify(raw);
        if (base.isEmpty()) {
            base = "blog";
        }
        String candidate = base;
        int i = 2;
        while (excludeId == null ? dao.slugExists(candidate) : dao.slugExistsExceptId(candidate, excludeId)) {
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
                if (required) {
                    throw new IllegalArgumentException("Vui lòng chọn ảnh.");
                }
                return null;
            }

            String relDir = "assets/images/blog";
            String absDir = getServletContext().getRealPath("/" + relDir);
            Files.createDirectories(Paths.get(absDir));
            String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dot = submitted.lastIndexOf('.');
            if (dot >= 0) {
                ext = submitted.substring(dot);
            }
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
}