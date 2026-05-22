package dao;

import model.product.TopProductDTO;
import model.user.MonthlyUserDTO;
import model.RevenueDTO;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    private final DataSource ds;

    public DashboardDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<TopProductDTO> getTop5BestSellingProducts() {
        List<TopProductDTO> list = new ArrayList<>();

        String sql = " SELECT p.name AS product_name, SUM(oi.quantity) AS total_sold FROM order_items oi JOIN products p ON oi.product_id = p.id JOIN orders o ON oi.order_id = o.id WHERE o.status = 'COMPLETED' GROUP BY p.id, p.name ORDER BY total_sold DESC LIMIT 5 ";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                TopProductDTO dto = new TopProductDTO();
                dto.setProductName(rs.getString("product_name"));
                dto.setTotalSold(rs.getInt("total_sold"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MonthlyUserDTO> getNewUsersByMonth() {
        List<MonthlyUserDTO> list = new ArrayList<>();

        String sql = " SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, COUNT(*) AS total_users FROM users WHERE role = 'customer' GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY month ASC ";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                MonthlyUserDTO dto = new MonthlyUserDTO();
                dto.setMonth(rs.getString("month"));
                dto.setTotalUsers(rs.getInt("total_users"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<RevenueDTO> getRevenueByMonth() {
        List<RevenueDTO> list = new ArrayList<>();

        String sql = " SELECT DATE_FORMAT(created_at, '%Y-%m') AS label, SUM(total_amount) AS revenue FROM orders WHERE status = 'COMPLETED' GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY label ASC ";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                RevenueDTO dto = new RevenueDTO();
                dto.setLabel(rs.getString("label"));
                dto.setRevenue(rs.getDouble("revenue"));
                list.add(dto);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}