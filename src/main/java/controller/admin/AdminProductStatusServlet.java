package controller.admin;

import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "AdminProductStatusServlet", urlPatterns = {"/admin/product/status"})
public class AdminProductStatusServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idsParam = request.getParameter("ids");
        String status = request.getParameter("status");

        if (idsParam != null && !idsParam.isEmpty() && status != null) {
            try {
                List<Integer> idList = new ArrayList<>();
                String[] parts = idsParam.split(",");
                for (String part : parts) {
                    idList.add(Integer.parseInt(part.trim()));
                }

                boolean success = productDAO.updateProductStatus(idList, status);
                if (success) {
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}