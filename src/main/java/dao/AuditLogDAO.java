package dao;

import model.user.AuditLog;
import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDAO {
    private final DataSource ds;

    public AuditLogDAO(DataSource ds) {
        this.ds = ds;
    }

    public boolean insert(int userId, int targetId, String fieldName, String oldValue, String newValue) {
        String sql = "INSERT INTO audit_logs (user_id, target_id, field_name, old_value, new_value) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, targetId);
            ps.setString(3, fieldName);
            ps.setString(4, oldValue);
            ps.setString(5, newValue);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<AuditLog> getLogsByCustomerId(int customerId) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT al.*, u.username AS performer_username " +
                     "FROM audit_logs al " +
                     "LEFT JOIN users u ON al.user_id = u.id " +
                     "WHERE al.target_id = ? " +
                     "ORDER BY al.created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getInt("id"));
                    log.setUserId(rs.getInt("user_id"));
                    log.setTargetId(rs.getInt("target_id"));
                    log.setFieldName(rs.getString("field_name"));
                    log.setOldValue(rs.getString("old_value"));
                    log.setNewValue(rs.getString("new_value"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    log.setPerformerUsername(rs.getString("performer_username"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
