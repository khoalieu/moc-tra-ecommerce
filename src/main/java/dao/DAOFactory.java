package dao;

import java.io.InputStream;
import java.util.Properties;
import javax.sql.DataSource;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Factory class for creating DAO instances with connection pooling support.
 * Uses HikariCP for efficient database connection management.
 */
public class DAOFactory {
    private static DAOFactory instance = new DAOFactory();
    private final DataSource dataSource;

    private DAOFactory() {
        Properties props = new Properties();

        try (InputStream input = DAOFactory.class.getClassLoader().getResourceAsStream("database.properties")) {

            props.load(input);

            // Configure HikariCP Connection Pool
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver"); // Explicitly set MySQL driver
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.user"));
            config.setPassword(props.getProperty("db.password"));

            // Pool configuration for optimal performance
            config.setMaximumPoolSize(10);              // Max 10 connections
            config.setMinimumIdle(2);                   // Min 2 idle connections
            config.setConnectionTimeout(30000);         // 30 seconds timeout
            config.setIdleTimeout(600000);              // 10 minutes idle timeout
            config.setMaxLifetime(1800000);             // 30 minutes max lifetime

            // Performance optimizations
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");

            this.dataSource = new HikariDataSource(config);

            System.out.println("✅ HikariCP Connection Pool initialized successfully");

        } catch (Exception e) {
            throw new RuntimeException("Failed to load DB configuration", e);
        }
    }

    public static DAOFactory getInstance() {
        return instance;
    }

    // --- Các phương thức lấy DAO ---

    // Banner
    public BannerDAO getBannerDAO() {
        return new BannerDAO(dataSource);
    }

    // Blog
    public BlogCategoryDAO getBlogCategoryDAO() {
        return new BlogCategoryDAO(dataSource);
    }

    public BlogCommentDAO getBlogCommentDAO() {
        return new BlogCommentDAO(dataSource);
    }

    public BlogPostDAO getBlogPostDAO() {
        return new BlogPostDAO(dataSource);
    }

    // Cart & Category
    public CartDAO getCartDAO() {
        return new CartDAO(dataSource);
    }

    public CategoryDAO getCategoryDAO() {
        return new CategoryDAO(dataSource);
    }

    // Order & Product
    public OrderDAO getOrderDAO() {
        return new OrderDAO(dataSource);
    }

    public ProductDAO getProductDAO() {
        return new ProductDAO(dataSource);
    }

    public ProductImageDAO getProductImageDAO() {
        return new ProductImageDAO(dataSource);
    }

    // Promotion & Review
    public PromotionDAO getPromotionDAO() {
        return new PromotionDAO(dataSource);
    }

    public ReviewDAO getReviewDAO() {
        return new ReviewDAO(dataSource);
    }

    // User
    public UserAddressDAO getUserAddressDAO() {
        return new UserAddressDAO(dataSource);
    }

    public UserDAO getUserDAO() {
        return new UserDAO(dataSource);
    }

    /**
     * Closes the connection pool. Should be called on application shutdown.
     */
    public void shutdown() {
        if (dataSource instanceof HikariDataSource) {
            ((HikariDataSource) dataSource).close();
            System.out.println("✅ HikariCP Connection Pool closed");
        }
    }

}
