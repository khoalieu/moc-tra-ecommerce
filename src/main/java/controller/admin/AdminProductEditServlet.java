package controller.admin;

import dao.CategoryDAO;
import dao.ProductDAO;
import model.product.Category;
import model.product.Product;
import model.enums.ProductStatus;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;

@WebServlet(name = "AdminProductEditServlet", urlPatterns = {"/admin/product/edit"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminProductEditServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            Product product = productDAO.getProductById(id);
            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/admin/products");
                return;
            }

            List<Category> categories = categoryDAO.getAllCategories();

            request.setAttribute("product", product);
            request.setAttribute("categories", categories);

            request.getRequestDispatcher("/admin/admin-product-edit.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        try {

            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String slug = request.getParameter("slug");
            String shortDesc = request.getParameter("short_description");
            String description = request.getParameter("description");
            String ingredients = request.getParameter("ingredients");
            String usage = request.getParameter("usage_instructions");
            String sku = request.getParameter("sku");

            double price = Double.parseDouble(request.getParameter("price"));

            String salePriceStr = request.getParameter("sale_price");
            double salePrice = (salePriceStr != null && !salePriceStr.isEmpty()) ? Double.parseDouble(salePriceStr) : 0;

            int stock = Integer.parseInt(request.getParameter("stock_quantity"));
            int categoryId = Integer.parseInt(request.getParameter("category_id"));
            String statusStr = request.getParameter("status");
            boolean isBestseller = request.getParameter("is_bestseller") != null;

            String currentImage = request.getParameter("current_image");
            String newImageUrl = currentImage;

            Part filePart = request.getPart("image_url");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                fileName = System.currentTimeMillis() + "_" + fileName.replaceAll("\\s+", "_");

                String uploadDir = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images";
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                filePart.write(uploadDir + File.separator + fileName);
                newImageUrl = "assets/images/" + fileName;
            }
            Product product = new Product();
            product.setId(id);
            product.setName(name);
            product.setSlug(slug);
            product.setShortDescription(shortDesc);
            product.setDescription(description);
            product.setIngredients(ingredients);
            product.setUsageInstructions(usage);
            product.setSku(sku);
            product.setPrice(price);
            product.setSalePrice(salePrice);
            product.setStockQuantity(stock);
            product.setCategoryId(categoryId);
            product.setBestseller(isBestseller);
            product.setImageUrl(newImageUrl);

            try {
                product.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
            } catch (Exception e) { product.setStatus(ProductStatus.ACTIVE); }

            boolean success = productDAO.updateProduct(product);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin/products?msg=update_success");
            } else {
                request.setAttribute("error", "Cập nhật thất bại!");
                request.setAttribute("product", product);
                doGet(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/products?msg=error");
        }
    }
}