package model.user;

import java.io.Serializable;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class AuditLog implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private int targetId;
    private String fieldName;
    private String oldValue;
    private String newValue;
    private Timestamp createdAt;

    // Join fields
    private String performerUsername;

    public AuditLog() {}

    public AuditLog(int id, int userId, int targetId, String fieldName, String oldValue, String newValue, Timestamp createdAt) {
        this.id = id;
        this.userId = userId;
        this.targetId = targetId;
        this.fieldName = fieldName;
        this.oldValue = oldValue;
        this.newValue = newValue;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getTargetId() { return targetId; }
    public void setTargetId(int targetId) { this.targetId = targetId; }

    public String getFieldName() { return fieldName; }
    public void setFieldName(String fieldName) { this.fieldName = fieldName; }

    public String getOldValue() { return oldValue; }
    public void setOldValue(String oldValue) { this.oldValue = oldValue; }

    public String getNewValue() { return newValue; }
    public void setNewValue(String newValue) { this.newValue = newValue; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getPerformerUsername() { return performerUsername; }
    public void setPerformerUsername(String performerUsername) { this.performerUsername = performerUsername; }

    // Friendly display name for field
    public String getFieldNameVi() {
        if (fieldName == null) return "N/A";
        switch (fieldName) {
            case "firstName": return "Tên";
            case "lastName": return "Họ đệm";
            case "phone": return "Số điện thoại";
            case "roleId": return "Vai trò";
            case "isActive": return "Trạng thái hoạt động";
            case "isVip": return "Hạng thành viên VIP";
            default: return fieldName;
        }
    }
}
