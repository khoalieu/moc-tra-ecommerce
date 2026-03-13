package controller.admin;

import db.DBConnect;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet(name = "AdminQuickDiscountServlet", urlPatterns = {"/admin/product/quick-discount"})
public class AdminQuickDiscountServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String type = request.getParameter("type");
        String valueStr = request.getParameter("value");
        String idsStr = request.getParameter("productIds");

        if (type != null && valueStr != null && idsStr != null) {
            try {
                double value = Double.parseDouble(valueStr);
                String[] ids = idsStr.split(",");

                String sql = "";
                if ("percent".equals(type)) {
                    sql = "UPDATE products SET sale_price = price * (100 - ?) / 100 WHERE id = ?";
                } else {
                    sql = "UPDATE products SET sale_price = GREATEST(0, price - ?) WHERE id = ?";
                }

                try (Connection conn = DBConnect.getConnection();
                     PreparedStatement ps = conn.prepareStatement(sql)) {

                    for (String id : ids) {
                        ps.setDouble(1, value);
                        ps.setInt(2, Integer.parseInt(id));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                response.setStatus(200);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(500);
            }
        }
    }
}