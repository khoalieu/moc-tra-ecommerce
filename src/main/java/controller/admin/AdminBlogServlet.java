package controller.admin;

import dao.BlogPostDAO;
import dao.BlogCategoryDAO;
import dao.DAOFactory;
import dao.UserDAO;
import model.blog.BlogPost;
import model.blog.BlogCategory;
import model.user.User;
import model.enums.BlogStatus;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/admin/blog")
public class AdminBlogServlet extends HttpServlet {
    private static final int PAGE_SIZE = 6;
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole().name())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        BlogPostDAO postDAO = DAOFactory.getInstance().getBlogPostDAO();
        BlogCategoryDAO catDAO = DAOFactory.getInstance().getBlogCategoryDAO();
        UserDAO userDAO = DAOFactory.getInstance().getUserDAO();

        String categoryParam = request.getParameter("category");
        String statusParam = request.getParameter("status");
        String authorParam = request.getParameter("author");
        String sortParam = request.getParameter("sort");
        String pageParam = request.getParameter("page");

        String q = request.getParameter("q");
        if (q != null) q = q.trim();
        if (q != null && q.isEmpty()) q = null;


        Integer categoryId = null;
        if (categoryParam != null && !categoryParam.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryParam);
            } catch (Exception e) {}
        }

        BlogStatus status = null;
        if (statusParam != null && !statusParam.isEmpty()) {
            try {
                status = BlogStatus.valueOf(statusParam.toUpperCase());
            } catch (Exception e) {}
        }

        Integer authorId = null;
        if (authorParam != null && !authorParam.isEmpty()) {
            try {
                authorId = Integer.parseInt(authorParam);
            } catch (Exception e) {}
        }

        int page = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (Exception e) {}
        }
        int totalPosts = postDAO.countPostsForAdmin(q, categoryId, status, authorId);
        int totalPages = (int) Math.ceil((double) totalPosts / PAGE_SIZE);

        if (totalPages > 0 && page > totalPages) {
            page = totalPages;
        }

        List<BlogPost> posts = postDAO.getPostsForAdmin(q, categoryId, status, authorId, sortParam, page, PAGE_SIZE);

        Map<Integer, String> categoryMap = new HashMap<>();
        List<BlogCategory> allCategories = catDAO.getAllCategories();
        for (BlogCategory c : allCategories) {
            categoryMap.put(c.getId(), c.getName());
        }

        List<User> allAuthors = userDAO.getAllAdminUsers();
        int fromItem = 0, toItem = 0;
        if (totalPosts > 0) {
            fromItem = (page - 1) * PAGE_SIZE + 1;
            toItem = Math.min(page * PAGE_SIZE, totalPosts);
        }

        request.setAttribute("posts", posts);
        request.setAttribute("categoryMap", categoryMap);
        request.setAttribute("allCategories", allCategories);
        request.setAttribute("allAuthors", allAuthors);
        request.setAttribute("totalPosts", totalPosts);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentCategory", categoryId);
        request.setAttribute("currentStatus", statusParam);
        request.setAttribute("currentAuthor", authorId);

        request.setAttribute("currentQ", q);


        if (sortParam == null || sortParam.isEmpty()) sortParam = "date_desc";
        request.setAttribute("currentSort", sortParam);

        request.setAttribute("fromItem", fromItem);
        request.setAttribute("toItem", toItem);

        request.getRequestDispatcher("/admin/admin-blog.jsp").forward(request, response);
    }
}

