package dao;

import model.enums.PaymentStatus;
import model.order.Order;
import model.refund.RefundRequest;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RefundDAO {
    private final DataSource ds;

    public RefundDAO(DataSource ds) {
        this.ds = ds;
    }

    public boolean createRefundRequest(RefundRequest refund) {
        String sql = "INSERT INTO refund_requests " +
                "(order_id, user_id, amount, reason, receive_method, account_holder, account_number, qr_image_url, note, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending')";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, refund.getOrderId());
            ps.setInt(2, refund.getUserId());
            ps.setDouble(3, refund.getAmount());
            ps.setString(4, refund.getReason());
            ps.setString(5, refund.getReceiveMethod());
            ps.setString(6, refund.getAccountHolder());
            ps.setString(7, refund.getAccountNumber());
            ps.setString(8, refund.getQrImageUrl());
            ps.setString(9, refund.getNote());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean createPendingInfoRefundForFailedDelivery(Order order, String reason) {
        if (!isPaidOnlineOrder(order) || hasOpenRefundRequest(order.getId())) {
            return false;
        }

        String sql = "INSERT INTO refund_requests " +
                "(order_id, user_id, amount, reason, receive_method, account_holder, account_number, qr_image_url, note, status) " +
                "VALUES (?, ?, ?, ?, NULL, NULL, NULL, NULL, NULL, 'pending_info')";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, order.getId());
            ps.setInt(2, order.getUserId());
            ps.setDouble(3, order.getTotalAmount());
            ps.setString(4, reason);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean completePendingInfoRefund(RefundRequest refund) {
        String sql = "UPDATE refund_requests " +
                "SET reason = ?, receive_method = ?, account_holder = ?, account_number = ?, " +
                "qr_image_url = ?, note = ?, status = 'pending' " +
                "WHERE id = ? AND user_id = ? AND order_id = ? AND status = 'pending_info'";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, refund.getReason());
            ps.setString(2, refund.getReceiveMethod());
            ps.setString(3, refund.getAccountHolder());
            ps.setString(4, refund.getAccountNumber());
            ps.setString(5, refund.getQrImageUrl());
            ps.setString(6, refund.getNote());
            ps.setInt(7, refund.getId());
            ps.setInt(8, refund.getUserId());
            ps.setInt(9, refund.getOrderId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean hasOpenRefundRequest(int orderId) {
        String sql = "SELECT 1 FROM refund_requests " +
                "WHERE order_id = ? AND status IN ('pending_info', 'pending', 'approved', 'refunded') LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Map<Integer, RefundRequest> getLatestRefundsByUserOrders(int userId, List<Integer> orderIds) {
        Map<Integer, RefundRequest> map = new HashMap<>();
        if (orderIds == null || orderIds.isEmpty()) {
            return map;
        }

        StringBuilder sql = new StringBuilder(
                "SELECT rr.* FROM refund_requests rr " +
                        "JOIN (SELECT order_id, MAX(id) AS latest_id FROM refund_requests WHERE user_id = ? "
        );
        sql.append("AND order_id IN (");
        appendPlaceholders(sql, orderIds.size());
        sql.append(") GROUP BY order_id) latest ON latest.latest_id = rr.id");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            for (Integer orderId : orderIds) {
                ps.setInt(paramIndex++, orderId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RefundRequest refund = mapRow(rs);
                    map.put(refund.getOrderId(), refund);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return map;
    }

    public List<RefundRequest> getRefundRequests(String status, int page, int pageSize) {
        List<RefundRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT rr.*, o.order_number, " +
                "COALESCE(NULLIF(TRIM(CONCAT(IFNULL(u.last_name, ''), ' ', IFNULL(u.first_name, ''))), ''), u.username) AS customer_name, " +
                "u.email AS customer_email " +
                "FROM refund_requests rr " +
                "JOIN orders o ON o.id = rr.order_id " +
                "JOIN users u ON u.id = rr.user_id " +
                "WHERE 1=1 ");

        if (status != null && !status.isBlank()) {
            sql.append("AND rr.status = ? ");
        }

        sql.append("ORDER BY rr.created_at DESC LIMIT ? OFFSET ?");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (status != null && !status.isBlank()) {
                ps.setString(paramIndex++, status);
            }
            ps.setInt(paramIndex++, pageSize);
            ps.setInt(paramIndex, (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countRefundRequests(String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM refund_requests WHERE 1=1 ");
        if (status != null && !status.isBlank()) {
            sql.append("AND status = ? ");
        }

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            if (status != null && !status.isBlank()) {
                ps.setString(1, status);
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public RefundRequest getLatestRefundByOrderId(int orderId) {
        String sql = "SELECT rr.*, o.order_number, " +
                "COALESCE(NULLIF(TRIM(CONCAT(IFNULL(u.last_name, ''), ' ', IFNULL(u.first_name, ''))), ''), u.username) AS customer_name, " +
                "u.email AS customer_email " +
                "FROM refund_requests rr " +
                "JOIN orders o ON o.id = rr.order_id " +
                "JOIN users u ON u.id = rr.user_id " +
                "WHERE rr.order_id = ? ORDER BY rr.id DESC LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public RefundRequest getRefundById(int id) {
        String sql = "SELECT rr.*, o.order_number, " +
                "COALESCE(NULLIF(TRIM(CONCAT(IFNULL(u.last_name, ''), ' ', IFNULL(u.first_name, ''))), ''), u.username) AS customer_name, " +
                "u.email AS customer_email " +
                "FROM refund_requests rr " +
                "JOIN orders o ON o.id = rr.order_id " +
                "JOIN users u ON u.id = rr.user_id " +
                "WHERE rr.id = ? LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateRefundStatus(int refundId, String status, String adminNote, Integer processedBy) {
        String sql = "UPDATE refund_requests " +
                "SET status = ?, admin_note = ?, processed_by = ?, processed_at = NOW() " +
                "WHERE id = ? AND status = 'pending'";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, adminNote);
            if (processedBy != null) {
                ps.setInt(3, processedBy);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setInt(4, refundId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private RefundRequest mapRow(ResultSet rs) throws Exception {
        RefundRequest refund = new RefundRequest();
        refund.setId(rs.getInt("id"));
        refund.setOrderId(rs.getInt("order_id"));
        refund.setUserId(rs.getInt("user_id"));
        refund.setAmount(rs.getDouble("amount"));
        refund.setReason(rs.getString("reason"));
        refund.setReceiveMethod(rs.getString("receive_method"));
        refund.setAccountHolder(rs.getString("account_holder"));
        refund.setAccountNumber(rs.getString("account_number"));
        refund.setQrImageUrl(rs.getString("qr_image_url"));
        refund.setNote(rs.getString("note"));
        refund.setStatus(rs.getString("status"));
        refund.setAdminNote(rs.getString("admin_note"));

        int processedBy = rs.getInt("processed_by");
        if (!rs.wasNull()) {
            refund.setProcessedBy(processedBy);
        }

        refund.setCreatedAt(rs.getTimestamp("created_at"));
        refund.setProcessedAt(rs.getTimestamp("processed_at"));
        try {
            refund.setOrderNumber(rs.getString("order_number"));
            refund.setCustomerName(rs.getString("customer_name"));
            refund.setCustomerEmail(rs.getString("customer_email"));
        } catch (Exception ignored) {
        }
        return refund;
    }

    private void appendPlaceholders(StringBuilder sql, int count) {
        for (int i = 0; i < count; i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
        }
    }

    private boolean isPaidOnlineOrder(Order order) {
        return order != null
                && order.getPaymentStatus() == PaymentStatus.PAID
                && order.getPaymentMethod() != null
                && !"cod".equalsIgnoreCase(order.getPaymentMethod());
    }
}
