package dao;

import db.DBConnect;
import model.Banner;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BannerDAO {

    public List<Banner> getAll() {
        List<Banner> list = new ArrayList<>();
        String sql =
                "SELECT * FROM banners " +
                        "ORDER BY " +
                        "  CASE WHEN sort_order IS NULL THEN 1 ELSE 0 END ASC, " +
                        "  sort_order ASC, " +
                        "  created_at DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public Banner getById(int id) {
        String sql = "SELECT * FROM banners WHERE id = ?";
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

    public void insert(Banner b) throws SQLException {
        // nếu có sort_order -> clear slot cũ trước
        if (b.getSortOrder() != null) {
            clearSameSlot(b.getSection(), b.getSortOrder(), null);
        }

        String sql = "INSERT INTO banners(title, subtitle, image_url, button_text, button_link, section, sort_order, is_active) " +
                "VALUES(?,?,?,?,?,?,?,?)";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, b.getTitle());
            ps.setString(2, b.getSubtitle());
            ps.setString(3, b.getImageUrl());
            ps.setString(4, b.getButtonText());
            ps.setString(5, b.getButtonLink());
            ps.setString(6, b.getSection());

            if (b.getSortOrder() == null) ps.setNull(7, Types.INTEGER);
            else ps.setInt(7, b.getSortOrder());

            ps.setBoolean(8, Boolean.TRUE.equals(b.getIsActive()));
            ps.executeUpdate();
        }
    }

    public void update(Banner b) throws SQLException {
        if (b.getSortOrder() != null) {
            clearSameSlot(b.getSection(), b.getSortOrder(), b.getId());
        }

        String sql = "UPDATE banners SET title=?, subtitle=?, image_url=?, button_text=?, button_link=?, section=?, sort_order=?, is_active=? " +
                "WHERE id=?";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, b.getTitle());
            ps.setString(2, b.getSubtitle());
            ps.setString(3, b.getImageUrl());
            ps.setString(4, b.getButtonText());
            ps.setString(5, b.getButtonLink());
            ps.setString(6, b.getSection());

            if (b.getSortOrder() == null) ps.setNull(7, Types.INTEGER);
            else ps.setInt(7, b.getSortOrder());

            ps.setBoolean(8, Boolean.TRUE.equals(b.getIsActive()));
            ps.setInt(9, b.getId());

            ps.executeUpdate();
        }
    }

    public void deleteByIds(int[] ids) throws SQLException {
        if (ids == null || ids.length == 0) return;

        StringBuilder sb = new StringBuilder("DELETE FROM banners WHERE id IN (");
        for (int i = 0; i < ids.length; i++) {
            sb.append("?");
            if (i < ids.length - 1) sb.append(",");
        }
        sb.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {

            for (int i = 0; i < ids.length; i++) ps.setInt(i + 1, ids[i]);
            ps.executeUpdate();
        }
    }

    public void updateActiveByIds(int[] ids, boolean isActive) throws SQLException {
        if (ids == null || ids.length == 0) return;

        StringBuilder sb = new StringBuilder("UPDATE banners SET is_active = ? WHERE id IN (");
        for (int i = 0; i < ids.length; i++) {
            sb.append("?");
            if (i < ids.length - 1) sb.append(",");
        }
        sb.append(")");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sb.toString())) {

            ps.setBoolean(1, isActive);
            for (int i = 0; i < ids.length; i++) ps.setInt(i + 2, ids[i]);
            ps.executeUpdate();
        }
    }

    private void clearSameSlot(String section, int sortOrder, Integer excludeId) throws SQLException {
        String sql = "UPDATE banners SET sort_order = NULL " +
                "WHERE section = ? AND sort_order = ? " +
                (excludeId != null ? "AND id <> ?" : "");

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, section);
            ps.setInt(2, sortOrder);
            if (excludeId != null) ps.setInt(3, excludeId);
            ps.executeUpdate();
        }
    }

    private Banner map(ResultSet rs) throws SQLException {
        Banner b = new Banner();
        b.setId(rs.getInt("id"));
        b.setTitle(rs.getString("title"));
        b.setSubtitle(rs.getString("subtitle"));
        b.setImageUrl(rs.getString("image_url"));
        b.setButtonText(rs.getString("button_text"));
        b.setButtonLink(rs.getString("button_link"));
        b.setSection(rs.getString("section"));

        int so = rs.getInt("sort_order");
        b.setSortOrder(rs.wasNull() ? null : so);

        b.setIsActive(rs.getBoolean("is_active"));

        Timestamp c = rs.getTimestamp("created_at");
        Timestamp u = rs.getTimestamp("updated_at");
        if (c != null) b.setCreatedAt(c.toLocalDateTime());
        if (u != null) b.setUpdatedAt(u.toLocalDateTime());
        return b;
    }
    public List<Banner> getHomeActive() {
        List<Banner> list = new ArrayList<>();
        String sql =
                "SELECT * FROM banners " +
                        "WHERE is_active = 1 AND section = 'home' " +
                        "ORDER BY " +
                        "  CASE WHEN sort_order IS NULL THEN 1 ELSE 0 END ASC, " +
                        "  sort_order ASC, " +
                        "  created_at DESC";

        try (Connection conn = DBConnect.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(map(rs));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

}
