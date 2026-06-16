package model.product;

import java.io.Serializable;

public class TopProductDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int productId;
    private String productName;
    private int totalSold;

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getTotalSold() {
        return totalSold;
    }

    public void setTotalSold(int totalSold) {
        this.totalSold = totalSold;
    }
}
