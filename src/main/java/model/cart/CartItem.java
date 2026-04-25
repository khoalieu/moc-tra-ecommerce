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
    public double getOriginalUnitPrice() {
        if (variant != null) {
            return variant.getPrice();
        }

        if (product != null) {
            return product.getPrice();
        }

        return 0;
    }

    public double getDiscountPerItem() {
        double originalPrice = getOriginalUnitPrice();
        double finalPrice = getUnitPrice();

        double discount = originalPrice - finalPrice;

        return Math.max(discount, 0);
    }

    public double getTotalOriginalPrice() {
        return getOriginalUnitPrice() * quantity;
    }

    public double getTotalDiscount() {
        return getDiscountPerItem() * quantity;
    }
}