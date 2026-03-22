package dao;

import db.DBConnect;
import model.user.CustomerDTO;
import model.user.User;
import model.user.UserAddress;
import model.enums.UserGender;
import model.enums.UserRole;
import org.mindrot.jbcrypt.BCrypt;
import model.GooglePojo;
import java.util.UUID;

import java.sql.*;
import java.util.*;

public class UserDAO {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    public User checkLogin(String username, String password) {
        try {
            String query = "SELECT * FROM users WHERE username = ? AND is_active = 1";
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, username);
            rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password_hash");
                boolean isVerified = BCrypt.checkpw(password, storedHash);

                if (isVerified) {
                    User user = new User();
                    user.setId(rs.getInt("id"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setFirstName(rs.getString("first_name"));
                    user.setLastName(rs.getString("last_name"));
                    user.setPhone(rs.getString("phone"));
                    java.sql.Timestamp ts = rs.getTimestamp("dateOfBirth");
                    if (ts != null) {
                        user.setDateOfBirth(ts.toLocalDateTime());
                    }
                    String genderStr = rs.getString("gender");
                    if (genderStr != null) {
                        try {
                            user.setGender(UserGender.valueOf(genderStr.toUpperCase()));
                        } catch (IllegalArgumentException e) {
                            user.setGender(UserGender.OTHER);
                        }
                    }
                    try {
                        user.setRole(UserRole.valueOf(rs.getString("role").toUpperCase()));
                    } catch (Exception e) {
                        user.setRole(UserRole.CUSTOMER);
                    }

                    return user;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean checkUserExist(String username, String email) {
        try {
            String query = "SELECT id FROM users WHERE username = ? OR email = ?";
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            if (rs.next()) return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void register(String username, String password, String phone, String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

            String query = "INSERT INTO users (username, password_hash, phone, email, role, is_active, created_at) VALUES (?, ?, ?, ?, 'customer', 1, NOW())";
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, hashedPassword);
            ps.setString(3, phone);
            if (email == null || email.trim().isEmpty()) {
                ps.setNull(4, java.sql.Types.VARCHAR);
            } else {
                ps.setString(4, email.trim());
            }
            int result = ps.executeUpdate();
            System.out.println("Kết quả lưu DB: "+ (result > 0? "Thành công":"Thất bại!"));
        } catch (Exception e) {
            System.out.println("Lỗi tại DAO "+e.getMessage());
            e.printStackTrace();
        }finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }

    public Map<Integer, User> getUserMapByPostId(int postId) {
        Map<Integer, User> map = new HashMap<>();

        String sql = "SELECT DISTINCT u.id, u.first_name, u.last_name, u.avatar "
                + "FROM users u "
                + "JOIN blog_comments bc ON bc.user_id = u.id "
                + "WHERE bc.post_id = ?";

        try (Connection c = new DBConnect().getConnection();
             PreparedStatement p = c.prepareStatement(sql)) {
            p.setInt(1, postId);
            try (ResultSet r = p.executeQuery()) {
                while (r.next()) {
                    User u = new User();
                    u.setId(r.getInt("id"));
                    u.setFirstName(r.getString("first_name"));
                    u.setLastName(r.getString("last_name"));
                    u.setAvatar(r.getString("avatar"));
                    map.put(u.getId(), u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    public boolean updateProfile(String firstname, String lastname, String phone, String dob, String gender, int userId) throws SQLException {
        String query = "UPDATE users SET first_name = ?, last_name = ?, phone = ?, dateOfBirth = ?, gender = ? WHERE id = ?";

        try (Connection conn = new DBConnect().getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, firstname);
            ps.setString(2, lastname);
            ps.setString(3, phone);

            if (dob != null && !dob.trim().isEmpty()) {
                ps.setDate(4, java.sql.Date.valueOf(dob));
            } else {
                ps.setNull(4, java.sql.Types.DATE);
            }
            if (gender != null) {
                ps.setString(5, gender.toLowerCase());
            } else {
                ps.setString(5, "other");
            }
            ps.setInt(6, userId);

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            System.err.println("Lỗi updateProfile: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean changePassword(int userId, String newPassword) {
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
        String query = "UPDATE users SET password_hash = ? WHERE id = ?";
        try {
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean checkPassword(int userId, String oldPassword) {
        String query = "SELECT password_hash FROM users WHERE id = ?";
        try {
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                String currentHash = rs.getString("password_hash");
                return BCrypt.checkpw(oldPassword, currentHash);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getAllAdminUsers() {
        List<User> list = new ArrayList<>();
        String sql =
                "SELECT id, username, first_name, last_name , email " +
                        "FROM users " +
                        "WHERE role IN ('admin','editor') " +
                        "ORDER BY username";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setFirstName(rs.getString("first_name"));
                u.setLastName(rs.getString("last_name"));
                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public User getById(int id) {
        String sql = "SELECT id, username, email, first_name, last_name, avatar, role FROM users WHERE id=? LIMIT 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Map<Integer, User> getMapByIds(Collection<Integer> ids) {
        Map<Integer, User> map = new HashMap<>();
        if (ids == null || ids.isEmpty()) return map;

        StringJoiner sj = new StringJoiner(",", "(", ")");
        for (int i = 0; i < ids.size(); i++) sj.add("?");

        String sql = "SELECT id, username, email, first_name, last_name, avatar, role FROM users WHERE id IN " + sj;
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            for (Integer id : ids) ps.setInt(idx++, id);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User u = map(rs);
                    map.put(u.getId(), u);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    private User map(ResultSet rs) throws Exception {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setFirstName(rs.getString("first_name"));
        u.setLastName(rs.getString("last_name"));
        u.setAvatar(rs.getString("avatar"));

        String role = rs.getString("role");
        if (role != null) u.setRole(UserRole.valueOf(role.trim().toUpperCase()));

        return u;
    }
    public Integer findUserIdByEmail(String email) {
        String sql = "SELECT id FROM users WHERE email = ? LIMIT 1";
        try (Connection conn = new DBConnect().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserDetailById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUsername(rs.getString("username"));
                    u.setEmail(rs.getString("email"));
                    u.setFirstName(rs.getString("first_name"));
                    u.setLastName(rs.getString("last_name"));
                    u.setPhone(rs.getString("phone"));
                    u.setAvatar(rs.getString("avatar"));

                    try {
                        String roleStr = rs.getString("role");
                        if(roleStr != null) u.setRole(UserRole.valueOf(roleStr.toUpperCase()));
                    } catch (Exception e) { u.setRole(UserRole.CUSTOMER); }

                    try {
                        String genderStr = rs.getString("gender");
                        if(genderStr != null) u.setGender(UserGender.valueOf(genderStr.toUpperCase()));
                    } catch (Exception e) { u.setGender(UserGender.OTHER); }

                    if (rs.getTimestamp("dateOfBirth") != null)
                        u.setDateOfBirth(rs.getTimestamp("dateOfBirth").toLocalDateTime());

                    if (rs.getTimestamp("created_at") != null)
                        u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

                    u.setIsActive(rs.getBoolean("is_active"));
                    return u;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public List<CustomerDTO> getCustomers(String search, String status, String spendingRange, String orderRange, String sort, int index, int size) {
        List<CustomerDTO> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT u.id, CONCAT(u.last_name, ' ', u.first_name) AS full_name, " +
                        "u.email, u.phone, u.created_at, u.is_active, " +
                        "ua.province, " +
                        "COUNT(o.id) AS total_orders, " +
                        "COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount ELSE 0 END), 0) AS total_spent, " +
                        "MAX(o.created_at) AS last_order_date " +
                        "FROM users u " +
                        "LEFT JOIN user_addresses ua ON u.id = ua.user_id AND ua.is_default = 1 " +
                        "LEFT JOIN orders o ON u.id = o.user_id " +
                        "WHERE u.role = 'customer' "
        );

        if (search != null && !search.isEmpty()) {
            sql.append(" AND (u.email LIKE ? OR u.phone LIKE ? OR CONCAT(u.last_name, ' ', u.first_name) LIKE ?) ");
        }

        sql.append(" GROUP BY u.id HAVING 1=1 ");

        if (spendingRange != null && !spendingRange.isEmpty()) {
            if (spendingRange.contains("-")) {
                String[] parts = spendingRange.split("-");
                sql.append(" AND total_spent BETWEEN ").append(parts[0]).append(" AND ").append(parts[1]);
            } else if (spendingRange.endsWith("+")) {
                String min = spendingRange.replace("+", "");
                sql.append(" AND total_spent >= ").append(min);
            }
        }
        if (orderRange != null && !orderRange.isEmpty()) {
            if (orderRange.equals("0")) {
                sql.append(" AND total_orders = 0 ");
            } else if (orderRange.contains("-")) {
                try {
                    String[] parts = orderRange.split("-");
                    int min = Integer.parseInt(parts[0]);
                    int max = Integer.parseInt(parts[1]);
                    sql.append(" AND total_orders BETWEEN ").append(min).append(" AND ").append(max);
                } catch (NumberFormatException e) {
                }
            } else if (orderRange.endsWith("+")) {
                try {
                    int min = Integer.parseInt(orderRange.replace("+", ""));
                    sql.append(" AND total_orders > ").append(min);
                } catch (NumberFormatException e) {
                }
            }
        }

        if (status != null && !status.isEmpty()) {
            switch (status) {
                case "inactive":
                    sql.append(" AND u.is_active = 0 ");
                    break;
                case "vip":
                    sql.append(" AND total_spent > 5000000 AND u.is_active = 1 ");
                    break;
                case "new":
                    sql.append(" AND DATEDIFF(NOW(), u.created_at) < 30 AND u.is_active = 1 ");
                    break;
                case "active":
                    sql.append(" AND u.is_active = 1 ");
                    break;
            }
        }

        if (sort != null) {
            switch (sort) {
                case "spending-desc": sql.append(" ORDER BY total_spent DESC "); break;
                case "spending-asc": sql.append(" ORDER BY total_spent ASC "); break;
                case "orders-desc": sql.append(" ORDER BY total_orders DESC "); break;
                case "oldest": sql.append(" ORDER BY u.created_at ASC "); break;
                default: sql.append(" ORDER BY u.created_at DESC "); // Default newest
            }
        } else {
            sql.append(" ORDER BY u.created_at DESC ");
        }

        sql.append(" LIMIT ? OFFSET ?");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
                ps.setString(paramIndex++, searchPattern);
            }

            ps.setInt(paramIndex++, size);
            ps.setInt(paramIndex++, (index - 1) * size);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CustomerDTO c = new CustomerDTO();
                c.setId(rs.getInt("id"));
                c.setFullName(rs.getString("full_name"));
                c.setEmail(rs.getString("email"));
                c.setPhone(rs.getString("phone"));
                c.setJoinDate(rs.getTimestamp("created_at"));
                c.setActive(rs.getBoolean("is_active"));
                c.setProvince(rs.getString("province"));
                c.setTotalOrders(rs.getInt("total_orders"));
                c.setTotalSpent(rs.getDouble("total_spent"));
                c.setLastOrderDate(rs.getTimestamp("last_order_date"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public int countCustomers(String search, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users u WHERE u.role = 'customer'");
        if (search != null && !search.isEmpty()) {
            sql.append(" AND (u.email LIKE ? OR u.phone LIKE ? OR CONCAT(u.last_name, ' ', u.first_name) LIKE ?) ");
        }
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
                ps.setString(3, searchPattern);
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    public boolean updateStatusBulk(List<Integer> ids, boolean isActive) {
        String sql = "UPDATE users SET is_active = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sql);

            for (Integer id : ids) {
                ps.setInt(1, isActive ? 1 : 0);
                ps.setInt(2, id);
                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try { if (ps != null) ps.close(); if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return false;
    }
    public List<Integer> getAllCustomerIds(String search, String status, String spendingRange, String orderRange) {
        List<Integer> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.id, " +
                        "COUNT(o.id) AS total_orders, " +
                        "COALESCE(SUM(CASE WHEN o.status = 'completed' THEN o.total_amount ELSE 0 END), 0) AS total_spent " +
                        "FROM users u " +
                        "LEFT JOIN orders o ON u.id = o.user_id " +
                        "WHERE u.role = 'customer' "
        );

        if (search != null && !search.isEmpty()) {
            sql.append(" AND (u.email LIKE ? OR u.phone LIKE ? OR CONCAT(u.last_name, ' ', u.first_name) LIKE ?) ");
        }

        sql.append(" GROUP BY u.id HAVING 1=1 ");

        if (spendingRange != null && !spendingRange.isEmpty()) {
            if (spendingRange.contains("-")) {
                String[] parts = spendingRange.split("-");
                sql.append(" AND total_spent BETWEEN ").append(parts[0]).append(" AND ").append(parts[1]);
            } else if (spendingRange.endsWith("+")) {
                sql.append(" AND total_spent >= ").append(spendingRange.replace("+", ""));
            }
        }

        if (orderRange != null && !orderRange.isEmpty()) {
            if (orderRange.equals("0")) {
                sql.append(" AND total_orders = 0 ");
            } else if (orderRange.contains("-")) {
                String[] parts = orderRange.split("-");
                sql.append(" AND total_orders BETWEEN ").append(parts[0]).append(" AND ").append(parts[1]);
            } else if (orderRange.endsWith("+")) {
                sql.append(" AND total_orders > ").append(orderRange.replace("+", ""));
            }
        }

        if (status != null && !status.isEmpty()) {
            switch (status) {
                case "inactive": sql.append(" AND u.is_active = 0 "); break;
                case "active": sql.append(" AND u.is_active = 1 "); break;
                case "vip": sql.append(" AND total_spent > 5000000 AND u.is_active = 1 "); break;
                case "new": sql.append(" AND DATEDIFF(NOW(), u.created_at) < 30 AND u.is_active = 1 "); break;
            }
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (search != null && !search.isEmpty()) {
                String searchPattern = "%" + search + "%";
                ps.setString(1, searchPattern);
                ps.setString(2, searchPattern);
                ps.setString(3, searchPattern);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getInt("id"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public int addAddressAndGetId(UserAddress addr) {
        String sql = "INSERT INTO user_addresses (user_id, full_name, phone_number, label, province, ward, street_address, is_default) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, addr.getUserId());
            ps.setString(2, addr.getFullName());
            ps.setString(3, addr.getPhoneNumber());
            ps.setString(4, addr.getLabel());
            ps.setString(5, addr.getProvince());
            ps.setString(6, addr.getWard());
            ps.setString(7, addr.getStreetAddress());
            ps.setBoolean(8, addr.getIsDefault());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1); // Trả về ID mới tạo
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return -1;
    }
    public boolean updateUserByAdmin(User u) {
        String sql = "UPDATE users SET first_name=?, last_name=?, phone=?, role=?, is_active=? WHERE id=?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, u.getFirstName());
            ps.setString(2, u.getLastName());
            ps.setString(3, u.getPhone());
            ps.setString(4, u.getRole().name());
            ps.setBoolean(5, u.getIsActive());
            ps.setInt(6, u.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public User loginWithGoogle(GooglePojo googleData) {
        // 1. Kiểm tra email đã tồn tại chưa
        String queryFind = "SELECT * FROM users WHERE email = ?";
        try {
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(queryFind);
            ps.setString(1, googleData.getEmail());
            rs = ps.executeQuery();

            if (rs.next()) {
                // Email đã tồn tại -> Trả về User để đăng nhập
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setFirstName(rs.getString("first_name"));
                user.setLastName(rs.getString("last_name"));
                user.setAvatar(rs.getString("avatar"));
                // Set role và các thông tin khác tương tự hàm checkLogin
                try {
                    user.setRole(UserRole.valueOf(rs.getString("role").toUpperCase()));
                } catch (Exception e) {
                    user.setRole(UserRole.CUSTOMER);
                }
                return user;
            } else {
                // Email chưa tồn tại -> Đăng ký mới
                // Vì bảng users yêu cầu password_hash NOT NULL, ta tạo password ngẫu nhiên
                String randomPassword = UUID.randomUUID().toString();
                String hashedPassword = BCrypt.hashpw(randomPassword, BCrypt.gensalt(12));
                // Username lấy từ email (bỏ phần @domain) hoặc random
                String newUsername = googleData.getEmail().split("@")[0];

                // Kiểm tra trùng username, nếu trùng thì append số random
                if(checkUserExist(newUsername, "")) {
                    newUsername += "_" + (int)(Math.random() * 1000);
                }

                String queryInsert = "INSERT INTO users (username, email, password_hash, first_name, last_name, avatar, role, is_active, created_at) VALUES (?, ?, ?, ?, ?, ?, 'customer', 1, NOW())";

                ps = conn.prepareStatement(queryInsert, Statement.RETURN_GENERATED_KEYS);
                ps.setString(1, newUsername);
                ps.setString(2, googleData.getEmail());
                ps.setString(3, hashedPassword);
                ps.setString(4, googleData.getFirstName());
                ps.setString(5, googleData.getLastName());
                ps.setString(6, googleData.getPicture());

                ps.executeUpdate();
                ResultSet generatedKeys = ps.getGeneratedKeys();
                if (generatedKeys.next()) {
                    User newUser = new User();
                    newUser.setId(generatedKeys.getInt(1));
                    newUser.setEmail(googleData.getEmail());
                    newUser.setUsername(newUsername);
                    newUser.setFirstName(googleData.getFirstName());
                    newUser.setLastName(googleData.getLastName());
                    newUser.setAvatar(googleData.getPicture());
                    newUser.setRole(UserRole.CUSTOMER);
                    return newUser;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public String checkUserExistDetailed(String username, String phone) {
        try {
            String query = "SELECT username, phone FROM users WHERE username = ? OR phone = ? LIMIT 1";
            conn = new DBConnect().getConnection();
            ps = conn.prepareStatement(query);
            ps.setString(1, username);
            ps.setString(2, phone);
            rs = ps.executeQuery();

            if (rs.next()) {
                String dbUsername = rs.getString("username");
                String dbPhone = rs.getString("phone");
                List<String> duplicatedFields = new ArrayList<>();
                if (username.equalsIgnoreCase(dbUsername)) {
                    duplicatedFields.add("Tên đăng nhập");
                }
                if (phone.equals(dbPhone)) {
                    duplicatedFields.add("Số điện thoại");
                }
                if (!duplicatedFields.isEmpty()) {
                    return String.join(", ", duplicatedFields) + " đã tồn tại trong hệ thống!";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean isValidCarrier(String phone) {
        if (phone == null || phone.length() < 3) return false;
        String prefix = phone.substring(0, 3);
        String[] validPrefixes = {
                "032", "033", "034", "035", "036", "037", "038", "039", // Viettel
                "070", "079", "077", "076", "078", "089", "090", "093", // Mobi
                "081", "082", "083", "084", "085", "088", "091", "094", // Vina
                "056", "058", "092", // Vietnamobile
                "059", "099" // Gmobile
        };
        for (String p : validPrefixes) {
            if (prefix.equals(p)) return true;
        }
        return false;
    }

}