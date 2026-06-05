package dao;

import model.promotion.Coupon;
import service.NotificationService;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class CouponDAO {
    private final DataSource ds;

    public CouponDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Coupon> getActiveCouponsForPromotionPage() {
        List<Coupon> list = new ArrayList<>();

        String sql = "SELECT * FROM coupons " +
                "WHERE is_active = 1 " +
                "AND start_date <= NOW() " +
                "AND end_date >= NOW() " +
                "ORDER BY created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapCoupon(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Set<Integer> getClaimedCouponIdsByUser(int userId) {
        Set<Integer> ids = new HashSet<>();

        String sql = "SELECT coupon_id FROM user_coupons WHERE user_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("coupon_id"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return ids;
    }

    public String claimCoupon(int userId, int couponId) {
        Connection conn = null;

        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);

            String checkClaimedSql = "SELECT id FROM user_coupons WHERE user_id = ? AND coupon_id = ? LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(checkClaimedSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, couponId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        return "ALREADY_CLAIMED";
                    }
                }
            }

            String getCouponSql = "SELECT * FROM coupons " +
                    "WHERE id = ? " +
                    "AND is_active = 1 " +
                    "AND start_date <= NOW() " +
                    "AND end_date >= NOW() " +
                    "FOR UPDATE";

            Coupon coupon = null;

            try (PreparedStatement ps = conn.prepareStatement(getCouponSql)) {
                ps.setInt(1, couponId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        coupon = mapCoupon(rs);
                    }
                }
            }

            if (coupon == null) {
                conn.rollback();
                return "NOT_FOUND";
            }

            if (coupon.getClaimLimit() != null && coupon.getCurrentClaims() >= coupon.getClaimLimit()) {
                conn.rollback();
                return "OUT_OF_STOCK";
            }

            String insertSql = "INSERT INTO user_coupons (user_id, coupon_id, claimed_at) VALUES (?, ?, NOW())";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, couponId);
                ps.executeUpdate();
            }

            String updateSql = "UPDATE coupons SET current_claims = current_claims + 1 WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, couponId);
                ps.executeUpdate();
            }

            conn.commit();
            new NotificationService().notifyAdminCouponLifecycle(getCouponById(couponId));
            return "SUCCESS";

        } catch (SQLIntegrityConstraintViolationException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }
            return "ALREADY_CLAIMED";

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }
            return "ERROR";

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    private Coupon mapCoupon(ResultSet rs) throws SQLException {
        Coupon c = new Coupon();

        c.setId(rs.getInt("id"));
        c.setCode(rs.getString("code"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        c.setDiscountType(rs.getString("discount_type"));
        c.setDiscountValue(rs.getDouble("discount_value"));

        double maxDiscount = rs.getDouble("max_discount_amount");
        if (rs.wasNull()) {
            c.setMaxDiscountAmount(null);
        } else {
            c.setMaxDiscountAmount(maxDiscount);
        }

        c.setMinOrderAmount(rs.getDouble("min_order_amount"));

        int claimLimit = rs.getInt("claim_limit");
        if (rs.wasNull()) {
            c.setClaimLimit(null);
        } else {
            c.setClaimLimit(claimLimit);
        }

        c.setCurrentClaims(rs.getInt("current_claims"));

        int maxUses = rs.getInt("max_uses");
        if (rs.wasNull()) {
            c.setMaxUses(null);
        } else {
            c.setMaxUses(maxUses);
        }

        c.setCurrentUses(rs.getInt("current_uses"));

        Timestamp start = rs.getTimestamp("start_date");
        if (start != null) {
            c.setStartDate(start.toLocalDateTime());
        }

        Timestamp end = rs.getTimestamp("end_date");
        if (end != null) {
            c.setEndDate(end.toLocalDateTime());
        }

        c.setActive(rs.getBoolean("is_active"));

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            c.setCreatedAt(created.toLocalDateTime());
        }

        return c;
    }
    public List<Coupon> getUsableCouponsForUser(int userId, double subtotal) {
        List<Coupon> list = new ArrayList<>();

        String sql = "SELECT c.* FROM coupons c " +
                "JOIN user_coupons uc ON c.id = uc.coupon_id " +
                "WHERE uc.user_id = ? " +
                "AND uc.used_at IS NULL " +
                "AND c.is_active = 1 " +
                "AND c.start_date <= NOW() " +
                "AND c.end_date >= NOW() " +
                "AND c.min_order_amount <= ? " +
                "AND (c.max_uses IS NULL OR c.current_uses < c.max_uses) " +
                "ORDER BY c.created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setDouble(2, subtotal);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCoupon(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Coupon getValidClaimedCouponForCheckout(int userId, int couponId, double subtotal) {
        String sql = "SELECT c.* FROM coupons c " +
                "JOIN user_coupons uc ON c.id = uc.coupon_id " +
                "WHERE uc.user_id = ? " +
                "AND uc.coupon_id = ? " +
                "AND uc.used_at IS NULL " +
                "AND c.is_active = 1 " +
                "AND c.start_date <= NOW() " +
                "AND c.end_date >= NOW() " +
                "AND c.min_order_amount <= ? " +
                "AND (c.max_uses IS NULL OR c.current_uses < c.max_uses) " +
                "LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, couponId);
            ps.setDouble(3, subtotal);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public Coupon getValidCouponByCodeForCheckout(int userId, String code, double subtotal) {
        String sql = "SELECT c.* FROM coupons c " +
                "LEFT JOIN user_coupons uc ON c.id = uc.coupon_id AND uc.user_id = ? " +
                "WHERE c.code = ? " +
                "AND c.is_active = 1 " +
                "AND c.start_date <= NOW() " +
                "AND c.end_date >= NOW() " +
                "AND c.min_order_amount <= ? " +
                "AND (c.max_uses IS NULL OR c.current_uses < c.max_uses) " +
                "AND (uc.used_at IS NULL) " +
                "LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, code.trim());
            ps.setDouble(3, subtotal);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean markCouponUsed(int userId, int couponId) {
        Connection conn = null;

        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);

            String checkCouponSql = "SELECT id FROM coupons " +
                    "WHERE id = ? " +
                    "AND is_active = 1 " +
                    "AND start_date <= NOW() " +
                    "AND end_date >= NOW() " +
                    "AND (max_uses IS NULL OR current_uses < max_uses) " +
                    "FOR UPDATE";

            boolean valid = false;

            try (PreparedStatement ps = conn.prepareStatement(checkCouponSql)) {
                ps.setInt(1, couponId);
                try (ResultSet rs = ps.executeQuery()) {
                    valid = rs.next();
                }
            }

            if (!valid) {
                conn.rollback();
                return false;
            }

            String checkUserCouponSql = "SELECT id, used_at FROM user_coupons WHERE user_id = ? AND coupon_id = ? LIMIT 1";
            Integer userCouponId = null;
            Timestamp usedAt = null;

            try (PreparedStatement ps = conn.prepareStatement(checkUserCouponSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, couponId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userCouponId = rs.getInt("id");
                        usedAt = rs.getTimestamp("used_at");
                    }
                }
            }

            if (usedAt != null) {
                conn.rollback();
                return false;
            }

            if (userCouponId == null) {
                String insertSql = "INSERT INTO user_coupons (user_id, coupon_id, claimed_at, used_at) VALUES (?, ?, NOW(), NOW())";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, couponId);
                    ps.executeUpdate();
                }
            } else {
                String updateUserCouponSql = "UPDATE user_coupons SET used_at = NOW() WHERE id = ? AND used_at IS NULL";
                try (PreparedStatement ps = conn.prepareStatement(updateUserCouponSql)) {
                    ps.setInt(1, userCouponId);
                    if (ps.executeUpdate() == 0) {
                        conn.rollback();
                        return false;
                    }
                }
            }

            String updateCouponSql = "UPDATE coupons SET current_uses = current_uses + 1 WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateCouponSql)) {
                ps.setInt(1, couponId);
                ps.executeUpdate();
            }

            conn.commit();
            new NotificationService().notifyAdminCouponLifecycle(getCouponById(couponId));
            return true;

        } catch (Exception e) {
            e.printStackTrace();

            try {
                if (conn != null) conn.rollback();
            } catch (Exception ignored) {
            }

            return false;

        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    public void markCouponUsed(Connection conn, int userId, int couponId) throws SQLException {
        String checkUserCouponSql = "SELECT id, used_at FROM user_coupons WHERE user_id = ? AND coupon_id = ? LIMIT 1";
        Integer userCouponId = null;
        Timestamp usedAt = null;

        try (PreparedStatement ps = conn.prepareStatement(checkUserCouponSql)) {
            ps.setInt(1, userId);
            ps.setInt(2, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    userCouponId = rs.getInt("id");
                    usedAt = rs.getTimestamp("used_at");
                }
            }
        }

        if (usedAt != null) {
            return;
        }

        if (userCouponId == null) {
            String insertSql = "INSERT INTO user_coupons (user_id, coupon_id, claimed_at, used_at) VALUES (?, ?, NOW(), NOW())";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, couponId);
                ps.executeUpdate();
            }
        } else {
            String updateUserCouponSql = "UPDATE user_coupons SET used_at = NOW() WHERE id = ? AND used_at IS NULL";
            try (PreparedStatement ps = conn.prepareStatement(updateUserCouponSql)) {
                ps.setInt(1, userCouponId);
                ps.executeUpdate();
            }
        }

        String updateCouponSql = "UPDATE coupons SET current_uses = current_uses + 1 WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(updateCouponSql)) {
            ps.setInt(1, couponId);
            ps.executeUpdate();
        }
    }

    public double calculateDiscount(Coupon coupon, double subtotal) {
        if (coupon == null) return 0;

        double discount;

        if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
            discount = subtotal * coupon.getDiscountValue() / 100.0;

            if (coupon.getMaxDiscountAmount() != null) {
                discount = Math.min(discount, coupon.getMaxDiscountAmount());
            }
        } else {
            discount = coupon.getDiscountValue();
        }

        return Math.min(discount, subtotal);
    }
    public List<Coupon> getAvailableCouponsForUser(int userId) {
        List<Coupon> list = new ArrayList<>();

        String sql = "SELECT c.* FROM coupons c " +
                "JOIN user_coupons uc ON c.id = uc.coupon_id " +
                "WHERE uc.user_id = ? " +
                "AND uc.used_at IS NULL " +
                "AND c.is_active = 1 " +
                "AND c.start_date <= NOW() " +
                "AND c.end_date >= NOW() " +
                "AND (c.max_uses IS NULL OR c.current_uses < c.max_uses) " +
                "ORDER BY c.end_date ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapCoupon(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public List<Coupon> getAllCoupons() {
        List<Coupon> list = new ArrayList<>();

        String sql = "SELECT * FROM coupons ORDER BY created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapCoupon(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Coupon getCouponById(int couponId) {
        String sql = "SELECT * FROM coupons WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, couponId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapCoupon(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean insertCoupon(Coupon coupon) {
        String sql = "INSERT INTO coupons " +
                "(code, title, description, discount_type, discount_value, max_discount_amount, min_order_amount, " +
                "claim_limit, current_claims, max_uses, current_uses, start_date, end_date, is_active, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, 0, ?, ?, 1, NOW())";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, coupon.getCode());
            ps.setString(2, coupon.getTitle());
            ps.setString(3, coupon.getDescription());
            ps.setString(4, coupon.getDiscountType());
            ps.setDouble(5, coupon.getDiscountValue());

            if (coupon.getMaxDiscountAmount() == null) {
                ps.setNull(6, Types.DECIMAL);
            } else {
                ps.setDouble(6, coupon.getMaxDiscountAmount());
            }

            ps.setDouble(7, coupon.getMinOrderAmount());

            if (coupon.getClaimLimit() == null) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, coupon.getClaimLimit());
            }

            if (coupon.getMaxUses() == null) {
                ps.setNull(9, Types.INTEGER);
            } else {
                ps.setInt(9, coupon.getMaxUses());
            }

            ps.setTimestamp(10, Timestamp.valueOf(coupon.getStartDate()));
            ps.setTimestamp(11, Timestamp.valueOf(coupon.getEndDate()));

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateCoupon(Coupon coupon) {
        String sql = "UPDATE coupons SET " +
                "code = ?, title = ?, description = ?, discount_type = ?, discount_value = ?, " +
                "max_discount_amount = ?, min_order_amount = ?, claim_limit = ?, max_uses = ?, " +
                "start_date = ?, end_date = ?, is_active = ? " +
                "WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, coupon.getCode());
            ps.setString(2, coupon.getTitle());
            ps.setString(3, coupon.getDescription());
            ps.setString(4, coupon.getDiscountType());
            ps.setDouble(5, coupon.getDiscountValue());

            if (coupon.getMaxDiscountAmount() == null) {
                ps.setNull(6, Types.DECIMAL);
            } else {
                ps.setDouble(6, coupon.getMaxDiscountAmount());
            }

            ps.setDouble(7, coupon.getMinOrderAmount());

            if (coupon.getClaimLimit() == null) {
                ps.setNull(8, Types.INTEGER);
            } else {
                ps.setInt(8, coupon.getClaimLimit());
            }

            if (coupon.getMaxUses() == null) {
                ps.setNull(9, Types.INTEGER);
            } else {
                ps.setInt(9, coupon.getMaxUses());
            }

            ps.setTimestamp(10, Timestamp.valueOf(coupon.getStartDate()));
            ps.setTimestamp(11, Timestamp.valueOf(coupon.getEndDate()));
            ps.setBoolean(12, coupon.isActive());
            ps.setInt(13, coupon.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean toggleCouponStatus(int couponId, boolean active) {
        String sql = "UPDATE coupons SET is_active = ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, couponId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteCoupon(int couponId) {
        String sql = "DELETE FROM coupons WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, couponId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}