package dao;

import model.ReviewDTO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.product.ProductReview;

import javax.sql.DataSource;

public class ReviewDAO {
    private final DataSource ds;
    public ReviewDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<ReviewDTO> getReviewsByProductId(int productId) {
        List<ReviewDTO> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, u.avatar " +
                "FROM product_reviews r " +
                "JOIN users u ON r.user_id = u.id " +
                "WHERE r.product_id = ? " +
                "ORDER BY r.created_at DESC";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {

                String avatar = rs.getString("avatar");
                if (avatar == null || avatar.isEmpty()) avatar = "assets/images/useravata.png";

                ReviewDTO review = new ReviewDTO(
                        rs.getString("username"),
                        avatar,
                        rs.getInt("rating"),
                        rs.getString("comment_text"),
                        rs.getTimestamp("created_at").toLocalDateTime()
                );
                list.add(review);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addReview(int productId, int userId, int rating, String comment) {
        String sql = "INSERT INTO product_reviews (product_id, user_id, rating, comment_text, created_at) VALUES (?, ?, ?, ?, NOW())";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, userId);
            ps.setInt(3, rating);
            ps.setString(4, comment);

            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<ProductReview> getReviewsByUserId(int userId) {
        List<ProductReview> list = new ArrayList<>();
        String sql = "SELECT r.*, p.name AS product_name " +
                "FROM product_reviews r " +
                "JOIN products p ON r.product_id = p.id " +
                "WHERE r.user_id = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                ProductReview r = new ProductReview();
                r.setId(rs.getInt("id"));
                r.setProductId(rs.getInt("product_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setRating(rs.getInt("rating"));
                r.setCommentText(rs.getString("comment_text")); // Lưu ý: Database cột là comment_text
                r.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

                r.setProductName(rs.getString("product_name"));

                list.add(r);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public boolean hasPurchasedProduct(int userId, int productId) {
        String sql = "SELECT 1 " +
                "FROM orders o " +
                "JOIN order_items oi ON o.id = oi.order_id " +
                "WHERE o.user_id = ? " +
                "AND oi.product_id = ? " +
                "AND o.status = 'completed' " +
                "LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean hasReviewed(int userId, int productId) {
        String sql = "SELECT 1 FROM product_reviews WHERE user_id = ? AND product_id = ? LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}