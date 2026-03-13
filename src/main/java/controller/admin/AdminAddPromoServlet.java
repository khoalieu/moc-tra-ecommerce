package controller.admin;

import dao.PromotionDAO;
import db.DBConnect;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet(name = "AdminAddPromoServlet", urlPatterns = {"/admin/promotion/add-products"})
public class AdminAddPromoServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String promoIdStr = request.getParameter("promoId");
        String action = request.getParameter("action");
        String productIdsStr = request.getParameter("productIds");

        PromotionDAO dao = new PromotionDAO();

        if ("remove".equals(action) && productIdsStr != null) {
            try {
                String[] ids = productIdsStr.split(",");
                dao.removeProductsFromPromotion(ids);
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
            return;
        }

        if (promoIdStr != null && productIdsStr != null) {
            try {
                int promoId = Integer.parseInt(promoIdStr);
                String[] ids = productIdsStr.split(",");
                dao.addProductsToPromotion(promoId, ids);
                response.setStatus(HttpServletResponse.SC_OK);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}