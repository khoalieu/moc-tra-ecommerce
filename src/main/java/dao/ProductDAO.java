package dao;

import model.product.Product;
import model.enums.ProductStatus;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ProductDAO {
    private final DataSource ds;
    private static final String VARIANT_SUMMARY_SELECT =
            ", (SELECT COALESCE(SUM(v.stock_quantity), 0) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS variant_total_stock " +
            ", (SELECT COUNT(*) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS variant_count " +
            ", (SELECT MIN(v.price) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS min_variant_price " +
            ", (SELECT MAX(v.price) FROM product_variants v " +
                    "WHERE v.product_id = p.id AND v.is_active = 1) AS max_variant_price " +
            ", (SELECT MIN(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) " +
                    "FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1) AS min_variant_effective_price " +
            ", (SELECT MAX(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) " +
                    "FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1) AS max_variant_effective_price ";
    private static final String VARIANT_EFFECTIVE_PRICE =
            "(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END)";
    private static final String MIN_VARIANT_EFFECTIVE_PRICE =
            "(SELECT MIN(" + VARIANT_EFFECTIVE_PRICE + ") FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1)";
    private static final String TOTAL_VARIANT_STOCK =
            "(SELECT COALESCE(SUM(v.stock_quantity), 0) FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1)";

    public ProductDAO(DataSource ds) {
        this.ds = ds;
    }


    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double maxPrice, int index, int size) {

        return getProducts(categoryId, promotionId, sort, maxPrice, index, size, "active");
    }
    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double maxPrice, int index, int size, String status) {
        return getProducts(categoryId, promotionId, sort, maxPrice, null, index, size, status);
    }

    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double maxPrice,
                                     String search, int index, int size, String status) {
        return getProducts(toCategoryList(categoryId), promotionId, sort, null, maxPrice, search, index, size, status);
    }

    public List<Product> getProducts(Integer categoryId, Integer promotionId, String sort, Double minPrice, Double maxPrice,
                                     String search, int index, int size, String status) {
        return getProducts(toCategoryList(categoryId), promotionId, sort, minPrice, maxPrice, search, index, size, status);
    }

    public List<Product> getProducts(List<Integer> categoryIds, Integer promotionId, String sort, Double minPrice, Double maxPrice,
                                     String search, int index, int size, String status) {
        return getProducts(categoryIds, promotionId, false, sort, minPrice, maxPrice, search, index, size, status);
    }

    public List<Product> getProducts(List<Integer> categoryIds, Integer promotionId, boolean promotionOnly, String sort, Double minPrice, Double maxPrice,
                                     String search, int index, int size, String status) {

        List<Product> list = new ArrayList<>();

        List<String> keywords = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            for (String keyword : search.trim().toLowerCase().split("\\s+")) {
                if (!keyword.isBlank()) {
                    keywords.add(keyword);
                }
            }
        }

        String phrase = search != null ? search.trim().toLowerCase() : "";
        String phraseLike = "%" + phrase + "%";
        String phraseStart = phrase + "%";

        StringBuilder sql = new StringBuilder(
                "SELECT p.*, " +
                        "(SELECT pi.promotion_id FROM promotion_items pi WHERE pi.product_id = p.id LIMIT 1) AS current_promo_id, " +
                        "(SELECT pr.discount_type " +
                        "   FROM promotion_items pi " +
                        "   JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "   WHERE pi.product_id = p.id LIMIT 1) AS current_promo_type, " +
                        "(SELECT pr.discount_value " +
                        "   FROM promotion_items pi " +
                        "   JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "   WHERE pi.product_id = p.id LIMIT 1) AS current_promo_value " +
                        VARIANT_SUMMARY_SELECT +
                        "FROM products p "
        );
        sql.append(" WHERE 1=1 ");

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND p.category_id IN (");
            appendPlaceholders(sql, categoryIds.size());
            sql.append(") ");
        }

        if (minPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" >= ?) ");
        }

        if (maxPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" <= ?) ");
        }

        if (promotionId != null) {
            sql.append(" AND p.id IN (SELECT product_id FROM promotion_items WHERE promotion_id = ?) ");
        } else if (promotionOnly) {
            sql.append(" AND p.id IN (");
            sql.append("SELECT pi.product_id FROM promotion_items pi ");
            sql.append("JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()");
            sql.append(") ");
        }

        if (!keywords.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" OR ");
                }
                sql.append("LOWER(p.name) LIKE ? ");
            }
            sql.append(") ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) {
                sql.append(" AND p.status = 'active' ");
            } else if ("inactive".equals(status)) {
                sql.append(" AND p.status = 'inactive' ");
            } else if ("out-of-stock".equals(status)) {
                sql.append(" AND p.stock_quantity = 0 ");
            }
        }

        if (!keywords.isEmpty()) {
            sql.append(" ORDER BY ");
            sql.append("CASE WHEN LOWER(p.name) = ? THEN 10000 ELSE 0 END DESC, ");
            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 9000 ELSE 0 END DESC, ");
            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 8000 ELSE 0 END DESC, ");

            sql.append("CASE WHEN ");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" AND ");
                }
                sql.append("LOWER(p.name) LIKE ? ");
            }
            sql.append("THEN 7000 ELSE 0 END DESC, ");

            sql.append("(");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" + ");
                }
                sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END ");
            }
            sql.append(") DESC, ");

            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END DESC, ");
            sql.append("CHAR_LENGTH(p.name) ASC, ");

            if ("price-asc".equals(sort)) {
                sql.append(MIN_VARIANT_EFFECTIVE_PRICE).append(" ASC ");
            } else if ("price-desc".equals(sort)) {
                sql.append(MIN_VARIANT_EFFECTIVE_PRICE).append(" DESC ");
            } else if ("name-asc".equals(sort)) {
                sql.append("p.name ASC ");
            } else {
                sql.append("p.created_at DESC ");
            }
        } else {
            if (sort != null) {
                switch (sort) {
                    case "price-asc":
                        sql.append(" ORDER BY ").append(MIN_VARIANT_EFFECTIVE_PRICE).append(" ASC ");
                        break;
                    case "price-desc":
                        sql.append(" ORDER BY ").append(MIN_VARIANT_EFFECTIVE_PRICE).append(" DESC ");
                        break;
                    case "name-asc":
                        sql.append(" ORDER BY p.name ASC ");
                        break;
                    case "newest":
                        sql.append(" ORDER BY p.created_at DESC ");
                        break;
                    default:
                        sql.append(" ORDER BY p.created_at DESC ");
                }
            } else {
                sql.append(" ORDER BY p.created_at DESC ");
            }
        }

        sql.append(" LIMIT ? OFFSET ?");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (categoryIds != null && !categoryIds.isEmpty()) {
                for (Integer categoryId : categoryIds) {
                    ps.setInt(paramIndex++, categoryId);
                }
            }

            if (minPrice != null) {
                ps.setDouble(paramIndex++, minPrice);
            }

            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }

            if (promotionId != null) {
                ps.setInt(paramIndex++, promotionId);
            }

            for (String keyword : keywords) {
                ps.setString(paramIndex++, "%" + keyword + "%");
            }

            if (!keywords.isEmpty()) {
                ps.setString(paramIndex++, phrase);
                ps.setString(paramIndex++, phraseStart);
                ps.setString(paramIndex++, phraseLike);

                for (String keyword : keywords) {
                    ps.setString(paramIndex++, "%" + keyword + "%");
                }

                for (String keyword : keywords) {
                    ps.setString(paramIndex++, "%" + keyword + "%");
                }

                ps.setString(paramIndex++, "%" + keywords.get(0) + "%");
            }

            int offset = (index - 1) * size;
            ps.setInt(paramIndex++, size);
            ps.setInt(paramIndex++, offset);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setShortDescription(rs.getString("short_description"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setSku(rs.getString("sku"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                mapVariantSummary(p, rs);
                p.setCategoryId(rs.getInt("category_id"));
                p.setImageUrl(rs.getString("image_url"));
                p.setBestseller(rs.getBoolean("is_bestseller"));

                p.setCurrentPromotionId(rs.getInt("current_promo_id"));
                p.setCurrentPromotionType(rs.getString("current_promo_type"));

                double promoValue = rs.getDouble("current_promo_value");
                if (!rs.wasNull()) {
                    p.setCurrentPromotionValue(promoValue);
                }
                String statusStr = rs.getString("status");
                if (statusStr != null) {
                    try {
                        p.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        p.setStatus(ProductStatus.ACTIVE);
                    }
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countProducts(Integer categoryId, Integer promotionId, Double maxPrice) throws SQLException {
        return countProducts(categoryId, promotionId, maxPrice, "active");
    }
    public int countProducts(Integer categoryId, Integer promotionId, Double maxPrice, String status) {
        return countProducts(categoryId, promotionId, maxPrice, null, status);
    }
    public int countProducts(Integer categoryId, Integer promotionId, Double maxPrice, String search, String status) {
        return countProducts(toCategoryList(categoryId), promotionId, null, maxPrice, search, status);
    }

    public int countProducts(Integer categoryId, Integer promotionId, Double minPrice, Double maxPrice, String search, String status) {
        return countProducts(toCategoryList(categoryId), promotionId, minPrice, maxPrice, search, status);
    }

    public int countProducts(List<Integer> categoryIds, Integer promotionId, Double minPrice, Double maxPrice, String search, String status) {
        return countProducts(categoryIds, promotionId, false, minPrice, maxPrice, search, status);
    }

    public int countProducts(List<Integer> categoryIds, Integer promotionId, boolean promotionOnly, Double minPrice, Double maxPrice, String search, String status) {
        List<String> keywords = new ArrayList<>();

        if (search != null && !search.isBlank()) {
            for (String keyword : search.trim().toLowerCase().split("\\s+")) {
                if (!keyword.isBlank()) {
                    keywords.add(keyword);
                }
            }
        }

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p ");

        if (promotionId != null) {
            sql.append(" JOIN promotion_items pi ON p.id = pi.product_id ");
        }
        sql.append(" WHERE 1=1 ");

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND p.category_id IN (");
            appendPlaceholders(sql, categoryIds.size());
            sql.append(") ");
        }

        if (minPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" >= ?) ");
        }

        if (maxPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" <= ?) ");
        }
        if (promotionId != null) {
            sql.append(" AND pi.promotion_id = ? ");
        } else if (promotionOnly) {
            sql.append(" AND p.id IN (");
            sql.append("SELECT pi.product_id FROM promotion_items pi ");
            sql.append("JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()");
            sql.append(") ");
        }

        if (!keywords.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" OR ");
                }
                sql.append(" LOWER(p.name) LIKE ? ");
            }
            sql.append(") ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) {
                sql.append(" AND p.status = 'active' ");
            } else if ("inactive".equals(status)) {
                sql.append(" AND p.status = 'inactive' ");
            } else if ("out-of-stock".equals(status)) {
                sql.append(" AND p.stock_quantity = 0 ");
            }
        }

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (categoryIds != null && !categoryIds.isEmpty()) {
                for (Integer categoryId : categoryIds) {
                    ps.setInt(paramIndex++, categoryId);
                }
            }

            if (minPrice != null) {
                ps.setDouble(paramIndex++, minPrice);
            }

            if (maxPrice != null) {
                ps.setDouble(paramIndex++, maxPrice);
            }

            if (promotionId != null) {
                ps.setInt(paramIndex++, promotionId);
            }

            for (String keyword : keywords) {
                ps.setString(paramIndex++, "%" + keyword + "%");
            }

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Product> getAdminProducts(List<Integer> categoryIds, Integer promotionId, String promotionStatus,
                                          String stockFilter, String sort, Double minPrice, Double maxPrice,
                                          String search, int index, int size, String status,
                                          int reorderThreshold, int lowStockThreshold) {
        return getAdminProducts(categoryIds, promotionId, promotionStatus, stockFilter, sort, minPrice, maxPrice,
                search, index, size, status, reorderThreshold, lowStockThreshold, "all");
    }

    public List<Product> getAdminProducts(List<Integer> categoryIds, Integer promotionId, String promotionStatus,
                                          String stockFilter, String sort, Double minPrice, Double maxPrice,
                                          String search, int index, int size, String status,
                                          int reorderThreshold, int lowStockThreshold, String unsoldPeriod) {
        List<Product> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();
        List<String> keywords = splitSearchKeywords(search);

        StringBuilder sql = new StringBuilder(
                "SELECT p.*, " +
                        "(SELECT pi.promotion_id FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "   WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW() LIMIT 1) AS current_promo_id, " +
                        "(SELECT pr.discount_type FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "   WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW() LIMIT 1) AS current_promo_type, " +
                        "(SELECT pr.discount_value FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id " +
                        "   WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW() LIMIT 1) AS current_promo_value, " +
                        "(SELECT COUNT(*) FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 " +
                        "   AND v.stock_quantity > 0 AND v.stock_quantity < ?) AS low_stock_variant_count, " +
                        "(SELECT GROUP_CONCAT(CONCAT(v.variant_name, ' còn ', v.stock_quantity) ORDER BY v.stock_quantity ASC SEPARATOR ', ') " +
                        "   FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 " +
                        "   AND v.stock_quantity > 0 AND v.stock_quantity < ?) AS low_stock_variant_summary " +
                        ", (SELECT GROUP_CONCAT(CONCAT(v.variant_name, '|', v.price, '|', v.stock_quantity) " +
                        "   ORDER BY v.stock_quantity ASC SEPARATOR ';;') " +
                        "   FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1) AS variant_inventory_summary " +
                        VARIANT_SUMMARY_SELECT +
                        "FROM products p " +
                        "LEFT JOIN categories c ON c.id = p.category_id " +
                        "WHERE 1=1 "
        );
        params.add(reorderThreshold);
        params.add(reorderThreshold);

        appendAdminProductFilters(sql, params, categoryIds, promotionId, promotionStatus, stockFilter,
                minPrice, maxPrice, search, keywords, status, reorderThreshold, lowStockThreshold, unsoldPeriod);
        appendAdminProductSort(sql, params, sort, search, keywords);
        sql.append(" LIMIT ? OFFSET ?");
        params.add(size);
        params.add((index - 1) * size);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            setParams(ps, params);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setShortDescription(rs.getString("short_description"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setSku(rs.getString("sku"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                mapVariantSummary(p, rs);
                p.setCategoryId(rs.getInt("category_id"));
                p.setImageUrl(rs.getString("image_url"));
                p.setBestseller(rs.getBoolean("is_bestseller"));

                int currentPromoId = rs.getInt("current_promo_id");
                if (!rs.wasNull()) {
                    p.setCurrentPromotionId(currentPromoId);
                }
                p.setCurrentPromotionType(rs.getString("current_promo_type"));

                double promoValue = rs.getDouble("current_promo_value");
                if (!rs.wasNull()) {
                    p.setCurrentPromotionValue(promoValue);
                }

                p.setLowStockVariantCount(rs.getInt("low_stock_variant_count"));
                p.setLowStockVariantSummary(rs.getString("low_stock_variant_summary"));
                p.setVariantInventorySummary(rs.getString("variant_inventory_summary"));

                String statusStr = rs.getString("status");
                if (statusStr != null) {
                    try {
                        p.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        p.setStatus(ProductStatus.ACTIVE);
                    }
                }
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAdminProducts(List<Integer> categoryIds, Integer promotionId, String promotionStatus,
                                  String stockFilter, Double minPrice, Double maxPrice, String search,
                                  String status, int reorderThreshold, int lowStockThreshold) {
        return countAdminProducts(categoryIds, promotionId, promotionStatus, stockFilter, minPrice, maxPrice, search,
                status, reorderThreshold, lowStockThreshold, "all");
    }

    public int countAdminProducts(List<Integer> categoryIds, Integer promotionId, String promotionStatus,
                                  String stockFilter, Double minPrice, Double maxPrice, String search,
                                  String status, int reorderThreshold, int lowStockThreshold, String unsoldPeriod) {
        List<Object> params = new ArrayList<>();
        List<String> keywords = splitSearchKeywords(search);
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(DISTINCT p.id) FROM products p " +
                        "LEFT JOIN categories c ON c.id = p.category_id " +
                        "WHERE 1=1 "
        );

        appendAdminProductFilters(sql, params, categoryIds, promotionId, promotionStatus, stockFilter,
                minPrice, maxPrice, search, keywords, status, reorderThreshold, lowStockThreshold, unsoldPeriod);

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            setParams(ps, params);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public double[] getActiveProductPriceRange() {
        return getProductPriceRange(null, null, null, "active");
    }

    public double[] getProductPriceRange(List<Integer> categoryIds, Integer promotionId, String search, String status) {
        return getProductPriceRange(categoryIds, promotionId, false, search, status);
    }

    public double[] getProductPriceRange(List<Integer> categoryIds, Integer promotionId, boolean promotionOnly, String search, String status) {
        List<String> keywords = new ArrayList<>();
        if (search != null && !search.isBlank()) {
            for (String keyword : search.trim().toLowerCase().split("\\s+")) {
                if (!keyword.isBlank()) {
                    keywords.add(keyword);
                }
            }
        }

        StringBuilder sql = new StringBuilder(
                "SELECT " +
                        "MIN(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) AS min_price, " +
                        "MAX(CASE WHEN v.sale_price > 0 AND v.sale_price < v.price THEN v.sale_price ELSE v.price END) AS max_price " +
                        "FROM products p "
        );
        sql.append(" JOIN product_variants v ON v.product_id = p.id AND v.is_active = 1 ");

        if (promotionId != null) {
            sql.append(" JOIN promotion_items pi ON p.id = pi.product_id ");
        }

        sql.append(" WHERE 1=1 ");

        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND p.category_id IN (");
            appendPlaceholders(sql, categoryIds.size());
            sql.append(") ");
        }

        if (promotionId != null) {
            sql.append(" AND pi.promotion_id = ? ");
        } else if (promotionOnly) {
            sql.append(" AND p.id IN (");
            sql.append("SELECT pi.product_id FROM promotion_items pi ");
            sql.append("JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()");
            sql.append(") ");
        }

        if (!keywords.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" OR ");
                }
                sql.append("LOWER(p.name) LIKE ? ");
            }
            sql.append(") ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) {
                sql.append(" AND p.status = 'active' ");
            } else if ("inactive".equals(status)) {
                sql.append(" AND p.status = 'inactive' ");
            } else if ("out-of-stock".equals(status)) {
                sql.append(" AND p.stock_quantity = 0 ");
            }
        }

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            if (categoryIds != null && !categoryIds.isEmpty()) {
                for (Integer categoryId : categoryIds) {
                    ps.setInt(paramIndex++, categoryId);
                }
            }

            if (promotionId != null) {
                ps.setInt(paramIndex++, promotionId);
            }

            for (String keyword : keywords) {
                ps.setString(paramIndex++, "%" + keyword + "%");
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                double min = rs.getDouble("min_price");
                if (rs.wasNull()) min = 0;

                double max = rs.getDouble("max_price");
                if (rs.wasNull()) max = 0;

                return new double[]{min, max};
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new double[]{0, 0};
    }

    private List<Integer> toCategoryList(Integer categoryId) {
        if (categoryId == null) {
            return null;
        }
        return Collections.singletonList(categoryId);
    }

    private void appendPlaceholders(StringBuilder sql, int count) {
        for (int i = 0; i < count; i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
        }
    }

    private void appendAdminProductFilters(StringBuilder sql, List<Object> params, List<Integer> categoryIds,
                                           Integer promotionId, String promotionStatus, String stockFilter,
                                           Double minPrice, Double maxPrice, String search, List<String> keywords, String status,
                                           int reorderThreshold, int lowStockThreshold) {
        appendAdminProductFilters(sql, params, categoryIds, promotionId, promotionStatus, stockFilter,
                minPrice, maxPrice, search, keywords, status, reorderThreshold, lowStockThreshold, "all");
    }

    private void appendAdminProductFilters(StringBuilder sql, List<Object> params, List<Integer> categoryIds,
                                           Integer promotionId, String promotionStatus, String stockFilter,
                                           Double minPrice, Double maxPrice, String search, List<String> keywords, String status,
                                           int reorderThreshold, int lowStockThreshold, String unsoldPeriod) {
        if (categoryIds != null && !categoryIds.isEmpty()) {
            sql.append(" AND p.category_id IN (");
            appendPlaceholders(sql, categoryIds.size());
            sql.append(") ");
            params.addAll(categoryIds);
        }

        if (minPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" >= ?) ");
            params.add(minPrice);
        }

        if (maxPrice != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 ");
            sql.append("AND ").append(VARIANT_EFFECTIVE_PRICE).append(" <= ?) ");
            params.add(maxPrice);
        }

        if (promotionId != null) {
            sql.append(" AND EXISTS (SELECT 1 FROM promotion_items pi WHERE pi.product_id = p.id AND pi.promotion_id = ?) ");
            params.add(promotionId);
        } else if ("active".equals(promotionStatus)) {
            sql.append(" AND EXISTS (SELECT 1 FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()) ");
        } else if ("discounted".equals(promotionStatus)) {
            sql.append(" AND (p.sale_price > 0 ");
            sql.append("OR EXISTS (SELECT 1 FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()) ");
            sql.append("OR EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id AND v.is_active = 1 AND v.sale_price > 0)) ");
        } else if ("none".equals(promotionStatus)) {
            sql.append(" AND NOT EXISTS (SELECT 1 FROM promotion_items pi JOIN promotions pr ON pr.id = pi.promotion_id ");
            sql.append("WHERE pi.product_id = p.id AND pr.is_active = 1 AND pr.start_date <= NOW() AND pr.end_date >= NOW()) ");
        }

        if (!keywords.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" OR ");
                }
                sql.append("LOWER(p.name) LIKE ? OR LOWER(IFNULL(p.slug, '')) LIKE ? ");
                sql.append("OR LOWER(IFNULL(p.sku, '')) LIKE ? OR LOWER(IFNULL(c.name, '')) LIKE ? ");
                sql.append("OR EXISTS (SELECT 1 FROM product_variants v WHERE v.product_id = p.id ");
                sql.append("AND (LOWER(IFNULL(v.sku, '')) LIKE ? OR LOWER(IFNULL(v.variant_name, '')) LIKE ?)) ");

                String keywordLike = "%" + keywords.get(i) + "%";
                for (int j = 0; j < 6; j++) {
                    params.add(keywordLike);
                }
            }
            sql.append(") ");
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equals(status)) {
                sql.append(" AND p.status = 'active' ");
            } else if ("inactive".equals(status)) {
                sql.append(" AND p.status = 'inactive' ");
            } else if ("out-of-stock".equals(status)) {
                sql.append(" AND (p.status = 'out_of_stock' OR ").append(TOTAL_VARIANT_STOCK).append(" = 0) ");
            }
        }

        if ("in-stock".equals(stockFilter)) {
            sql.append(" AND ").append(TOTAL_VARIANT_STOCK).append(" > 0 ");
        } else if ("need-reorder".equals(stockFilter)) {
            sql.append(" AND (").append(TOTAL_VARIANT_STOCK).append(" > 0 AND ");
            sql.append(TOTAL_VARIANT_STOCK).append(" < ?) ");
            params.add(reorderThreshold);
        } else if ("low-stock".equals(stockFilter)) {
            sql.append(" AND (").append(TOTAL_VARIANT_STOCK).append(" >= ? AND ");
            sql.append(TOTAL_VARIANT_STOCK).append(" <= ?) ");
            params.add(reorderThreshold);
            params.add(lowStockThreshold);
        } else if ("out-of-stock".equals(stockFilter)) {
            sql.append(" AND ").append(TOTAL_VARIANT_STOCK).append(" = 0 ");
        } else if ("unsold".equals(stockFilter)) {
            sql.append(" AND NOT EXISTS (");
            sql.append("SELECT 1 FROM order_items oi JOIN orders o ON o.id = oi.order_id ");
            sql.append("WHERE oi.product_id = p.id AND o.status = 'COMPLETED'");
            appendUnsoldPeriodCondition(sql, unsoldPeriod);
            sql.append(") ");
        }
    }

    private void appendUnsoldPeriodCondition(StringBuilder sql, String period) {
        if ("day".equals(period)) {
            sql.append(" AND o.created_at >= CURDATE()");
        } else if ("week".equals(period)) {
            sql.append(" AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");
        } else if ("month".equals(period)) {
            sql.append(" AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)");
        } else if ("six-months".equals(period)) {
            sql.append(" AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)");
        } else if ("year".equals(period)) {
            sql.append(" AND o.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)");
        }
    }

    private void appendAdminProductSort(StringBuilder sql, List<Object> params, String sort, String search, List<String> keywords) {
        sql.append(" ORDER BY ");

        if (!keywords.isEmpty()) {
            String phrase = search != null ? search.trim().toLowerCase() : "";
            String phraseLike = "%" + phrase + "%";
            String phraseStart = phrase + "%";

            sql.append("CASE WHEN LOWER(p.name) = ? THEN 10000 ELSE 0 END DESC, ");
            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 9000 ELSE 0 END DESC, ");
            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 8000 ELSE 0 END DESC, ");

            sql.append("CASE WHEN ");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" AND ");
                }
                sql.append("LOWER(p.name) LIKE ? ");
            }
            sql.append("THEN 7000 ELSE 0 END DESC, ");

            sql.append("(");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" + ");
                }
                sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END ");
            }
            sql.append(") DESC, ");

            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END DESC, ");
            sql.append("CHAR_LENGTH(p.name) ASC, ");

            params.add(phrase);
            params.add(phraseStart);
            params.add(phraseLike);
            for (String keyword : keywords) {
                params.add("%" + keyword + "%");
            }
            for (String keyword : keywords) {
                params.add("%" + keyword + "%");
            }
            params.add("%" + keywords.get(0) + "%");
        }

        if ("oldest".equals(sort)) {
            sql.append("p.created_at ASC ");
        } else if ("price-asc".equals(sort)) {
            sql.append(MIN_VARIANT_EFFECTIVE_PRICE).append(" ASC ");
        } else if ("price-desc".equals(sort)) {
            sql.append(MIN_VARIANT_EFFECTIVE_PRICE).append(" DESC ");
        } else if ("stock-asc".equals(sort)) {
            sql.append(TOTAL_VARIANT_STOCK).append(" ASC ");
        } else if ("name-asc".equals(sort)) {
            sql.append("p.name ASC ");
        } else {
            sql.append("p.created_at DESC ");
        }
    }

    private void setParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else if (value instanceof Double) {
                ps.setDouble(i + 1, (Double) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }

    public Product getProductById(int id) {
        String sql = "SELECT p.*, " +
                "pi.promotion_id AS current_promo_id, " +
                "pr.discount_type AS current_promo_type, " +
                "pr.discount_value AS current_promo_value " +
                VARIANT_SUMMARY_SELECT +
                "FROM products p " +
                "LEFT JOIN promotion_items pi ON p.id = pi.product_id " +
                "LEFT JOIN promotions pr ON pr.id = pi.promotion_id " +
                "WHERE p.id = ? " +
                "LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setSlug(rs.getString("slug"));
                p.setDescription(rs.getString("description"));
                p.setShortDescription(rs.getString("short_description"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                p.setSku(rs.getString("sku"));
                p.setStockQuantity(rs.getInt("stock_quantity"));
                mapVariantSummary(p, rs);
                p.setCategoryId(rs.getInt("category_id"));
                p.setImageUrl(rs.getString("image_url"));
                p.setBestseller(rs.getBoolean("is_bestseller"));
                int currentPromoId = rs.getInt("current_promo_id");
                if (!rs.wasNull()) {
                    p.setCurrentPromotionId(currentPromoId);
                }

                p.setCurrentPromotionType(rs.getString("current_promo_type"));

                double currentPromoValue = rs.getDouble("current_promo_value");
                if (!rs.wasNull()) {
                    p.setCurrentPromotionValue(currentPromoValue);
                }
                String statusStr = rs.getString("status");
                if (statusStr != null) {
                    try {
                        p.setStatus(ProductStatus.valueOf(statusStr.toUpperCase()));
                    } catch (IllegalArgumentException e) {
                        p.setStatus(ProductStatus.ACTIVE);
                    }
                }

                p.setIngredients(rs.getString("ingredients"));
                p.setUsageInstructions(rs.getString("usage_instructions"));

                if (rs.getTimestamp("created_at") != null) {
                    p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                }
                return p;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Product> getRelatedProducts(int categoryId, int currentProductId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.* " + VARIANT_SUMMARY_SELECT +
                "FROM products p WHERE p.category_id = ? AND p.id != ? AND p.status = 'active' ORDER BY RAND() LIMIT 4";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            ps.setInt(2, currentProductId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                mapVariantSummary(p, rs);
                p.setImageUrl(rs.getString("image_url"));
                p.setSlug(rs.getString("slug"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int insertProduct(Product p) {
        String sql = "INSERT INTO products (name, slug, description, short_description, price, sale_price, " +
                "sku, stock_quantity, category_id, image_url, is_bestseller, status, " +
                "ingredients, usage_instructions, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getSlug());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getShortDescription());
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getSalePrice());
            ps.setString(7, p.getSku());
            ps.setInt(8, p.getStockQuantity());

            if (p.getCategoryId() != null) ps.setInt(9, p.getCategoryId());
            else ps.setNull(9, java.sql.Types.INTEGER);

            ps.setString(10, p.getImageUrl());
            ps.setBoolean(11, p.isBestseller());
            ps.setString(12, p.getStatus() != null ? p.getStatus().name().toLowerCase() : "active");
            ps.setString(13, p.getIngredients());
            ps.setString(14, p.getUsageInstructions());
            ps.setTimestamp(15, Timestamp.valueOf(p.getCreatedAt()));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void insertProductImage(int productId, String imageUrl, String altText, int sortOrder) {
        String sql = "INSERT INTO product_images (product_id, image_url, alt_text, sort_order) VALUES (?, ?, ?, ?)";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setString(2, imageUrl);
            ps.setString(3, altText);
            ps.setInt(4, sortOrder);

            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void softDeleteProduct(int id) {
        String sql = "UPDATE products SET status = 'inactive' WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name=?, slug=?, description=?, short_description=?, price=?, sale_price=?, " +
                "sku=?, stock_quantity=?, category_id=?, is_bestseller=?, status=?, ingredients=?, usage_instructions=?, " +
                "image_url=? WHERE id=?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getName());
            ps.setString(2, p.getSlug());
            ps.setString(3, p.getDescription());
            ps.setString(4, p.getShortDescription());
            ps.setDouble(5, p.getPrice());
            ps.setDouble(6, p.getSalePrice());
            ps.setString(7, p.getSku());
            ps.setInt(8, p.getStockQuantity());

            if (p.getCategoryId() != null) ps.setInt(9, p.getCategoryId());
            else ps.setNull(9, java.sql.Types.INTEGER);

            ps.setBoolean(10, p.isBestseller());
            ps.setString(11, p.getStatus() != null ? p.getStatus().name().toLowerCase() : "active");
            ps.setString(12, p.getIngredients());
            ps.setString(13, p.getUsageInstructions());
            ps.setString(14, p.getImageUrl());
            ps.setInt(15, p.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }


    public void decreaseStock(int productId, int quantityPurchased) {
        String sql = "UPDATE products SET stock_quantity = stock_quantity - ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantityPurchased);
            ps.setInt(2, productId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

    public boolean updateProductStatus(List<Integer> productIds, String newStatus) {
        if (productIds == null || productIds.isEmpty()) return false;

        StringBuilder sql = new StringBuilder("UPDATE products SET status = ? WHERE id IN (");
        for (int i = 0; i < productIds.size(); i++) {
            sql.append(i == 0 ? "?" : ",?");
        }
        sql.append(")");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setString(1, newStatus); // 'ACTIVE' hoặc 'INACTIVE'

            // Gán các ID vào tham số
            for (int i = 0; i < productIds.size(); i++) {
                ps.setInt(i + 2, productIds.get(i));
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> getTopSellingByParentCategory(int parentId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.*, IFNULL(SUM(IF(o.status = 'completed', oi.quantity, 0)), 0) AS sold_qty "
                + VARIANT_SUMMARY_SELECT
                + "FROM products p " + "JOIN categories c ON c.id = p.category_id "
                + "LEFT JOIN order_items oi ON oi.product_id = p.id "
                + "LEFT JOIN orders o ON o.id = oi.order_id "
                + "WHERE p.status = 'active' AND c.parent_id = ? "
                + "GROUP BY p.id "
                + "ORDER BY sold_qty DESC, p.created_at DESC " + "LIMIT ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, parentId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setSlug(rs.getString("slug"));
                    p.setPrice(rs.getDouble("price"));
                    p.setSalePrice(rs.getDouble("sale_price"));
                    p.setSku(rs.getString("sku"));
                    p.setStockQuantity(rs.getInt("stock_quantity"));
                    mapVariantSummary(p, rs);
                    int catId = rs.getInt("category_id");
                    p.setCategoryId(rs.wasNull() ? null : catId);
                    p.setImageUrl(rs.getString("image_url"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Product> getBestSellerProducts(int categoryId, int limit) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.* " + VARIANT_SUMMARY_SELECT +
                "FROM products p WHERE p.category_id = ? AND p.is_bestseller = 1 AND p.status = 'ACTIVE' LIMIT ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, categoryId);
            ps.setInt(2, limit);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRowToProduct(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Product mapRowToProduct(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setId(rs.getInt("id"));
        p.setName(rs.getString("name"));
        p.setSlug(rs.getString("slug"));
        p.setDescription(rs.getString("description"));
        p.setShortDescription(rs.getString("short_description"));
        p.setPrice(rs.getDouble("price"));
        p.setSalePrice(rs.getDouble("sale_price"));
        p.setSku(rs.getString("sku"));
        p.setStockQuantity(rs.getInt("stock_quantity"));
        mapVariantSummary(p, rs);
        p.setCategoryId(rs.getInt("category_id"));

        String img = rs.getString("image_url");
        p.setImageUrl(img != null ? img : "");

        p.setBestseller(rs.getBoolean("is_bestseller"));

        try {
            String statusStr = rs.getString("status");
            if (statusStr != null) {
                p.setStatus(ProductStatus.valueOf(statusStr));
            } else {
                p.setStatus(ProductStatus.ACTIVE);
            }
        } catch (IllegalArgumentException e) {
            p.setStatus(ProductStatus.ACTIVE);
        }

        p.setIngredients(rs.getString("ingredients"));
        p.setUsageInstructions(rs.getString("usage_instructions"));

        if (rs.getTimestamp("created_at") != null) {
            p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return p;
    }

    private void mapVariantSummary(Product p, ResultSet rs) throws SQLException {
        if (!hasColumn(rs, "variant_total_stock")) {
            return;
        }

        p.setTotalStockQuantity(rs.getInt("variant_total_stock"));
        p.setVariantCount(rs.getInt("variant_count"));

        double minVariantPrice = rs.getDouble("min_variant_price");
        p.setMinVariantPrice(rs.wasNull() ? 0 : minVariantPrice);

        double maxVariantPrice = rs.getDouble("max_variant_price");
        p.setMaxVariantPrice(rs.wasNull() ? 0 : maxVariantPrice);

        double minEffectivePrice = rs.getDouble("min_variant_effective_price");
        p.setMinVariantEffectivePrice(rs.wasNull() ? 0 : minEffectivePrice);

        double maxEffectivePrice = rs.getDouble("max_variant_effective_price");
        p.setMaxVariantEffectivePrice(rs.wasNull() ? 0 : maxEffectivePrice);
    }

    private boolean hasColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        for (int i = 1; i <= metaData.getColumnCount(); i++) {
            if (columnName.equalsIgnoreCase(metaData.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }

    public void updateProductDiscounts(String type, double value, String[] ids) throws Exception {
        String productSql = "percent".equals(type)
                ? "UPDATE products SET sale_price = price * (100 - ?) / 100 WHERE id = ?"
                : "UPDATE products SET sale_price = GREATEST(0, price - ?) WHERE id = ?";

        String variantSql = "percent".equals(type)
                ? "UPDATE product_variants SET sale_price = price * (100 - ?) / 100 WHERE product_id = ?"
                : "UPDATE product_variants SET sale_price = GREATEST(0, price - ?) WHERE product_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement psProduct = conn.prepareStatement(productSql);
             PreparedStatement psVariant = conn.prepareStatement(variantSql)) {

            for (String id : ids) {
                int productId = Integer.parseInt(id.trim());

                psProduct.setDouble(1, value);
                psProduct.setInt(2, productId);
                psProduct.addBatch();

                psVariant.setDouble(1, value);
                psVariant.setInt(2, productId);
                psVariant.addBatch();
            }

            psProduct.executeBatch();
            psVariant.executeBatch();
        }
    }

    public void clearProductDiscounts(String[] ids) throws Exception {
        String productSql = "UPDATE products SET sale_price = 0 WHERE id = ?";
        String variantSql = "UPDATE product_variants SET sale_price = 0 WHERE product_id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement psProduct = conn.prepareStatement(productSql);
             PreparedStatement psVariant = conn.prepareStatement(variantSql)) {

            for (String id : ids) {
                int productId = Integer.parseInt(id.trim());

                psProduct.setInt(1, productId);
                psProduct.addBatch();

                psVariant.setInt(1, productId);
                psVariant.addBatch();
            }

            psProduct.executeBatch();
            psVariant.executeBatch();
        }
    }

    public boolean increaseStock(int productId, int quantity) {
        String sql = "UPDATE products SET stock_quantity = stock_quantity + ? WHERE id = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    private List<String> splitSearchKeywords(String search) {
        List<String> keywords = new ArrayList<>();

        if (search == null || search.trim().isEmpty()) {
            return keywords;
        }

        String[] parts = search.trim().toLowerCase().split("\\s+");
        for (String part : parts) {
            if (!part.trim().isEmpty()) {
                keywords.add(part.trim());
            }
        }

        return keywords;
    }

    private int setProductNameSearchParams(PreparedStatement ps, int paramIndex, String search, List<String> keywords) throws SQLException {
        if (search == null || search.trim().isEmpty()) {
            return paramIndex;
        }
        String phrase = "%" + search.trim().toLowerCase() + "%";
        ps.setString(paramIndex++, phrase);

        for (String keyword : keywords) {
            String kw = "%" + keyword + "%";
            ps.setString(paramIndex++, kw);
        }
        return paramIndex;
    }
    public List<Product> searchProductSuggestions(String keyword, int limit) {
        List<Product> list = new ArrayList<>();

        if (keyword == null || keyword.trim().isEmpty()) {
            return list;
        }

        List<String> keywords = new ArrayList<>();
        for (String word : keyword.trim().toLowerCase().split("\\s+")) {
            if (!word.isBlank()) {
                keywords.add(word);
            }
        }

        String phrase = keyword.trim().toLowerCase();
        String phraseLike = "%" + phrase + "%";
        String phraseStart = phrase + "%";

        StringBuilder sql = new StringBuilder(
                "SELECT p.id, p.name, p.image_url, p.price, p.sale_price " +
                        VARIANT_SUMMARY_SELECT +
                        "FROM products p " +
                        "WHERE p.status = 'active' "
        );

        if (!keywords.isEmpty()) {
            sql.append(" AND (");
            for (int i = 0; i < keywords.size(); i++) {
                if (i > 0) {
                    sql.append(" OR ");
                }
                sql.append("LOWER(p.name) LIKE ? ");
            }
            sql.append(") ");
        }

        sql.append(" ORDER BY ");
        sql.append("CASE WHEN LOWER(p.name) = ? THEN 10000 ELSE 0 END DESC, ");
        sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 9000 ELSE 0 END DESC, ");
        sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 8000 ELSE 0 END DESC, ");

        sql.append("CASE WHEN ");
        for (int i = 0; i < keywords.size(); i++) {
            if (i > 0) {
                sql.append(" AND ");
            }
            sql.append("LOWER(p.name) LIKE ? ");
        }
        sql.append("THEN 7000 ELSE 0 END DESC, ");

        sql.append("(");
        for (int i = 0; i < keywords.size(); i++) {
            if (i > 0) {
                sql.append(" + ");
            }
            sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END ");
        }
        sql.append(") DESC, ");

        sql.append("CASE WHEN LOWER(p.name) LIKE ? THEN 1 ELSE 0 END DESC, ");
        sql.append("CHAR_LENGTH(p.name) ASC, ");
        sql.append("p.created_at DESC ");
        sql.append("LIMIT ?");

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;

            for (String word : keywords) {
                ps.setString(paramIndex++, "%" + word + "%");
            }

            ps.setString(paramIndex++, phrase);
            ps.setString(paramIndex++, phraseStart);
            ps.setString(paramIndex++, phraseLike);

            for (String word : keywords) {
                ps.setString(paramIndex++, "%" + word + "%");
            }

            for (String word : keywords) {
                ps.setString(paramIndex++, "%" + word + "%");
            }

            ps.setString(paramIndex++, "%" + keywords.get(0) + "%");
            ps.setInt(paramIndex++, limit);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setImageUrl(rs.getString("image_url"));
                p.setPrice(rs.getDouble("price"));
                p.setSalePrice(rs.getDouble("sale_price"));
                mapVariantSummary(p, rs);

                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public Product getProductByName(String name) {
        String sql = "SELECT * FROM products WHERE name = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRowToProduct(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Product getProductBySku(String sku) {
        if (sku == null || sku.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT * FROM products WHERE sku = ? LIMIT 1";
        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sku.trim());
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapRowToProduct(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();

        String sql = "SELECT * FROM products WHERE status = 'active' ORDER BY created_at DESC";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public void updateImageUrl(int productId, String imageUrl) {
        String sql = "UPDATE products SET image_url = ? WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, imageUrl);
            ps.setInt(2, productId);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public Product getProductByIdForMigration(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";

        try (Connection conn = ds.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToProduct(rs);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}
