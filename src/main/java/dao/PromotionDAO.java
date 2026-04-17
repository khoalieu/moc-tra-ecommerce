package dao;

import db.DBConnect;
import model.product.Product;
import model.promotion.Promotion;
import model.enums.DiscountType;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAO {

    public List<Promotion> getActivePromotions() {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE is_active = 1 AND start_date <= NOW() AND end_date >= NOW()";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Promotion p = new Promotion();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setDiscountType(DiscountType.valueOf(rs.getString("discount_type")));
                p.setDiscountValue(rs.getDouble("discount_value"));
                p.setStartDate(rs.getTimestamp("start_date").toLocalDateTime());
                p.setEndDate(rs.getTimestamp("end_date").toLocalDateTime());
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getProductsByPromotionId(int promoId, int limit) {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT p.*, pi.promotion_id AS current_promo_id, pr.discount_type, pr.discount_value " +
                "FROM products p " +
                "JOIN promotion_items pi ON p.id = pi.product_id " +
                "JOIN promotions pr ON pr.id = pi.promotion_id " +
                "WHERE pi.promotion_id = ? AND p.status = 'active' " +
                "LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, promoId);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setImageUrl(rs.getString("image_url"));
                p.setShortDescription(rs.getString("short_description"));

                p.setCurrentPromotionId(rs.getInt("current_promo_id"));
                p.setCurrentPromotionType(rs.getString("discount_type"));
                p.setCurrentPromotionValue(rs.getDouble("discount_value"));

                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public String getPromotionName(int promoId) {
        String sql = "SELECT name FROM promotions WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, promoId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("name");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "Chương Trình Khuyến Mãi";
    }

    public void addProductsToPromotion(int promoId, String[] productIds) {
        Connection conn = null;
        PreparedStatement psGetPromo = null;
        PreparedStatement psInsert = null;
        PreparedStatement psUpdatePrice = null;
        PreparedStatement psCleanOld = null;

        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            String sqlGetPromo = "SELECT discount_type, discount_value FROM promotions WHERE id = ?";
            psGetPromo = conn.prepareStatement(sqlGetPromo);
            psGetPromo.setInt(1, promoId);
            ResultSet rs = psGetPromo.executeQuery();

            String type = "";
            double value = 0;

            if (rs.next()) {
                type = rs.getString("discount_type");
                value = rs.getDouble("discount_value");
            } else {
                throw new Exception("Không tìm thấy chương trình khuyến mãi ID: " + promoId);
            }

            String sqlClean = "DELETE FROM promotion_items WHERE product_id = ?";
            psCleanOld = conn.prepareStatement(sqlClean);

            String sqlInsert = "INSERT INTO promotion_items (promotion_id, product_id) VALUES (?, ?)";
            psInsert = conn.prepareStatement(sqlInsert);

            String sqlUpdatePrice = "";
            if ("PERCENT".equals(type)) {
                sqlUpdatePrice = "UPDATE products SET sale_price = price * (100 - ?) / 100 WHERE id = ?";
            } else {
                sqlUpdatePrice = "UPDATE products SET sale_price = GREATEST(0, price - ?) WHERE id = ?";
            }
            psUpdatePrice = conn.prepareStatement(sqlUpdatePrice);

            for (String idStr : productIds) {
                try {
                    int pid = Integer.parseInt(idStr);

                    psCleanOld.setInt(1, pid);
                    psCleanOld.executeUpdate();

                    psInsert.setInt(1, promoId);
                    psInsert.setInt(2, pid);
                    psInsert.executeUpdate();

                    psUpdatePrice.setDouble(1, value);
                    psUpdatePrice.setInt(2, pid);
                    psUpdatePrice.executeUpdate();

                } catch (NumberFormatException e) {
                    System.err.println("Lỗi ID sản phẩm: " + idStr);
                }
            }

            conn.commit();
            System.out.println("Đã thêm vào KM và cập nhật giá (Loại: " + type + ")");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
            }
        } finally {

            try {
                if (psCleanOld != null) psCleanOld.close();
            } catch (Exception e) {
            }
            try {
                if (psGetPromo != null) psGetPromo.close();
            } catch (Exception e) {
            }
            try {
                if (psInsert != null) psInsert.close();
            } catch (Exception e) {
            }
            try {
                if (psUpdatePrice != null) psUpdatePrice.close();
            } catch (Exception e) {
            }
            try {
                if (conn != null) conn.close();
            } catch (Exception e) {
            }
        }
    }

    public void removeProductsFromPromotion(String[] productIds) {
        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psResetPrice = null;

        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            String sqlDelete = "DELETE FROM promotion_items WHERE product_id = ?";
            psDelete = conn.prepareStatement(sqlDelete);

            String sqlResetPrice = "UPDATE products SET sale_price = 0 WHERE id = ?";
            psResetPrice = conn.prepareStatement(sqlResetPrice);

            for (String idStr : productIds) {
                try {
                    int pid = Integer.parseInt(idStr);

                    psDelete.setInt(1, pid);
                    psDelete.executeUpdate();

                    psResetPrice.setInt(1, pid);
                    psResetPrice.executeUpdate();

                } catch (NumberFormatException e) {
                }
            }

            conn.commit();
            System.out.println("Đã gỡ sản phẩm khỏi KM và reset giá!");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
            }
        } finally {
            try {
                if (psDelete != null) psDelete.close();
            } catch (Exception e) {
            }
            try {
                if (psResetPrice != null) psResetPrice.close();
            } catch (Exception e) {
            }
            try {
                if (conn != null) conn.close();
            } catch (Exception e) {
            }
        }
    }

    public List<Promotion> getAllPromotions() {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions ORDER BY created_at DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Promotion p = new Promotion();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setDiscountType(DiscountType.valueOf(rs.getString("discount_type")));
                p.setDiscountValue(rs.getDouble("discount_value"));
                p.setStartDate(rs.getTimestamp("start_date").toLocalDateTime());
                p.setEndDate(rs.getTimestamp("end_date").toLocalDateTime());
                p.setActive(rs.getBoolean("is_active"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertPromotion(Promotion p) {
        String sql = "INSERT INTO promotions (name, description, discount_type, discount_value, start_date, end_date, is_active, image_url, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getDiscountType().name());
            ps.setDouble(4, p.getDiscountValue());
            ps.setTimestamp(5, Timestamp.valueOf(p.getStartDate()));
            ps.setTimestamp(6, Timestamp.valueOf(p.getEndDate()));
            ps.setBoolean(7, p.isActive());
            ps.setString(8, p.getImageUrl());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void togglePromotionStatus(int promoId, boolean newStatus) {
        Connection conn = null;
        try {
            conn = DBConnect.getConnection();
            conn.setAutoCommit(false);

            String sqlUpdateStatus = "UPDATE promotions SET is_active = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateStatus)) {
                ps.setBoolean(1, newStatus);
                ps.setInt(2, promoId);
                ps.executeUpdate();
            }

            if (!newStatus) {
                String sqlResetPrice = "UPDATE products p " +
                        "JOIN promotion_items pi ON p.id = pi.product_id " +
                        "SET p.sale_price = 0 " +
                        "WHERE pi.promotion_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlResetPrice)) {
                    ps.setInt(1, promoId);
                    ps.executeUpdate();
                }

                String sqlDeleteItems = "DELETE FROM promotion_items WHERE promotion_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlDeleteItems)) {
                    ps.setInt(1, promoId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
            }
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException ex) {
            }
        }
    }

    public boolean updatePromotion(Promotion p) {
        String sql = "UPDATE promotions SET name=?, description=?, discount_type=?, discount_value=?, " +
                "start_date=?, end_date=?, image_url=? WHERE id=?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getDiscountType().name());
            ps.setDouble(4, p.getDiscountValue());
            ps.setTimestamp(5, Timestamp.valueOf(p.getStartDate()));
            ps.setTimestamp(6, Timestamp.valueOf(p.getEndDate()));
            ps.setString(7, p.getImageUrl());
            ps.setInt(8, p.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}