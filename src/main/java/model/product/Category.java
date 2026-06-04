package model.product;

import java.io.Serializable;

public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer id;
    private String name;
    private String slug;
    private Integer parentId;
    private Boolean isActive;

    public Category() {}

    public Category(Integer id, String name, String slug, Integer parentId, Boolean isActive) {
        this.id = id;
        this.name = name;
        this.slug = slug;
        this.parentId = parentId;
        this.isActive = isActive;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }

    public Boolean isActive() { return isActive; }
    /** @deprecated Use {@link #isActive()} in Java code; kept for JSP EL compatibility (${cat.isActive}) */
    public Boolean getIsActive() { return isActive; }
    public void setActive(Boolean active) { isActive = active; }
}
