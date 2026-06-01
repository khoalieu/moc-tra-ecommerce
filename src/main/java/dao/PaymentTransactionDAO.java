package dao;

import model.payment.PaymentTransaction;

import javax.sql.DataSource;
import java.sql.*;

public class PaymentTransactionDAO {
    private final DataSource ds;

    public PaymentTransactionDAO(DataSource ds) {
        this.ds = ds;
    }

    public int create(PaymentTransaction tx) {
        String sql = "INSERT INTO payment_transactions " +
                "(order_id, payment_method, provider, request_id, provider_order_id, amount, " +
                "qr_code_url, pay_url, deeplink, transaction_status, raw_response, expired_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, tx.getOrderId());
            ps.setString(2, tx.getPaymentMethod());
            ps.setString(3, tx.getProvider());
            ps.setString(4, tx.getRequestId());
            ps.setString(5, tx.getProviderOrderId());
            ps.setDouble(6, tx.getAmount());
            ps.setString(7, tx.getQrCodeUrl());
            ps.setString(8, tx.getPayUrl());
            ps.setString(9, tx.getDeeplink());
            ps.setString(10, tx.getTransactionStatus());
            ps.setString(11, tx.getRawResponse());
            ps.setTimestamp(12, tx.getExpiredAt());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public PaymentTransaction getByOrderId(int orderId) {
        String sql = "SELECT * FROM payment_transactions WHERE order_id = ? ORDER BY id DESC LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public PaymentTransaction getByProviderOrderId(String providerOrderId) {
        String sql = "SELECT * FROM payment_transactions WHERE provider_order_id = ? ORDER BY id DESC LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, providerOrderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateStatusByProviderOrderId(String providerOrderId, String status, String rawResponse) {
        String sql = "UPDATE payment_transactions " +
                "SET transaction_status = ?, raw_response = ? " +
                "WHERE provider_order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, rawResponse);
            ps.setString(3, providerOrderId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean markPaidByProviderOrderId(String providerOrderId, String rawResponse) {
        String sql = "UPDATE payment_transactions " +
                "SET transaction_status = 'paid', raw_response = ?, paid_at = NOW() " +
                "WHERE provider_order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, rawResponse);
            ps.setString(2, providerOrderId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    public boolean markExpiredById(int id) {
        String sql = "UPDATE payment_transactions " +
                "SET transaction_status = 'expired' " +
                "WHERE id = ? AND transaction_status = 'pending'";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private PaymentTransaction mapRow(ResultSet rs) throws SQLException {
        PaymentTransaction tx = new PaymentTransaction();

        tx.setId(rs.getInt("id"));
        tx.setOrderId(rs.getInt("order_id"));
        tx.setPaymentMethod(rs.getString("payment_method"));
        tx.setProvider(rs.getString("provider"));
        tx.setRequestId(rs.getString("request_id"));
        tx.setProviderOrderId(rs.getString("provider_order_id"));
        tx.setAmount(rs.getDouble("amount"));
        tx.setQrCodeUrl(rs.getString("qr_code_url"));
        tx.setPayUrl(rs.getString("pay_url"));
        tx.setDeeplink(rs.getString("deeplink"));
        tx.setTransactionStatus(rs.getString("transaction_status"));
        tx.setRawResponse(rs.getString("raw_response"));
        tx.setCreatedAt(rs.getTimestamp("created_at"));
        tx.setPaidAt(rs.getTimestamp("paid_at"));
        tx.setExpiredAt(rs.getTimestamp("expired_at"));

        return tx;
    }
}