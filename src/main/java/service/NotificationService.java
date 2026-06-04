package service;

import dao.DAOFactory;
import dao.NotificationDAO;
import model.enums.OrderStatus;
import model.enums.PaymentStatus;
import model.notification.Notification;
import model.order.Order;
import model.promotion.Promotion;
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

    public int notifyOrderStatusChanged(Order order, OrderStatus newStatus) {
        if (order == null || newStatus == null) {
            return 0;
        }
        String code = displayOrderNumber(order.getOrderNumber(), order.getId());
        String type;
        String title;
        String message;

        switch (newStatus) {
            case SHIPPING:
                type = "order_shipping";
                title = "Đơn hàng đang được giao";
                message = "Đơn hàng " + code + " đang trên đường giao đến bạn.";
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
