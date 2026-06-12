package dao;

import model.product.ProductVariant;

import javax.sql.DataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class ProductVariantDAO {
    private final DataSource ds;

    public ProductVariantDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<ProductVariant> getVariantsByProductId(int productId) {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT * FROM product_variants WHERE product_id = ? AND is_active = 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setId(rs.getInt("id"));
                    v.setProductId(rs.getInt("product_id"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setSku(rs.getString("sku"));
                    v.setPrice(rs.getDouble("price"));
                    v.setSalePrice(rs.getDouble("sale_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));

                    variants.add(v);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return variants;
    }

    public ProductVariant getVariantById(int variantId) {
        String sql = "SELECT * FROM product_variants WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setId(rs.getInt("id"));
                    v.setProductId(rs.getInt("product_id"));
                    v.setVariantName(rs.getString("variant_name"));
                    v.setSku(rs.getString("sku"));
                    v.setPrice(rs.getDouble("price"));
                    v.setSalePrice(rs.getDouble("sale_price"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));

                    return v;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public ProductVariant getVariantBySku(String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM product_variants WHERE sku = ? LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToVariant(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean increaseStockBySku(String sku, int quantity) {
        if (sku == null || sku.trim().isEmpty() || quantity <= 0) {
            return false;
        }
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE sku = ? AND is_active = 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setString(2, sku.trim());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ProductVariant> getInventoryVariants(String keyword, Integer categoryId, String stockFilter,
                                                     String sort, int page, int pageSize,
                                                     int reorderThreshold, int lowStockThreshold) {
        List<ProductVariant> variants = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT v.*, p.name AS product_name, p.sku AS product_sku, c.name AS category_name " +
                        "FROM product_variants v " +
                        "JOIN products p ON p.id = v.product_id " +
                        "LEFT JOIN categories c ON c.id = p.category_id " +
                        "WHERE v.is_active = 1 ");

        appendInventoryFilters(sql, params, keyword, categoryId, stockFilter, reorderThreshold, lowStockThreshold);
        appendInventorySort(sql, sort);
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    variants.add(mapInventoryRowToVariant(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return variants;
    }

    public int countInventoryVariants(String keyword, Integer categoryId, String stockFilter,
                                      int reorderThreshold, int lowStockThreshold) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM product_variants v " +
                        "JOIN products p ON p.id = v.product_id " +
                        "LEFT JOIN categories c ON c.id = p.category_id " +
                        "WHERE v.is_active = 1 ");

        appendInventoryFilters(sql, params, keyword, categoryId, stockFilter, reorderThreshold, lowStockThreshold);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public ProductVariant getVariantByProductAndName(int productId, String variantName) {
        if (variantName == null || variantName.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM product_variants WHERE product_id = ? AND variant_name = ? LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setString(2, variantName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToVariant(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void decreaseStock(int variantId, int quantity) {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity - ? WHERE id = ? AND stock_quantity >= ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, variantId);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void decreaseStock(Connection conn, int variantId, int quantity) throws SQLException {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity - ? WHERE id = ? AND stock_quantity >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, variantId);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        }
    }

    public void increaseStock(int variantId, int quantity) {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean increaseStockById(int variantId, int quantity) {
        if (variantId <= 0 || quantity <= 0) {
            return false;
        }
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE id = ? AND is_active = 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, variantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private ProductVariant mapRowToVariant(ResultSet rs) throws SQLException {
        ProductVariant v = new ProductVariant();
        v.setId(rs.getInt("id"));
        v.setProductId(rs.getInt("product_id"));
        v.setVariantName(rs.getString("variant_name"));
        v.setSku(rs.getString("sku"));
        v.setPrice(rs.getDouble("price"));
        v.setSalePrice(rs.getDouble("sale_price"));
        v.setStockQuantity(rs.getInt("stock_quantity"));
        return v;
    }

    private ProductVariant mapInventoryRowToVariant(ResultSet rs) throws SQLException {
        ProductVariant v = mapRowToVariant(rs);
        v.setProductName(rs.getString("product_name"));
        v.setProductSku(rs.getString("product_sku"));
        v.setCategoryName(rs.getString("category_name"));
        return v;
    }

    private void appendInventoryFilters(StringBuilder sql, List<Object> params, String keyword, Integer categoryId,
                                        String stockFilter, int reorderThreshold, int lowStockThreshold) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            String like = "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%";
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(IFNULL(p.sku, '')) LIKE ? ")
                    .append("OR LOWER(IFNULL(v.variant_name, '')) LIKE ? OR LOWER(IFNULL(v.sku, '')) LIKE ?) ");
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (categoryId != null) {
            sql.append(" AND p.category_id = ? ");
            params.add(categoryId);
        }
        if ("in-stock".equals(stockFilter)) {
            sql.append(" AND v.stock_quantity > ? ");
            params.add(lowStockThreshold);
        } else if ("need-reorder".equals(stockFilter)) {
            sql.append(" AND v.stock_quantity > 0 AND v.stock_quantity < ? ");
            params.add(reorderThreshold);
        } else if ("low-stock".equals(stockFilter)) {
            sql.append(" AND v.stock_quantity >= ? AND v.stock_quantity <= ? ");
            params.add(reorderThreshold);
            params.add(lowStockThreshold);
        } else if ("out-of-stock".equals(stockFilter)) {
            sql.append(" AND v.stock_quantity = 0 ");
        }
    }

    private void appendInventorySort(StringBuilder sql, String sort) {
        if ("stock-desc".equals(sort)) {
            sql.append(" ORDER BY v.stock_quantity DESC, p.name ASC, v.variant_name ASC ");
        } else if ("name-asc".equals(sort)) {
            sql.append(" ORDER BY p.name ASC, v.variant_name ASC ");
        } else {
            sql.append(" ORDER BY v.stock_quantity ASC, p.name ASC, v.variant_name ASC ");
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            if (param instanceof Integer value) {
                ps.setInt(i + 1, value);
            } else {
                ps.setString(i + 1, String.valueOf(param));
            }
        }
    }

    public void addVariant(ProductVariant variant) {
        if (variant.getSalePrice() > variant.getPrice()) {
            variant.setSalePrice(variant.getPrice());
        }

        String sql = "INSERT INTO product_variants (product_id, variant_name, sku, price, sale_price, stock_quantity, is_active) VALUES (?, ?, ?, ?, ?, ?, 1)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variant.getProductId());
            ps.setString(2, variant.getVariantName());
            ps.setString(3, variant.getSku());
            ps.setDouble(4, variant.getPrice());
            ps.setDouble(5, variant.getSalePrice());
            ps.setInt(6, variant.getStockQuantity());
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void deleteVariantsByProductId(int productId) {
        String sql = "DELETE FROM product_variants WHERE product_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateVariant(ProductVariant variant) {
        if (variant.getSalePrice() > variant.getPrice()) {
            variant.setSalePrice(variant.getPrice());
        }

        String sql = "UPDATE product_variants SET variant_name = ?, sku = ?, price = ?, sale_price = ?, stock_quantity = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, variant.getVariantName());
            ps.setString(2, variant.getSku());
            ps.setDouble(3, variant.getPrice());
            ps.setDouble(4, variant.getSalePrice());
            ps.setInt(5, variant.getStockQuantity());
            ps.setInt(6, variant.getId());
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Lỗi updateVariant: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void deactivateVariant(int variantId) {
        String sql = "UPDATE product_variants SET is_active = 0 WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            System.err.println("Lỗi deactivateVariant: " + e.getMessage());
            e.printStackTrace();
        }
    }
    public boolean updateStockByProductId(int productId, int newStock) {
        String sql = "UPDATE product_variants SET stock_quantity = ? WHERE product_id = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, newStock);
            ps.setInt(2, productId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Lỗi khi cập nhật stock variant: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
