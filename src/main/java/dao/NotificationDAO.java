package dao;

import model.notification.Notification;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {
    private final DataSource ds;

    public NotificationDAO(DataSource ds) {
        this.ds = ds;
    }

    public int createForUser(Notification notification) {
        String sql = "INSERT INTO notifications " +
                "(user_id, type, title, message, target_url, entity_type, entity_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, notification.getUserId());
            ps.setString(2, notification.getType());
            ps.setString(3, notification.getTitle());
            ps.setString(4, notification.getMessage());
            ps.setString(5, notification.getTargetUrl());
            ps.setString(6, notification.getEntityType());
            setNullableInt(ps, 7, notification.getEntityId());

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int createForRole(Notification notification) {
        String sql = "INSERT INTO notifications " +
                "(recipient_role, type, title, message, target_url, entity_type, entity_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, notification.getRecipientRole());
            ps.setString(2, notification.getType());
            ps.setString(3, notification.getTitle());
            ps.setString(4, notification.getMessage());
            ps.setString(5, notification.getTargetUrl());
            ps.setString(6, notification.getEntityType());
            setNullableInt(ps, 7, notification.getEntityId());

            if (ps.executeUpdate() > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Notification> getByUser(int userId, int page, int pageSize) {
        String sql = "SELECT * FROM notifications " +
                "WHERE user_id = ? " +
                "ORDER BY created_at DESC LIMIT ? OFFSET ?";

        List<Notification> list = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, pageSize);
            ps.setInt(3, Math.max(0, (page - 1) * pageSize));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Notification> getLatestByUser(int userId, int limit) {
        String sql = "SELECT * FROM notifications " +
                "WHERE user_id = ? " +
                "ORDER BY created_at DESC LIMIT ?";

        List<Notification> list = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Notification> getByRole(String recipientRole, int page, int pageSize) {
        String sql = "SELECT * FROM notifications " +
                "WHERE recipient_role = ? " +
                "ORDER BY created_at DESC LIMIT ? OFFSET ?";

        List<Notification> list = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, recipientRole);
            ps.setInt(2, pageSize);
            ps.setInt(3, Math.max(0, (page - 1) * pageSize));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Notification> getLatestByRole(String recipientRole, int limit) {
        String sql = "SELECT * FROM notifications " +
                "WHERE recipient_role = ? " +
                "ORDER BY created_at DESC LIMIT ?";

        List<Notification> list = new ArrayList<>();
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, recipientRole);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Notification getByIdForUser(int notificationId, int userId) {
        String sql = "SELECT * FROM notifications WHERE id = ? AND user_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Notification getByIdForRole(int notificationId, String recipientRole) {
        String sql = "SELECT * FROM notifications WHERE id = ? AND recipient_role = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setString(2, recipientRole);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public int countUnreadByUser(int userId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countUnreadByRole(String recipientRole) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE recipient_role = ? AND is_read = 0";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, recipientRole);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean existsByRoleTypeAndEntity(String recipientRole, String type, String entityType, Integer entityId) {
        String sql = "SELECT 1 FROM notifications " +
                "WHERE recipient_role = ? AND type = ? AND entity_type = ? AND entity_id = ? LIMIT 1";

        if (entityId == null) {return false;}

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, recipientRole);
            ps.setString(2, type);
            ps.setString(3, entityType);
            ps.setInt(4, entityId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAsReadForUser(int notificationId, int userId) {
        String sql = "UPDATE notifications SET is_read = 1, read_at = NOW() " +
                "WHERE id = ? AND user_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAsReadForRole(int notificationId, String recipientRole) {
        String sql = "UPDATE notifications SET is_read = 1, read_at = NOW() " +
                "WHERE id = ? AND recipient_role = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, notificationId);
            ps.setString(2, recipientRole);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAllAsReadForUser(int userId) {
        String sql = "UPDATE notifications SET is_read = 1, read_at = NOW() " +
                "WHERE user_id = ? AND is_read = 0";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean markAllAsReadForRole(String recipientRole) {
        String sql = "UPDATE notifications SET is_read = 1, read_at = NOW() " +
                "WHERE recipient_role = ? AND is_read = 0";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, recipientRole);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private Notification mapRow(ResultSet rs) throws Exception {
        Notification notification = new Notification();
        notification.setId(rs.getInt("id"));

        int userId = rs.getInt("user_id");
        if (!rs.wasNull()) {
            notification.setUserId(userId);
        }

        notification.setRecipientRole(rs.getString("recipient_role"));
        notification.setType(rs.getString("type"));
        notification.setTitle(rs.getString("title"));
        notification.setMessage(rs.getString("message"));
        notification.setTargetUrl(rs.getString("target_url"));
        notification.setEntityType(rs.getString("entity_type"));

        int entityId = rs.getInt("entity_id");
        if (!rs.wasNull()) {
            notification.setEntityId(entityId);
        }

        notification.setRead(rs.getBoolean("is_read"));
        notification.setReadAt(rs.getTimestamp("read_at"));
        notification.setCreatedAt(rs.getTimestamp("created_at"));
        return notification;
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws Exception {
        if (value != null) {
            ps.setInt(index, value);
        } else {
            ps.setNull(index, Types.INTEGER);
        }
    }
}
