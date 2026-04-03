package dao;

import db.DBConnect;
import model.blog.BlogPost;
import model.user.User;
import model.enums.BlogStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class BlogPostDAO {

    public int countAllPublished() {
        String sql = "SELECT COUNT(*) " + "FROM blog_posts " + "WHERE status = 'published'";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BlogPost> getAllPublished(int page, int size) {
        List<BlogPost> list = new ArrayList<>();

        String sql = "SELECT id, title, slug, excerpt, featured_image, views_count, created_at "
                + "FROM blog_posts "
                + "WHERE status = 'published' "
                + "ORDER BY created_at DESC "
                + "LIMIT ? OFFSET ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, size);
            ps.setInt(2, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCard(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countPublishedByCategorySlug(String catSlug) {
        String sql = "SELECT COUNT(*) "
                + "FROM blog_posts bp "
                + "JOIN blog_categories bc ON bc.id = bp.category_id "
                + "WHERE bp.status = 'published' " + "AND bc.slug = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, catSlug);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BlogPost> getPublishedByCategorySlug(String catSlug, int page, int size) {
        List<BlogPost> list = new ArrayList<>();

        String sql = "SELECT bp.id, bp.title, bp.slug, bp.excerpt, bp.featured_image, bp.views_count, bp.created_at "
                + "FROM blog_posts bp "
                + "JOIN blog_categories bc ON bc.id = bp.category_id "
                + "WHERE bp.status = 'published' " + "AND bc.slug = ? "
                + "ORDER BY bp.created_at DESC "
                + "LIMIT ? OFFSET ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, catSlug);
            ps.setInt(2, size);
            ps.setInt(3, (page - 1) * size);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCard(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countSearchPublished(String q) {
        String[] keywords = splitKeywords(q);
        if (keywords.length == 0) return 0;

        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM blog_posts WHERE status = 'published' AND ("
        );

        for (int i = 0; i < keywords.length; i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("(title LIKE ? OR excerpt LIKE ? OR content LIKE ?)");
        }
        sql.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (String keyword : keywords) {
                String kw = "%" + keyword + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BlogPost> searchPublished(String q, int page, int size) {
        List<BlogPost> list = new ArrayList<>();

        String[] keywords = splitKeywords(q);
        if (keywords.length == 0) return list;

        StringBuilder sql = new StringBuilder(
                "SELECT id, title, slug, excerpt, featured_image, views_count, created_at " +
                        "FROM blog_posts " +
                        "WHERE status = 'published' AND ("
        );

        for (int i = 0; i < keywords.length; i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("(title LIKE ? OR excerpt LIKE ? OR content LIKE ?)");
        }

        sql.append(") ORDER BY created_at DESC LIMIT ? OFFSET ?");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;
            for (String keyword : keywords) {
                String kw = "%" + keyword + "%";
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
                ps.setString(idx++, kw);
            }

            ps.setInt(idx++, size);
            ps.setInt(idx++, (page - 1) * size);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCard(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    private String[] splitKeywords(String q) {
        if (q == null) return new String[0];

        q = q.trim();
        if (q.isEmpty()) return new String[0];

        return q.split("\\s+");
    }

    public List<BlogPost> getRecentPublishedPosts(int limit) {
        List<BlogPost> list = new ArrayList<>();

        String sql = "SELECT id, title, slug, featured_image, created_at " +
                "FROM blog_posts " +
                "WHERE status = 'published' " +
                "ORDER BY created_at DESC " +
                "LIMIT ?";
        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogPost p = new BlogPost();
                    p.setId(rs.getInt("id"));
                    p.setTitle(rs.getString("title"));
                    p.setSlug(rs.getString("slug"));
                    p.setFeaturedImage(rs.getString("featured_image"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) p.setCreatedAt(ts.toLocalDateTime());
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public BlogPost getPublishedBySlug(String slug) {
        String sql = "SELECT id, title, slug, excerpt, content, featured_image, " +
                "author_id, category_id, status, views_count, meta_title, meta_description, created_at " +
                "FROM blog_posts " +
                "WHERE status = 'published' AND slug = ? " +
                "LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, slug);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BlogPost b = new BlogPost();
                    b.setId(rs.getInt("id"));
                    b.setTitle(rs.getString("title"));
                    b.setSlug(rs.getString("slug"));
                    b.setExcerpt(rs.getString("excerpt"));
                    b.setContent(rs.getString("content"));
                    b.setFeaturedImage(rs.getString("featured_image"));
                    b.setAuthorId(rs.getInt("author_id"));

                    int catId = rs.getInt("category_id");
                    b.setCategoryId(rs.wasNull() ? null : catId);

                    b.setViewsCount(rs.getInt("views_count"));
                    b.setMetaTitle(rs.getString("meta_title"));
                    b.setMetaDescription(rs.getString("meta_description"));

                    String st = rs.getString("status");
                    if (st != null) b.setStatus(BlogStatus.valueOf(st.toUpperCase()));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) b.setCreatedAt(ts.toLocalDateTime());

                    return b;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public void incrementViews(int postId) {
        String sql = "UPDATE blog_posts " +
                "SET views_count = IFNULL(views_count, 0) + 1 " +
                "WHERE id = ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<BlogPost> getTopViewedPublished(int limit) {
        List<BlogPost> list = new ArrayList<>();

        String sql = "SELECT id, title, slug, excerpt, featured_image, views_count, created_at " +
                "FROM blog_posts " +
                "WHERE status = 'published' " +
                "ORDER BY IFNULL(views_count, 0) DESC, created_at DESC " +
                "LIMIT ?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCard(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }


    private BlogPost mapCard(ResultSet rs) throws Exception {
        BlogPost b = new BlogPost();
        b.setId(rs.getInt("id"));
        b.setTitle(rs.getString("title"));
        b.setSlug(rs.getString("slug"));
        b.setExcerpt(rs.getString("excerpt"));
        b.setFeaturedImage(rs.getString("featured_image"));
        b.setViewsCount(rs.getInt("views_count"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) b.setCreatedAt(ts.toLocalDateTime());
        return b;
    }

    public int countPostsForAdmin(String q, Integer categoryId, BlogStatus status, Integer authorId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM blog_posts bp WHERE 1=1");

        String[] keywords = splitKeywords(q);
        boolean hasQ = keywords.length > 0;

        if (hasQ) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("(bp.title LIKE ? OR bp.slug LIKE ? OR IFNULL(bp.excerpt,'') LIKE ? OR IFNULL(bp.content,'') LIKE ?)");
            }
            sql.append(")");
        }

        if (categoryId != null) sql.append(" AND bp.category_id = ?");
        if (status != null) sql.append(" AND bp.status = ?");
        if (authorId != null) sql.append(" AND bp.author_id = ?");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            if (hasQ) {
                for (String keyword : keywords) {
                    String kw = "%" + keyword + "%";
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                }
            }

            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (status != null) ps.setString(idx++, status.name().toLowerCase());
            if (authorId != null) ps.setInt(idx++, authorId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BlogPost> getPostsForAdmin(String q, Integer categoryId, BlogStatus status, Integer authorId, String sort, int page, int size) {
        List<BlogPost> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT bp.*, u.username, u.email, u.first_name, u.last_name, u.avatar " +
                        "FROM blog_posts bp " +
                        "LEFT JOIN users u ON u.id = bp.author_id " +
                        "WHERE 1=1"
        );

        String[] keywords = splitKeywords(q);
        boolean hasQ = keywords.length > 0;

        if (hasQ) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.length; i++) {
                if (i > 0) sql.append(" OR ");
                sql.append("(bp.title LIKE ? OR bp.slug LIKE ? OR IFNULL(bp.excerpt,'') LIKE ? OR IFNULL(bp.content,'') LIKE ?)");
            }
            sql.append(")");
        }

        if (categoryId != null) sql.append(" AND bp.category_id = ?");
        if (status != null) sql.append(" AND bp.status = ?");
        if (authorId != null) sql.append(" AND bp.author_id = ?");

        if (sort == null) sort = "date_desc";
        switch (sort) {
            case "title_asc":
                sql.append(" ORDER BY bp.title ASC");
                break;
            case "title_desc":
                sql.append(" ORDER BY bp.title DESC");
                break;
            case "views_asc":
                sql.append(" ORDER BY bp.views_count ASC");
                break;
            case "views_desc":
                sql.append(" ORDER BY bp.views_count DESC");
                break;
            case "date_asc":
                sql.append(" ORDER BY bp.created_at ASC");
                break;
            case "date_desc":
            default:
                sql.append(" ORDER BY bp.created_at DESC");
                break;
        }

        sql.append(" LIMIT ? OFFSET ?");

        if (page < 1) page = 1;
        int offset = (page - 1) * size;

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            if (hasQ) {
                for (String keyword : keywords) {
                    String kw = "%" + keyword + "%";
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                    ps.setString(idx++, kw);
                }
            }

            if (categoryId != null) ps.setInt(idx++, categoryId);
            if (status != null) ps.setString(idx++, status.name().toLowerCase());
            if (authorId != null) ps.setInt(idx++, authorId);

            ps.setInt(idx++, size);
            ps.setInt(idx++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogPost p = new BlogPost();
                    p.setId(rs.getInt("id"));
                    p.setTitle(rs.getString("title"));
                    p.setSlug(rs.getString("slug"));
                    p.setExcerpt(rs.getString("excerpt"));

                    String st = rs.getString("status");
                    if (st != null) p.setStatus(BlogStatus.valueOf(st.toUpperCase()));

                    Integer aid = (Integer) rs.getObject("author_id");
                    p.setAuthorId(aid);

                    if (aid != null) {
                        User au = new User();
                        au.setId(aid);
                        au.setUsername(rs.getString("username"));
                        au.setEmail(rs.getString("email"));
                        au.setFirstName(rs.getString("first_name"));
                        au.setLastName(rs.getString("last_name"));
                        au.setAvatar(rs.getString("avatar"));
                        p.setAuthor(au);
                    }

                    int catId = rs.getInt("category_id");
                    p.setCategoryId(rs.wasNull() ? null : catId);

                    p.setViewsCount(rs.getInt("views_count"));
                    p.setFeaturedImage(rs.getString("featured_image"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) p.setCreatedAt(ts.toLocalDateTime());

                    list.add(p);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean slugExists(String slug) {
        String sql = "SELECT 1 FROM blog_posts WHERE slug = ? LIMIT 1";
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

    public int insertForAdmin(BlogPost p, LocalDateTime createdAt) {
        String sql = "INSERT INTO blog_posts " +
                "(title, slug, excerpt, content, featured_image, author_id, category_id, status, views_count, meta_title, meta_description, created_at) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?, COALESCE(?, NOW()))";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getTitle());
            ps.setString(2, p.getSlug());
            ps.setString(3, p.getExcerpt());
            ps.setString(4, p.getContent());
            ps.setString(5, p.getFeaturedImage());
            ps.setObject(6, p.getAuthorId());
            ps.setObject(7, p.getCategoryId());
            ps.setString(8, p.getStatus() == null ? "draft" : p.getStatus().name().toLowerCase());
            ps.setInt(9, 0);
            ps.setString(10, p.getMetaTitle());
            ps.setString(11, p.getMetaDescription());

            if (createdAt != null) ps.setTimestamp(12, Timestamp.valueOf(createdAt));
            else ps.setNull(12, java.sql.Types.TIMESTAMP);

            int ok = ps.executeUpdate();
            if (ok > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
                return 1; // fallback
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public BlogPost getByIdForAdmin(int id) {
        String sql =
                "SELECT bp.*, u.username, u.email, u.first_name, u.last_name, u.avatar " +
                        "FROM blog_posts bp " +
                        "LEFT JOIN users u ON u.id = bp.author_id " +
                        "WHERE bp.id = ? " +
                        "LIMIT 1";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                BlogPost p = new BlogPost();
                p.setId(rs.getInt("id"));
                p.setTitle(rs.getString("title"));
                p.setSlug(rs.getString("slug"));
                p.setExcerpt(rs.getString("excerpt"));
                p.setContent(rs.getString("content"));
                p.setFeaturedImage(rs.getString("featured_image"));

                Integer aid = (Integer) rs.getObject("author_id");
                p.setAuthorId(aid);

                if (aid != null) {
                    User au = new User();
                    au.setId(aid);
                    au.setUsername(rs.getString("username"));
                    au.setEmail(rs.getString("email"));
                    au.setFirstName(rs.getString("first_name"));
                    au.setLastName(rs.getString("last_name"));
                    au.setAvatar(rs.getString("avatar"));
                    p.setAuthor(au);
                }

                Integer cid = (Integer) rs.getObject("category_id");
                p.setCategoryId(cid);

                String st = rs.getString("status");
                if (st != null) p.setStatus(BlogStatus.valueOf(st.toUpperCase()));

                p.setViewsCount(rs.getInt("views_count"));
                p.setMetaTitle(rs.getString("meta_title"));
                p.setMetaDescription(rs.getString("meta_description"));

                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) p.setCreatedAt(ts.toLocalDateTime());

                return p;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateForAdmin(BlogPost p, boolean keepOldImage) {
        StringBuilder sql = new StringBuilder(
                "UPDATE blog_posts SET " +
                        "title = ?, " +
                        "slug = ?, " +
                        "excerpt = ?, " +
                        "content = ?, "
        );

        if (!keepOldImage) {
            sql.append("featured_image = ?, ");
        }

        sql.append(
                "author_id = ?, " +
                        "category_id = ?, " +
                        "status = ?, " +
                        "meta_title = ?, " +
                        "meta_description = ? " +
                        "WHERE id = ? " +
                        "LIMIT 1"
        );

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int idx = 1;

            ps.setString(idx++, p.getTitle());
            ps.setString(idx++, p.getSlug());
            ps.setString(idx++, p.getExcerpt());
            ps.setString(idx++, p.getContent());

            if (!keepOldImage) {
                ps.setString(idx++, p.getFeaturedImage());
            }

            ps.setObject(idx++, p.getAuthorId());
            ps.setObject(idx++, p.getCategoryId());
            ps.setString(idx++, p.getStatus() == null ? "draft" : p.getStatus().name().toLowerCase());
            ps.setString(idx++, p.getMetaTitle());
            ps.setString(idx++, p.getMetaDescription());

            ps.setInt(idx++, p.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public boolean slugExistsExceptId(String slug, int excludeId) {
        String sql = "SELECT 1 FROM blog_posts WHERE slug = ? AND id <> ? LIMIT 1";
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


    public boolean deleteByIds(List<Integer> ids) {
        if (ids == null || ids.isEmpty()) return false;

        StringBuilder sql = new StringBuilder("DELETE FROM blog_posts WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sql.append("?");
            if (i < ids.size() - 1) sql.append(",");
        }
        sql.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 1, ids.get(i));
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatusByIds(List<Integer> ids, BlogStatus newStatus) {
        if (ids == null || ids.isEmpty() || newStatus == null) return false;

        StringBuilder sql = new StringBuilder("UPDATE blog_posts SET status = ? WHERE id IN (");
        for (int i = 0; i < ids.size(); i++) {
            sql.append("?");
            if (i < ids.size() - 1) sql.append(",");
        }
        sql.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setString(1, newStatus.name().toLowerCase());

            for (int i = 0; i < ids.size(); i++) {
                ps.setInt(i + 2, ids.get(i));
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

}

