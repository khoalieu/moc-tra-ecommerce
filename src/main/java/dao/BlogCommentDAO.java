package dao;

import db.DBConnect;
import model.BlogComment;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class BlogCommentDAO {

    public List<BlogComment> getByPostId(int postId) {
        List<BlogComment> list = new ArrayList<>();

        String sql = "SELECT* FROM blog_comments " +
                "WHERE post_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean insert(int postId, int userId, String commentText) {
        String sql =
                "INSERT INTO blog_comments(post_id, user_id, comment_text, created_at) " +
                        "VALUES(?, ?, ?, NOW())";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.setInt(2, userId);
            ps.setString(3, commentText);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private BlogComment map(ResultSet rs) throws Exception {
        BlogComment c = new BlogComment();
        c.setId(rs.getInt("id"));
        c.setPostId(rs.getInt("post_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setCommentText(rs.getString("comment_text"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) c.setCreatedAt(ts.toLocalDateTime());
    
        return c;
    }
    public BlogComment getById(int id) {
        String sql = "SELECT * FROM blog_comments WHERE id = ? LIMIT 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteById(int id) {
        String sql = "DELETE FROM blog_comments WHERE id = ? LIMIT 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<BlogComment> getByUserId(int userId) {
        List<BlogComment> list = new ArrayList<>();
        String sql = "SELECT c.*, p.title AS post_title " +
                "FROM blog_comments c " +
                "JOIN blog_posts p ON c.post_id = p.id " +
                "WHERE c.user_id = ? ORDER BY c.created_at DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogComment c = new BlogComment();
                    c.setId(rs.getInt("id"));
                    c.setPostId(rs.getInt("post_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setCommentText(rs.getString("comment_text"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) c.setCreatedAt(ts.toLocalDateTime());

                    c.setPostTitle(rs.getString("post_title"));

                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}

