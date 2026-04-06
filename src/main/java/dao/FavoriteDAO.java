package dao;

import db.DBConnect;
import model.product.Product;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class FavoriteDAO {

    public List<Product> getFavoriteProducts(int userId, Integer categoryId, Double maxPrice, String sort, int page, int pageSize) {
        List<Product> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT p.*, f.created_at AS favorite_created_at " +
                        "FROM favorite_products f " +
                        "JOIN products p ON p.id = f.product_id " +
                        "WHERE f.user_id = ? AND p.status = 'active' "
        );

        if (categoryId != null) {
            sql.append(" AND p.category_id = ? ");
        }

        if (maxPrice != null) {
            sql.append(" AND (CASE " +
                    "WHEN p.sale_price > 0 AND p.sale_price < p.price THEN p.sale_price " +
                    "ELSE p.price END) <= ? ");
        }

        if (sort != null) {
            switch (sort) {
                case "price-asc":
                    sql.append(" ORDER BY (CASE " +
                            "WHEN p.sale_price > 0 AND p.sale_price < p.price THEN p.sale_price " +
                            "ELSE p.price END) ASC ");
                    break;
                case "price-desc":
                    sql.append(" ORDER BY (CASE " +
                            "WHEN p.sale_price > 0 AND p.sale_price < p.price THEN p.sale_price " +
                            "ELSE p.price END) DESC ");
                    break;
                case "name-asc":
                    sql.append(" ORDER BY p.name ASC ");
                    break;
                case "oldest":
                    sql.append(" ORDER BY favorite_created_at ASC ");
                    break;
                case "newest":
                default:
                    sql.append(" ORDER BY favorite_created_at DESC ");
                    break;
            }
        } else {
            sql.append(" ORDER BY favorite_created_at DESC ");
        }

        sql.append(" LIMIT ? OFFSET ? ");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);

            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }

            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }

            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex, (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
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

                    int catId = rs.getInt("category_id");
                    p.setCategoryId(rs.wasNull() ? null : catId);

                    p.setImageUrl(rs.getString("image_url"));
                    p.setIngredients(rs.getString("ingredients"));
                    p.setUsageInstructions(rs.getString("usage_instructions"));
                    p.setBestseller(rs.getBoolean("is_bestseller"));

                    list.add(p);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countFavoriteProducts(int userId, Integer categoryId, Double maxPrice) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                        "FROM favorite_products f " +
                        "JOIN products p ON p.id = f.product_id " +
                        "WHERE f.user_id = ? AND p.status = 'active' "
        );

        if (categoryId != null) {
            sql.append(" AND p.category_id = ? ");
        }

        if (maxPrice != null) {
            sql.append(" AND (CASE " +
                    "WHEN p.sale_price > 0 AND p.sale_price < p.price THEN p.sale_price " +
                    "ELSE p.price END) <= ? ");
        }

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);

            if (categoryId != null) {
                ps.setInt(paramIndex++, categoryId);
            }

            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }
}