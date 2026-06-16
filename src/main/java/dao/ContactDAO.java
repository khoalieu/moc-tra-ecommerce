package dao;

import model.contact.Contact;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactDAO {
    private final DataSource ds;

    public ContactDAO(DataSource ds) {
        this.ds = ds;
    }

    public boolean create(Contact contact) {
        String sql = "INSERT INTO contacts (name, email, phone, subject, message, status) " +
                "VALUES (?, ?, ?, ?, ?, 'UNREAD')";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, contact.getName());
            ps.setString(2, contact.getEmail());
            ps.setString(3, contact.getPhone());
            ps.setString(4, contact.getSubject());
            ps.setString(5, contact.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Contact> getContacts(String status, String search, int page, int pageSize) {
        List<Contact> contacts = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT c.*, CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS replied_by_name " +
                        "FROM contacts c LEFT JOIN users u ON c.replied_by = u.id WHERE 1=1 ");

        appendFilters(sql, params, status, search);
        sql.append("ORDER BY c.created_at DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    contacts.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return contacts;
    }

    public int countContacts(String status, String search) {
        List<Object> params = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM contacts c WHERE 1=1 ");
        appendFilters(sql, params, status, search);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countUnreadContacts() {
        String sql = "SELECT COUNT(*) FROM contacts WHERE status = 'UNREAD'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Contact getContactById(int id) {
        String sql = "SELECT c.*, CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS replied_by_name " +
                "FROM contacts c LEFT JOIN users u ON c.replied_by = u.id WHERE c.id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean markRead(int id) {
        String sql = "UPDATE contacts SET status = 'READ', updated_at = NOW() WHERE id = ? AND status = 'UNREAD'";
        return updateSimple(sql, id);
    }

    public boolean reply(int id, String adminReply, Integer adminId) {
        String sql = "UPDATE contacts SET admin_reply = ?, status = 'REPLIED', replied_by = ?, " +
                "replied_at = NOW(), updated_at = NOW() WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, adminReply);
            if (adminId != null) {
                ps.setInt(2, adminId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean resolve(int id) {
        String sql = "UPDATE contacts SET status = 'RESOLVED', resolved_at = NOW(), updated_at = NOW() WHERE id = ?";
        return updateSimple(sql, id);
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM contacts WHERE id = ?";
        return updateSimple(sql, id);
    }

    private void appendFilters(StringBuilder sql, List<Object> params, String status, String search) {
        if (status != null && !status.isBlank()) {
            sql.append("AND c.status = ? ");
            params.add(status);
        }

        if (search != null && !search.isBlank()) {
            String keyword = "%" + search.trim() + "%";
            sql.append("AND (c.name LIKE ? OR c.email LIKE ? OR c.phone LIKE ? OR c.subject LIKE ?) ");
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
            params.add(keyword);
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }

    private boolean updateSimple(String sql, int id) {
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Contact mapRow(ResultSet rs) throws SQLException {
        Contact contact = new Contact();
        contact.setId(rs.getInt("id"));
        contact.setName(rs.getString("name"));
        contact.setEmail(rs.getString("email"));
        contact.setPhone(rs.getString("phone"));
        contact.setSubject(rs.getString("subject"));
        contact.setMessage(rs.getString("message"));
        contact.setAdminReply(rs.getString("admin_reply"));
        contact.setStatus(rs.getString("status"));
        int repliedBy = rs.getInt("replied_by");
        contact.setRepliedBy(rs.wasNull() ? null : repliedBy);
        contact.setRepliedByName(rs.getString("replied_by_name"));
        contact.setRepliedAt(rs.getTimestamp("replied_at"));
        contact.setResolvedAt(rs.getTimestamp("resolved_at"));
        contact.setCreatedAt(rs.getTimestamp("created_at"));
        contact.setUpdatedAt(rs.getTimestamp("updated_at"));
        return contact;
    }
}
