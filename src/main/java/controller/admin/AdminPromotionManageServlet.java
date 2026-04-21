package controller.admin;

import dao.PromotionDAO;
import dao.VipVoucherDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.enums.DiscountType;
import model.promotion.Promotion;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "AdminPromotionManageServlet", urlPatterns = {"/admin/promotions", "/admin/vouchers"})
public class AdminPromotionManageServlet extends HttpServlet {

    private PromotionDAO promotionDAO;
    private VipVoucherDAO vipVoucherDAO;

    @Override
    public void init() {
        promotionDAO = new PromotionDAO();
        vipVoucherDAO = new VipVoucherDAO();
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

                case "createVoucher":
                    handleCreateVoucher(request);
                    break;

                case "updateVoucher":
                    handleUpdateVoucher(request);
                    break;

                case "deleteVoucher":
                    handleDeleteVoucher(request);
                    break;

                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(redirectPath);
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
            String name = request.getParameter("name");
            String description = request.getParameter("description");
            String discountTypeStr = request.getParameter("discountType");
            String discountValueStr = request.getParameter("discountValue");
            String promotionType = request.getParameter("promotionType");
            String startDateStr = request.getParameter("startDate");
            String endDateStr = request.getParameter("endDate");
            String imageUrl = request.getParameter("imageUrl");

            if (name == null || name.trim().isEmpty())
                return null;
            if (discountTypeStr == null || discountTypeStr.trim().isEmpty())
                return null;
            if (discountValueStr == null || discountValueStr.trim().isEmpty()) return null;
            if (startDateStr == null || startDateStr.trim().isEmpty())
                return null;
            if (endDateStr == null || endDateStr.trim().isEmpty()) return null;
            Promotion p = new Promotion();

            if (isUpdate) {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.trim().isEmpty()) return null;
                p.setId(Integer.parseInt(idStr));
            }

            p.setName(name.trim());
            p.setDescription(description);
            p.setDiscountType(DiscountType.valueOf(discountTypeStr.trim().toUpperCase()));
            p.setDiscountValue(Double.parseDouble(discountValueStr));
            p.setPromotionType(promotionType != null && !promotionType.trim().isEmpty() ? promotionType.trim().toUpperCase() : "ALL");
            p.setStartDate(LocalDateTime.parse(startDateStr));
            p.setEndDate(LocalDateTime.parse(endDateStr));
            p.setImageUrl(imageUrl);
            p.setActive(true);

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
            if (discountType == null || discountType.trim().isEmpty())
                return;
            if (discountValueStr == null || discountValueStr.trim().isEmpty())
                return;
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
}