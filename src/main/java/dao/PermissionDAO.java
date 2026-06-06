package dao;

import model.rbac.Permission;

import javax.sql.DataSource;
import java.sql.*;
import java.util.*;

public class PermissionDAO {
    private final DataSource ds;

    public PermissionDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Permission> getAllPermissions() {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT id, name, display_name, description, group_name, created_at FROM permissions ORDER BY group_name, name";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapPermission(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, List<Permission>> getAllPermissionsGrouped() {
        Map<String, List<Permission>> grouped = new LinkedHashMap<>();
        List<Permission> all = getAllPermissions();
        for (Permission p : all) {
            String group = p.getGroupName() != null ? p.getGroupName() : "other";
            grouped.computeIfAbsent(group, k -> new ArrayList<>()).add(p);
        }
        return grouped;
    }

    public Set<String> getPermissionNamesByUserId(int userId) {
        Set<String> perms = new HashSet<>();
        String sql = "SELECT p.name FROM permissions p " +
                     "JOIN role_permissions rp ON rp.permission_id = p.id " +
                     "JOIN users u ON u.role_id = rp.role_id " +
                     "WHERE u.id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) perms.add(rs.getString("name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return perms;
    }

    private Permission mapPermission(ResultSet rs) throws SQLException {
        Permission p = new Permission();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setDisplayName(rs.getString("display_name"));
        p.setDescription(rs.getString("description"));
        p.setGroupName(rs.getString("group_name"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
        return p;
    }
}
