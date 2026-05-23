package controller.admin;

import dao.CategoryDAO;
import dao.DAOFactory;
import dao.ProductDAO;
import service.SystemLogService;
import model.enums.ProductStatus;
import model.product.Product;
import model.product.ProductImportResult;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.InputStream;

public class ProductImportService {

    private final ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();
    private final CategoryDAO categoryDAO = DAOFactory.getInstance().getCategoryDAO();
    private final SystemLogService logService = new SystemLogService();
    public ProductImportResult importProducts(InputStream inputStream, Integer adminId) {
        ProductImportResult result = new ProductImportResult();
        try {
            Workbook workbook = new XSSFWorkbook(inputStream);
            Sheet sheet = workbook.getSheetAt(0);
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) {
                    continue;
                }
                try {
                    String productName = getCellString(row.getCell(0));
                    double price = row.getCell(1).getNumericCellValue();
                    double salePrice = row.getCell(2).getNumericCellValue();
                    int stock = (int) row.getCell(3).getNumericCellValue();
                    String categoryName = getCellString(row.getCell(4));
                    String status = getCellString(row.getCell(5));
                    String bestseller = getCellString(row.getCell(6));
                    String shortDescription = getCellString(row.getCell(7));
                    String description = getCellString(row.getCell(8));
                    String imageFile = getCellString(row.getCell(9));

                    if (categoryName == null || categoryName.isBlank()) {
                        result.addError("Dòng " + (i + 1) + ": Danh mục trống");
                        continue;
                    }

                    if (productName == null || productName.isBlank() || price <= 0 || stock < 0 || status == null || status.isBlank()) {
                        result.addError("Dòng " + (i + 1) + ": Thiếu hoặc sai dữ liệu bắt buộc");
                        continue;
                    }
                    Integer categoryId = categoryDAO.getCategoryIdByName(categoryName);
                    if (categoryId == null) {
                        result.addError("Dòng " + (i + 1) + ": Danh mục không tồn tại - " + categoryName);
                        continue;
                    }
                    Product existingProduct = productDAO.getProductByName(productName);

                    if (existingProduct == null) {
                        Product product = new Product();
                        product.setCategoryId(categoryId);
                        product.setName(productName);
                        product.setSlug(productName.toLowerCase().replace(" ", "-") + "-" + System.currentTimeMillis());
                        product.setPrice(price);
                        product.setSalePrice(salePrice);
                        product.setStockQuantity(stock);
                        product.setShortDescription(shortDescription);
                        product.setDescription(description);
                        product.setSku("SKU-" + System.nanoTime());
                        if (imageFile == null || imageFile.isBlank()) {
                            product.setImageUrl("assets/images/default-product.png");
                        } else {
                            product.setImageUrl("assets/images/products/import/" + imageFile);
                        }
                        product.setBestseller(bestseller.equalsIgnoreCase("true"));
                        product.setIngredients("");
                        product.setUsageInstructions("");
                        product.setCreatedAt(java.time.LocalDateTime.now());

                        if (status.equalsIgnoreCase("ACTIVE")) {
                            product.setStatus(ProductStatus.ACTIVE);
                        } else {
                            product.setStatus(ProductStatus.INACTIVE);
                        }

                        int newId = productDAO.insertProduct(product);

                        if (newId > 0) {
                            result.increaseAdded();
                        } else {
                            result.addError("Dòng " + (i + 1) + ": Thêm sản phẩm thất bại");
                        }
                    } else {

                        existingProduct.setPrice(price);
                        existingProduct.setSalePrice(salePrice);
                        existingProduct.setStockQuantity(stock);
                        existingProduct.setCategoryId(categoryId);
                        boolean updated = productDAO.updateProduct(existingProduct);
                        if (updated) {
                            result.increaseUpdated();
                        } else {
                            result.addError("Dòng " + (i + 1) + ": Cập nhật sản phẩm thất bại");
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    result.addError("Lỗi dòng " + (i + 1) + ": " + e.getMessage());
                }
            }

            workbook.close();

        } catch (Exception e) {
            System.out.println("===== READ EXCEL ERROR =====");
            e.printStackTrace();
            result.addError("Không thể đọc file Excel: " + e.getMessage());
        }

        for (String err : result.getErrorMessages()) {
            System.out.println(err);
        }

        String action;
        if (result.getAddedCount() > 0 && result.getUpdatedCount() > 0) {
            action = "Import Excel: thêm " + result.getAddedCount() + " sản phẩm, cập nhật " + result.getUpdatedCount() + " sản phẩm";
        } else if (result.getAddedCount() > 0) {
            action = "Import Excel: thêm " + result.getAddedCount() + " sản phẩm mới";
        } else if (result.getUpdatedCount() > 0) {
            action = "Import Excel: cập nhật " + result.getUpdatedCount() + " sản phẩm";
        } else {
            if (result.getErrorMessages().isEmpty()) {
                action = "Import Excel sản phẩm thất bại";
            } else {
                action = "Import Excel thất bại: " + result.getErrorMessages().get(0);
            }
        }
        logService.log(adminId, action, "Product", null);
        return result;
    }

    private String getCellString(Cell cell) {

        if (cell == null) {
            return "";
        }

        return switch (cell.getCellType()) {
            case STRING ->
                    cell.getStringCellValue().trim();

            case NUMERIC ->
                    String.valueOf((int) cell.getNumericCellValue());

            case BOOLEAN ->
                    String.valueOf(cell.getBooleanCellValue());

            default -> "";
        };
    }
}