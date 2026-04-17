package model.product;

public class ProductVariant {
    private int id;
    private int productId;
    private String variantName;
    private String sku;
    private double price;
    private double salePrice;
    private int stockQuantity;

    public ProductVariant(int id, int productId, String variantName, String sku, double price, double salePrice, int stockQuantity) {
        this.id = id;
        this.productId = productId;
        this.variantName = variantName;
        this.sku = sku;
        this.price = price;
        this.salePrice = salePrice;
        this.stockQuantity = stockQuantity;
    }

    public ProductVariant() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getVariantName() {
        return variantName;
    }

    public void setVariantName(String variantName) {
        this.variantName = variantName;
    }

    public String getSku() {
        return sku;
    }

    public void setSku(String sku) {
        this.sku = sku;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public double getSalePrice() {
        return salePrice;
    }

    public void setSalePrice(double salePrice) {
        this.salePrice = salePrice;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }
}

