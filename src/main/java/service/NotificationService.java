package service;

import dao.DAOFactory;
import dao.NotificationDAO;
import model.enums.OrderStatus;
import model.enums.PaymentStatus;
import model.notification.Notification;
import model.order.Order;
import model.product.Product;
import model.product.ProductVariant;
import model.promotion.Coupon;
import model.promotion.Promotion;
import model.promotion.VipVoucher;
import model.refund.RefundRequest;

import java.time.LocalDateTime;
import java.util.List;

public class NotificationService {
    private static final String ADMIN_ROLE = "ADMIN";
    private final NotificationDAO notificationDAO;

    public NotificationService() {
        this.notificationDAO = DAOFactory.getInstance().getNotificationDAO();
    }

    public int notifyUser(int userId, String type, String title, String message,
                          String targetUrl, String entityType, Integer entityId) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setTargetUrl(targetUrl);
        notification.setEntityType(entityType);
        notification.setEntityId(entityId);
        return notificationDAO.createForUser(notification);
    }

    public int notifyAdmin(String type, String title, String message,
                           String targetUrl, String entityType, Integer entityId) {
        Notification notification = new Notification();
        notification.setRecipientRole(ADMIN_ROLE);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setTargetUrl(targetUrl);
        notification.setEntityType(entityType);
        notification.setEntityId(entityId);
        return notificationDAO.createForRole(notification);
    }

    private int notifyAdminOnce(String type, String title, String message,
                                String targetUrl, String entityType, Integer entityId) {
        if (entityId != null && notificationDAO.existsByRoleTypeAndEntity(ADMIN_ROLE, type, entityType, entityId)) {
            return 0;
        }
        return notifyAdmin(type, title, message, targetUrl, entityType, entityId);
    }

    public List<Notification> getUserNotifications(int userId, int page, int pageSize) {
        return notificationDAO.getByUser(userId, page, pageSize);
    }
    public List<Notification> getLatestUserNotifications(int userId, int limit) {
        return notificationDAO.getLatestByUser(userId, limit);
    }
    public List<Notification> getAdminNotifications(int page, int pageSize) {
        return notificationDAO.getByRole(ADMIN_ROLE, page, pageSize);
    }
    public List<Notification> getLatestAdminNotifications(int limit) {
        return notificationDAO.getLatestByRole(ADMIN_ROLE, limit);
    }
    public Notification getUserNotification(int notificationId, int userId) {
        return notificationDAO.getByIdForUser(notificationId, userId);
    }

    public Notification getAdminNotification(int notificationId) {
        return notificationDAO.getByIdForRole(notificationId, ADMIN_ROLE);
    }
    public int notifyOrderCreated(int userId, int orderId, String orderNumber) {
        String code = displayOrderNumber(orderNumber, orderId);
        return notifyUser(userId,
                "order_created",
                "Đặt hàng thành công",
                "Đơn hàng " + code + " đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.",
                "don-hang",
                "order",
                orderId);
    }

    public int notifyAdminOrderCreated(Order order) {
        if (order == null) {
            return 0;
        }

        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        return notifyAdmin(
                "admin_order_created",
                "Có đơn hàng mới",
                "Đơn hàng " + code + " vừa được tạo. Admin cần kiểm tra và xử lý đơn.",
                "admin/order/detail?id=" + order.getId(),
                "order",
                order.getId());
    }

    public int notifyOrderStatusChanged(Order order, OrderStatus newStatus) {
        if (order == null || newStatus == null) {
            return 0;
        }
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String type;
        String title;
        String message;

        switch (newStatus) {
            case PROCESSING:
                type = "order_processing";
                title = "Đơn hàng đang được chuẩn bị";
                message = "Đơn hàng " + code + " đang được shop/GHN chuẩn bị lấy hàng.";
                break;
            case SHIPPING:
                type = "order_shipping";
                title = "Đơn hàng đang được giao";
                message = "Đơn hàng " + code + " đang trên đường giao đến bạn.";
                break;
            case DELIVERY_ATTEMPT_FAILED:
                type = "order_delivery_attempt_failed";
                title = "Giao hàng chưa thành công";
                message = "Đơn hàng " + code + " giao chưa thành công trong lần này. Đơn vị vận chuyển có thể tiếp tục giao lại.";
                break;
            case RETURNING:
                type = "order_returning";
                title = "Đơn hàng đang hoàn về shop";
                message = "Đơn hàng " + code + " đang trong quá trình hoàn về shop.";
                break;
            case COMPLETED:
                type = "order_completed";
                title = "Đơn hàng đã giao thành công";
                message = "Đơn hàng " + code + " đã giao thành công. Cảm ơn bạn đã mua hàng.";
                break;
            case CANCELLED:
                type = "order_cancelled";
                title = "Đơn hàng đã bị hủy";
                message = "Đơn hàng " + code + " đã bị hủy. Bạn có thể xem chi tiết trong đơn hàng.";
                break;
            case DELIVERY_FAILED:
                type = "order_delivery_failed";
                title = "Đơn hàng giao không thành công";
                message = "Đơn hàng " + code + " giao không thành công. Shop sẽ xử lý các bước tiếp theo nếu cần.";
                break;
            default:
                type = "order_updated";
                title = "Đơn hàng đã cập nhật";
                message = "Đơn hàng " + code + " vừa được cập nhật trạng thái.";
                break;
        }

        return notifyUser(order.getUserId(), type, title, message,
                "don-hang", "order", order.getId());
    }

    public int notifyPaymentStatusChanged(Order order, PaymentStatus paymentStatus) {
        if (order == null || paymentStatus == null) {
            return 0;
        }
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String type;
        String title;
        String message;

        switch (paymentStatus) {
            case PAID:
                type = "payment_paid";
                title = "Thanh toán thành công";
                message = "Hệ thống đã ghi nhận thanh toán cho đơn hàng " + code + ".";
                break;
            case FAILED:
                type = "payment_failed";
                title = "Thanh toán thất bại";
                message = "Thanh toán cho đơn hàng " + code + " không thành công. Bạn có thể thanh toán lại nếu đơn còn hợp lệ.";
                break;
            case EXPIRED:
                type = "payment_expired";
                title = "Mã thanh toán đã hết hạn";
                message = "Mã thanh toán của đơn hàng " + code + " đã hết hạn. Bạn có thể tạo mã mới để tiếp tục thanh toán.";
                break;
            default:
                return 0;
        }

        return notifyUser(order.getUserId(), type, title, message,
                "don-hang", "order", order.getId());
    }

    public int notifyOrderAutoCancelledUnpaid(Order order) {
        if (order == null) {
            return 0;
        }
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        return notifyUser(order.getUserId(),
                "order_auto_cancelled_unpaid",
                "Đơn hàng đã tự hủy",
                "Đơn hàng " + code + " đã bị hủy do quá thời gian thanh toán 24 giờ.",
                "don-hang",
                "order",
                order.getId());
    }

    public int notifyRefundRequested(Order order, boolean completedPendingInfo) {
        if (order == null) {return 0;}

        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String title = completedPendingInfo
                ? "Đã bổ sung thông tin hoàn tiền"
                : "Đã gửi yêu cầu hoàn tiền";
        String message = completedPendingInfo
                ? "Thông tin nhận tiền cho đơn hàng " + code + " đã được gửi. Shop sẽ kiểm tra và xử lý thủ công."
                : "Yêu cầu hoàn tiền cho đơn hàng " + code + " đã được gửi. Shop sẽ kiểm tra và xử lý thủ công.";

        return notifyUser(order.getUserId(), "refund_requested", title, message,
                "don-hang", "refund", order.getId());
    }

    public int notifyRefundPendingInfo(Order order) {
        if (order == null) {return 0;}

        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        return notifyUser(order.getUserId(),
                "refund_pending_info",
                "Cần bổ sung thông tin hoàn tiền",
                "Đơn hàng " + code + " giao không thành công. Vui lòng bổ sung thông tin nhận tiền để shop hoàn tiền.",
                "don-hang",
                "refund",
                order.getId());
    }

    public int notifyAdminDeliveryFailed(Order order) {
        if (order == null) {
            return 0;
        }

        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        return notifyAdmin(
                "admin_order_delivery_failed",
                "Có đơn giao thất bại cần xử lý",
                "Đơn hàng " + code + " giao không thành công. Admin cần kiểm tra đơn và xử lý hoàn tiền nếu cần.",
                "admin/order/detail?id=" + order.getId(),
                "order",
                order.getId());
    }

    public int notifyAdminRefundRequested(Order order, boolean completedPendingInfo) {
        if (order == null) {return 0;}

        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String title = completedPendingInfo
                ? "Khách đã bổ sung thông tin hoàn tiền" : "Có yêu cầu hoàn tiền mới";
        String message = completedPendingInfo
                ? "Khách đã bổ sung thông tin nhận tiền cho đơn hàng " + code + ". Admin cần kiểm tra và hoàn tiền thủ công." : "Khách vừa gửi yêu cầu hoàn tiền cho đơn hàng " + code + ". Admin cần kiểm tra thông tin nhận tiền.";

        return notifyAdmin(
                "admin_refund_requested", title, message,
                "admin/refunds?status=pending", "refund",
                order.getId());
    }

    public int notifyAdminVariantStock(ProductVariant variant, Product product) {
        if (variant == null) {return 0;}
        int stock = variant.getStockQuantity();
        if (stock > 10) {return 0;}

        String productName = product != null && product.getName() != null
                ? product.getName() : "Sản phẩm #" + variant.getProductId();
        String variantName = variant.getVariantName() != null && !variant.getVariantName().trim().isEmpty()
                ? variant.getVariantName().trim() : "Biến thể #" + variant.getId();

        if (stock <= 0) {
            return notifyAdminOnce(
                    "admin_variant_out_of_stock",
                    "Biến thể sản phẩm hết hàng",
                    productName + " - " + variantName + " đã hết hàng.",
                    "admin/products?stockFilter=out-of-stock",
                    "product_variant",
                    variant.getId());
        }

        String type = stock < 3 ? "admin_variant_need_reorder" : "admin_variant_low_stock";
        String title = stock < 3 ? "Biến thể cần nhập hàng" : "Biến thể sắp hết hàng";
        String target = stock < 3 ? "admin/products?stockFilter=need-reorder"
                : "admin/products?stockFilter=low-stock";

        return notifyAdminOnce(type, title,
                productName + " - " + variantName + " chỉ còn " + stock + " sản phẩm.",
                target, "product_variant", variant.getId());
    }

    public int notifyAdminPromotionLifecycle(Promotion promotion) {
        if (promotion == null || promotion.getStartDate() == null || promotion.getEndDate() == null) {
            return 0;
        }

        LocalDateTime now = LocalDateTime.now();
        String name = promotion.getName() != null ? promotion.getName() : "Chương trình #" + promotion.getId();

        if (promotion.isActive() && !promotion.getStartDate().isAfter(now) && !promotion.getEndDate().isBefore(now)) {
            return notifyAdminOnce("admin_promotion_started", "Chương trình khuyến mãi đã đến hạn",
                    "Chương trình \"" + name + "\" đang trong thời gian hiển thị.",
                    "admin/promotions?tab=promotion", "promotion", promotion.getId());
        }

        if (promotion.getEndDate().isBefore(now)) {
            return notifyAdminOnce("admin_promotion_expired",
                    "Chương trình khuyến mãi đã hết hạn",
                    "Chương trình \"" + name + "\" đã hết hạn.",
                    "admin/promotions?tab=promotion", "promotion", promotion.getId());
        }
        return 0;
    }

    public int notifyAdminCouponLifecycle(Coupon coupon) {
        if (coupon == null || coupon.getStartDate() == null || coupon.getEndDate() == null) {
            return 0;
        }

        LocalDateTime now = LocalDateTime.now();
        String code = coupon.getCode() != null ? coupon.getCode() : "Coupon #" + coupon.getId();
        int created = 0;

        if (coupon.isActive() && !coupon.getStartDate().isAfter(now) && !coupon.getEndDate().isBefore(now)) {
            created += notifyAdminOnce(
                    "admin_coupon_started", "Mã giảm giá đã đến hạn",
                    "Mã \"" + code + "\" đang trong thời gian hiển thị.",
                    "admin/promotions?tab=coupon", "coupon", coupon.getId());
        }

        if (coupon.getEndDate().isBefore(now)) {
            created += notifyAdminOnce(
                    "admin_coupon_expired", "Mã giảm giá đã hết hạn",
                    "Mã \"" + code + "\" đã hết hạn.",
                    "admin/promotions?tab=coupon", "coupon", coupon.getId());
        }

        if (coupon.getClaimLimit() != null && coupon.getCurrentClaims() >= coupon.getClaimLimit()) {
            created += notifyAdminOnce(
                    "admin_coupon_claim_limit_reached", "Mã giảm giá đã hết lượt nhận",
                    "Mã \"" + code + "\" đã đạt giới hạn lượt nhận.",
                    "admin/promotions?tab=coupon", "coupon", coupon.getId());
        }

        if (coupon.getMaxUses() != null && coupon.getCurrentUses() >= coupon.getMaxUses()) {
            created += notifyAdminOnce(
                    "admin_coupon_use_limit_reached", "Mã giảm giá đã hết lượt sử dụng",
                    "Mã \"" + code + "\" đã đạt giới hạn lượt sử dụng.",
                    "admin/promotions?tab=coupon", "coupon",
                    coupon.getId());
        }
        return created;
    }

    public int notifyAdminVoucherLifecycle(VipVoucher voucher) {
        if (voucher == null || voucher.getStartDate() == null || voucher.getEndDate() == null) {
            return 0;
        }

        LocalDateTime now = LocalDateTime.now();
        String code = voucher.getCode() != null ? voucher.getCode() : "Voucher #" + voucher.getId();
        int created = 0;

        if (Boolean.TRUE.equals(voucher.getActive())
                && !voucher.getStartDate().isAfter(now) && !voucher.getEndDate().isBefore(now)) {
            created += notifyAdminOnce(
                    "admin_voucher_started", "Voucher VIP đã đến hạn",
                    "Voucher \"" + code + "\" đang trong thời gian sử dụng.",
                    "admin/promotions?tab=voucher", "voucher", voucher.getId());
        }

        if (voucher.getEndDate().isBefore(now)) {
            created += notifyAdminOnce(
                    "admin_voucher_expired", "Voucher VIP đã hết hạn",
                    "Voucher \"" + code + "\" đã hết hạn.",
                    "admin/promotions?tab=voucher", "voucher", voucher.getId());
        }

        if (voucher.getMaxUses() != null && voucher.getCurrentUses() != null
                && voucher.getCurrentUses() >= voucher.getMaxUses()) {
            created += notifyAdminOnce(
                    "admin_voucher_use_limit_reached", "Voucher VIP đã hết lượt sử dụng",
                    "Voucher \"" + code + "\" đã đạt giới hạn lượt sử dụng.",
                    "admin/promotions?tab=voucher", "voucher", voucher.getId());
        }
        return created;
    }

    public int notifyRefundStatusChanged(RefundRequest refund, String status) {
        if (refund == null || status == null) {return 0;}

        String code = displayOrderNumber(refund.getOrderNumber(), refund.getOrderId());
        String type;
        String title;
        String message;

        if ("refunded".equals(status)) {
            type = "refund_completed";
            title = "Đã hoàn tiền";
            message = "Shop đã ghi nhận hoàn tiền cho đơn hàng " + code + ".";
        } else if ("rejected".equals(status)) {
            type = "refund_rejected";
            title = "Yêu cầu hoàn tiền bị từ chối";
            message = "Yêu cầu hoàn tiền cho đơn hàng " + code + " đã bị từ chối. Vui lòng xem ghi chú xử lý nếu có.";
        } else {
            return 0;
        }

        return notifyUser(refund.getUserId(), type, title, message,
                "don-hang", "refund", refund.getOrderId());
    }

    public int notifyPasswordChanged(int userId) {
        return notifyUser(userId,
                "account_password_changed",
                "Mật khẩu đã được thay đổi",
                "Mật khẩu tài khoản của bạn vừa được cập nhật thành công.",
                "tai-khoan-cua-toi",
                "account",
                userId);
    }

    public int notifyProfileUpdated(int userId, String message) {
        return notifyUser(userId,
                "account_profile_updated",
                "Thông tin tài khoản đã được cập nhật",
                message != null && !message.trim().isEmpty()
                        ? message
                        : "Thông tin tài khoản của bạn vừa được cập nhật thành công.",
                "tai-khoan-cua-toi", "account", userId);
    }

    public int notifyPromotionCreated(Promotion promotion) {
        if (!isPromotionVisibleNow(promotion)) {
            return 0;
        }

        boolean vipOnly = "VIP".equalsIgnoreCase(promotion.getPromotionType());
        List<Integer> userIds = DAOFactory.getInstance()
                .getUserDAO().getActiveCustomerIdsForNotifications(vipOnly);

        int createdCount = 0;
        String promotionName = promotion.getName() != null && !promotion.getName().trim().isEmpty()
                ? promotion.getName().trim() : "chương trình khuyến mãi mới";

        for (Integer userId : userIds) {
            if (userId == null) {
                continue;
            }

            int notificationId = notifyUser(userId,
                    "promotion_new",
                    "Có chương trình khuyến mãi mới",
                    "Chương trình \"" + promotionName + "\" đã được mở. Bạn có thể xem chi tiết tại trang khuyến mãi.",
                    "khuyen-mai",
                    "promotion",
                    promotion.getId() > 0 ? promotion.getId() : null);
            if (notificationId > 0) {
                createdCount++;
            }
        }
        return createdCount;
    }

    private boolean isPromotionVisibleNow(Promotion promotion) {
        if (promotion == null || !promotion.isActive()
                || promotion.getStartDate() == null || promotion.getEndDate() == null) {
            return false;
        }

        LocalDateTime now = LocalDateTime.now();
        return !promotion.getStartDate().isAfter(now) && !promotion.getEndDate().isBefore(now);
    }

    public int countUnreadForUser(int userId) {
        return notificationDAO.countUnreadByUser(userId);
    }

    public int countUnreadForAdmin() {
        return notificationDAO.countUnreadByRole(ADMIN_ROLE);
    }
    public boolean markAsReadForUser(int notificationId, int userId) {
        return notificationDAO.markAsReadForUser(notificationId, userId);
    }
    public boolean markAsReadForAdmin(int notificationId) {
        return notificationDAO.markAsReadForRole(notificationId, ADMIN_ROLE);
    }
    public boolean markAllAsReadForUser(int userId) {
        return notificationDAO.markAllAsReadForUser(userId);
    }
    public boolean markAllAsReadForAdmin() {
        return notificationDAO.markAllAsReadForRole(ADMIN_ROLE);
    }
    private String displayOrderNumber(String orderNumber, int orderId) {
        if (orderNumber != null && !orderNumber.trim().isEmpty()) {
            return "#" + orderNumber.trim();
        }
        return "#" + orderId;
    }
}
