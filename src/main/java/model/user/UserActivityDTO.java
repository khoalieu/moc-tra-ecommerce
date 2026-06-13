package model.user;

import java.io.Serializable;
import java.time.LocalDateTime;

public class UserActivityDTO implements Serializable, Comparable<UserActivityDTO> {
    private static final long serialVersionUID = 1L;

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
