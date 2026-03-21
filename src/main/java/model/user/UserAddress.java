package model.user;

public class UserAddress {
    private Integer id;
    private Integer userId;
    private String fullName;
    private String phoneNumber;
    private String label;
    private String province;
    private String ward;
    private String streetAddress;
    private Boolean isDefault;

    public UserAddress() {}

    public UserAddress(Integer id, Integer userId, String fullName, String phoneNumber, String label,
                       String province, String ward, String streetAddress, Boolean isDefault) {
        this.id = id;
        this.userId = userId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.label = label;
        this.province = province;
        this.ward = ward;
        this.streetAddress = streetAddress;
        this.isDefault = isDefault;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }

    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }

    public String getWard() { return ward; }
    public void setWard(String ward) { this.ward = ward; }

    public String getStreetAddress() { return streetAddress; }
    public void setStreetAddress(String streetAddress) { this.streetAddress = streetAddress; }

    public Boolean getIsDefault() { return isDefault; }
    public void setIsDefault(Boolean aDefault) { isDefault = aDefault; }
}
