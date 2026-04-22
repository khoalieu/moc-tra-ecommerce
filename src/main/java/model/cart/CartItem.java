package model.cart;

import model.product.Product;
import model.product.ProductVariant;

public class CartItem {
    private Product product;
    private int quantity;
    private int variantId;
    private ProductVariant variant;

    public CartItem() {
    }

    public CartItem(Product product, ProductVariant variant, int quantity) {
        this.product = product;
        this.variant = variant;
        this.quantity = quantity;
        if (variant != null) {
            this.variantId = variant.getId();
        }
    }

    public double getUnitPrice() {
        if (variant != null) {
            return (variant.getSalePrice() > 0) ? variant.getSalePrice() : variant.getPrice();
        }
        return (product.getSalePrice() > 0) ? product.getSalePrice() : product.getPrice();
    }

    public double getTotalPrice() {
        return getUnitPrice() * quantity;
    }
    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getVariantId() {
        return variantId;
    }

    public void setVariantId(int variantId) {
        this.variantId = variantId;
    }

    public ProductVariant getVariant() {
        return variant;
    }

    public void setVariant(ProductVariant variant) {
        this.variant = variant;
        if (variant != null) {
            this.variantId = variant.getId();
        }
    }
}