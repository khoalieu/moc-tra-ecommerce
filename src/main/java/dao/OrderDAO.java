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
                } else {
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
        String sql = "INSERT INTO order_items " +
                "(order_id, product_id, variant_id, quantity, price, original_price, discount_amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            for (CartItem item : items) {
                ps.setInt(1, orderId);
                ps.setInt(2, item.getProduct().getId());
                Integer variantId = item.getVariant() != null ? item.getVariant().getId() :
                        (item.getVariantId() > 0 ? item.getVariantId() : null);
                if (variantId != null && variantId > 0) {
                    ps.setInt(3, variantId);
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setInt(4, item.getQuantity());

                double finalPrice = item.getUnitPrice();
                double originalPrice = item.getOriginalUnitPrice();
                double discountAmount = item.getDiscountPerItem();

                ps.setDouble(5, finalPrice);
                ps.setDouble(6, originalPrice);
                ps.setDouble(7, discountAmount);

                ps.addBatch();
            }
            ps.executeBatch();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private List<OrderItem> getOrderItems(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, oi.variant_id AS order_variant_id, p.name, p.image_url, " +
                "v.variant_name, v.price AS v_price, v.sale_price AS v_sale_price " +
                "FROM order_items oi " +
                "JOIN products p ON oi.product_id = p.id " +
                "LEFT JOIN product_variants v ON oi.variant_id = v.id " +
                "WHERE oi.order_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                OrderItem item = new OrderItem();
                item.setId(rs.getInt("id"));
                item.setOrderId(orderId);
                item.setProductId(rs.getInt("product_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getDouble("price"));
                item.setOriginalPrice(rs.getDouble("original_price"));
                item.setDiscountAmount(rs.getDouble("discount_amount"));

                Integer variantId = (Integer) rs.getObject("order_variant_id");
                if (variantId != null && variantId > 0) {
                    model.product.ProductVariant variant = new model.product.ProductVariant();
                    variant.setId(variantId);
                    variant.setProductId(item.getProductId());
                    variant.setVariantName(rs.getString("variant_name"));
                    variant.setPrice(rs.getDouble("v_price"));
                    variant.setSalePrice(rs.getDouble("v_sale_price"));
                    item.setVariant(variant);
                } else {
                    item.setVariantId(null);
                }

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
                o.setCreatedAt(rs.getTimestamp("created_at"));
                try {
                    String statusStr = rs.getString("status");
                    o.setStatus(statusStr != null ? OrderStatus.valueOf(statusStr.toUpperCase()) : OrderStatus.PENDING);
                } catch (IllegalArgumentException e) {
                    o.setStatus(OrderStatus.PENDING);
                }

                try {
                    String payStatusStr = rs.getString("payment_status");
                    o.setPaymentStatus(payStatusStr != null ? PaymentStatus.valueOf(payStatusStr.toUpperCase()) : PaymentStatus.PENDING);
                } catch (IllegalArgumentException e) {
                    o.setPaymentStatus(PaymentStatus.PENDING);
                }

                String fullName = rs.getString("full_name");
                if (fullName != null) {
                    String fullAddr = String.format("<strong>%s - %s</strong><br>%s, %s, %s",
                            fullName,
                            rs.getString("phone_number"),
                            rs.getString("street_address"),
                            rs.getString("ward"),
                            rs.getString("province"));
                    o.setNotes(fullAddr);
                } else {
                    o.setNotes("Địa chỉ không xác định");
                }

                int sId = rs.getInt("shipper_id");
                if (!rs.wasNull()) o.setShipperId(sId);
                o.setShippingProvider(rs.getString("shipping_provider"));
                o.setTrackingCode(rs.getString("tracking_code"));
                o.setCancelReason(rs.getString("cancel_reason"));

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
                "SELECT o.*, a.full_name, a.phone_number, u.email AS user_email FROM orders o " +
                        "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (");
            sql.append("o.order_number LIKE ? ");
            sql.append("OR CAST(o.id AS CHAR) LIKE ? ");
            sql.append("OR a.full_name LIKE ? ");
            sql.append("OR a.phone_number LIKE ? ");
            sql.append("OR u.email LIKE ? ");
            sql.append(") ");
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
                ps.setString(paramIndex++, kw);
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
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "WHERE 1=1 "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (");
            sql.append("o.order_number LIKE ? ");
            sql.append("OR CAST(o.id AS CHAR) LIKE ? ");
            sql.append("OR a.full_name LIKE ? ");
            sql.append("OR a.phone_number LIKE ? ");
            sql.append("OR u.email LIKE ? ");
            sql.append(") ");
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
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }

            if (status != null && !status.isEmpty()) {
                ps.setString(paramIndex++, status.toLowerCase());
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

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

        try {
            int sId = rs.getInt("shipper_id");
            if (!rs.wasNull()) o.setShipperId(sId);
            o.setShippingProvider(rs.getString("shipping_provider"));
            o.setTrackingCode(rs.getString("tracking_code"));
            o.setCancelReason(rs.getString("cancel_reason"));
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

    public boolean cancelOrder(int orderId, String cancelReason) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            Order order = getOrderById(orderId);
            if (order == null || order.getStatus() != OrderStatus.PENDING) {
                return false;
            }
            String sqlUpdateOrder = "UPDATE orders SET status = 'cancelled', cancel_reason = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdateOrder)) {
                ps.setString(1, cancelReason);
                ps.setInt(2, orderId);
                ps.executeUpdate();
            }
            for (OrderItem item : order.getItems()) {
                Integer variantId = item.getVariantId();
                if (variantId != null && variantId > 0) {
                    String sqlUpdateVariant = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE id = ?";
                    try (PreparedStatement psStock = conn.prepareStatement(sqlUpdateVariant)) {
                        psStock.setInt(1, item.getQuantity());
                        psStock.setInt(2, variantId);
                        psStock.executeUpdate();
                    }
                } else {
                    String sqlUpdateStock = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
                    try (PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock)) {
                        psStock.setInt(1, item.getQuantity());
                        psStock.setInt(2, item.getProductId());
                        psStock.executeUpdate();
                    }
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

    public boolean updatePaymentStatus(int orderId, model.enums.PaymentStatus status) {
        String sql = "UPDATE orders SET payment_status = ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name().toLowerCase());
            ps.setInt(2, orderId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Integer getOrderIdByOrderNumber(String orderNumber) {
        String sql = "SELECT id FROM orders WHERE order_number = ? LIMIT 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, orderNumber);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("id");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    // --- Các hàm mới thêm phục vụ Shipper ---

    public List<Order> getOrdersForShipper(Integer shipperId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.*, a.full_name, a.phone_number, a.street_address, a.ward, a.province " +
                "FROM orders o " +
                "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                "WHERE o.shipper_id = ? " +
                "ORDER BY o.created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, shipperId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Order o = mapRowToOrder(rs);

                try {
                    o.setCustomerName(rs.getString("full_name"));
                    o.setCustomerPhone(rs.getString("phone_number"));
                    String address = rs.getString("street_address") + ", " +
                            rs.getString("ward") + ", " +
                            rs.getString("province");
                    o.setShippingAddress(address);

                    o.setNotes(rs.getString("notes"));
                } catch (Exception ignored) {}

                o.setItems(getOrderItems(o.getId()));
                list.add(o);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateOrderCancelReason(int orderId, OrderStatus status, String cancelReason) {
        String sql = "UPDATE orders SET status = ?, cancel_reason = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name().toLowerCase());
            ps.setString(2, cancelReason);
            ps.setInt(3, orderId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public boolean shipperCompleteOrder(int orderId, int shipperId) {
        String sql = "UPDATE orders " +
                "SET status = 'completed', " +
                "    payment_status = CASE WHEN payment_status = 'pending' THEN 'paid' ELSE payment_status END " +
                "WHERE id = ? AND shipper_id = ? AND status = 'shipping'";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, shipperId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean shipperFailOrder(int orderId, int shipperId, String reason) {
        Connection conn = null;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            String sql = "UPDATE orders SET status = 'delivery_failed', cancel_reason = ? WHERE id = ? AND shipper_id = ? AND status = 'shipping'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, reason);
                ps.setInt(2, orderId);
                ps.setInt(3, shipperId);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }
            Order order = getOrderById(orderId);
            if (order != null && order.getItems() != null) {
                for (OrderItem item : order.getItems()) {
                    Integer variantId = item.getVariantId();
                    if (variantId != null && variantId > 0) {
                        String sqlUpdateVariant = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE id = ?";
                        try (PreparedStatement psStock = conn.prepareStatement(sqlUpdateVariant)) {
                            psStock.setInt(1, item.getQuantity());
                            psStock.setInt(2, variantId);
                            psStock.executeUpdate();
                        }
                    } else {
                        String sqlUpdateStock = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
                        try (PreparedStatement psStock = conn.prepareStatement(sqlUpdateStock)) {
                            psStock.setInt(1, item.getQuantity());
                            psStock.setInt(2, item.getProductId());
                            psStock.executeUpdate();
                        }
                    }
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
    public boolean updateShippingInfo(int orderId, int shipperId, String status, String provider, String trackingCode) {
        String sql = "UPDATE orders SET status = ?, shipping_provider = ?, tracking_code = ? WHERE id = ? AND shipper_id = ? AND status = 'pending'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setString(2, provider);
            ps.setString(3, trackingCode);
            ps.setInt(4, orderId);
            ps.setInt(5, shipperId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    public boolean assignShipper(int orderId, int shipperId) {
        String sql = "UPDATE orders SET shipper_id = ? WHERE id = ? AND status = 'pending'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}