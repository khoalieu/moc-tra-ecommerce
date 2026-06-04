package service;

import dao.DAOFactory;
import dao.NotificationDAO;
import model.notification.Notification;

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

    public int countUnreadForUser(int userId) {
        return notificationDAO.countUnreadByUser(userId);
    }

    public boolean markAsReadForUser(int notificationId, int userId) {
        return notificationDAO.markAsReadForUser(notificationId, userId);
    }

    public boolean markAllAsReadForUser(int userId) {
        return notificationDAO.markAllAsReadForUser(userId);
    }
}
