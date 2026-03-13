package controller.admin;

import dao.PromotionDAO;
import model.Promotion;
import model.enums.DiscountType;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import jakarta.servlet.annotation.MultipartConfig;
import java.util.List;
import java.io.File;
import jakarta.servlet.http.Part;
import java.nio.file.Paths;


@WebServlet(name = "AdminPromotionManageServlet", urlPatterns = {"/admin/promotions"})
@MultipartConfig( // Cấu hình để nhận file
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminPromotionManageServlet extends HttpServlet {

    private PromotionDAO promotionDAO;

    @Override
    public void init() {
        promotionDAO = new PromotionDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Promotion> list = promotionDAO.getAllPromotions();
        request.setAttribute("promotionList", list);
        request.getRequestDispatcher("/admin/admin-promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createPromotion(request, response);
        } else if ("update".equals(action)) {
            updatePromotion(request, response);
        } else if ("toggle".equals(action)) {
            toggleStatus(request, response);
        } else {
            response.sendRedirect("promotions");
        }
    }
    private void updatePromotion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String desc = request.getParameter("description");
            String type = request.getParameter("discount_type");
            double value = Double.parseDouble(request.getParameter("discount_value"));
            String startStr = request.getParameter("start_date");
            String endStr = request.getParameter("end_date");

            String currentImage = request.getParameter("current_image");
            String newImageUrl = currentImage;

            Part filePart = request.getPart("image");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                fileName = "promo_" + System.currentTimeMillis() + "_" + fileName;

                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                filePart.write(uploadDir + File.separator + fileName);
                newImageUrl = "assets/images/" + fileName;
            }
            // ------------------------------------

            Promotion p = new Promotion();
            p.setId(id);
            p.setName(name);
            p.setDescription(desc);
            p.setDiscountType(DiscountType.valueOf(type));
            p.setDiscountValue(value);
            p.setStartDate(LocalDateTime.parse(startStr));
            p.setEndDate(LocalDateTime.parse(endStr));
            p.setImageUrl(newImageUrl);

            promotionDAO.updatePromotion(p);
            response.sendRedirect("promotions?msg=update_success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("promotions?msg=error");
        }
    }
    private void createPromotion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String name = request.getParameter("name");
            String desc = request.getParameter("description");
            String type = request.getParameter("discount_type");
            double value = Double.parseDouble(request.getParameter("discount_value"));
            String startStr = request.getParameter("start_date");
            String endStr = request.getParameter("end_date");

            // --- XỬ LÝ ẢNH ---
            String imageUrl = "assets/images/default-promo.jpg";
            Part filePart = request.getPart("image");

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                fileName = "promo_" + System.currentTimeMillis() + "_" + fileName;

                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                filePart.write(uploadDir + File.separator + fileName);
                imageUrl = "assets/images/" + fileName;
            }
            Promotion p = new Promotion();
            p.setName(name);
            p.setDescription(desc);
            p.setDiscountType(DiscountType.valueOf(type));
            p.setDiscountValue(value);
            p.setStartDate(LocalDateTime.parse(startStr));
            p.setEndDate(LocalDateTime.parse(endStr));
            p.setImageUrl(imageUrl);
            p.setActive(false);

            promotionDAO.insertPromotion(p);
            response.sendRedirect("promotions?msg=success");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("promotions?msg=error");
        }
    }
    private void toggleStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean newStatus = Boolean.parseBoolean(request.getParameter("status"));

            promotionDAO.togglePromotionStatus(id, newStatus);
            response.setStatus(200);
        } catch (Exception e) {
            response.setStatus(500);
        }
    }
}