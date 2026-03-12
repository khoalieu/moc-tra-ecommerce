package model;

public class GooglePojo {
    private String id;
    private String email;
    private boolean verified_email;
    private String name;
    private String given_name;
    private String family_name;
    private String picture;

    public String getEmail() { return email; }
    public String getName() { return name; }
    public String getFirstName() { return given_name; }
    public String getLastName() { return family_name; }
    public String getPicture() { return picture; }

}