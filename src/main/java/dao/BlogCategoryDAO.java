package dao;
import db.DBConnect;
import model.blog.BlogCategory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BlogCategoryDAO {

    public List<BlogCategory> getActiveCategories() {
        List<BlogCategory> list = new ArrayList<>();

        String sql = "SELECT * FROM blog_categories "
                + "WHERE is_active = 1 "
                + "ORDER BY name ASC";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(map(rs));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public Map<Integer, Integer> getPublishedCountMap() {
        Map<Integer, Integer> map = new HashMap<>();
        String sql = "SELECT category_id, COUNT(*) AS cnt " +
                "FROM blog_posts " +
                "WHERE status = 'published' AND category_id IS NOT NULL " +
                "GROUP BY category_id";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) map.put(rs.getInt("category_id"), rs.getInt("cnt"));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public BlogCategory getById(int id) {
        String sql = "SELECT * FROM blog_categories WHERE id = ?";

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

    private BlogCategory map(ResultSet rs) throws Exception {
        BlogCategory c = new BlogCategory();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setSlug(rs.getString("slug"));
        c.setDescription(rs.getString("description"));
        c.setIsActive(rs.getBoolean("is_active"));
        return c;
    }

    public List<BlogCategory> getAllCategories() {
        List<BlogCategory> list = new ArrayList<>();
        String sql = "SELECT * FROM blog_categories ORDER BY name ASC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

        public boolean slugExists(String slug) {
            String sql = "SELECT 1 FROM blog_categories WHERE slug = ? LIMIT 1";
            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, slug);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

    public boolean slugExistsExceptId(String slug, int excludeId) {
        String sql = "SELECT 1 FROM blog_categories WHERE slug = ? AND id <> ? LIMIT 1";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, slug);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

        public int insertCategory(BlogCategory cat) {
            String sql = "INSERT INTO blog_categories (name, slug, description, is_active) VALUES (?, ?, ?, ?)";

            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, cat.getName());
                ps.setString(2, cat.getSlug());
                ps.setString(3, cat.getDescription());
                ps.setBoolean(4, cat.getIsActive() != null ? cat.getIsActive() : true);

                int ok = ps.executeUpdate();
                if (ok > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) return rs.getInt(1);
                    }
                    return 1;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return 0;
        }

        public BlogCategory getCategoryById(int id) {
            String sql = "SELECT * FROM blog_categories WHERE id = ? LIMIT 1";

            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        BlogCategory cat = new BlogCategory();
                        cat.setId(rs.getInt("id"));
                        cat.setName(rs.getString("name"));
                        cat.setSlug(rs.getString("slug"));
                        cat.setDescription(rs.getString("description"));
                        cat.setIsActive(rs.getBoolean("is_active"));
                        return cat;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        public boolean updateCategory(BlogCategory cat) {
            String sql = "UPDATE blog_categories SET name = ?, slug = ?, description = ?, is_active = ? WHERE id = ? LIMIT 1";

            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, cat.getName());
                ps.setString(2, cat.getSlug());
                ps.setString(3, cat.getDescription());
                ps.setBoolean(4, cat.getIsActive() != null ? cat.getIsActive() : true);
                ps.setInt(5, cat.getId());

                return ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        public boolean deleteCategory(int id) {
            String sql = "DELETE FROM blog_categories WHERE id = ? LIMIT 1";

            try (Connection conn = DBConnect.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                return ps.executeUpdate() > 0;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

}
