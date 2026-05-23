package model.product;

import java.util.ArrayList;
import java.util.List;

public class ProductImportResult {
    private int addedCount;
    private int updatedCount;
    private int errorCount;
    private List<String> errorMessages = new ArrayList<>();

    public void increaseAdded() {
        addedCount++;
    }

    public void increaseUpdated() {
        updatedCount++;
    }

    public void addError(String message) {
        errorCount++;
        errorMessages.add(message);
    }

    public int getAddedCount() {
        return addedCount;
    }

    public int getUpdatedCount() {
        return updatedCount;
    }

    public int getErrorCount() {
        return errorCount;
    }

    public List<String> getErrorMessages() {
        return errorMessages;
    }

    public String getSummary() {
        return "Đã thêm " + addedCount + " sản phẩm, cập nhật " + updatedCount + " sản phẩm, lỗi " + errorCount + " dòng.";
    }
}
