package dao;

import model.product.Category;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.*;

public class CategoryDAO {
    private final DataSource ds;
    public CategoryDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE is_active = 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<Integer, Integer> getCategoryCounts() {
        Map<Integer, Integer> map = new HashMap<>();
        String sql = "SELECT category_id, COUNT(id) as count FROM products WHERE status = 'active' GROUP BY category_id";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                map.put(rs.getInt("category_id"), rs.getInt("count"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    public List<Category> getAllActiveCategories() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT * FROM categories WHERE is_active = 1 ORDER BY parent_id ASC, id ASC";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Category c = new Category();
                c.setId(rs.getInt("id"));
                c.setName(rs.getString("name"));
                c.setSlug(rs.getString("slug"));
                c.setParentId((Integer) rs.getObject("parent_id"));
                list.add(c);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<Integer, String> getActiveCategories() {
        Map<Integer, String> map = new LinkedHashMap<>();
        String sql = "SELECT id, name FROM categories WHERE is_active = 1 ORDER BY parent_id IS NULL DESC, parent_id ASC, name ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) map.put(rs.getInt("id"), rs.getString("name"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return map;
    }

    private Category map(ResultSet rs) throws Exception {
        Category c = new Category();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setSlug(rs.getString("slug"));

        int parentId = rs.getInt("parent_id");
        c.setParentId(rs.wasNull() ? null : parentId);

        c.setIsActive(rs.getBoolean("is_active"));
        return c;
    }

    public List<Category> fetchAdminCategoryList() {
        List<Category> list = new ArrayList<>();
        String sql =
                "SELECT * FROM categories " +
                        "ORDER BY (parent_id IS NOT NULL) ASC, parent_id ASC, name ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Category> fetchParentOptionsExcluding(int excludeId) {
        List<Category> list = new ArrayList<>();
        String sql =
                "SELECT * FROM categories " +
                        "WHERE id <> ? " +
                        "ORDER BY name ASC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, excludeId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Category fetchById(int id) {
        String sql = "SELECT * FROM categories WHERE id = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
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

    public boolean existsSlug(String slug) {
        String sql = "SELECT 1 FROM categories WHERE slug = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
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

    public boolean existsSlugExceptId(String slug, int excludeId) {
        String sql = "SELECT 1 FROM categories WHERE slug = ? AND id <> ? LIMIT 1";
        try (Connection conn = ds.getConnection();
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

    public int create(Category cat) {
        String sql = "INSERT INTO categories (name, slug, parent_id, is_active) VALUES (?, ?, ?, ?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, cat.getName());
            ps.setString(2, cat.getSlug());

            if (cat.getParentId() != null && cat.getParentId() > 0) ps.setInt(3, cat.getParentId());
            else ps.setNull(3, java.sql.Types.INTEGER);

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

    public boolean update(Category cat) {
        String sql = "UPDATE categories SET name=?, slug=?, parent_id=?, is_active=? WHERE id=? LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, cat.getName());
            ps.setString(2, cat.getSlug());

            if (cat.getParentId() != null && cat.getParentId() > 0) ps.setInt(3, cat.getParentId());
            else ps.setNull(3, java.sql.Types.INTEGER);

            ps.setBoolean(4, cat.getIsActive() != null ? cat.getIsActive() : true);
            ps.setInt(5, cat.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean removeById(int id) {
        String sql = "DELETE FROM categories WHERE id = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}