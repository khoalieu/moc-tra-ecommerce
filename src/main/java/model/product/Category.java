package model.product;

public class Category {
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

    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean active) { isActive = active; }
}
