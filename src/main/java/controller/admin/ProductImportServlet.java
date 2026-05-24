package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import model.product.ProductImportResult;
import model.user.User;
import service.SystemLogService;

import java.io.IOException;
import java.io.InputStream;

@WebServlet("/admin/products/import")
@MultipartConfig
public class ProductImportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        Part filePart = request.getPart("excelFile");

        if (filePart == null || filePart.getSize() == 0) {
            request.getSession().setAttribute("importMessage", "Vui lòng chọn file Excel để import.");
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        try (InputStream inputStream = filePart.getInputStream()) {
            ProductImportService importService = new ProductImportService();
            User admin =  (User) request.getSession().getAttribute("user");
            Integer adminId = null;

            if (admin != null) {
                adminId = admin.getId();
            }
            ProductImportResult result = importService.importProducts(inputStream, adminId);
            request.getSession().setAttribute("importMessage", result.getSummary());
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("importMessage", "Import thất bại: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
