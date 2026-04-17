package dao;

import model.cart.Cart;
import model.product.Product;
import model.product.ProductVariant;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CartDAO {
    private final DataSource ds;
    public CartDAO(DataSource ds) {
        this.ds = ds;
    }

    public Cart getCartByUserId(int userId) {
        Cart cart = new Cart();
        
        String sql = "SELECT c.product_id, c.variant_id, c.quantity, " +
                "p.name, p.image_url, p.price as p_price, p.sale_price as p_sale_price, p.slug, " +
                "v.variant_name, v.price as v_price, v.sale_price as v_sale_price " +
                "FROM cart c " +
                "JOIN products p ON c.product_id = p.id " +
                "LEFT JOIN product_variants v ON c.variant_id = v.id " +
                "WHERE c.user_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("product_id"));
                    p.setName(rs.getString("name"));
                    p.setImageUrl(rs.getString("image_url"));
                    p.setPrice(rs.getDouble("p_price"));
                    p.setSalePrice(rs.getDouble("p_sale_price"));
                    p.setSlug(rs.getString("slug"));

                    ProductVariant v = null;
                    int variantId = rs.getInt("variant_id");
                    if (!rs.wasNull()) {
                        v = new ProductVariant();
                        v.setId(variantId);
                        v.setProductId(p.getId());
                        v.setVariantName(rs.getString("variant_name"));
                        v.setPrice(rs.getDouble("v_price"));
                        v.setSalePrice(rs.getDouble("v_sale_price"));
                    }

                    int quantity = rs.getInt("quantity");

                    cart.add(p, v, quantity);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cart;
    }

    public void addToCart(int userId, int productId, int variantId, int quantity) {
        String checkSql = "SELECT quantity FROM cart WHERE user_id = ? AND variant_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            checkPs.setInt(1, userId);
            checkPs.setInt(2, variantId);
            ResultSet rs = checkPs.executeQuery();

            if (rs.next()) {
                int newQuantity = rs.getInt("quantity") + quantity;
                updateQuantity(userId, variantId, newQuantity);
            } else {
                String insertSql = "INSERT INTO cart (user_id, product_id, variant_id, quantity) VALUES (?, ?, ?, ?)";
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setInt(1, userId);
                    insertPs.setInt(2, productId);
                    insertPs.setInt(3, variantId);
                    insertPs.setInt(4, quantity);
                    insertPs.executeUpdate();
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateQuantity(int userId, int variantId, int quantity) {
        if (quantity <= 0) {
            removeProduct(userId, variantId);
            return;
        }
        String sql = "UPDATE cart SET quantity = ?, updated_at = CURRENT_TIMESTAMP WHERE user_id = ? AND variant_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, userId);
            ps.setInt(3, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void removeProduct(int userId, int variantId) {
        String sql = "DELETE FROM cart WHERE user_id = ? AND variant_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, variantId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void clearCart(int userId) {
        String sql = "DELETE FROM cart WHERE user_id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}