package model.blog;


import model.user.User;
import model.enums.BlogStatus;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Date;

public class BlogPost {
    private Integer id;
    private String title;
    private String slug;
    private String excerpt;
    private String content;
    private String featuredImage;
    private Integer authorId;
    private Integer categoryId;
    private BlogStatus status;
    private Integer viewsCount;
    private String metaTitle;
    private String metaDescription;
    private LocalDateTime createdAt;

    private BlogCategory category;
    private User author;

    public BlogPost() {}

    public BlogPost(Integer id, String title, String slug, String excerpt, String content, String featuredImage,
                    Integer authorId, Integer categoryId, BlogStatus status, Integer viewsCount,
                    String metaTitle, String metaDescription, LocalDateTime createdAt) {
        this.id = id;
        this.title = title;
        this.slug = slug;
        this.excerpt = excerpt;
        this.content = content;
        this.featuredImage = featuredImage;
        this.authorId = authorId;
        this.categoryId = categoryId;
        this.status = status;
        this.viewsCount = viewsCount;
        this.metaTitle = metaTitle;
        this.metaDescription = metaDescription;
        this.createdAt = createdAt;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public String getExcerpt() { return excerpt; }
    public void setExcerpt(String excerpt) { this.excerpt = excerpt; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getFeaturedImage() { return featuredImage; }
    public void setFeaturedImage(String featuredImage) { this.featuredImage = featuredImage; }

    public Integer getAuthorId() { return authorId; }
    public void setAuthorId(Integer authorId) { this.authorId = authorId; }

    public Integer getCategoryId() { return categoryId; }
    public void setCategoryId(Integer categoryId) { this.categoryId = categoryId; }

    public BlogStatus getStatus() { return status; }
    public void setStatus(BlogStatus status) { this.status = status; }

    public Integer getViewsCount() { return viewsCount; }
    public void setViewsCount(Integer viewsCount) { this.viewsCount = viewsCount; }

    public String getMetaTitle() { return metaTitle; }
    public void setMetaTitle(String metaTitle) { this.metaTitle = metaTitle; }

    public String getMetaDescription() { return metaDescription; }
    public void setMetaDescription(String metaDescription) { this.metaDescription = metaDescription; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Date getCreatedAtDate() {
        return createdAt == null ? null : Timestamp.valueOf(createdAt);
    }
    public BlogCategory getCategory() { return category; }
    public void setCategory(BlogCategory category) { this.category = category; }

    public User getAuthor() { return author; }
    public void setAuthor(User author) { this.author = author; }
}

