package model.product;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ProductImportResult implements Serializable {
    private static final long serialVersionUID = 1L;

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
    public String getInventorySummary() {
        return "Da cap nhat ton kho cho " + updatedCount + " bien the, loi " + errorCount + " dong.";
    }
}
