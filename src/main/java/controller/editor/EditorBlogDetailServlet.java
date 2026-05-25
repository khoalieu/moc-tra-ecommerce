package controller.editor;

import dao.*;
import model.blog.BlogCategory;
import model.blog.BlogComment;
import model.blog.BlogPost;
import model.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

@WebServlet("/editor/blog/detail")
public class EditorBlogDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
            return;
        }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogPost post = postDAO.getByIdForAdmin(id);
        User editor = (User) request.getSession().getAttribute("user");

        if (post == null) {
            response.sendRedirect(request.getContextPath() + "/errors/404.jsp");
            return;
        }

        if (!post.getAuthorId().equals(editor.getId())) {
            response.sendRedirect(request.getContextPath() + "/errors/403.jsp");
            return;
        }

        BlogCategory category = null;

        if (post.getCategoryId() != null) {
            category = DAOFactory.getInstance().getBlogCategoryDAO().getById(post.getCategoryId());
        }
        List<BlogComment> comments = DAOFactory.getInstance().getBlogCommentDAO().getByPostId(post.getId());
        Set<Integer> userIds = new HashSet<>();
        if (post.getAuthorId() != null) {
            userIds.add(post.getAuthorId());
        }

        for (BlogComment c : comments) {
            if (c.getUserId() != null) {
                userIds.add(c.getUserId());
            }
        }

        Map<Integer, User> userMap = DAOFactory.getInstance().getUserDAO().getMapByIds(userIds);
        if (post.getAuthorId() != null) {
            post.setAuthor(userMap.get(post.getAuthorId()));
        }

        request.setAttribute("post", post);
        request.setAttribute("category", category);
        request.setAttribute("comments", comments);
        request.setAttribute("commentsCount", comments.size());
        request.setAttribute("commentUserMap", userMap);
        request.getRequestDispatcher("/editor/editor-blog-detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = (User) request.getSession().getAttribute("user");
        String action = request.getParameter("action");
        int postId = parseInt(request.getParameter("postId"));
        if (postId <= 0) {
            response.sendRedirect(request.getContextPath() + "/editor/blog");
            return;
        }

        BlogPost post = DAOFactory.getInstance().getBlogPostDAO().getByIdForAdmin(postId);
        if (post == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (post.getAuthorId() == null || !post.getAuthorId().equals(user.getId())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        BlogCommentDAO dao = DAOFactory.getInstance().getBlogCommentDAO();

        if ("delete".equalsIgnoreCase(action)) {
            int commentId = parseInt(request.getParameter("commentId"));
            if (commentId > 0) {
                dao.deleteById(commentId);
            }
            response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + postId);
            return;
        }

        if ("reply".equalsIgnoreCase(action)) {
            int replyToId = parseInt(request.getParameter("commentId"));
            String text = trimOrEmpty(request.getParameter("text"));
            if (text.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + postId + "&err=empty");
                return;
            }
            String prefix = "";
            if (replyToId > 0) {
                BlogComment target = dao.getById(replyToId);
                if (target != null) {
                    User u = DAOFactory.getInstance().getUserDAO().getById(target.getUserId());
                    String name = (u == null) ? ("User " + target.getUserId()) : u.getDisplayName();
                    prefix = "Trả lời @" + name + ": ";
                }
            }
            dao.insert(postId, user.getId(), prefix + text);
            response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + postId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/editor/blog/detail?id=" + postId);
    }

    private int parseInt(String s) {
        try {
            return Integer.parseInt(s);
        } catch (Exception e) {
            return -1;
        }
    }

    private String trimOrEmpty(String s) {
        return (s == null) ? "" : s.trim();
    }
}