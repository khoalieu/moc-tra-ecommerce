package controller.blog;

import dao.BlogCategoryDAO;
import dao.BlogCommentDAO;
import dao.BlogPostDAO;
import model.blog.BlogCategory;
import model.blog.BlogComment;
import model.blog.BlogPost;
import model.user.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;
import dao.UserDAO;
@WebServlet("/chi-tiet-blog")
public class
BlogDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String slug = request.getParameter("slug");
        if (slug != null) slug = slug.trim();

        if (slug == null || slug.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/blog");
            return;
        }
        BlogPostDAO postDAO = new BlogPostDAO();
        BlogCategoryDAO catDAO = new BlogCategoryDAO();
        BlogCommentDAO commentDAO = new BlogCommentDAO();

        BlogPost post = postDAO.getPublishedBySlug(slug);
        if (post == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        HttpSession session = request.getSession();
        String lastViewedPost = (String) session.getAttribute("lastViewedPost");

        if (!slug.equals(lastViewedPost)) {
            postDAO.incrementViews(post.getId());
            if (post.getViewsCount() == null) post.setViewsCount(0);
            post.setViewsCount(post.getViewsCount() + 1);
            session.setAttribute("lastViewedPost", slug);
        } else {
            BlogPost refreshed = postDAO.getPublishedBySlug(slug);
            post.setViewsCount(refreshed.getViewsCount());
        }
        BlogCategory postCategory = null;
        if (post.getCategoryId() != null) {
            postCategory = catDAO.getById(post.getCategoryId());
        }
        request.setAttribute("activeCatSlug", postCategory != null ? postCategory.getSlug() : null);

        List<BlogCategory> categories = catDAO.getActiveCategories();
        Map<Integer, Integer> categoryCountMap = catDAO.getPublishedCountMap();

        List<BlogPost> recentPosts = postDAO.getRecentPublishedPosts(3);
        List<BlogComment> comments = commentDAO.getByPostId(post.getId());
        request.setAttribute("commentUserMap", new UserDAO().getUserMapByPostId(post.getId()));

        request.setAttribute("post", post);
        request.setAttribute("postCategory", postCategory);

        request.setAttribute("categories", categories);
        request.setAttribute("categoryCountMap", categoryCountMap);

        request.setAttribute("recentPosts", recentPosts);
        request.setAttribute("comments", comments);
        request.setAttribute("commentsCount", comments.size());

        request.getRequestDispatcher("/blog/chi-tiet-blog.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String slug = request.getParameter("slug");
        if (slug != null) slug = slug.trim();

        String commentText = request.getParameter("comment_text");
        if (commentText != null) commentText = commentText.trim();

        if (slug == null || slug.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/blog");
            return;
        }

        BlogPostDAO postDAO = new BlogPostDAO();
        BlogPost post = postDAO.getPublishedBySlug(slug);
        if (post == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Integer userId = resolveUserId(request.getSession(false));
        if (userId == null) {
            request.setAttribute("commentError", "Vui lòng đăng nhập để bình luận.");
            doGet(request, response);
            return;
        }

        if (commentText == null || commentText.isEmpty()) {
            request.setAttribute("commentError", "Nội dung bình luận không được để trống.");
            doGet(request, response);
            return;
        }

        if (commentText.length() > 1000) {
            request.setAttribute("commentError", "Bình luận quá dài (tối đa 1000 ký tự).");
            doGet(request, response);
            return;
        }

        BlogCommentDAO commentDAO = new BlogCommentDAO();
        boolean ok = commentDAO.insert(post.getId(), userId, commentText);

        if (!ok) {
            request.setAttribute("commentError", "Gửi bình luận thất bại. Vui lòng thử lại.");
            doGet(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/chi-tiet-blog?slug=" + slug + "#comments");
    }

    private Integer resolveUserId(HttpSession session) {
        if (session == null) return null;

        Object userObj = session.getAttribute("user");
        if (!(userObj instanceof User)) return null;

        User u = (User) userObj;
        return u.getId();
    }

}
