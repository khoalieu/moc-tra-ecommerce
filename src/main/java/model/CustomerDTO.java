package model;

import java.sql.Timestamp;
import java.text.NumberFormat;
import java.util.Locale;

public class CustomerDTO {
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

    public CustomerDTO() {}

    // Logic tính toán trạng thái hiển thị
    public String getStatusLabel() {
        if (!isActive) {
            return "Không hoạt động"; // Inactive
        }

        // Tổng chi tiêu lớn hơn 5000
        if (totalSpent > 5000000) {
            return "VIP";
        }

        // Logic: Tham gia trong vòng 30 ngày
        long diffInMillies = System.currentTimeMillis() - joinDate.getTime();
        long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
        if (diffInDays < 30) {
            return "Mới";
        }

        return "Hoạt động"; // Active thường
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
}