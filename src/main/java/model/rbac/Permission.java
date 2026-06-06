package model.rbac;

import java.io.Serializable;
import java.time.LocalDateTime;

public class Permission implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private String name;
    private String displayName;
    private String description;
    private String groupName;
    private LocalDateTime createdAt;

    public Permission() {}

    public Permission(Integer id, String name, String displayName, String description, String groupName, LocalDateTime createdAt) {
        this.id = id;
        this.name = name;
        this.displayName = displayName;
        this.description = description;
        this.groupName = groupName;
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

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
