package dao;

import model.product.ProductVariant;

import javax.sql.DataSource;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    public void addVariant(ProductVariant variant) {
        if (variant.getSalePrice() > variant.getPrice()) {
            variant.setSalePrice(variant.getPrice());
        }

        String sql = "INSERT INTO product_variants (product_id, variant_name, price, sale_price, stock_quantity, is_active) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variant.getProductId());
            ps.setString(2, variant.getVariantName());
            ps.setDouble(3, variant.getPrice());
            ps.setDouble(4, variant.getSalePrice());
            ps.setInt(5, variant.getStockQuantity());
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

        String sql = "UPDATE product_variants SET variant_name = ?, price = ?, sale_price = ?, stock_quantity = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, variant.getVariantName());
            ps.setDouble(2, variant.getPrice());
            ps.setDouble(3, variant.getSalePrice());
            ps.setInt(4, variant.getStockQuantity());
            ps.setInt(5, variant.getId());
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