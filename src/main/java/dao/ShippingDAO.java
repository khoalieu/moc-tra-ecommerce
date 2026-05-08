package dao;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ShippingDAO {
    private final DataSource ds;

    public ShippingDAO(DataSource ds) {
        this.ds = ds;
    }

    public double getFeeByProvince(String provinceName) {
        String sql = "SELECT fee FROM shipping_configs WHERE ? LIKE CONCAT('%', province_name, '%')";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, provinceName.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("fee");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 30000;
    }
}