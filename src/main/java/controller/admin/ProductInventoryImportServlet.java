package controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.product.ProductImportResult;
import model.user.User;

import java.io.IOException;
import java.io.InputStream;

@WebServlet("/admin/products/inventory-import")
@MultipartConfig
public class ProductInventoryImportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Part filePart = request.getPart("inventoryFile");

        if (filePart == null || filePart.getSize() == 0) {
            request.getSession().setAttribute("importMessage", "Vui long chon file Excel de import ton kho.");
            response.sendRedirect(request.getContextPath() + "/admin/inventory");
            return;
        }

        try (InputStream inputStream = filePart.getInputStream()) {
            ProductInventoryImportService importService = new ProductInventoryImportService();
            User admin = (User) request.getSession().getAttribute("user");
            Integer adminId = admin != null ? admin.getId() : null;
            ProductImportResult result = importService.importInventory(inputStream, adminId);
            request.getSession().setAttribute("importMessage", result.getInventorySummary());
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("importMessage", "Import ton kho that bai: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/inventory");
    }
}
