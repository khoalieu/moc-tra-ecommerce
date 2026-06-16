package model.user;

import java.io.Serializable;

public class VipUpdateResult implements Serializable {
    private static final long serialVersionUID = 1L;

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
