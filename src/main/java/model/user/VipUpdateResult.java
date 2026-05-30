package model.user;

public class VipUpdateResult {
    private int upgradedCount;
    private int downgradedCount;

    public VipUpdateResult(int upgradedCount, int downgradedCount) {
        this.upgradedCount = upgradedCount;
        this.downgradedCount = downgradedCount;
    }

    public int getUpgradedCount() {
        return upgradedCount;
    }

    public int getDowngradedCount() {
        return downgradedCount;
    }
}