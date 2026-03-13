package controller.admin;

import dao.BannerDAO;
import dao.CategoryDAO;
import dao.PromotionDAO;
import model.Banner;
import model.Promotion;
import model.User;
import model.enums.UserRole;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(urlPatterns = {
        "/admin/banner",
        "/admin/banner/add",
        "/admin/banner/edit",
        "/admin/banner/save",
        "/admin/banner/delete",
        "/admin/banner/change-status"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5L * 1024 * 1024,
        maxRequestSize = 10L * 1024 * 1024
)
public class AdminBannerServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        String path = request.getServletPath();
        switch (path) {
            case "/admin/banner":
                showList(request, response);
                return;
            case "/admin/banner/add":
                showForm(request, response, "add");
                return;
            case "/admin/banner/edit":
                showForm(request, response, "edit");
                return;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/banner");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User me = requireAdminOrEditor(request, response);
        if (me == null) return;

        request.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        switch (path) {
            case "/admin/banner/save":
                save(request, response);
                return;
            case "/admin/banner/delete":
                delete(request, response);
                return;
            case "/admin/banner/change-status":
                changeStatus(request, response);
                return;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/banner");
        }
    }

    private void showList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BannerDAO dao = new BannerDAO();
        request.setAttribute("banners", dao.getAll());
        request.getRequestDispatcher("/admin/admin-banner-list.jsp").forward(request, response);
    }

    private void showForm(HttpServletRequest request, HttpServletResponse response, String mode) throws ServletException, IOException {
        loadTargets(request);

        if ("edit".equals(mode)) {
            int id = parseInt(request.getParameter("id"), -1);
            if (id <= 0) {
                response.sendRedirect(request.getContextPath() + "/admin/banner");
                return;
            }
            Banner b = new BannerDAO().getById(id);
            if (b == null) {
                response.sendRedirect(request.getContextPath() + "/admin/banner");
                return;
            }
            request.setAttribute("banner", b);
        }

        request.setAttribute("mode", mode);
        request.getRequestDispatcher("/admin/admin-banners.jsp").forward(request, response);
    }

    private void save(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String mode = nvl(request.getParameter("mode"));
        int id = parseInt(request.getParameter("id"), -1);

        Map<String, String> errors = new HashMap<>();

        String title = trim(request.getParameter("title"));
        String subtitle = trim(request.getParameter("subtitle"));
        String buttonText = trim(request.getParameter("button_text"));
        String buttonLink = trim(request.getParameter("button_link"));

        String section = "home";
        if (section == null || section.isBlank()) section = "home";

        boolean isActive = "1".equals(request.getParameter("is_active"));

        Integer sortOrder = null;
        String sortStr = trim(request.getParameter("sort_order"));
        if (sortStr != null && !sortStr.isBlank()) {
            try { sortOrder = Integer.parseInt(sortStr); }
            catch (Exception e) { errors.put("sort_order", "Thứ tự không hợp lệ"); }
        }

        if (title == null || title.isBlank()) errors.put("title", "Vui lòng nhập tiêu đề");
        Part imagePart = null;
        try { imagePart = request.getPart("image_url"); } catch (Exception ignored) {}

        String imageUrlOld = trim(request.getParameter("old_image_url"));
        boolean hasNewImage = (imagePart != null && imagePart.getSize() > 0);

        String imageUrl = imageUrlOld;
        if ("add".equals(mode) && !hasNewImage) {
            errors.put("image_url", "Vui lòng chọn ảnh banner");
        }
        if (hasNewImage) {
            String saved = saveBannerImage(imagePart);
            if (saved == null) errors.put("image_url", "Upload ảnh thất bại");
            else imageUrl = saved;
        }

        if (!errors.isEmpty()) {
            loadTargets(request);

            Banner b = new Banner();
            if ("edit".equals(mode)) b.setId(id);
            b.setTitle(title);
            b.setSubtitle(subtitle);
            b.setButtonText(buttonText);
            b.setButtonLink(buttonLink);
            b.setSection(section);
            b.setSortOrder(sortOrder);
            b.setIsActive(isActive);
            b.setImageUrl(imageUrl);

            request.setAttribute("mode", mode);
            request.setAttribute("banner", b);
            request.setAttribute("errors", errors);
            request.getRequestDispatcher("/admin/admin-banners.jsp").forward(request, response);
            return;
        }

        Banner b = new Banner();
        if ("edit".equals(mode)) b.setId(id);
        b.setTitle(title);
        b.setSubtitle(subtitle);
        b.setImageUrl(imageUrl);
        b.setButtonText(buttonText);
        b.setButtonLink(buttonLink);
        b.setSection(section);
        b.setSortOrder(sortOrder);
        b.setIsActive(isActive);

        BannerDAO dao = new BannerDAO();
        try {
            if ("edit".equals(mode)) dao.update(b);
            else dao.insert(b);

            request.getSession().setAttribute("successMsg", "Lưu banner thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lưu banner thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/banner");
    }

    private void delete(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] idsStr = request.getParameterValues("ids");
        if (idsStr == null || idsStr.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/banner");
            return;
        }

        int[] ids = parseIds(idsStr);
        if (ids.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/banner");
            return;
        }

        try {
            new BannerDAO().deleteByIds(ids);
            request.getSession().setAttribute("successMsg", "Đã xóa banner!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Xóa banner thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/banner");
    }

    private void changeStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String[] idsStr = request.getParameterValues("ids");
        if (idsStr == null || idsStr.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/banner");
            return;
        }
        int[] ids = parseIds(idsStr);
        if (ids.length == 0) {
            response.sendRedirect(request.getContextPath() + "/admin/banner");
            return;
        }

        boolean isActive = "1".equals(request.getParameter("is_active"));

        try {
            new BannerDAO().updateActiveByIds(ids, isActive);
            request.getSession().setAttribute("successMsg", isActive ? "Đã bật hiển thị banner!" : "Đã ẩn banner!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Đổi trạng thái thất bại!");
        }

        response.sendRedirect(request.getContextPath() + "/admin/banner");
    }

    private void loadTargets(HttpServletRequest request) {
        CategoryDAO catDao = new CategoryDAO();
        request.setAttribute("categoryMap", catDao.getActiveCategories());

        PromotionDAO promoDao = new PromotionDAO();
        List<Promotion> promos = promoDao.getActivePromotions();
        request.setAttribute("promotions", promos);
    }

    private String saveBannerImage(Part part) {
        try {
            if (part == null || part.getSize() == 0) return null;

            String relDir = "assets/images/banners";
            String absDir = getServletContext().getRealPath("/" + relDir);
            Files.createDirectories(Paths.get(absDir));

            String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
            String ext = "";
            int dot = submitted.lastIndexOf('.');
            if (dot >= 0) ext = submitted.substring(dot);

            String fileName = System.currentTimeMillis() + "_" + Math.abs(new Random().nextInt()) + ext;
            Path target = Paths.get(absDir, fileName);

            try (java.io.InputStream in = part.getInputStream()) {
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
            }

            return relDir + "/" + fileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private int[] parseIds(String[] idsStr) {
        List<Integer> list = new ArrayList<>();
        for (String s : idsStr) {
            int v = parseInt(s, -1);
            if (v > 0) list.add(v);
        }
        int[] ids = new int[list.size()];
        for (int i = 0; i < list.size(); i++) ids[i] = list.get(i);
        return ids;
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

    private static int parseInt(String s, int def) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }

    private static String nvl(String s) {
        return s == null ? "" : s;
    }
}
