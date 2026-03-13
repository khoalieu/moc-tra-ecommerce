package dao;

import db.DBConnect;
import model.Product;
import model.enums.ProductStatus;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {

    public ProductDAO() {
    }

    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double maxPrice, int index, int size) {

        return getProducts(categoryId, promotionId, sort, maxPrice, index, size, "active");
    }

    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double maxPrice, int index, int size, String status) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, " +
                        "(SELECT promotion_id FROM promotion_items pi WHERE pi.product_id = p.id LIMIT 1) AS current_promo_id " +
                        "FROM products p "
        );

        sql.append(" WHERE 1=1 ");

        if (categoryId != null) {
            sql.append(" AND p.category_id = ? ");
        }

        if (maxPrice != null) {
            sql.append(" AND (CASE WHEN p.sale_price > 0 THEN p.sale_price ELSE p.price END) <= ? ");
        }

        if (promotionId != null) {
            sql.append(" AND p.id IN (SELECT product_id FROM promotion_items WHERE promotion_id = ?) ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) sql.append(" AND p.status = 'active' ");
            else if ("inactive".equals(status)) sql.append(" AND p.status = 'inactive' ");
            else if ("out-of-stock".equals(status)) sql.append(" AND p.stock_quantity = 0 ");
        }

        if (sort != null) {
            switch (sort) {
                case "price-asc":
                    sql.append(" ORDER BY p.price ASC ");
                    break;
                case "price-desc":
                    sql.append(" ORDER BY p.price DESC ");
                    break;
                case "name-asc":
                    sql.append(" ORDER BY p.name ASC ");
                    break;
                case "newest":
                    sql.append(" ORDER BY p.created_at DESC ");
                    break;
                default:
                    sql.append(" ORDER BY p.created_at DESC ");
            }
        } else {
            sql.append(" ORDER BY p.created_at DESC ");
        }

        sql.append(" LIMIT ? OFFSET ?");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (categoryId != null) ps.setInt(paramIndex++, categoryId);
            if (maxPrice != null) ps.setDouble(paramIndex++, maxPrice);
            if (promotionId != null) ps.setInt(paramIndex++, promotionId);

            int offset = (index - 1) * size;
            ps.setInt(paramIndex++, size);
            ps.setInt(paramIndex++, offset);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setShortDescription(rs.getString("short_description"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setSku(rs.getString("sku"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setImageUrl(rs.getString("image_url"));
                p.setBestseller(rs.getBoolean("is_bestseller"));

                p.setCurrentPromotionId(rs.getInt("current_promo_id"));

                String statusStr = rs.getString("status");
                if (statusStr != null) {
                    try {
                        p.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        p.setStatus(ProductStatus.ACTIVE);
                    }
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProducts(Integer categoryId, Integer promotionId, Double maxPrice) throws SQLException {
        return countProducts(categoryId, promotionId, maxPrice, "active");
    }

    public int countProducts(Integer categoryId, Integer promotionId, Double maxPrice, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p ");

        if (promotionId != null) {
            sql.append(" JOIN promotion_items pi ON p.id = pi.product_id ");
        }

        sql.append(" WHERE 1=1 ");

        if (categoryId != null) {
            sql.append(" AND p.category_id = ? ");
        }

        if (maxPrice != null) {
            sql.append(" AND (CASE WHEN p.sale_price > 0 THEN p.sale_price ELSE p.price END) <= ? ");
        }

        if (promotionId != null) {
            sql.append(" AND pi.promotion_id = ? ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) sql.append(" AND p.status = 'active' ");
            else if ("inactive".equals(status)) sql.append(" AND p.status = 'inactive' ");
            else if ("out-of-stock".equals(status)) sql.append(" AND p.stock_quantity = 0 ");
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (categoryId != null) ps.setInt(paramIndex++, categoryId);
            if (maxPrice != null) ps.setDouble(paramIndex++, maxPrice);
            if (promotionId != null) ps.setInt(paramIndex++, promotionId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setShortDescription(rs.getString("short_description"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setSku(rs.getString("sku"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setImageUrl(rs.getString("image_url"));
                p.setBestseller(rs.getBoolean("is_bestseller"));
                String statusStr = rs.getString("status");
                if (statusStr != null) {
                    try {
                        p.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        p.setStatus(ProductStatus.ACTIVE);
                    }
                }

                p.setIngredients(rs.getString("ingredients"));
                p.setUsageInstructions(rs.getString("usage_instructions"));

                if (rs.getTimestamp("created_at") != null) {
                    p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                }
                return p;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Product> getRelatedProducts(int categoryId, int currentProductId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category_id = ? AND id != ? AND status = 'active' ORDER BY RAND() LIMIT 4";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, currentProductId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setImageUrl(rs.getString("image_url"));
                p.setSlug(rs.getString("slug"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertProduct(Product p) {
        String sql = "INSERT INTO products (name, slug, description, short_description, price, sale_price, " +
                "sku, stock_quantity, category_id, image_url, is_bestseller, status, " +
                "ingredients, usage_instructions, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getSlug());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getShortDescription());
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getSalePrice());
            ps.setString(7, p.getSku());
            ps.setInt(8, p.getStockQuantity());

            if (p.getCategoryId() != null) ps.setInt(9, p.getCategoryId());
            else ps.setNull(9, java.sql.Types.INTEGER);

            ps.setString(10, p.getImageUrl());
            ps.setBoolean(11, p.isBestseller());
            ps.setString(12, p.getStatus() != null ? p.getStatus().name().toLowerCase() : "active");
            ps.setString(13, p.getIngredients());
            ps.setString(14, p.getUsageInstructions());
            ps.setTimestamp(15, Timestamp.valueOf(p.getCreatedAt()));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertProductImage(int productId, String imageUrl, String altText, int sortOrder) {
        String sql = "INSERT INTO product_images (product_id, image_url, alt_text, sort_order) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            ps.setString(3, altText);
            ps.setInt(4, sortOrder);

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void softDeleteProduct(int id) {
        String sql = "UPDATE products SET status = 'inactive' WHERE id = ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, slug=?, description=?, short_description=?, price=?, sale_price=?, " +
                "sku=?, stock_quantity=?, category_id=?, is_bestseller=?, status=?, ingredients=?, usage_instructions=?, " +
                "image_url=? WHERE id=?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getSlug());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getShortDescription());
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getSalePrice());
            ps.setString(7, p.getSku());
            ps.setInt(8, p.getStockQuantity());

            if (p.getCategoryId() != null) ps.setInt(9, p.getCategoryId());
            else ps.setNull(9, java.sql.Types.INTEGER);

            ps.setBoolean(10, p.isBestseller());
            ps.setString(11, p.getStatus() != null ? p.getStatus().name().toLowerCase() : "active");
            ps.setString(12, p.getIngredients());
            ps.setString(13, p.getUsageInstructions());
            ps.setString(14, p.getImageUrl());
            ps.setInt(15, p.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


    public void decreaseStock(int productId, int quantityPurchased) {
        String sql = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityPurchased);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    public boolean updateProductStatus(List<Integer> productIds, String newStatus) {
        if (productIds == null || productIds.isEmpty()) return false;

        StringBuilder sql = new StringBuilder("UPDATE products SET status = ? WHERE id IN (");
        for (int i = 0; i < productIds.size(); i++) {
            sql.append(i == 0 ? "?" : ",?");
        }
        sql.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setString(1, newStatus); // 'ACTIVE' hoặc 'INACTIVE'

            // Gán các ID vào tham số
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 2, productIds.get(i));
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> getTopSellingByParentCategory(int parentId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, IFNULL(SUM(IF(o.status = 'completed', oi.quantity, 0)), 0) AS sold_qty "
                + "FROM products p " + "JOIN categories c ON c.id = p.category_id "
                + "LEFT JOIN order_items oi ON oi.product_id = p.id "
                + "LEFT JOIN orders o ON o.id = oi.order_id "
                + "WHERE p.status = 'active' AND c.parent_id = ? "
                + "GROUP BY p.id "
                + "ORDER BY sold_qty DESC, p.created_at DESC " + "LIMIT ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setSlug(rs.getString("slug"));
                    p.setPrice(rs.getDouble("price"));
                    p.setSalePrice(rs.getDouble("sale_price"));
                    p.setSku(rs.getString("sku"));
                    p.setStockQuantity(rs.getInt("stock_quantity"));
                    int catId = rs.getInt("category_id");
                    p.setCategoryId(rs.wasNull() ? null : catId);
                    p.setImageUrl(rs.getString("image_url"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getBestSellerProducts(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category_id = ? AND is_bestseller = 1 AND status = 'ACTIVE' LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            ps.setInt(2, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Product mapRowToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setSlug(rs.getString("slug"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));
        p.setPrice(rs.getDouble("price"));
        p.setSalePrice(rs.getDouble("sale_price"));
        p.setSku(rs.getString("sku"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        p.setCategoryId(rs.getInt("category_id"));

        String img = rs.getString("image_url");
        p.setImageUrl(img != null ? img : "");

        p.setBestseller(rs.getBoolean("is_bestseller"));

        try {
            String statusStr = rs.getString("status");
            if (statusStr != null) {
                p.setStatus(ProductStatus.valueOf(statusStr));
            } else {
                p.setStatus(ProductStatus.ACTIVE);
            }
        } catch (IllegalArgumentException e) {
            p.setStatus(ProductStatus.ACTIVE);
        }

        p.setIngredients(rs.getString("ingredients"));
        p.setUsageInstructions(rs.getString("usage_instructions"));

        if (rs.getTimestamp("created_at") != null) {
            p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return p;
    }
}