package model.rbac;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Role implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private String name;
    private String displayName;
    private String description;
    private Boolean isSystem;
    private Double maxDiscountPercent;
    private LocalDateTime createdAt;

    public Role() {}

    public Role(Integer id, String name, String displayName, String description, Boolean isSystem, Double maxDiscountPercent, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.displayName = displayName;
        this.description = description;
        this.isSystem = isSystem;
        this.maxDiscountPercent = maxDiscountPercent;
        this.createdAt = createdAt;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Boolean getIsSystem() { return isSystem; }
    public void setIsSystem(Boolean isSystem) { this.isSystem = isSystem; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Double getMaxDiscountPercent() { return maxDiscountPercent; }
    public void setMaxDiscountPercent(Double maxDiscountPercent) { this.maxDiscountPercent = maxDiscountPercent; }
}
