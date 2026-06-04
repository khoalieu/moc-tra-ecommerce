package service;

import dao.DAOFactory;
import dao.NotificationDAO;
import model.enums.OrderStatus;
import model.notification.Notification;
import model.order.Order;

import java.util.List;

public class NotificationService {
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

    public List<Notification> getUserNotifications(int userId, int page, int pageSize) {
        return notificationDAO.getByUser(userId, page, pageSize);
    }

    public List<Notification> getLatestUserNotifications(int userId, int limit) {
        return notificationDAO.getLatestByUser(userId, limit);
    }

    public Notification getUserNotification(int notificationId, int userId) {
        return notificationDAO.getByIdForUser(notificationId, userId);
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

    public int countUnreadForUser(int userId) {
        return notificationDAO.countUnreadByUser(userId);
    }

    public boolean markAsReadForUser(int notificationId, int userId) {
        return notificationDAO.markAsReadForUser(notificationId, userId);
    }

    public boolean markAllAsReadForUser(int userId) {
        return notificationDAO.markAllAsReadForUser(userId);
    }

    private String displayOrderNumber(String orderNumber, int orderId) {
        if (orderNumber != null && !orderNumber.trim().isEmpty()) {
            return "#" + orderNumber.trim();
        }
        return "#" + orderId;
    }
}
