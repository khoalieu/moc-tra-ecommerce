package controller.admin;

import dao.CouponDAO;
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
import model.promotion.Coupon;
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
    private CouponDAO couponDAO;

    @Override
    public void init() {
        promotionDAO = DAOFactory.getInstance().getPromotionDAO();
        vipVoucherDAO = DAOFactory.getInstance().getVipVoucherDAO();
        couponDAO = DAOFactory.getInstance().getCouponDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        promotionDAO.syncPromotionPrices();
        List<Promotion> promotionList = promotionDAO.getAllPromotions();
        request.setAttribute("promotionList", promotionList);
        request.setAttribute("voucherList", vipVoucherDAO.getAllVouchers());
        request.setAttribute("couponList", couponDAO.getAllCoupons());

        request.getRequestDispatcher("/admin/admin-promotions.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String redirectPath = request.getContextPath() + "/admin/promotions";

        String redirectTab = "promotion";

        try {
            if (action == null || action.trim().isEmpty()) {
                response.sendRedirect(redirectPath);
                return;
            }
            switch (action) {
                case "createPromotion":
                    handleCreatePromotion(request);
                    redirectTab = "promotion";
                    break;

                case "updatePromotion":
                    handleUpdatePromotion(request);
                    redirectTab = "promotion";
                    break;
                case "togglePromotion":
                    handleTogglePromotion(request);
                    redirectTab = "promotion";
                    break;
                case "deletePromotion":
                    handleDeletePromotion(request);
                    redirectTab = "promotion";
                    break;

                case "createVoucher":
                    handleCreateVoucher(request);
                    redirectTab = "voucher";
                    break;
                case "updateVoucher":
                    handleUpdateVoucher(request);
                    redirectTab = "voucher";
                    break;
                case "deleteVoucher":
                    handleDeleteVoucher(request);
                    redirectTab = "voucher";
                    break;

                case "createCoupon":
                    handleCreateCoupon(request);
                    redirectTab = "coupon";
                    break;

                case "updateCoupon":
                    handleUpdateCoupon(request);
                    redirectTab = "coupon";
                    break;

                case "toggleCoupon":
                    handleToggleCoupon(request);
                    redirectTab = "coupon";
                    break;

                case "deleteCoupon":
                    handleDeleteCoupon(request);
                    redirectTab = "coupon";
                    break;

                default:
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        promotionDAO.syncPromotionPrices();
        response.sendRedirect(redirectPath + "?tab=" + redirectTab);
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
        try {
            int promoId = Integer.parseInt(request.getParameter("id"));
            boolean newStatus = Boolean.parseBoolean(request.getParameter("active"));
            promotionDAO.togglePromotionStatus(promoId, newStatus);
        } catch (Exception e) {
            e.printStackTrace();
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
            String code = trimOrNull(request.getParameter("code"));
            String discountType = trimOrNull(request.getParameter("discountType"));
            String discountValueStr = trimOrNull(request.getParameter("discountValue"));
            String maxUsesStr = trimOrNull(request.getParameter("maxUses"));
            String startDateStr = trimOrNull(request.getParameter("startDate"));
            String endDateStr = trimOrNull(request.getParameter("endDate"));

            if (code == null || discountType == null || discountValueStr == null ||
                    startDateStr == null || endDateStr == null) {
                return;
            }

            double discountValue = Double.parseDouble(discountValueStr);
            Integer maxUses = null;
            if (maxUsesStr != null) {
                maxUses = Integer.parseInt(maxUsesStr);
            }

            LocalDateTime startDate = LocalDateTime.parse(startDateStr);
            LocalDateTime endDate = LocalDateTime.parse(endDateStr);

            vipVoucherDAO.insertVoucher(code.trim(), discountType.trim().toUpperCase(),
                    discountValue, maxUses, startDate, endDate);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handleUpdateVoucher(HttpServletRequest request) {
        try {
            String idStr = trimOrNull(request.getParameter("id"));
            String code = trimOrNull(request.getParameter("code"));
            String discountType = trimOrNull(request.getParameter("discountType"));
            String discountValueStr = trimOrNull(request.getParameter("discountValue"));
            String maxUsesStr = trimOrNull(request.getParameter("maxUses"));
            String startDateStr = trimOrNull(request.getParameter("startDate"));
            String endDateStr = trimOrNull(request.getParameter("endDate"));
            String activeStr = request.getParameter("active");

            if (idStr == null || code == null || discountType == null || discountValueStr == null ||
                    startDateStr == null || endDateStr == null) {
                return;
            }

            int id = Integer.parseInt(idStr);
            double discountValue = Double.parseDouble(discountValueStr);

            Integer maxUses = null;
            if (maxUsesStr != null) {
                maxUses = Integer.parseInt(maxUsesStr);
            }

            LocalDateTime startDate = LocalDateTime.parse(startDateStr);
            LocalDateTime endDate = LocalDateTime.parse(endDateStr);
            boolean isActive = activeStr != null && (
                    "true".equalsIgnoreCase(activeStr)
                            || "1".equals(activeStr)
                            || "on".equalsIgnoreCase(activeStr)
            );

            vipVoucherDAO.updateVoucher(id, code.trim(), discountType.trim().toUpperCase(),
                    discountValue, maxUses, startDate, endDate, isActive);

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

    private void handleCreateCoupon(HttpServletRequest request) {
        Coupon coupon = buildCouponFromRequest(request, false);

        if (coupon != null) {
            couponDAO.insertCoupon(coupon);
        }
    }

    private void handleUpdateCoupon(HttpServletRequest request) {
        Coupon coupon = buildCouponFromRequest(request, true);

        if (coupon != null) {
            couponDAO.updateCoupon(coupon);
        }
    }

    private void handleToggleCoupon(HttpServletRequest request) {
        try {
            int couponId = Integer.parseInt(request.getParameter("id"));
            boolean active = Boolean.parseBoolean(request.getParameter("active"));

            couponDAO.toggleCouponStatus(couponId, active);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void handleDeleteCoupon(HttpServletRequest request) {
        try {
            String idStr = trimOrNull(request.getParameter("id"));
            if (idStr == null) return;

            int couponId = Integer.parseInt(idStr);
            couponDAO.deleteCoupon(couponId);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Coupon buildCouponFromRequest(HttpServletRequest request, boolean isUpdate) {
        try {
            String code = trimOrNull(request.getParameter("code"));
            String title = trimOrNull(request.getParameter("title"));
            String description = trimOrNull(request.getParameter("description"));
            String discountType = trimOrNull(request.getParameter("discountType"));
            String discountValueStr = trimOrNull(request.getParameter("discountValue"));
            String maxDiscountAmountStr = trimOrNull(request.getParameter("maxDiscountAmount"));
            String minOrderAmountStr = trimOrNull(request.getParameter("minOrderAmount"));
            String claimLimitStr = trimOrNull(request.getParameter("claimLimit"));
            String maxUsesStr = trimOrNull(request.getParameter("maxUses"));
            String startDateStr = trimOrNull(request.getParameter("startDate"));
            String endDateStr = trimOrNull(request.getParameter("endDate"));
            String activeStr = request.getParameter("active");

            if (code == null || title == null || discountType == null || discountValueStr == null ||
                    startDateStr == null || endDateStr == null) {
                return null;
            }

            Coupon coupon = new Coupon();

            if (isUpdate) {
                String idStr = trimOrNull(request.getParameter("id"));
                if (idStr == null) return null;
                coupon.setId(Integer.parseInt(idStr));
            }

            coupon.setCode(code.trim().toUpperCase());
            coupon.setTitle(title);
            coupon.setDescription(description);
            coupon.setDiscountType(discountType.trim().toUpperCase());
            coupon.setDiscountValue(Double.parseDouble(discountValueStr));

            if (maxDiscountAmountStr == null) {
                coupon.setMaxDiscountAmount(null);
            } else {
                coupon.setMaxDiscountAmount(Double.parseDouble(maxDiscountAmountStr));
            }

            if (minOrderAmountStr == null) {
                coupon.setMinOrderAmount(0);
            } else {
                coupon.setMinOrderAmount(Double.parseDouble(minOrderAmountStr));
            }

            if (claimLimitStr == null) {
                coupon.setClaimLimit(null);
            } else {
                coupon.setClaimLimit(Integer.parseInt(claimLimitStr));
            }

            if (maxUsesStr == null) {
                coupon.setMaxUses(null);
            } else {
                coupon.setMaxUses(Integer.parseInt(maxUsesStr));
            }

            coupon.setStartDate(LocalDateTime.parse(startDateStr));
            coupon.setEndDate(LocalDateTime.parse(endDateStr));

            if (isUpdate) {
                boolean active = activeStr != null && (
                        "true".equalsIgnoreCase(activeStr)
                                || "1".equals(activeStr)
                                || "on".equalsIgnoreCase(activeStr)
                );
                coupon.setActive(active);
            } else {
                coupon.setActive(true);
            }

            return coupon;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String savePromotionImage(Part part, boolean required) {
        try {
            if (part == null || part.getSize() == 0) {
                if (required) {
                    throw new IllegalArgumentException("Vui lòng chọn ảnh");
                }
                return null;
            }

            String relDir = "assets/images";
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
            throw new IllegalArgumentException("Upload ảnh khuyến mãi lỗi.");
        }
    }

    private String trimOrNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}