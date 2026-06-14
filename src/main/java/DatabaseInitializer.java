import java.io.InputStream;
import java.io.FileInputStream;
import java.sql.*;
import java.util.Properties;

public class DatabaseInitializer {
    public static void main(String[] args) {
        System.out.println("🚀 Starting database initialization...");
        Properties props = new Properties();
        try {
            try (InputStream input = DatabaseInitializer.class.getClassLoader().getResourceAsStream("database.properties")) {
                if (input != null) {
                    props.load(input);
                    System.out.println("Loaded database.properties from classpath.");
                } else {
                    try (FileInputStream fis = new FileInputStream("src/main/resources/database.properties")) {
                        props.load(fis);
                        System.out.println("Loaded database.properties from file system.");
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("❌ Failed to load database.properties: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }

        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String password = props.getProperty("db.password");

        if (url == null || user == null || password == null) {
            System.err.println("❌ Database credentials are not complete in properties file!");
            System.exit(1);
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver class not found: " + e.getMessage());
        }

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("✅ Connected to database successfully.");

            ensureRoleExists(conn, "CSKH", "Chăm sóc khách hàng", "Nhân viên hỗ trợ khách hàng và tra cứu đơn hàng");
            ensureRoleExists(conn, "MARKETING", "Marketing & Sales", "Đội ngũ quản lý banner, chương trình khuyến mãi và mã giảm giá");

            String[][] missingPerms = {
                {"product.status", "Cập nhật trạng thái sản phẩm", "product"},
                {"order.shipping", "Giao hàng / Tạo vận đơn", "order"},
                {"blog.edit_own", "Sửa bài viết của chính mình", "blog"},
                {"blog.delete_own", "Xóa bài viết của chính mình", "blog"},
                {"blog.delete_all", "Xóa mọi bài viết", "blog"},
                {"blog.manage_category", "Quản lý danh mục bài viết", "blog"},
                {"customer.view_unmasked", "Xem thông tin khách hàng không ẩn", "customer"},
                {"customer.delete", "Xóa khách hàng", "customer"},
                {"contact.manage", "Quản lý liên hệ hỗ trợ", "contact"},
                {"dashboard.view", "Xem trang tổng quan Dashboard", "dashboard"}
            };

            for (String[] perm : missingPerms) {
                String name = perm[0];
                String displayName = perm[1];
                String groupName = perm[2];

                int permId = ensurePermissionExists(conn, name, displayName, groupName);

                if (permId > 0) {
                    mapPermissionToRole(conn, 1, permId, name, "ADMIN");

                    if (name.equals("blog.edit_own") || name.equals("blog.delete_own") || name.equals("dashboard.view")) {
                        mapPermissionToRole(conn, 3, permId, name, "EDITOR");
                    }

                    if (name.equals("dashboard.view")) {
                        int marketingRoleId = getRoleIdByName(conn, "MARKETING");
                        if (marketingRoleId > 0) {
                            mapPermissionToRole(conn, marketingRoleId, permId, name, "MARKETING");
                        }
                        int cskhRoleId = getRoleIdByName(conn, "CSKH");
                        if (cskhRoleId > 0) {
                            mapPermissionToRole(conn, cskhRoleId, permId, name, "CSKH");
                        }
                    }
                }
            }

            setupMarketingRolePermissions(conn);
            setupCSKHRolePermissions(conn);

            System.out.println("🎉 Database initialization completed successfully!");
        } catch (SQLException e) {
            System.err.println("❌ Database error occurred during initialization:");
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void ensureRoleExists(Connection conn, String name, String displayName, String description) throws SQLException {
        String checkSql = "SELECT id FROM roles WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    System.out.println("ℹ️ Role " + name + " already exists (ID: " + rs.getInt("id") + ")");
                    return;
                }
            }
        }

        String insertSql = "INSERT INTO roles (name, display_name, description, max_discount_percent, is_system) VALUES (?, ?, ?, 0.0, 1)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setString(1, name);
            ps.setString(2, displayName);
            ps.setString(3, description);
            ps.executeUpdate();
            System.out.println("➕ Created role: " + name);
        }
    }

    private static int ensurePermissionExists(Connection conn, String name, String displayName, String groupName) throws SQLException {
        String checkSql = "SELECT id FROM permissions WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int id = rs.getInt("id");
                    System.out.println("ℹ️ Permission " + name + " already exists (ID: " + id + ")");
                    return id;
                }
            }
        }

        String insertSql = "INSERT INTO permissions (name, display_name, group_name) VALUES (?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name);
            ps.setString(2, displayName);
            ps.setString(3, groupName);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int id = rs.getInt(1);
                    System.out.println("➕ Inserted permission: " + name + " (ID: " + id + ")");
                    return id;
                }
            }
        }
        return -1;
    }

    private static void mapPermissionToRole(Connection conn, int roleId, int permId, String permName, String roleName) throws SQLException {
        String checkSql = "SELECT 1 FROM role_permissions WHERE role_id = ? AND permission_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return;
                }
            }
        }

        String insertSql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
            ps.setInt(1, roleId);
            ps.setInt(2, permId);
            ps.executeUpdate();
            System.out.println("🔗 Mapped permission '" + permName + "' to role '" + roleName + "'");
        }
    }

    private static int getRoleIdByName(Connection conn, String name) throws SQLException {
        String sql = "SELECT id FROM roles WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        return -1;
    }

    private static int getPermissionIdByName(Connection conn, String name) throws SQLException {
        String sql = "SELECT id FROM permissions WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        return -1;
    }

    private static void setupMarketingRolePermissions(Connection conn) throws SQLException {
        int marketingRoleId = getRoleIdByName(conn, "MARKETING");
        if (marketingRoleId <= 0) return;

        String[] marketingPerms = {
            "banner.manage", "promotion.create", "promotion.manage", "coupon.manage"
        };

        for (String permName : marketingPerms) {
            int permId = getPermissionIdByName(conn, permName);
            if (permId > 0) {
                mapPermissionToRole(conn, marketingRoleId, permId, permName, "MARKETING");
            }
        }
    }

    private static void setupCSKHRolePermissions(Connection conn) throws SQLException {
        int cskhRoleId = getRoleIdByName(conn, "CSKH");
        if (cskhRoleId <= 0) return;

        String[] cskhPerms = {
            "customer.view", "order.view", "contact.manage"
        };

        for (String permName : cskhPerms) {
            int permId = getPermissionIdByName(conn, permName);
            if (permId > 0) {
                mapPermissionToRole(conn, cskhRoleId, permId, permName, "CSKH");
            }
        }
    }
}
