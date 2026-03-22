
package controller.admin;

import dao.*;
import model.blog.BlogCategory;
import model.blog.BlogComment;
import model.blog.BlogPost;
import model.enums.UserRole;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.user.User;

import java.io.IOException;
import java.util.*;

@WebServlet("/admin/blog/detail")
public class AdminBlogDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        int id;
        try { id = Integer.parseInt(request.getParameter("id")); }
        catch (Exception e) { response.sendRedirect(request.getContextPath() + "/admin/blog"); return; }

        BlogPostDAO postDAO = new BlogPostDAO();
        BlogPost post = postDAO.getByIdForAdmin(id);
        if (post == null) { response.sendError(404); return; }

        BlogCategory category = null;
        if (post.getCategoryId() != null) category = new BlogCategoryDAO().getById(post.getCategoryId());

        List<BlogComment> comments = new BlogCommentDAO().getByPostId(post.getId());

        Set<Integer> userIds = new HashSet<>();
        if (post.getAuthorId() != null) userIds.add(post.getAuthorId());
        for (BlogComment c : comments) if (c.getUserId() != null) userIds.add(c.getUserId());

        Map<Integer, User> userMap = new UserDAO().getMapByIds(userIds);
        if (post.getAuthorId() != null) post.setAuthor(userMap.get(post.getAuthorId()));

        request.setAttribute("post", post);
        request.setAttribute("category", category);
        request.setAttribute("comments", comments);
        request.setAttribute("commentsCount", comments.size());
        request.setAttribute("commentUserMap", userMap);

        request.getRequestDispatcher("/admin/admin-blog-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        int postId = parseInt(request.getParameter("postId"));

        if (postId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/blog");
            return;
        }

        BlogCommentDAO dao = new BlogCommentDAO();

        if ("delete".equalsIgnoreCase(action)) {
            int commentId = parseInt(request.getParameter("commentId"));
            if (commentId > 0) dao.deleteById(commentId);

            response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + postId);
            return;
        }

        if ("reply".equalsIgnoreCase(action)) {
            int replyToId = parseInt(request.getParameter("commentId"));
            String text = trimOrEmpty(request.getParameter("text"));
            if (text.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + postId + "&err=empty");
                return;
            }

            String prefix = "";
            if (replyToId > 0) {
                BlogComment target = dao.getById(replyToId);
                if (target != null) {
                    User u = new UserDAO().getById(target.getUserId());
                    String name = (u == null) ? ("User " + target.getUserId()) : u.getDisplayName();
                    prefix = "Trả lời @" + name + ": ";
                }
            }

            dao.insert(postId, me.getId(), prefix + text);
            response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + postId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/blog/detail?id=" + postId);
    }

    private int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return -1; }
    }

    private String trimOrEmpty(String s) { return (s == null) ? "" : s.trim(); }

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