package controller.admin;

import dao.DAOFactory;
import dao.PromotionDAO;
import dao.VipVoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.enums.DiscountType;
import model.promotion.Promotion;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "AdminPromotionManageServlet", urlPatterns = {"/admin/promotions", "/admin/vouchers"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2L * 1024 * 1024,
        maxRequestSize = 5L * 1024 * 1024
)
public class AdminPromotionManageServlet extends HttpServlet {

    private PromotionDAO promotionDAO;
    private VipVoucherDAO vipVoucherDAO;

    @Override
    public void init() {
        promotionDAO = DAOFactory.getInstance().getPromotionDAO();
        vipVoucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        List<Promotion> promotionList = promotionDAO.getAllPromotions();
        request.setAttribute("promotionList", promotionList);

        request.setAttribute("voucherList", vipVoucherDAO.getAllVouchers());

        request.getRequestDispatcher("/admin/admin-promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String redirectPath = request.getContextPath() + "/admin/promotions";
        boolean keepVoucherTab = false;
        try {
            if (action == null || action.trim().isEmpty()) {
                response.sendRedirect(redirectPath);
                return;
            }
            switch (action) {
                case "createPromotion":
                    handleCreatePromotion(request);
                    break;
                case "updatePromotion":
                    handleUpdatePromotion(request);
                    break;
                case "togglePromotion":
                    handleTogglePromotion(request);
                    break;
                case "deletePromotion":
                    handleDeletePromotion(request);
                    break;

                case "createVoucher":
                    handleCreateVoucher(request);
                    keepVoucherTab = true;
                    break;
                case "updateVoucher":
                    handleUpdateVoucher(request);
                    keepVoucherTab = true;
                    break;
                case "deleteVoucher":
                    handleDeleteVoucher(request);
                    keepVoucherTab = true;
                    break;

                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (keepVoucherTab) {
            response.sendRedirect(redirectPath + "?tab=voucher");
        } else {
            response.sendRedirect(redirectPath + "?tab=promotion");
        }
    }

    private void handleCreatePromotion(HttpServletRequest request) {
        Promotion promotion = buildPromotionFromRequest(request, false);
        if (promotion != null) {
            promotionDAO.insertPromotion(promotion);
        }
    }

    private void handleUpdatePromotion(HttpServletRequest request) {
        Promotion promotion = buildPromotionFromRequest(request, true);
        if (promotion != null) {
            promotionDAO.updatePromotion(promotion);
        }
    }

    private void handleTogglePromotion(HttpServletRequest request) {
        String idStr = request.getParameter("id");
        String activeStr = request.getParameter("active");

        if (idStr == null || activeStr == null) return;
        try {
            int promoId = Integer.parseInt(idStr);
            boolean newStatus = Boolean.parseBoolean(activeStr);
            promotionDAO.togglePromotionStatus(promoId, newStatus);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Promotion buildPromotionFromRequest(HttpServletRequest request, boolean isUpdate) {
        try {
            String name = trimOrNull(request.getParameter("name"));
            String description = trimOrNull(request.getParameter("description"));
            String discountTypeStr = trimOrNull(request.getParameter("discountType"));
            String discountValueStr = trimOrNull(request.getParameter("discountValue"));
            String startDateStr = trimOrNull(request.getParameter("startDate"));
            String endDateStr = trimOrNull(request.getParameter("endDate"));

            if (name == null || discountTypeStr == null || discountValueStr == null ||
                    startDateStr == null || endDateStr == null) {
                return null;
            }
            Promotion p = new Promotion();

            if (isUpdate) {
                String idStr = trimOrNull(request.getParameter("id"));
                if (idStr == null) return null;
                p.setId(Integer.parseInt(idStr));
            }
            p.setName(name);
            p.setDescription(description);
            p.setDiscountType(DiscountType.valueOf(discountTypeStr.toUpperCase()));
            p.setDiscountValue(Double.parseDouble(discountValueStr));

            p.setPromotionType("ALL");

            p.setStartDate(LocalDateTime.parse(startDateStr));
            p.setEndDate(LocalDateTime.parse(endDateStr));
            p.setActive(true);

            String oldImage = trimOrNull(request.getParameter("oldImageUrl"));
            String uploadedPath = savePromotionImage(request.getPart("image"), !isUpdate);

            if (uploadedPath != null) {
                p.setImageUrl(uploadedPath);
            } else {
                p.setImageUrl(oldImage);
            }

            return p;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private void handleCreateVoucher(HttpServletRequest request) {
        try {
            String code = request.getParameter("code");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String maxUsesStr = request.getParameter("maxUses");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");

            if (code == null || code.trim().isEmpty()) return;
            if (discountType == null || discountType.trim().isEmpty()) return;
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) return;
            if (startDateStr == null || startDateStr.trim().isEmpty()) return;
            if (endDateStr == null || endDateStr.trim().isEmpty()) return;

            double discountValue = Double.parseDouble(discountValueStr);
            Integer maxUses = null;
            if (maxUsesStr != null && !maxUsesStr.trim().isEmpty()) {
                maxUses = Integer.parseInt(maxUsesStr.trim());
            }

            LocalDateTime startDate = LocalDateTime.parse(startDateStr);
            LocalDateTime endDate = LocalDateTime.parse(endDateStr);

            vipVoucherDAO.insertVoucher(code.trim(), discountType.trim().toUpperCase(), discountValue, maxUses, startDate, endDate);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handleUpdateVoucher(HttpServletRequest request) {
        try {
            String idStr = request.getParameter("id");
            String code = request.getParameter("code");
            String discountType = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String maxUsesStr = request.getParameter("maxUses");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String activeStr = request.getParameter("active");

            if (idStr == null || idStr.trim().isEmpty()) return;
            if (code == null || code.trim().isEmpty()) return;
            if (discountType == null || discountType.trim().isEmpty()) return;
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) return;
            if (startDateStr == null || startDateStr.trim().isEmpty()) return;
            if (endDateStr == null || endDateStr.trim().isEmpty()) return;

            int id = Integer.parseInt(idStr);
            double discountValue = Double.parseDouble(discountValueStr);

            Integer maxUses = null;
            if (maxUsesStr != null && !maxUsesStr.trim().isEmpty()) {
                maxUses = Integer.parseInt(maxUsesStr.trim());
            }

            LocalDateTime startDate = LocalDateTime.parse(startDateStr);
            LocalDateTime endDate = LocalDateTime.parse(endDateStr);
            boolean isActive = activeStr != null && (
                    "true".equalsIgnoreCase(activeStr)
                            || "1".equals(activeStr)
                            || "on".equalsIgnoreCase(activeStr)
            );

            vipVoucherDAO.updateVoucher(id, code.trim(), discountType.trim().toUpperCase(), discountValue, maxUses, startDate, endDate, isActive);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handleDeleteVoucher(HttpServletRequest request) {
        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) return;
            int voucherId = Integer.parseInt(idStr);
            vipVoucherDAO.deleteVoucher(voucherId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String savePromotionImage(Part part, boolean required) {
        try {
            if (part == null || part.getSize() == 0) {
                if (required) {
                    throw new IllegalArgumentException("vuii lòng chọn ảnh");
                }
                return null;
            }

            String relDir = "assets/images";
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
            throw new IllegalArgumentException("Upload ảnh khuyến mãi lỗi.");
        }
    }
    private void handleDeletePromotion(HttpServletRequest request) {
        try {
            String idStr = request.getParameter("id");
            if (idStr == null || idStr.trim().isEmpty()) return;

            int promoId = Integer.parseInt(idStr);
            promotionDAO.deletePromotion(promoId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}