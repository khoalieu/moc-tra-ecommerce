package dao;

import model.promotion.Coupon;

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
}