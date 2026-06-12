package controller.admin;

import dao.DAOFactory;
import dao.ProductVariantDAO;
import model.product.ProductImportResult;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import service.SystemLogService;

import java.io.InputStream;

public class ProductInventoryImportService {
    private final ProductVariantDAO variantDAO = DAOFactory.getInstance().getProductVariantDAO();
    private final SystemLogService logService = new SystemLogService();

    public ProductImportResult importInventory(InputStream inputStream, Integer adminId) {
        ProductImportResult result = new ProductImportResult();

        try (Workbook workbook = new XSSFWorkbook(inputStream)) {
            Sheet sheet = workbook.getSheetAt(0);

            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null || isBlankRow(row)) {
                    continue;
                }

                int variantId = (int) getCellDouble(row.getCell(0));
                String variantSku = getCellString(row.getCell(1));
                int quantityAdd = (int) getCellDouble(row.getCell(4));

                if ((variantId <= 0 && variantSku.isBlank()) || quantityAdd <= 0) {
                    result.addError("Dong " + (i + 1) + ": Can co variant_id hoac variant_sku va quantity_add > 0");
                    continue;
                }

                boolean updated = variantId > 0
                        ? variantDAO.increaseStockById(variantId, quantityAdd)
                        : variantDAO.increaseStockBySku(variantSku, quantityAdd);

                if (updated) {
                    result.increaseUpdated();
                } else {
                    result.addError("Dong " + (i + 1) + ": Khong tim thay bien the de cap nhat ton kho");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.addError("Khong the doc file Excel: " + e.getMessage());
        }

        logService.log(adminId, "Import ton kho bien the: cap nhat " + result.getUpdatedCount()
                + ", loi " + result.getErrorCount(), "ProductVariant", null);
        return result;
    }

    private boolean isBlankRow(Row row) {
        for (int i = 0; i <= 4; i++) {
            if (!getCellString(row.getCell(i)).isBlank()) {
                return false;
            }
        }
        return true;
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
}
