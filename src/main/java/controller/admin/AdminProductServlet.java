package controller.admin;

import dao.DAOFactory;
import dao.ProductDAO;
import model.product.Product;
import model.enums.ProductStatus;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import dao.CategoryDAO;
import model.product.Category;
import java.util.Collection;
import java.util.List;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/product/add", "/admin/product/delete"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class AdminProductServlet extends HttpServlet {

    private ProductDAO productDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        productDAO = DAOFactory.getInstance().getProductDAO();
        categoryDAO = DAOFactory.getInstance().getCategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        loadCategoriesToRequest(request);
        request.getRequestDispatcher("/admin/admin-product-add.jsp").forward(request, response);
    }

    private void loadCategoriesToRequest(HttpServletRequest request) {
        List<Category> listCategories = categoryDAO.getAllCategories();
        List<Category> parentCategories = new ArrayList<>();
        Map<Integer, List<Category>> childrenMap = new HashMap<>();
        for (Category c : listCategories) {
            if (c.getParentId() == null || c.getParentId() == 0) {
                parentCategories.add(c);
            } else {
                childrenMap.computeIfAbsent(c.getParentId(), k -> new ArrayList<>()).add(c);
            }
        }
        request.setAttribute("parentCategories", parentCategories);
        request.setAttribute("childrenMap", childrenMap);
        request.setAttribute("categories", listCategories);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String servletPath = request.getServletPath();
        if ("/admin/product/delete".equals(servletPath)) {
            deleteProduct(request, response);
            return;
        }
        try {
            String relativeDir = "assets" + File.separator + "images";
            String uploadPath = getServletContext().getRealPath("") + File.separator + relativeDir;

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String name = request.getParameter("name");
            String slug = request.getParameter("slug");

            if (slug == null || slug.trim().isEmpty()) {
                String rawSlug = name.toLowerCase().replaceAll("[^a-z0-9]+", "-").replaceAll("^-|-$", "");
                slug = rawSlug + "-" + System.currentTimeMillis();
            }
            String shortDesc = request.getParameter("short_description");
            String description = request.getParameter("description");
            String ingredients = request.getParameter("ingredients");
            String usage = request.getParameter("usage_instructions");
            String sku = request.getParameter("sku");

            double price = parseDoubleSafe(request.getParameter("price"));
            double salePrice = parseDoubleSafe(request.getParameter("sale_price"));
            int stock = parseIntSafe(request.getParameter("stock_quantity"));
            int categoryId = parseIntSafe(request.getParameter("category_id"));
            String statusStr = request.getParameter("status");
            boolean isBestseller = "1".equals(request.getParameter("is_bestseller"));

            Part mainImagePart = request.getPart("image_url");
            String mainImageUrl = "";

            if (mainImagePart != null && mainImagePart.getSize() > 0) {
                String fileName = Paths.get(mainImagePart.getSubmittedFileName()).getFileName().toString();
                fileName = fileName.replaceAll("\\s+", "_");
                String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                mainImagePart.write(uploadPath + File.separator + uniqueFileName);
                mainImageUrl = "assets/images/" + uniqueFileName;
            }

            Product product = new Product();
            product.setName(name);
            product.setSlug(slug);
            product.setShortDescription(shortDesc);
            product.setDescription(description);
            product.setPrice(price);
            product.setSalePrice(salePrice);
            product.setStockQuantity(stock);
            product.setSku(sku);
            product.setCategoryId(categoryId);

            try {
                product.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
            } catch (Exception e) {
                product.setStatus(ProductStatus.ACTIVE);
            }

            product.setBestseller(isBestseller);
            product.setIngredients(ingredients);
            product.setUsageInstructions(usage);
            product.setImageUrl(mainImageUrl);
            product.setCreatedAt(LocalDateTime.now());

            int newProductId = productDAO.insertProduct(product);

            if (newProductId > 0) {
                Collection<Part> parts = request.getParts();
                int sortOrder = 1;

                for (Part part : parts) {
                    if ("gallery[]".equals(part.getName()) && part.getSize() > 0) {
                        String fileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
                        if (fileName != null && !fileName.isEmpty()) {
                            fileName = fileName.replaceAll("\\s+", "_");
                            String uniqueGalleryName = System.currentTimeMillis() + "_g_" + fileName;

                            part.write(uploadPath + File.separator + uniqueGalleryName);
                            String galleryUrl = "assets/images/" + uniqueGalleryName;
                            String altText = name + " - " + sortOrder;

                            productDAO.insertProductImage(newProductId, galleryUrl, altText, sortOrder);
                            sortOrder++;
                        }
                    }
                }

                response.sendRedirect(request.getContextPath() + "/admin/product/add?msg=success");
            } else {
                loadCategoriesToRequest(request);
                request.setAttribute("error", "Thêm sản phẩm thất bại");
                request.getRequestDispatcher("/admin/admin-product-add.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            loadCategoriesToRequest(request);
            request.setAttribute("error", "Lỗi: " + e.getMessage());
            request.getRequestDispatcher("/admin/admin-product-add.jsp").forward(request, response);
        }
    }
    private double parseDoubleSafe(String value) {
        if (value == null || value.trim().isEmpty()) return 0.0;
        try { return Double.parseDouble(value); } catch (NumberFormatException e) { return 0.0; }
    }

    private int parseIntSafe(String value) {
        if (value == null || value.trim().isEmpty()) return 0;
        try { return Integer.parseInt(value); } catch (NumberFormatException e) { return 0; }
    }
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                productDAO.softDeleteProduct(id);
                response.setStatus(200);
            } catch (Exception e) {
                e.printStackTrace();
                response.setStatus(500);
            }
        } else {
            response.setStatus(400);
        }
    }
}