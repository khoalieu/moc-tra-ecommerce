package dao;

import model.cart.CartItem;
import model.order.Order;
import model.order.OrderItem;
import model.product.Product;
import model.enums.OrderStatus;
import model.enums.PaymentStatus;
import model.user.User;
import service.EcommerceEmailService;
import service.NotificationService;

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

                o.setSubtotalAmount(rs.getDouble("subtotal_amount"));

                int couponId = rs.getInt("coupon_id");
                if (!rs.wasNull()) {
                    o.setCouponId(couponId);
                }

                o.setCouponCode(rs.getString("coupon_code"));
                o.setCouponDiscountAmount(rs.getDouble("coupon_discount_amount"));
                o.setVipDiscountAmount(rs.getDouble("vip_discount_amount"));

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
                o.setCancelReason(rs.getString("cancel_reason"));

                list.add(o);

            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int createOrder(Order order) {
        String sql = "INSERT INTO orders " +
                "(user_id, shipping_address_id, order_number, status, subtotal_amount, total_amount, shipping_fee, " +
                "coupon_id, coupon_code, coupon_discount_amount, vip_discount_amount, " +
                "payment_method, payment_status, notes, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

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
            ps.setDouble(5, order.getSubtotalAmount());
            ps.setDouble(6, order.getTotalAmount());
            ps.setDouble(7, order.getShippingFee());

            if (order.getCouponId() != null) {
                ps.setInt(8, order.getCouponId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }

            ps.setString(9, order.getCouponCode());
            ps.setDouble(10, order.getCouponDiscountAmount());
            ps.setDouble(11, order.getVipDiscountAmount());

            ps.setString(12, order.getPaymentMethod());
            ps.setString(13, PaymentStatus.PENDING.name().toLowerCase());
            ps.setString(14, order.getNotes());

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

    public int createOrder(Connection conn, Order order) throws SQLException {
        String sql = "INSERT INTO orders " +
                "(user_id, shipping_address_id, order_number, status, subtotal_amount, total_amount, shipping_fee, " +
                "coupon_id, coupon_code, coupon_discount_amount, vip_discount_amount, " +
                "payment_method, payment_status, notes, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, order.getUserId());

            if (order.getShippingAddressId() != null) {
                ps.setInt(2, order.getShippingAddressId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }

            ps.setString(3, order.getOrderNumber());
            ps.setString(4, OrderStatus.PENDING.name().toLowerCase());
            ps.setDouble(5, order.getSubtotalAmount());
            ps.setDouble(6, order.getTotalAmount());
            ps.setDouble(7, order.getShippingFee());

            if (order.getCouponId() != null) {
                ps.setInt(8, order.getCouponId());
            } else {
                ps.setNull(8, Types.INTEGER);
            }

            ps.setString(9, order.getCouponCode());
            ps.setDouble(10, order.getCouponDiscountAmount());
            ps.setDouble(11, order.getVipDiscountAmount());
            ps.setString(12, order.getPaymentMethod());
            ps.setString(13, PaymentStatus.PENDING.name().toLowerCase());
            ps.setString(14, order.getNotes());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return 0;
    }

    public void addOrderItems(Connection conn, int orderId, List<CartItem> items) throws SQLException {
        String sql = "INSERT INTO order_items " +
                "(order_id, product_id, variant_id, quantity, price, original_price, discount_amount) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
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
                ps.setDouble(5, item.getUnitPrice());
                ps.setDouble(6, item.getOriginalUnitPrice());
                ps.setDouble(7, item.getDiscountPerItem());
                ps.addBatch();
            }
            ps.executeBatch();
        }
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

    public List<OrderItem> getOrderItems(int orderId) {
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

                o.setSubtotalAmount(rs.getDouble("subtotal_amount"));

                int couponId = rs.getInt("coupon_id");
                if (!rs.wasNull()) {
                    o.setCouponId(couponId);
                }

                o.setCouponCode(rs.getString("coupon_code"));
                o.setCouponDiscountAmount(rs.getDouble("coupon_discount_amount"));
                o.setVipDiscountAmount(rs.getDouble("vip_discount_amount"));

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

//                int sId = rs.getInt("shipper_id");
//                if (!rs.wasNull()) o.setShipperId(sId);
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

    public List<Order> getAllOrders(int index, int size, String search, String status, String paymentStatus,
                                    String paymentMethod, String timeFilter, String dateFrom, String dateTo,
                                    String sortOrder, String quickFilter) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.*, a.full_name, a.phone_number, u.email AS user_email FROM orders o " +
                        "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "WHERE 1=1 "
        );

        appendAdminOrderFilters(sql, search, status, paymentStatus, paymentMethod, timeFilter, dateFrom, dateTo,
                quickFilter);

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

            paramIndex = bindAdminOrderFilters(ps, paramIndex, search, status, paymentStatus, paymentMethod,
                    timeFilter, dateFrom, dateTo);

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

    public int countAllOrders(String search, String status, String paymentStatus, String paymentMethod,
                              String timeFilter, String dateFrom, String dateTo, String quickFilter) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) " +
                        "FROM orders o " +
                        "LEFT JOIN user_addresses a ON o.shipping_address_id = a.id " +
                        "LEFT JOIN users u ON o.user_id = u.id " +
                        "WHERE 1=1 "
        );

        appendAdminOrderFilters(sql, search, status, paymentStatus, paymentMethod, timeFilter, dateFrom, dateTo,
                quickFilter);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            bindAdminOrderFilters(ps, paramIndex, search, status, paymentStatus, paymentMethod,
                    timeFilter, dateFrom, dateTo);
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
        Order oldOrder = getOrderById(orderId);
        String sql = "UPDATE orders SET status = ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status.name().toLowerCase());
            ps.setInt(2, orderId);

            boolean updated = ps.executeUpdate() > 0;
            if (updated && oldOrder != null && oldOrder.getStatus() != status) {
                new NotificationService().notifyOrderStatusChanged(oldOrder, status);
                sendOrderStatusEmail(oldOrder, status);
            }
            if (updated && oldOrder != null
                    && oldOrder.getStatus() == OrderStatus.SHIPPING
                    && status == OrderStatus.DELIVERY_FAILED) {
                oldOrder.setStatus(OrderStatus.DELIVERY_FAILED);
                NotificationService notificationService = new NotificationService();
                notificationService.notifyAdminDeliveryFailed(oldOrder);
                boolean refundCreated = new RefundDAO(ds)
                        .createPendingInfoRefundForFailedDelivery(oldOrder, "Đơn giao không thành công");
                if (refundCreated) {
                    notificationService.notifyRefundPendingInfo(oldOrder);
                }
            }
            return updated;
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
//            if (!rs.wasNull()) o.setShipperId(sId);
            o.setShippingProvider(rs.getString("shipping_provider"));
            o.setTrackingCode(rs.getString("tracking_code"));
            o.setCancelReason(rs.getString("cancel_reason"));
        } catch (Exception e) {
        }

        return o;
    }

    private void appendAdminOrderFilters(StringBuilder sql, String search, String status, String paymentStatus,
                                         String paymentMethod, String timeFilter, String dateFrom, String dateTo,
                                         String quickFilter) {
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (");
            sql.append("o.order_number LIKE ? ");
            sql.append("OR CAST(o.id AS CHAR) LIKE ? ");
            sql.append("OR a.full_name LIKE ? ");
            sql.append("OR a.phone_number LIKE ? ");
            sql.append("OR u.email LIKE ? ");
            sql.append("OR o.tracking_code LIKE ? ");
            sql.append(") ");
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND o.status = ? ");
        }
        if (paymentStatus != null && !paymentStatus.isEmpty()) {
            sql.append(" AND o.payment_status = ? ");
        }
        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            sql.append(" AND o.payment_method = ? ");
        }

        appendQuickFilter(sql, quickFilter);

        if ("today".equals(timeFilter)) {
            sql.append(" AND DATE(o.created_at) = CURRENT_DATE() ");
        } else if ("last_7_days".equals(timeFilter)) {
            sql.append(" AND o.created_at >= CURRENT_DATE() - INTERVAL 7 DAY ");
        } else if ("last_30_days".equals(timeFilter)) {
            sql.append(" AND o.created_at >= CURRENT_DATE() - INTERVAL 30 DAY ");
        } else if ("custom".equals(timeFilter)) {
            if (dateFrom != null && !dateFrom.isEmpty()) {
                sql.append(" AND DATE(o.created_at) >= ? ");
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                sql.append(" AND DATE(o.created_at) <= ? ");
            }
        }
    }

    private int bindAdminOrderFilters(PreparedStatement ps, int paramIndex, String search, String status,
                                      String paymentStatus, String paymentMethod, String timeFilter,
                                      String dateFrom, String dateTo) throws SQLException {
        if (search != null && !search.trim().isEmpty()) {
            String kw = "%" + search.trim() + "%";

            ps.setString(paramIndex++, kw);
            ps.setString(paramIndex++, kw);
            ps.setString(paramIndex++, kw);
            ps.setString(paramIndex++, kw);
            ps.setString(paramIndex++, kw);
            ps.setString(paramIndex++, kw);
        }

        if (status != null && !status.isEmpty()) {
            ps.setString(paramIndex++, status.toLowerCase());
        }
        if (paymentStatus != null && !paymentStatus.isEmpty()) {
            ps.setString(paramIndex++, paymentStatus.toLowerCase());
        }
        if (paymentMethod != null && !paymentMethod.isEmpty()) {
            ps.setString(paramIndex++, paymentMethod.toLowerCase());
        }
        if ("custom".equals(timeFilter)) {
            if (dateFrom != null && !dateFrom.isEmpty()) {
                ps.setString(paramIndex++, dateFrom);
            }
            if (dateTo != null && !dateTo.isEmpty()) {
                ps.setString(paramIndex++, dateTo);
            }
        }
        return paramIndex;
    }

    private void appendQuickFilter(StringBuilder sql, String quickFilter) {
        if ("need_process".equals(quickFilter)) {
            sql.append(" AND o.status = 'pending' ");
        } else if ("paid_waiting_process".equals(quickFilter)) {
            sql.append(" AND o.status = 'pending' ");
            sql.append(" AND o.payment_method <> 'cod' ");
            sql.append(" AND o.payment_status = 'paid' ");
        } else if ("cancelled_waiting_refund".equals(quickFilter)) {
            sql.append(" AND o.status = 'cancelled' ");
            sql.append(" AND o.payment_method <> 'cod' ");
            sql.append(" AND o.payment_status = 'paid' ");
            sql.append(" AND NOT EXISTS (");
            sql.append("SELECT 1 FROM refund_requests rr ");
            sql.append("WHERE rr.order_id = o.id AND rr.status IN ('refunded', 'rejected')");
            sql.append(") ");
        } else if ("shipping".equals(quickFilter)) {
            sql.append(" AND o.status = 'shipping' ");
        } else if ("delivery_failed".equals(quickFilter)) {
            sql.append(" AND o.status = 'delivery_failed' ");
        }
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
            new NotificationService().notifyOrderStatusChanged(order, OrderStatus.CANCELLED);
            sendOrderStatusEmail(order, OrderStatus.CANCELLED);
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
        Order order = getOrderById(orderId);
        String sql = "UPDATE orders " +
                "SET status = 'completed', " +
                "    payment_status = CASE WHEN payment_status = 'pending' THEN 'paid' ELSE payment_status END " +
                "WHERE id = ? AND shipper_id = ? AND status = 'shipping'";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderId);
            ps.setInt(2, shipperId);

            boolean updated = ps.executeUpdate() > 0;
            if (updated && order != null) {
                new NotificationService().notifyOrderStatusChanged(order, OrderStatus.COMPLETED);
                sendOrderStatusEmail(order, OrderStatus.COMPLETED);
            }
            return updated;
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
            if (order != null) {
                NotificationService notificationService = new NotificationService();
                notificationService.notifyOrderStatusChanged(order, OrderStatus.DELIVERY_FAILED);
                notificationService.notifyAdminDeliveryFailed(order);
                sendOrderStatusEmail(order, OrderStatus.DELIVERY_FAILED);
                String refundReason = "Đơn giao không thành công";
                if (reason != null && !reason.trim().isEmpty()) {
                    refundReason += ": " + reason.trim();
                }
                boolean refundCreated = new RefundDAO(ds).createPendingInfoRefundForFailedDelivery(order,
                        refundReason);
                if (refundCreated) {
                    notificationService.notifyRefundPendingInfo(order);
                }
            }
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
            if (rowsAffected > 0 && "shipping".equalsIgnoreCase(status)) {
                Order order = getOrderById(orderId);
                new NotificationService().notifyOrderStatusChanged(order, OrderStatus.SHIPPING);
            }
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
    public boolean removeOrderItem(int orderItemId) {
        String sql = "DELETE FROM order_items WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateOrderTotal(int orderId) {
        String sql = "UPDATE orders " + "SET total_amount = (SELECT COALESCE(SUM(quantity * price),0) FROM order_items  WHERE order_id = ?) + shipping_fee WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean addProductToOrder(int orderId, int productId, int quantity) {
        ProductDAO productDAO = new ProductDAO(ds);
        Product product = productDAO.getProductById(productId);
        if (product == null) return false;
        String sql = "INSERT INTO order_items (order_id, product_id, quantity, price, original_price, discount_amount) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            double finalPrice = product.getSalePrice() > 0 ? product.getSalePrice() : product.getPrice();
            ps.setInt(1, orderId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);
            ps.setDouble(4, finalPrice);
            ps.setDouble(5, product.getPrice());
            ps.setDouble(6, product.getPrice() - finalPrice);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean canCustomerEditOrder(int orderId, int userId) {

        String sql = "SELECT * FROM orders WHERE id = ? AND user_id = ? AND status = 'pending'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public OrderItem getOrderItemById(int orderItemId) {

        String sql = "SELECT oi.*, p.name, p.image_url FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderItemId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                OrderItem item = new OrderItem();
                item.setId(rs.getInt("id"));
                item.setOrderId(rs.getInt("order_id"));
                item.setProductId(rs.getInt("product_id"));
                item.setQuantity(rs.getInt("quantity"));
                item.setPrice(rs.getDouble("price"));
                Product product = new Product();
                product.setId(rs.getInt("product_id"));
                product.setName(rs.getString("name"));
                product.setImageUrl(rs.getString("image_url"));
                item.setProduct(product);
                return item;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
    public boolean decreaseOrderItemQuantity(int orderItemId) {
        String sql = "UPDATE order_items SET quantity = quantity - 1 WHERE id = ? AND quantity > 1";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderItemId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }
    public boolean increaseOrderItemQuantity(int orderItemId) {
        String sql = "UPDATE order_items SET quantity = quantity + 1 WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean canAdminEditOrder(int orderId) {
        String sql = "SELECT 1 FROM orders WHERE id = ? AND (status = 'PENDING' OR status = 'COMPLETED')";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật thông tin vận đơn GHN sau khi tạo thành công trên GHN.
     * Chuyển trạng thái đơn sang SHIPPING và lưu mã vận đơn GHN.
     */
    public boolean updateGHNShippingInfo(int orderId, String ghnOrderCode) {
        String sql = "UPDATE orders SET status = 'shipping', shipping_provider = 'GHN', tracking_code = ? WHERE id = ? AND status = 'pending'";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ghnOrderCode);
            ps.setInt(2, orderId);
            boolean updated = ps.executeUpdate() > 0;
            if (updated) {
                Order order = getOrderById(orderId);
                new NotificationService().notifyOrderStatusChanged(order, OrderStatus.SHIPPING);
            }
            return updated;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private void sendOrderStatusEmail(Order order, OrderStatus status) {
        if (order == null || status == null) {
            return;
        }

        User user = new UserDAO(ds).getById(order.getUserId());
        EcommerceEmailService emailService = new EcommerceEmailService();

        if (status == OrderStatus.CANCELLED) {
            emailService.sendOrderCancelledToUser(user, order);
        } else if (status == OrderStatus.COMPLETED) {
            emailService.sendOrderCompletedToUser(user, order);
        } else if (status == OrderStatus.DELIVERY_FAILED) {
            emailService.sendDeliveryFailedToUser(user, order);
            emailService.sendDeliveryFailedToAdmin(order);
        }
    }

}
