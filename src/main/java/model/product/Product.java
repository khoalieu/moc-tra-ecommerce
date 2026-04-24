package model.product;

import model.enums.ProductStatus;

import java.time.LocalDateTime;
import java.util.List;

public class Product {
    private int id;
    private String name;
    private String slug;
    private String description;
    private String shortDescription;
    private double price;           // decimal(15,2)
    private double salePrice;       // decimal(15,2)
    private String sku;
    private int stockQuantity;
    private Integer categoryId;
    private String imageUrl;
    private boolean isBestseller;
    private ProductStatus status;
    private String ingredients;
    private String usageInstructions;
    private LocalDateTime createdAt;
    private int currentPromotionId;
    private String currentPromotionType;
    private Double currentPromotionValue;
    private List<ProductVariant> variants;
    public Product() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getShortDescription() { return shortDescription; }
    public void setShortDescription(String shortDescription) { this.shortDescription = shortDescription; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public double getSalePrice() { return salePrice; }
    public void setSalePrice(double salePrice) { this.salePrice = salePrice; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isBestseller() { return isBestseller; }
    public void setBestseller(boolean bestseller) { isBestseller = bestseller; }

    public ProductStatus getStatus() { return status; }
    public void setStatus(ProductStatus status) { this.status = status; }

    public String getIngredients() { return ingredients; }
    public void setIngredients(String ingredients) { this.ingredients = ingredients; }

    public String getUsageInstructions() { return usageInstructions; }
    public void setUsageInstructions(String usageInstructions) { this.usageInstructions = usageInstructions; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public int getCurrentPromotionId() { return currentPromotionId; }
    public void setCurrentPromotionId(int currentPromotionId) { this.currentPromotionId = currentPromotionId; }


    public String getCurrentPromotionType() { return currentPromotionType; }
    public void setCurrentPromotionType(String currentPromotionType) { this.currentPromotionType = currentPromotionType; }

    public Double getCurrentPromotionValue() { return currentPromotionValue; }
    public void setCurrentPromotionValue(Double currentPromotionValue) { this.currentPromotionValue = currentPromotionValue; }
    public List<ProductVariant> getVariants() {
        return variants;
    }

    public void setVariants(List<ProductVariant> variants) {
        this.variants = variants;
    }
}
