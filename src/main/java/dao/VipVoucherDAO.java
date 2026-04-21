package dao;

import db.DBConnect;
import model.promotion.VipVoucher;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VipVoucherDAO {

    public List<VipVoucher> getActiveVouchersForUser(int userId) {
        List<VipVoucher> list = new ArrayList<>();
        String sql = "SELECT vv.* FROM vip_vouchers vv " +
                "JOIN user_vip_vouchers uvv ON vv.id = uvv.voucher_id " +
                "WHERE uvv.user_id = ? " +
                "AND uvv.used_at IS NULL " +
                "AND vv.is_active = 1 " +
                "AND vv.start_date <= NOW() AND vv.end_date >= NOW() " +
                "AND (vv.max_uses IS NULL OR vv.current_uses < vv.max_uses)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public VipVoucher getActiveVoucherForUser(int userId, int voucherId) {
        String sql = "SELECT vv.* FROM vip_vouchers vv " +
                "JOIN user_vip_vouchers uvv ON vv.id = uvv.voucher_id " +
                "WHERE uvv.user_id = ? " +
                "AND uvv.voucher_id = ? " +
                "AND uvv.used_at IS NULL " +
                "AND vv.is_active = 1 " +
                "AND vv.start_date <= NOW() AND vv.end_date >= NOW() " +
                "AND (vv.max_uses IS NULL OR vv.current_uses < vv.max_uses) " +
                "LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapVoucher(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public VipVoucher getVoucherByCode(String code) {
        String sql = "SELECT * FROM vip_vouchers WHERE code = ? AND is_active = 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapVoucher(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public void incrementVoucherUsage(int voucherId) {
        String sql = "UPDATE vip_vouchers SET current_uses = current_uses + 1 WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void markVoucherUsed(int userId, int voucherId) {
        String sql = "UPDATE user_vip_vouchers " +
                "SET used_at = NOW() " +
                "WHERE user_id = ? AND voucher_id = ? AND used_at IS NULL " +
                "LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void addVoucherToUser(int userId, int voucherId) {
        String sql = "INSERT INTO user_vip_vouchers (user_id, voucher_id) VALUES (?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, voucherId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<VipVoucher> getAllVouchers() {
        List<VipVoucher> list = new ArrayList<>();
        String sql = "SELECT * FROM vip_vouchers ORDER BY created_at DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapVoucher(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public VipVoucher getVoucherById(int voucherId) {
        String sql = "SELECT * FROM vip_vouchers WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, voucherId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapVoucher(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private VipVoucher mapVoucher(ResultSet rs) throws SQLException {
        VipVoucher voucher = new VipVoucher();
        voucher.setId(rs.getInt("id"));
        voucher.setCode(rs.getString("code"));
        voucher.setDiscountType(rs.getString("discount_type"));
        voucher.setDiscountValue(rs.getDouble("discount_value"));

        int maxUses = rs.getInt("max_uses");
        if (rs.wasNull()) {
            voucher.setMaxUses(null);
        } else {
            voucher.setMaxUses(maxUses);
        }

        voucher.setCurrentUses(rs.getInt("current_uses"));
        voucher.setActive(rs.getBoolean("is_active"));

        Timestamp startTs = rs.getTimestamp("start_date");
        if (startTs != null) {
            voucher.setStartDate(startTs.toLocalDateTime());
        }

        Timestamp endTs = rs.getTimestamp("end_date");
        if (endTs != null) {
            voucher.setEndDate(endTs.toLocalDateTime());
        }

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            voucher.setCreatedAt(createdTs.toLocalDateTime());
        }

        return voucher;
    }
}