package controller.admin;

import dao.CategoryDAO;
import dao.DAOFactory;
import dao.ProductDAO;
import dao.ProductVariantDAO;
import model.enums.ProductStatus;
import model.product.Product;
import model.product.ProductImportResult;
import model.product.ProductVariant;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import service.SystemLogService;

import java.io.InputStream;
import java.time.LocalDateTime;

public class ProductImportService {

    private final ProductDAO productDAO = DAOFactory.getInstance().getProductDAO();
    private final ProductVariantDAO variantDAO = DAOFactory.getInstance().getProductVariantDAO();
    private final CategoryDAO categoryDAO = DAOFactory.getInstance().getCategoryDAO();
    private final SystemLogService logService = new SystemLogService();

    public ProductImportResult importProducts(InputStream inputStream, Integer adminId) {
        ProductImportResult result = new ProductImportResult();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null || isBlankRow(row)) {
                    continue;
                }

                try {
                    String productSku = getCellString(row.getCell(0));
                    String productName = getCellString(row.getCell(1));
                    String categoryName = getCellString(row.getCell(2));
                    String status = getCellString(row.getCell(3));
                    String bestseller = getCellString(row.getCell(4));
                    String shortDescription = getCellString(row.getCell(5));
                    String description = getCellString(row.getCell(6));
                    String imageFile = getCellString(row.getCell(7));
                    String variantSku = getCellString(row.getCell(8));
                    String variantName = getCellString(row.getCell(9));
                    double variantPrice = getCellDouble(row.getCell(10));
                    double variantSalePrice = getCellDouble(row.getCell(11));
                    int variantStock = (int) getCellDouble(row.getCell(12));

                    if (productSku.isBlank() || productName.isBlank() || categoryName.isBlank()
                            || variantPrice <= 0 || variantStock < 0) {
                        result.addError("Dòng " + (i + 1) + ": Thiếu hoặc sai dữ liệu bắt buộc");
                        continue;
                    }

                    if (variantName.isBlank()) {
                        variantName = "Mặc định";
                    }
                    if (variantSku.isBlank()) {
                        variantSku = productSku + ("Mặc định".equals(variantName) ? "-MD" : "-" + normalizeSkuPart(variantName));
                    }

                    Integer categoryId = categoryDAO.getCategoryIdByName(categoryName);
                    if (categoryId == null) {
                        result.addError("Dòng " + (i + 1) + ": Danh mục không tồn tại - " + categoryName);
                        continue;
                    }

                    Product product = productDAO.getProductBySku(productSku);
                    boolean newProduct = product == null;
                    if (newProduct) {
                        product = new Product();
                        product.setSku(productSku);
                        product.setSlug(productName.toLowerCase().replaceAll("[^a-z0-9]+", "-")
                                .replaceAll("^-|-$", "") + "-" + System.currentTimeMillis());
                        product.setCreatedAt(LocalDateTime.now());
                    }

                    product.setName(productName);
                    product.setCategoryId(categoryId);
                    product.setShortDescription(shortDescription);
                    product.setDescription(description);
                    product.setPrice(variantPrice);
                    product.setSalePrice(variantSalePrice);
                    product.setStockQuantity(variantStock);
                    product.setImageUrl(imageFile.isBlank()
                            ? (product.getImageUrl() != null ? product.getImageUrl() : "assets/images/default-product.png")
                            : "assets/images/products/import/" + imageFile);
                    product.setBestseller("true".equalsIgnoreCase(bestseller) || "1".equals(bestseller));
                    product.setIngredients(product.getIngredients() != null ? product.getIngredients() : "");
                    product.setUsageInstructions(product.getUsageInstructions() != null ? product.getUsageInstructions() : "");
                    product.setStatus(parseStatus(status));

                    int productId;
                    if (newProduct) {
                        productId = productDAO.insertProduct(product);
                        if (productId <= 0) {
                            result.addError("Dòng " + (i + 1) + ": Thêm sản phẩm thất bại");
                            continue;
                        }
                        product.setId(productId);
                        result.increaseAdded();
                    } else {
                        productDAO.updateProduct(product);
                        productId = product.getId();
                        result.increaseUpdated();
                    }

                    ProductVariant variant = variantDAO.getVariantBySku(variantSku);
                    if (variant == null) {
                        variant = variantDAO.getVariantByProductAndName(productId, variantName);
                    }

                    if (variant == null) {
                        variant = new ProductVariant();
                        variant.setProductId(productId);
                        variant.setVariantName(variantName);
                        variant.setSku(variantSku);
                        variant.setPrice(variantPrice);
                        variant.setSalePrice(Math.min(variantSalePrice, variantPrice));
                        variant.setStockQuantity(variantStock);
                        variantDAO.addVariant(variant);
                    } else {
                        variant.setProductId(productId);
                        variant.setVariantName(variantName);
                        variant.setSku(variantSku);
                        variant.setPrice(variantPrice);
                        variant.setSalePrice(Math.min(variantSalePrice, variantPrice));
                        variant.setStockQuantity(variantStock);
                        variantDAO.updateVariant(variant);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    result.addError("Lỗi dòng " + (i + 1) + ": " + e.getMessage());
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.addError("Không thể đọc file Excel: " + e.getMessage());
        }

        String action = "Import sản phẩm/biến thể: thêm " + result.getAddedCount()
                + ", cập nhật " + result.getUpdatedCount()
                + ", lỗi " + result.getErrorCount();
        logService.log(adminId, action, "Product", null);
        return result;
    }

    private boolean isBlankRow(Row row) {
        for (int i = 0; i <= 12; i++) {
            if (!getCellString(row.getCell(i)).isBlank()) {
                return false;
            }
        }
        return true;
    }

    private ProductStatus parseStatus(String status) {
        if (status == null || status.isBlank()) {
            return ProductStatus.ACTIVE;
        }
        try {
            return ProductStatus.valueOf(status.trim().toUpperCase());
        } catch (Exception e) {
            return ProductStatus.ACTIVE;
        }
    }

    private String getCellString(Cell cell) {
        if (cell == null) {
            return "";
        }
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue().trim();
            case NUMERIC -> String.valueOf((long) cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            default -> "";
        };
    }

    private double getCellDouble(Cell cell) {
        if (cell == null) {
            return 0;
        }
        try {
            return switch (cell.getCellType()) {
                case NUMERIC -> cell.getNumericCellValue();
                case STRING -> cell.getStringCellValue().trim().isEmpty()
                        ? 0
                        : Double.parseDouble(cell.getStringCellValue().trim());
                default -> 0;
            };
        } catch (Exception e) {
            return 0;
        }
    }

    private String normalizeSkuPart(String value) {
        String normalized = value == null ? "" : value.trim().toUpperCase()
                .replaceAll("[^A-Z0-9]+", "-")
                .replaceAll("^-|-$", "");
        return normalized.isBlank() ? "MD" : normalized;
    }
}
