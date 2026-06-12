package dao;

import model.SystemLog;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class SystemLogDAO {

    private final DataSource ds;

    public SystemLogDAO(DataSource ds) {
        this.ds = ds;
    }

    public void insertLog(Integer userID, String action, String entityType, Integer entityID) {
        String sql = "INSERT INTO SystemLogs (UserID, Action, EntityType, EntityID) VALUES (?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (userID == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, userID);
            }
            ps.setString(2, action);
            if (entityType == null) {
                ps.setNull(3, Types.VARCHAR);
            } else {
                ps.setString(3, entityType);
            }
            if (entityID == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, entityID);
            }
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<SystemLog> getAllLogs() {
        List<SystemLog> logs = new ArrayList<>();

        String sql = "SELECT LogID, UserID, Action, EntityType, EntityID, Timestamp " +
                "FROM SystemLogs ORDER BY Timestamp DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                SystemLog log = new SystemLog();

                log.setLogID(rs.getInt("LogID"));

                int userID = rs.getInt("UserID");
                log.setUserID(rs.wasNull() ? null : userID);

                log.setAction(rs.getString("Action"));
                log.setEntityType(rs.getString("EntityType"));

                int entityID = rs.getInt("EntityID");
                log.setEntityID(rs.wasNull() ? null : entityID);

                log.setTimestamp(rs.getTimestamp("Timestamp"));

                logs.add(log);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }
}