package model.promotion;

public class PromotionItem {
    private Integer id;
    private Integer promotionId;
    private Integer productId;

    public PromotionItem() {}

    public PromotionItem(Integer id, Integer promotionId, Integer productId) {
        this.id = id;
        this.promotionId = promotionId;
        this.productId = productId;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getPromotionId() { return promotionId; }
    public void setPromotionId(Integer promotionId) { this.promotionId = promotionId; }

    public Integer getProductId() { return productId; }
    public void setProductId(Integer productId) { this.productId = productId; }
}
