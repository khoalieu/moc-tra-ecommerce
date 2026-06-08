package model.user;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class CustomerDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String fullName;
    private String email;
    private String phone;
    private String province;
    private int totalOrders;
    private double totalSpent;
    private Timestamp joinDate;
    private Timestamp lastOrderDate;
    private boolean isActive;
    private boolean isVip;

    public CustomerDTO() {}

    public String getStatusLabel() {
        if (!isActive) {
            return "Không hoạt động";
        }

        if (isVip) {
            return "VIP";
        }

        if (joinDate != null) {
            long diffInMillies = System.currentTimeMillis() - joinDate.getTime();
            long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
            if (diffInDays < 30) {
                return "Mới";
            }
        }
        return "Hoạt động";
    }
    //format tiền tệ
    public String getTotalSpentFormatted() {
        Locale localeVN = new Locale("vi", "VN");
        NumberFormat currencyVN = NumberFormat.getCurrencyInstance(localeVN);
        return currencyVN.format(totalSpent);
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getMaskedEmail() {
        if (email == null || !email.contains("@")) return email;
        int atIndex = email.indexOf("@");
        String mailbox = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (mailbox.length() <= 1) return mailbox + "***" + domain;
        return mailbox.charAt(0) + "***" + domain;
    }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public int getTotalOrders() { return totalOrders; }
    public void setTotalOrders(int totalOrders) { this.totalOrders = totalOrders; }
    public double getTotalSpent() { return totalSpent; }
    public void setTotalSpent(double totalSpent) { this.totalSpent = totalSpent; }
    public Timestamp getJoinDate() { return joinDate; }
    public void setJoinDate(Timestamp joinDate) { this.joinDate = joinDate; }
    public Timestamp getLastOrderDate() { return lastOrderDate; }
    public void setLastOrderDate(Timestamp lastOrderDate) { this.lastOrderDate = lastOrderDate; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public boolean isVip() {
        return isVip;
    }

    public void setVip(boolean vip) {
        isVip = vip;
    }
}