package model;

import java.time.LocalDateTime;

public class ReviewDTO {
    private String userName;
    private String userAvatar;
    private int rating;
    private String comment;
    private LocalDateTime createdAt;

    public ReviewDTO(String userName, String userAvatar, int rating, String comment, LocalDateTime createdAt) {
        this.userName = userName;
        this.userAvatar = userAvatar;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    public String getUserName() { return userName; }
    public String getUserAvatar() { return userAvatar; }
    public int getRating() { return rating; }
    public String getComment() { return comment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}