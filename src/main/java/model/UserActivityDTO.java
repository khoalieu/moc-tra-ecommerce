package model;

import java.time.LocalDateTime;

public class UserActivityDTO implements Comparable<UserActivityDTO> {
    private String icon;
    private String title;
    private String description;
    private LocalDateTime time;

    public UserActivityDTO(String icon, String title, String description, LocalDateTime time) {
        this.icon = icon;
        this.title = title;
        this.description = description;
        this.time = time;
    }
    public String getIcon() { return icon; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public LocalDateTime getTime() { return time; }
    @Override
    public int compareTo(UserActivityDTO other) {
        return other.time.compareTo(this.time);
    }
}