package dao;

import model.refund.RefundRequest;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
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

    public boolean hasOpenRefundRequest(int orderId) {
        String sql = "SELECT 1 FROM refund_requests " +
                "WHERE order_id = ? AND status IN ('pending', 'approved', 'refunded') LIMIT 1";

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
}
