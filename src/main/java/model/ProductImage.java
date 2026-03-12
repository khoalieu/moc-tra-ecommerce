package model;

import java.time.LocalDateTime;

public class ProductImage {
    private Integer id;
    private Integer productId;
    private String imageUrl;
    private String altText;
    private Integer sortOrder;
    private LocalDateTime createdAt;

    public ProductImage() {}

    public ProductImage(Integer id, Integer productId, String imageUrl, String altText,
                        Integer sortOrder, LocalDateTime createdAt) {
        this.id = id;
        this.productId = productId;
        this.imageUrl = imageUrl;
        this.altText = altText;
        this.sortOrder = sortOrder;
        this.createdAt = createdAt;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getAltText() { return altText; }
    public void setAltText(String altText) { this.altText = altText; }

    public Integer getSortOrder() { return sortOrder; }
    public void setSortOrder(Integer sortOrder) { this.sortOrder = sortOrder; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
