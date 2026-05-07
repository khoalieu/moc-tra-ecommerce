package dao;

import model.user.UserAddress;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserAddressDAO {

    private final DataSource ds;

    // Constructor nhận DataSource từ DAOFactory
    public UserAddressDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<UserAddress> getListAddress(int userId) {
        List<UserAddress> list = new ArrayList<>();
        String sql = "SELECT * FROM user_addresses WHERE user_id = ? ORDER BY is_default DESC, id DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserAddress a = new UserAddress();
                    a.setId(rs.getInt("id"));
                    a.setUserId(rs.getInt("user_id"));
                    a.setFullName(rs.getString("full_name"));
                    a.setPhoneNumber(rs.getString("phone_number"));
                    a.setLabel(rs.getString("label"));
                    a.setProvince(rs.getString("province"));
                    a.setWard(rs.getString("ward"));
                    a.setStreetAddress(rs.getString("street_address"));
                    a.setIsDefault(rs.getBoolean("is_default"));
                    list.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addAddress(UserAddress addr) {
        String sql = "INSERT INTO user_addresses (user_id, full_name, phone_number, label, province, ward, street_address, is_default) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, addr.getUserId());
            ps.setString(2, addr.getFullName());
            ps.setString(3, addr.getPhoneNumber());
            ps.setString(4, addr.getLabel());
            ps.setString(5, addr.getProvince());
            ps.setString(6, addr.getWard());
            ps.setString(7, addr.getStreetAddress());
            ps.setBoolean(8, addr.getIsDefault());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteAddress(int addressId, int userId) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            String checkSql = "SELECT is_default FROM user_addresses WHERE id = ? AND user_id = ?";
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, addressId);
            psCheck.setInt(2, userId);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next() && rs.getBoolean("is_default")) {
                String findOtherSql = "SELECT id FROM user_addresses WHERE user_id = ? AND id != ? LIMIT 1";
                PreparedStatement psFind = conn.prepareStatement(findOtherSql);
                psFind.setInt(1, userId);
                psFind.setInt(2, addressId);
                ResultSet rsOther = psFind.executeQuery();

                if (rsOther.next()) {
                    int newDefaultId = rsOther.getInt("id");
                    String updateSql = "UPDATE user_addresses SET is_default = 1 WHERE id = ?";
                    PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                    psUpdate.setInt(1, newDefaultId);
                    psUpdate.executeUpdate();
                }
            }
            String deleteSql = "DELETE FROM user_addresses WHERE id = ? AND user_id = ?";
            PreparedStatement psDelete = conn.prepareStatement(deleteSql);
            psDelete.setInt(1, addressId);
            psDelete.setInt(2, userId);
            int rowAffected = psDelete.executeUpdate();
            return rowAffected > 0;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }

    public boolean setDefaultAddress(int addressId, int userId) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            String sqlReset = "UPDATE user_addresses SET is_default = 0 WHERE user_id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlReset)) {
                ps1.setInt(1, userId);
                ps1.executeUpdate();
            }
            String sqlSet = "UPDATE user_addresses SET is_default = 1 WHERE id = ? AND user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlSet)) {
                ps2.setInt(1, addressId);
                ps2.setInt(2, userId);
                ps2.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
            }
            e.printStackTrace();
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
            }
        }
        return false;
    }

    public int addAddressAndGetId(UserAddress addr) {
        String sql = "INSERT INTO user_addresses (user_id, full_name, phone_number, label, province, ward, street_address, is_default) VALUES (?,?,?,?,?,?,?,?)";

        // Thêm tham số Statement.RETURN_GENERATED_KEYS để lấy ID vừa tạo
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

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
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
}