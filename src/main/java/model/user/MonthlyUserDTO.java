package model.user;

import java.io.Serializable;

public class MonthlyUserDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private String month;
    private int totalUsers;

    public String getMonth() {
        return month;
    }

    public void setMonth(String month) {
        this.month = month;
    }

    public int getTotalUsers() {
        return totalUsers;
    }

    public void setTotalUsers(int totalUsers) {
        this.totalUsers = totalUsers;
    }
}
