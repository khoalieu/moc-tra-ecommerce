package controller.admin;

import dao.DAOFactory;
import dao.ProductDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "AdminQuickDiscountServlet", urlPatterns = {"/admin/product/quick-discount"})
public class AdminQuickDiscountServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String type = request.getParameter("type");
        String valueStr = request.getParameter("value");
        String idsStr = request.getParameter("productIds");

        if (idsStr == null || idsStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            String[] ids = idsStr.split(",");
            ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();

            if ("clear".equals(action)) {
                productDAO.clearProductDiscounts(ids);
                DAOFactory.getInstance().getPromotionDAO().syncPromotionPrices();
                response.setStatus(HttpServletResponse.SC_OK);
                return;
            }

            if (type == null || valueStr == null || valueStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            double value = Double.parseDouble(valueStr);

            if (value < 0 || ("percent".equals(type) && value > 100)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
            productDAO.updateProductDiscounts(type, value, ids);
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}