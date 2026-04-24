package model.promotion;

import java.time.LocalDateTime;

public class VipVoucher {
    private Integer id;
    private String code;
    private String discountType; // PERCENT | FIXED_AMOUNT
    private Double discountValue;
    private Integer maxUses;
    private Integer currentUses;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime usedAt;

    public VipVoucher() {
    }

    public Double getDiscountValue() {
        return discountValue;
    }
    public void setDiscountValue(Double discountValue) {
        this.discountValue = discountValue;
    }
    public Integer getMaxUses() {
        return maxUses;
    }
    public void setMaxUses(Integer maxUses) {
        this.maxUses = maxUses;
    }
    public Integer getCurrentUses() {
        return currentUses;
    }
    public void setCurrentUses(Integer currentUses) {
        this.currentUses = currentUses;
    }
    public LocalDateTime getStartDate() {
        return startDate;
    }
    public void setStartDate(LocalDateTime startDate) {
        this.startDate = startDate;
    }
    public LocalDateTime getEndDate() {
        return endDate;
    }
    public void setEndDate(LocalDateTime endDate) {
        this.endDate = endDate;
    }
    public Boolean getActive() {
        return isActive;
    }
    public void setActive(Boolean active) {
        isActive = active;
    }
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
    public String getCode() {
        return code;
    }
    public void setCode(String code) {
        this.code = code;
    }
    public String getDiscountType() {
        return discountType;
    }
    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    public LocalDateTime getUsedAt() {
        return usedAt;
    }

    public void setUsedAt(LocalDateTime usedAt) {
        this.usedAt = usedAt;
    }

}
