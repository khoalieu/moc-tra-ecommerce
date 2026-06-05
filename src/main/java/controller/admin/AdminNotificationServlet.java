package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.notification.Notification;
import service.NotificationService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminNotificationServlet", value = "/admin/notifications")
public class AdminNotificationServlet extends HttpServlet {
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("summary".equals(action)) {
            handleSummary(response); return;}
        if ("markAll".equals(action)) {
            notificationService.markAllAsReadForAdmin();
            response.sendRedirect(request.getContextPath() + "/admin/notifications");
            return;
        }
        if ("read".equals(action)) {
            handleRead(request, response); return;}

        int page = parsePositiveInt(request.getParameter("page"), 1);
        int pageSize = 10;
        List<Notification> notifications = notificationService.getAdminNotifications(page, pageSize);

        request.setAttribute("notifications", notifications);
        request.setAttribute("unreadCount", notificationService.countUnreadForAdmin());
        request.setAttribute("currentPage", page);
        request.setAttribute("hasNextPage", notifications.size() == pageSize);
        request.getRequestDispatcher("/admin/admin-notifications.jsp").forward(request, response);
    }

    private void handleRead(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int notificationId = parsePositiveInt(request.getParameter("id"), 0);
        if (notificationId <= 0) {
            response.sendRedirect(request.getContextPath() + "/admin/notifications");
            return;
        }
        Notification notification = notificationService.getAdminNotification(notificationId);
        if (notification == null) {
            response.sendRedirect(request.getContextPath() + "/admin/notifications");
            return;
        }
        notificationService.markAsReadForAdmin(notificationId);
        response.sendRedirect(request.getContextPath() + normalizeTargetUrl(notification.getTargetUrl()));
    }

    private void handleSummary(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        int unreadCount = notificationService.countUnreadForAdmin();
        List<Notification> notifications = notificationService.getLatestAdminNotifications(5);

        StringBuilder json = new StringBuilder();
        json.append("{\"unreadCount\":").append(unreadCount).append(",\"notifications\":[");
        for (int i = 0; i < notifications.size(); i++) {
            Notification notification = notifications.get(i);
            if (i > 0) {
                json.append(",");
            }
            json.append("{")
                    .append("\"id\":").append(notification.getId()).append(",")
                    .append("\"title\":\"").append(escapeJson(notification.getTitle())).append("\",")
                    .append("\"read\":").append(notification.isRead())
                    .append("}");
        }
        json.append("]}");

        response.getWriter().write(json.toString());
    }

    private String normalizeTargetUrl(String targetUrl) {
        if (targetUrl == null || targetUrl.trim().isEmpty()) {
            return "/admin/notifications";
        }
        String value = targetUrl.trim();
        if (value.contains("://") || value.startsWith("//")) {
            return "/admin/notifications";
        }
        return value.startsWith("/") ? value : "/" + value;
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n");
    }
}
