package dao;

import model.cart.CartItem;
import model.order.Order;
import model.order.OrderItem;
import model.product.Product;
import model.enums.OrderStatus;
import model.enums.PaymentStatus;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {
    private final DataSource ds;
    public OrderDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, a.full_name, a.phone_number, a.street_address, a.ward, a.province " +
                "FROM orders o " +
                "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                "WHERE o.user_id = ? " +
                "ORDER BY o.created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setShippingAddressId(rs.getInt("shipping_address_id"));
                o.setOrderNumber(rs.getString("order_number"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setShippingFee(rs.getDouble("shipping_fee"));
                o.setPaymentMethod(rs.getString("payment_method"));

                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) {
                    o.setCreatedAt(Timestamp.valueOf(ts.toLocalDateTime()));
                }

                try {
                    String statusStr = rs.getString("status");
                    if (statusStr != null) {
                        o.setStatus(OrderStatus.valueOf(statusStr.toUpperCase()));
                    } else {
                        o.setStatus(OrderStatus.PENDING);
                    }
                } catch (IllegalArgumentException e) {
                    o.setStatus(OrderStatus.PENDING);
                }

                try {
                    String payStatusStr = rs.getString("payment_status");
                    if (payStatusStr != null) {
                        o.setPaymentStatus(PaymentStatus.valueOf(payStatusStr.toUpperCase()));
                    } else {
                        o.setPaymentStatus(PaymentStatus.PENDING);
                    }
                } catch (IllegalArgumentException e) {
                    o.setPaymentStatus(PaymentStatus.PENDING);
                }

                String fullName = rs.getString("full_name");
                if (fullName != null) {
                    String phone = rs.getString("phone_number");
                    String street = rs.getString("street_address");
                    String ward = rs.getString("ward");
                    String province = rs.getString("province");

                    String fullAddr = String.format("<strong>%s - %s</strong><br>%s, %s, %s",
                            fullName, phone, street, ward, province);
                    o.setNotes(fullAddr);
                    o.setNotes("Địa chỉ đã bị xóa hoặc không tồn tại.");
                }

                o.setItems(getOrderItems(o.getId()));

                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createOrder(Order order) {
        String sql = "INSERT INTO orders (user_id, shipping_address_id, order_number, status, total_amount, shipping_fee, payment_method, payment_status, notes, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, order.getUserId());

            if (order.getShippingAddressId() != null) {
                ps.setInt(2, order.getShippingAddressId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, order.getOrderNumber());

            ps.setString(4, OrderStatus.PENDING.name().toLowerCase());

            ps.setDouble(5, order.getTotalAmount());
            ps.setDouble(6, order.getShippingFee());
            ps.setString(7, order.getPaymentMethod());

            ps.setString(8, PaymentStatus.PENDING.name().toLowerCase());

            ps.setString(9, order.getNotes());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public void addOrderItems(int orderId, List<CartItem> items) {
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (?, ?, ?, ?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (CartItem item : items) {
                ps.setInt(1, orderId);
                ps.setInt(2, item.getProduct().getId());
                ps.setInt(3, item.getQuantity());

                double finalPrice = item.getProduct().getSalePrice() > 0 ?
                        item.getProduct().getSalePrice() :
                        item.getProduct().getPrice();

                ps.setDouble(4, finalPrice);
                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, p.name, p.image_url " +
                "FROM order_items oi " +
                "JOIN products p ON oi.product_id = p.id " +
                "WHERE oi.order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setId(rs.getInt("id")); // Lấy ID của item nếu cần
                item.setOrderId(orderId);
                item.setProductId(rs.getInt("product_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getDouble("price"));

                Product p = new Product();
                p.setId(rs.getInt("product_id"));
                p.setName(rs.getString("name"));
                p.setImageUrl(rs.getString("image_url"));

                item.setProduct(p);
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    public Order getOrderById(int orderId) {
        Order o = null;
        String sql = "SELECT o.*, a.full_name, a.phone_number, a.street_address, a.ward, a.province " +
                "FROM orders o " +
                "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                "WHERE o.id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                o = new Order();
                o.setId(rs.getInt("id"));
                o.setUserId(rs.getInt("user_id"));
                o.setShippingAddressId(rs.getInt("shipping_address_id"));
                o.setOrderNumber(rs.getString("order_number"));
                o.setTotalAmount(rs.getDouble("total_amount"));
                o.setShippingFee(rs.getDouble("shipping_fee"));
                o.setPaymentMethod(rs.getString("payment_method"));
                Timestamp ts = rs.getTimestamp("created_at");
                if (ts != null) {
                    o.setCreatedAt(Timestamp.valueOf(ts.toLocalDateTime()));
                }
                try {
                    String statusStr = rs.getString("status");
                    o.setStatus(statusStr != null ? OrderStatus.valueOf(statusStr.toUpperCase()) : OrderStatus.PENDING);
                } catch (Exception e) {
                    o.setStatus(OrderStatus.PENDING);
                }
                try {
                    String payStatusStr = rs.getString("payment_status");
                    o.setPaymentStatus(payStatusStr != null ? PaymentStatus.valueOf(payStatusStr.toUpperCase()) : PaymentStatus.PENDING);
                } catch (Exception e) {
                    o.setPaymentStatus(PaymentStatus.PENDING);
                }
                String fullName = rs.getString("full_name");
                if (fullName != null) {
                    String phone = rs.getString("phone_number");
                    String street = rs.getString("street_address");
                    String ward = rs.getString("ward");
                    String province = rs.getString("province");
                    String fullAddr = String.format("%s - %s<br>%s, %s, %s",
                            fullName, phone, street, ward, province);
                    o.setNotes(fullAddr);
                } else {
                    o.setNotes(rs.getString("notes"));
                }
                o.setItems(getOrderItems(o.getId()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return o;
    }

    public List<Order> getAllOrders(int index, int size, String search, String status, String timeFilter, String sortOrder) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, a.full_name, a.phone_number FROM orders o " +
                        "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                        "WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (o.order_number LIKE ? OR a.full_name LIKE ?) ");
        }

        if (status != null && !status.isEmpty()) {
            sql.append(" AND o.status = ? ");
        }

        if ("this_month".equals(timeFilter)) {
            sql.append(" AND MONTH(o.created_at) = MONTH(CURRENT_DATE()) AND YEAR(o.created_at) = YEAR(CURRENT_DATE()) ");
        } else if ("last_month".equals(timeFilter)) {
            sql.append(" AND MONTH(o.created_at) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH) ");
        }

        if ("price_asc".equals(sortOrder)) {
            sql.append(" ORDER BY o.total_amount ASC ");
        } else if ("price_desc".equals(sortOrder)) {
            sql.append(" ORDER BY o.total_amount DESC ");
        } else if ("oldest".equals(sortOrder)) {
            sql.append(" ORDER BY o.created_at ASC ");
        } else {
            sql.append(" ORDER BY o.created_at DESC ");
        }

        sql.append(" LIMIT ? OFFSET ?");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (search != null && !search.trim().isEmpty()) {
                String kw = "%" + search.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }

            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status.toLowerCase());
            }

            ps.setInt(paramIndex++, size);
            ps.setInt(paramIndex++, (index - 1) * size);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = mapRowToOrder(rs);
                o.setItems(getOrderItems(o.getId()));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAllOrders(String search, String status, String timeFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                        "FROM orders o " +
                        "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                        "WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (o.order_number LIKE ? OR a.full_name LIKE ?) ");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND o.status = ? ");
        }
        if ("this_month".equals(timeFilter)) {
            sql.append(" AND MONTH(o.created_at) = MONTH(CURRENT_DATE()) AND YEAR(o.created_at) = YEAR(CURRENT_DATE()) ");
        } else if ("last_month".equals(timeFilter)) {
            sql.append(" AND MONTH(o.created_at) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH) ");
        }

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (search != null && !search.trim().isEmpty()) {
                String kw = "%" + search.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }

            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status.toLowerCase());
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean updateOrderStatus(int orderId, OrderStatus status) {
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name().toLowerCase());
            ps.setInt(2, orderId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Order mapRowToOrder(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setId(rs.getInt("id"));
        o.setUserId(rs.getInt("user_id"));
        o.setOrderNumber(rs.getString("order_number"));
        o.setTotalAmount(rs.getDouble("total_amount"));
        o.setShippingFee(rs.getDouble("shipping_fee"));
        o.setPaymentMethod(rs.getString("payment_method"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) o.setCreatedAt(ts);

        try {
            o.setStatus(OrderStatus.valueOf(rs.getString("status").toUpperCase()));
        } catch (Exception e) {
            o.setStatus(OrderStatus.PENDING);
        }

        try {
            o.setPaymentStatus(PaymentStatus.valueOf(rs.getString("payment_status").toUpperCase()));
        } catch (Exception e) {
            o.setPaymentStatus(PaymentStatus.PENDING);
        }

        try {
            String customerName = rs.getString("full_name");
            if (customerName != null) o.setNotes(customerName);
        } catch (Exception e) {
        }

        return o;
    }

    public List<Order> getRecentOrders(int limit) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, a.full_name FROM orders o " +
                "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                "ORDER BY o.created_at DESC LIMIT ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = mapRowToOrder(rs);
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    public boolean cancelOrder(int orderId) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            Order order = getOrderById(orderId);
            if (order == null || order.getStatus() != OrderStatus.PENDING) {
                return false;
            }
            String sqlUpdateOrder = "UPDATE orders SET status = 'cancelled' WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateOrder)) {
                ps.setInt(1, orderId);
                ps.executeUpdate();
            }
            for (OrderItem item : order.getItems()) {
                String sqlUpdateStock = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
                try (PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock)) {
                    psStock.setInt(1, item.getQuantity());
                    psStock.setInt(2, item.getProductId());
                    psStock.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }
    public boolean cancelOrder(int orderId, String reason) {
        String sql = "UPDATE orders SET status = 'cancelled', cancel_reason = ? WHERE id = ? AND status = 'pending'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}