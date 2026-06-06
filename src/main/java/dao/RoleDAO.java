package dao;

import model.rbac.Permission;
import model.rbac.Role;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {
    private final DataSource ds;

    public RoleDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT id, name, display_name, description, is_system, max_discount_percent, created_at FROM roles ORDER BY id";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRole(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Role getRoleById(int id) {
        String sql = "SELECT id, name, display_name, description, is_system, max_discount_percent, created_at FROM roles WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRole(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Role getRoleByName(String name) {
        String sql = "SELECT id, name, display_name, description, is_system, max_discount_percent, created_at FROM roles WHERE name = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRole(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean createRole(Role role) {
        String sql = "INSERT INTO roles (name, display_name, description, is_system) VALUES (?, ?, ?, 0)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, role.getName().toUpperCase().trim());
            ps.setString(2, role.getDisplayName());
            ps.setString(3, role.getDescription());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) role.setId(keys.getInt(1));
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateRole(Role role) {
        String sql = "UPDATE roles SET display_name = ?, description = ?, max_discount_percent = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role.getDisplayName());
            ps.setString(2, role.getDescription());
            ps.setDouble(3, role.getMaxDiscountPercent() != null ? role.getMaxDiscountPercent() : 100.0);
            ps.setInt(4, role.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteRole(int id) {
        String checkSql = "SELECT COUNT(*) FROM users WHERE role_id = ?";
        String deleteSql = "DELETE FROM roles WHERE id = ? AND is_system = 0";
        try (Connection conn = ds.getConnection()) {
            try (PreparedStatement check = conn.prepareStatement(checkSql)) {
                check.setInt(1, id);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return false;
                }
            }
            try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
                del.setInt(1, id);
                return del.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public int countUsersByRoleId(int roleId) {
        String sql = "SELECT COUNT(*) FROM users WHERE role_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Permission> getPermissionsByRoleId(int roleId) {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT p.id, p.name, p.display_name, p.description, p.group_name, p.created_at " +
                     "FROM permissions p " +
                     "JOIN role_permissions rp ON rp.permission_id = p.id " +
                     "WHERE rp.role_id = ? ORDER BY p.group_name, p.name";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapPermission(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateRolePermissions(int roleId, List<Integer> permissionIds) {
        String deleteSql = "DELETE FROM role_permissions WHERE role_id = ?";
        String insertSql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)";
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement del = conn.prepareStatement(deleteSql)) {
                del.setInt(1, roleId);
                del.executeUpdate();
            }

            if (permissionIds != null && !permissionIds.isEmpty()) {
                try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
                    for (Integer pid : permissionIds) {
                        ins.setInt(1, roleId);
                        ins.setInt(2, pid);
                        ins.addBatch();
                    }
                    ins.executeBatch();
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (Exception ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    private Role mapRole(ResultSet rs) throws SQLException {
        Role r = new Role();
        r.setId(rs.getInt("id"));
        r.setName(rs.getString("name"));
        r.setDisplayName(rs.getString("display_name"));
        r.setDescription(rs.getString("description"));
        r.setIsSystem(rs.getBoolean("is_system"));
        r.setMaxDiscountPercent(rs.getDouble("max_discount_percent"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) r.setCreatedAt(ts.toLocalDateTime());
        return r;
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
