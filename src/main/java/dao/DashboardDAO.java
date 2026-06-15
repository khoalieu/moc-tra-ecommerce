package dao;

import model.product.TopProductDTO;
import model.user.MonthlyUserDTO;
import model.RevenueDTO;

import javax.sql.DataSource;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    private final DataSource ds;

    public DashboardDAO(DataSource ds) {
        this.ds = ds;
    }

    public List<TopProductDTO> getTop5BestSellingProducts() {
        return getTopProducts(5, "best", "all");
    }

    public List<TopProductDTO> getTopProducts(int limit, String mode, String period) {
        List<TopProductDTO> list = new ArrayList<>();

        int safeLimit = Math.max(1, Math.min(limit, 50));
        String orderDirection = "least".equals(mode) ? "ASC" : "DESC";
        DateRange range = resolveDateRange(period);

        StringBuilder sql = new StringBuilder(
                "SELECT p.id AS product_id, p.name AS product_name, " +
                        "COALESCE(SUM(CASE WHEN o.id IS NOT NULL THEN oi.quantity ELSE 0 END), 0) AS total_sold " +
                        "FROM products p " +
                        "LEFT JOIN order_items oi ON oi.product_id = p.id " +
                        "LEFT JOIN orders o ON oi.order_id = o.id AND o.status = 'COMPLETED' "
        );
        if (range != null) {
            sql.append("AND o.created_at >= ? AND o.created_at < ? ");
        }
        sql.append("GROUP BY p.id, p.name ");
        if (!"least".equals(mode)) {
            sql.append("HAVING total_sold > 0 ");
        }
        sql.append("ORDER BY total_sold ").append(orderDirection).append(", p.name ASC LIMIT ?");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int index = 1;
            if (range != null) {
                ps.setTimestamp(index++, Timestamp.valueOf(range.start.atStartOfDay()));
                ps.setTimestamp(index++, Timestamp.valueOf(range.endExclusive.atStartOfDay()));
            }
            ps.setInt(index, safeLimit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    TopProductDTO dto = new TopProductDTO();
                    dto.setProductId(rs.getInt("product_id"));
                    dto.setProductName(rs.getString("product_name"));
                    dto.setTotalSold(rs.getInt("total_sold"));
                    list.add(dto);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<MonthlyUserDTO> getNewUsersByMonth() {
        List<MonthlyUserDTO> list = new ArrayList<>();

        String sql = " SELECT DATE_FORMAT(created_at, '%Y-%m') AS month, COUNT(*) AS total_users FROM users WHERE role_id = 2 GROUP BY DATE_FORMAT(created_at, '%Y-%m') ORDER BY month ASC ";

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
        return getRevenueByPeriod("month");
    }

    public List<RevenueDTO> getRevenueByPeriod(String period) {
        List<RevenueDTO> list = new ArrayList<>();

        String safePeriod = normalizeRevenuePeriod(period);
        String labelExpr;
        String startSql;

        if ("day".equals(safePeriod)) {
            labelExpr = "DATE_FORMAT(created_at, '%d/%m')";
            startSql = "DATE_SUB(CURDATE(), INTERVAL 3 DAY)";
        } else if ("week".equals(safePeriod)) {
            labelExpr = "CONCAT(YEAR(created_at), '-W', LPAD(WEEK(created_at, 1), 2, '0'))";
            startSql = "DATE_SUB(CURDATE(), INTERVAL 7 WEEK)";
        } else if ("six-months".equals(safePeriod)) {
            labelExpr = "DATE_FORMAT(created_at, '%Y-%m')";
            startSql = "DATE_SUB(CURDATE(), INTERVAL 5 MONTH)";
        } else if ("year".equals(safePeriod)) {
            labelExpr = "DATE_FORMAT(created_at, '%Y-%m')";
            startSql = "DATE_SUB(CURDATE(), INTERVAL 11 MONTH)";
        } else {
            labelExpr = "DATE_FORMAT(created_at, '%Y-%m')";
            startSql = null;
        }

        StringBuilder sql = new StringBuilder("SELECT " + labelExpr + " AS label, SUM(total_amount) AS revenue " +
                "FROM orders WHERE status = 'COMPLETED' ");
        if (startSql != null) {
            sql.append("AND created_at >= ").append(startSql).append(" ");
        }
        sql.append("GROUP BY label ORDER BY MIN(created_at) ASC");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString());
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

    private String normalizeRevenuePeriod(String period) {
        if ("day".equals(period) || "week".equals(period) || "six-months".equals(period) || "year".equals(period)) {
            return period;
        }
        return "month";
    }

    private DateRange resolveDateRange(String period) {
        if (period == null || period.isBlank() || "all".equals(period)) {
            return null;
        }

        LocalDate today = LocalDate.now();
        LocalDate start;
        if ("day".equals(period)) {
            start = today;
        } else if ("week".equals(period)) {
            start = today.minusDays(6);
        } else if ("month".equals(period)) {
            start = today.minusMonths(1).plusDays(1);
        } else if ("six-months".equals(period)) {
            start = today.minusMonths(6).plusDays(1);
        } else if ("year".equals(period)) {
            start = today.minusYears(1).plusDays(1);
        } else {
            return null;
        }
        return new DateRange(start, today.plusDays(1));
    }

    private static class DateRange {
        private final LocalDate start;
        private final LocalDate endExclusive;

        private DateRange(LocalDate start, LocalDate endExclusive) {
            this.start = start;
            this.endExclusive = endExclusive;
        }
    }
}
