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
        String type = request.getParameter("type");
        String valueStr = request.getParameter("value");
        String idsStr = request.getParameter("productIds");

        if (type != null && valueStr != null && idsStr != null) {
            try {
                double value = Double.parseDouble(valueStr);
                String[] ids = idsStr.split(",");
                ProductDAO p = DAOFactory.getInstance().getProductDAO();
                p.updateProductDiscounts(type, value, ids);
                response.setStatus(200);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(500);
            }
        }
    }
}