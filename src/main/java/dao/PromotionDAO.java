package dao;

import model.product.Product;
import model.promotion.Promotion;
import model.enums.DiscountType;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAO {
    private final DataSource ds;
    private static final String VARIANT_SUMMARY_SELECT =
            ", (SELECT COALESCE(SUM(v.stock_quantity), 0) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS variant_total_stock " +
            ", (SELECT COUNT(*) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS variant_count " +
            ", (SELECT MIN(v.price) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS min_variant_price " +
            ", (SELECT MAX(v.price) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS max_variant_price " +
            ", (SELECT MIN(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) " +
                    "FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1) AS min_variant_effective_price " +
            ", (SELECT MAX(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) " +
                    "FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1) AS max_variant_effective_price ";

    public PromotionDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Promotion> getActivePromotions() {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE is_active = 1 AND approval_status = 'APPROVED' AND start_date <= NOW() AND end_date >= NOW()";

        try (Connection conn = ds.getConnection();
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
                p.setApprovalStatus(rs.getString("approval_status"));
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
                VARIANT_SUMMARY_SELECT +
                "FROM products p " +
                "JOIN promotion_items pi ON p.id = pi.product_id " +
                "JOIN promotions pr ON pr.id = pi.promotion_id " +
                "WHERE pi.promotion_id = ? AND p.status = 'active' " +
                "LIMIT ?";

        try (Connection conn = ds.getConnection();
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
                mapVariantSummary(p, rs);
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
        try (Connection conn = ds.getConnection();
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
        String getPromoSql =
                "SELECT discount_type, discount_value, is_active, approval_status, start_date, end_date " +
                        "FROM promotions WHERE id = ?";

        String deleteOldSql = "DELETE FROM promotion_items WHERE product_id = ?";
        String resetProductSql = "UPDATE products SET sale_price = 0 WHERE id = ?";
        String resetVariantSql = "UPDATE product_variants SET sale_price = 0 WHERE product_id = ?";
        String insertSql = "INSERT INTO promotion_items (promotion_id, product_id) VALUES (?, ?)";

        try (Connection conn = ds.getConnection()) {
            conn.setAutoCommit(false);

            try {
                String type;
                double value;
                boolean running = false;

                try (PreparedStatement ps = conn.prepareStatement(getPromoSql)) {
                    ps.setInt(1, promoId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException("Không tìm thấy khuyến mãi ID: " + promoId);
                        }

                        type = rs.getString("discount_type");
                        value = rs.getDouble("discount_value");

                        boolean active = rs.getBoolean("is_active");
                        boolean approved = "APPROVED".equals(rs.getString("approval_status"));
                        Timestamp startDate = rs.getTimestamp("start_date");
                        Timestamp endDate = rs.getTimestamp("end_date");
                        Timestamp now = new Timestamp(System.currentTimeMillis());

                        running = active && approved
                                && startDate != null
                                && endDate != null
                                && !startDate.after(now)
                                && !endDate.before(now);
                    }
                }

                String updateProductSql;
                String updateVariantSql;

                if ("PERCENT".equalsIgnoreCase(type)) {
                    updateProductSql = "UPDATE products SET sale_price = price * (100 - ?) / 100 WHERE id = ?";
                    updateVariantSql = "UPDATE product_variants SET sale_price = price * (100 - ?) / 100 WHERE product_id = ?";
                } else {
                    updateProductSql = "UPDATE products SET sale_price = GREATEST(0, price - ?) WHERE id = ?";
                    updateVariantSql = "UPDATE product_variants SET sale_price = GREATEST(0, price - ?) WHERE product_id = ?";
                }

                try (PreparedStatement psDelete = conn.prepareStatement(deleteOldSql);
                     PreparedStatement psResetProduct = conn.prepareStatement(resetProductSql);
                     PreparedStatement psResetVariant = conn.prepareStatement(resetVariantSql);
                     PreparedStatement psInsert = conn.prepareStatement(insertSql);
                     PreparedStatement psUpdateProduct = conn.prepareStatement(updateProductSql);
                     PreparedStatement psUpdateVariant = conn.prepareStatement(updateVariantSql)) {

                    for (String idStr : productIds) {
                        int productId = Integer.parseInt(idStr.trim());

                        psDelete.setInt(1, productId);
                        psDelete.executeUpdate();

                        psResetProduct.setInt(1, productId);
                        psResetProduct.executeUpdate();

                        psResetVariant.setInt(1, productId);
                        psResetVariant.executeUpdate();

                        psInsert.setInt(1, promoId);
                        psInsert.setInt(2, productId);
                        psInsert.executeUpdate();

                        if (running) {
                            psUpdateProduct.setDouble(1, value);
                            psUpdateProduct.setInt(2, productId);
                            psUpdateProduct.executeUpdate();

                            psUpdateVariant.setDouble(1, value);
                            psUpdateVariant.setInt(2, productId);
                            psUpdateVariant.executeUpdate();
                        }
                    }
                }

                conn.commit();

            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public void removeProductsFromPromotion(String[] productIds) {
        Connection conn = null;
        PreparedStatement psDelete = null;
        PreparedStatement psResetPrice = null;
        PreparedStatement psResetVariantPrice = null;

        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);

            String sqlDelete = "DELETE FROM promotion_items WHERE product_id = ?";
            psDelete = conn.prepareStatement(sqlDelete);

            String sqlResetPrice = "UPDATE products SET sale_price = 0 WHERE id = ?";
            psResetPrice = conn.prepareStatement(sqlResetPrice);

            String sqlResetVariantPrice = "UPDATE product_variants SET sale_price = 0 WHERE product_id = ?";
            psResetVariantPrice = conn.prepareStatement(sqlResetVariantPrice);

            for (String idStr : productIds) {
                try {
                    int pid = Integer.parseInt(idStr);

                    psDelete.setInt(1, pid);
                    psDelete.executeUpdate();

                    psResetPrice.setInt(1, pid);
                    psResetPrice.executeUpdate();

                    psResetVariantPrice.setInt(1, pid);
                    psResetVariantPrice.executeUpdate();

                } catch (NumberFormatException e) {
                    System.err.println("Lỗi ID sản phẩm: " + idStr);
                }
            }

            conn.commit();
            System.out.println("Đã gỡ sản phẩm khỏi KM và reset giá sản phẩm + phân loại!");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
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
                if (psResetVariantPrice != null) psResetVariantPrice.close();
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
        try (Connection conn = ds.getConnection();
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
                p.setApprovalStatus(rs.getString("approval_status"));

                p.setImageUrl(rs.getString("image_url"));
                p.setPromotionType(rs.getString("promotion_type"));

                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insertPromotion(Promotion p) {
        String sql = "INSERT INTO promotions " +
                "(name, description, discount_type, discount_value, promotion_type, start_date, end_date, is_active, image_url, approval_status, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getDiscountType().name());
            ps.setDouble(4, p.getDiscountValue());
            ps.setString(5, p.getPromotionType() != null ? p.getPromotionType() : "ALL");
            ps.setTimestamp(6, Timestamp.valueOf(p.getStartDate()));
            ps.setTimestamp(7, Timestamp.valueOf(p.getEndDate()));
            ps.setBoolean(8, p.isActive());
            ps.setString(9, p.getImageUrl());
            ps.setString(10, p.getApprovalStatus() != null ? p.getApprovalStatus() : "PENDING");

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public void togglePromotionStatus(int promoId, boolean newStatus) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
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

                String sqlResetVariantPrice = "UPDATE product_variants v " +
                        "JOIN promotion_items pi ON v.product_id = pi.product_id " +
                        "SET v.sale_price = 0 " +
                        "WHERE pi.promotion_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlResetVariantPrice)) {
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
                ex.printStackTrace();
            }
        } finally {
            try {
                if (conn != null) conn.close();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }
    public boolean updatePromotion(Promotion p) {
        String sql = "UPDATE promotions SET name=?, description=?, discount_type=?, discount_value=?, promotion_type=?, " +
                "start_date=?, end_date=?, image_url=?, approval_status=? WHERE id=?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getDescription());
            ps.setString(3, p.getDiscountType().name());
            ps.setDouble(4, p.getDiscountValue());
            ps.setString(5, p.getPromotionType() != null ? p.getPromotionType() : "ALL");
            ps.setTimestamp(6, Timestamp.valueOf(p.getStartDate()));
            ps.setTimestamp(7, Timestamp.valueOf(p.getEndDate()));
            ps.setString(8, p.getImageUrl());
            ps.setString(9, p.getApprovalStatus() != null ? p.getApprovalStatus() : "PENDING");
            ps.setInt(10, p.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Promotion> getPromotionsByType(String type) {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE is_active = 1 " +
                "AND approval_status = 'APPROVED' " +
                "AND start_date <= NOW() AND end_date >= NOW() " +
                "AND promotion_type = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Promotion p = new Promotion();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setDescription(rs.getString("description"));
                p.setPromotionType(rs.getString("promotion_type"));
                p.setDiscountType(DiscountType.valueOf(rs.getString("discount_type")));
                p.setDiscountValue(rs.getDouble("discount_value"));
                p.setImageUrl(rs.getString("image_url"));
                p.setStartDate(rs.getTimestamp("start_date").toLocalDateTime());
                p.setEndDate(rs.getTimestamp("end_date").toLocalDateTime());
                p.setApprovalStatus(rs.getString("approval_status"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getProductsByPromotionAndType(int promoId, String type, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, pi.promotion_id AS current_promo_id, pr.discount_type, pr.discount_value " +
                VARIANT_SUMMARY_SELECT +
                "FROM products p " +
                "JOIN promotion_items pi ON p.id = pi.product_id " +
                "JOIN promotions pr ON pr.id = pi.promotion_id " +
                "WHERE pi.promotion_id = ? AND pr.promotion_type = ? AND p.status = 'active' " +
                "LIMIT ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, promoId);
            ps.setString(2, type);
            ps.setInt(3, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                mapVariantSummary(p, rs);
                p.setImageUrl(rs.getString("image_url"));
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

    private void mapVariantSummary(Product p, ResultSet rs) throws SQLException {
        p.setTotalStockQuantity(rs.getInt("variant_total_stock"));
        p.setVariantCount(rs.getInt("variant_count"));

        double minVariantPrice = rs.getDouble("min_variant_price");
        p.setMinVariantPrice(rs.wasNull() ? 0 : minVariantPrice);

        double maxVariantPrice = rs.getDouble("max_variant_price");
        p.setMaxVariantPrice(rs.wasNull() ? 0 : maxVariantPrice);

        double minEffectivePrice = rs.getDouble("min_variant_effective_price");
        p.setMinVariantEffectivePrice(rs.wasNull() ? 0 : minEffectivePrice);

        double maxEffectivePrice = rs.getDouble("max_variant_effective_price");
        p.setMaxVariantEffectivePrice(rs.wasNull() ? 0 : maxEffectivePrice);
    }

    public boolean deletePromotion(int promoId) {
        String resetPriceSql = "UPDATE products p " +
                "JOIN promotion_items pi ON p.id = pi.product_id " +
                "SET p.sale_price = 0 " +
                "WHERE pi.promotion_id = ?";

        String resetVariantPriceSql = "UPDATE product_variants v " +
                "JOIN promotion_items pi ON v.product_id = pi.product_id " +
                "SET v.sale_price = 0 " +
                "WHERE pi.promotion_id = ?";

        String deleteItemsSql = "DELETE FROM promotion_items WHERE promotion_id = ?";
        String deletePromoSql = "DELETE FROM promotions WHERE id = ?";

        try (Connection conn = ds.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(resetPriceSql);
                 PreparedStatement ps2 = conn.prepareStatement(resetVariantPriceSql);
                 PreparedStatement ps3 = conn.prepareStatement(deleteItemsSql);
                 PreparedStatement ps4 = conn.prepareStatement(deletePromoSql)) {

                ps1.setInt(1, promoId);
                ps1.executeUpdate();

                ps2.setInt(1, promoId);
                ps2.executeUpdate();

                ps3.setInt(1, promoId);
                ps3.executeUpdate();

                ps4.setInt(1, promoId);
                boolean deleted = ps4.executeUpdate() > 0;

                conn.commit();
                return deleted;

            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    public void syncPromotionPrices() {
        String resetProductSql =
                "UPDATE products p " +
                        "JOIN promotion_items pi ON p.id = pi.product_id " +
                        "JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "SET p.sale_price = 0 " +
                        "WHERE pr.is_active = 0 OR pr.approval_status != 'APPROVED' OR pr.start_date > NOW() OR pr.end_date < NOW()";

        String resetVariantSql =
                "UPDATE product_variants v " +
                        "JOIN promotion_items pi ON v.product_id = pi.product_id " +
                        "JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "SET v.sale_price = 0 " +
                        "WHERE pr.is_active = 0 OR pr.approval_status != 'APPROVED' OR pr.start_date > NOW() OR pr.end_date < NOW()";

        String applyProductSql =
                "UPDATE products p " +
                        "JOIN promotion_items pi ON p.id = pi.product_id " +
                        "JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "SET p.sale_price = CASE " +
                        "   WHEN pr.discount_type = 'PERCENT' THEN p.price * (100 - pr.discount_value) / 100 " +
                        "   ELSE GREATEST(0, p.price - pr.discount_value) " +
                        "END " +
                        "WHERE pr.is_active = 1 AND pr.approval_status = 'APPROVED' " +
                        "AND pr.start_date <= NOW() " +
                        "AND pr.end_date >= NOW()";

        String applyVariantSql =
                "UPDATE product_variants v " +
                        "JOIN promotion_items pi ON v.product_id = pi.product_id " +
                        "JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "SET v.sale_price = CASE " +
                        "   WHEN pr.discount_type = 'PERCENT' THEN v.price * (100 - pr.discount_value) / 100 " +
                        "   ELSE GREATEST(0, v.price - pr.discount_value) " +
                        "END " +
                        "WHERE pr.is_active = 1 AND pr.approval_status = 'APPROVED' " +
                        "AND pr.start_date <= NOW() " +
                        "AND pr.end_date >= NOW()";

        String disableExpiredPromotionSql =
                "UPDATE promotions " +
                        "SET is_active = 0 " +
                        "WHERE is_active = 1 " +
                        "AND end_date < NOW()";

        try (Connection conn = ds.getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement ps1 = conn.prepareStatement(resetProductSql);
                 PreparedStatement ps2 = conn.prepareStatement(resetVariantSql);
                 PreparedStatement ps3 = conn.prepareStatement(applyProductSql);
                 PreparedStatement ps4 = conn.prepareStatement(applyVariantSql);
                 PreparedStatement ps5 = conn.prepareStatement(disableExpiredPromotionSql)) {

                ps1.executeUpdate();
                ps2.executeUpdate();
                ps3.executeUpdate();
                ps4.executeUpdate();
                ps5.executeUpdate();

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public List<Promotion> getAvailablePromotionsForAdmin() {
        List<Promotion> list = new ArrayList<>();

        String sql = "SELECT * FROM promotions " +
                "WHERE is_active = 1 " +
                "AND end_date >= NOW() " +
                "ORDER BY start_date ASC";

        try (Connection conn = ds.getConnection();
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
                p.setActive(rs.getBoolean("is_active"));
                p.setPromotionType(rs.getString("promotion_type"));

                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public boolean hasPromotionConflict(int newPromoId, String[] productIds) {
        String sql = "SELECT 1 " + "FROM promotion_items pi " +
                        "JOIN promotions old_pr ON old_pr.id = pi.promotion_id " +
                        "JOIN promotions new_pr ON new_pr.id = ? " +
                        "WHERE pi.product_id = ? " + "AND old_pr.id <> ? " + "AND old_pr.is_active = 1 " + "AND new_pr.is_active = 1 " +
                        "AND old_pr.start_date <= new_pr.end_date " +
                        "AND old_pr.end_date >= new_pr.start_date " +
                        "LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (String idStr : productIds) {
                if (idStr == null || idStr.trim().isEmpty()) {
                    continue;
                }

                int productId = Integer.parseInt(idStr.trim());

                ps.setInt(1, newPromoId);
                ps.setInt(2, productId);
                ps.setInt(3, newPromoId);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return true;
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean approvePromotion(int promoId) {
        String sql = "UPDATE promotions SET approval_status = 'APPROVED' WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
