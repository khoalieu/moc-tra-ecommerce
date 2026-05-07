SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `banners`;
CREATE TABLE `banners`  (
                            `id` int NOT NULL AUTO_INCREMENT,
                            `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                            `subtitle` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                            `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                            `button_text` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                            `button_link` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                            `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'home' COMMENT 'home, promotion, sidebar...',
                            `sort_order` int NULL DEFAULT 0,
                            `is_active` tinyint(1) NULL DEFAULT 1,
                            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
                            PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `blog_categories`;
CREATE TABLE `blog_categories`  (
                                    `id` int NOT NULL AUTO_INCREMENT,
                                    `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                                    `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                                    `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                                    `is_active` tinyint(1) NULL DEFAULT 1,
                                    PRIMARY KEY (`id`) USING BTREE,
                                    UNIQUE INDEX `slug`(`slug` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `blog_comments`;
CREATE TABLE `blog_comments`  (
                                  `id` int NOT NULL AUTO_INCREMENT,
                                  `post_id` int NOT NULL,
                                  `user_id` int NOT NULL,
                                  `comment_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                                  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                                  PRIMARY KEY (`id`) USING BTREE,
                                  INDEX `fk_cmt_post`(`post_id` ASC) USING BTREE,
                                  INDEX `fk_cmt_user`(`user_id` ASC) USING BTREE,
                                  CONSTRAINT `fk_cmt_post` FOREIGN KEY (`post_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                  CONSTRAINT `fk_cmt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `blog_posts`;
CREATE TABLE `blog_posts`  (
                               `id` int NOT NULL AUTO_INCREMENT,
                               `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                               `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                               `excerpt` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                               `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                               `featured_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                               `author_id` int NULL DEFAULT NULL,
                               `category_id` int NULL DEFAULT NULL,
                               `status` enum('draft','published','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'draft',
                               `views_count` int NULL DEFAULT 0,
                               `meta_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                               `meta_description` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                               `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                               PRIMARY KEY (`id`) USING BTREE,
                               UNIQUE INDEX `slug`(`slug` ASC) USING BTREE,
                               INDEX `fk_post_author`(`author_id` ASC) USING BTREE,
                               INDEX `fk_post_cat`(`category_id` ASC) USING BTREE,
                               CONSTRAINT `fk_post_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
                               CONSTRAINT `fk_post_cat` FOREIGN KEY (`category_id`) REFERENCES `blog_categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
                         `id` int NOT NULL AUTO_INCREMENT,
                         `user_id` int NOT NULL,
                         `product_id` int NOT NULL,
                         `quantity` int NULL DEFAULT 1,
                         `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                         `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
                         PRIMARY KEY (`id`) USING BTREE,
                         INDEX `fk_cart_user`(`user_id` ASC) USING BTREE,
                         INDEX `fk_cart_prod`(`product_id` ASC) USING BTREE,
                         CONSTRAINT `fk_cart_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                         CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
                               `id` int NOT NULL AUTO_INCREMENT,
                               `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                               `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                               `parent_id` int NULL DEFAULT NULL,
                               `is_active` tinyint(1) NULL DEFAULT 1,
                               PRIMARY KEY (`id`) USING BTREE,
                               UNIQUE INDEX `slug`(`slug` ASC) USING BTREE,
                               INDEX `fk_cat_parent`(`parent_id` ASC) USING BTREE,
                               CONSTRAINT `fk_cat_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
                                `id` int NOT NULL AUTO_INCREMENT,
                                `order_id` int NOT NULL,
                                `product_id` int NOT NULL,
                                `quantity` int NOT NULL,
                                `price` decimal(15, 2) NOT NULL COMMENT 'Giá tại thời điểm mua',
                                PRIMARY KEY (`id`) USING BTREE,
                                INDEX `fk_item_ord`(`order_id` ASC) USING BTREE,
                                INDEX `fk_item_prod`(`product_id` ASC) USING BTREE,
                                CONSTRAINT `fk_item_ord` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                CONSTRAINT `fk_item_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
                           `id` int NOT NULL AUTO_INCREMENT,
                           `user_id` int NOT NULL,
                           `shipping_address_id` int NULL DEFAULT NULL,
                           `order_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                           `status` enum('pending','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
                           `total_amount` decimal(15, 2) NOT NULL,
                           `shipping_fee` decimal(15, 2) NULL DEFAULT 0.00,
                           `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                           `payment_status` enum('pending','paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
                           `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                           `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                           PRIMARY KEY (`id`) USING BTREE,
                           UNIQUE INDEX `order_number`(`order_number` ASC) USING BTREE,
                           INDEX `fk_ord_user`(`user_id` ASC) USING BTREE,
                           INDEX `fk_ord_addr`(`shipping_address_id` ASC) USING BTREE,
                           CONSTRAINT `fk_ord_addr` FOREIGN KEY (`shipping_address_id`) REFERENCES `user_addresses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
                           CONSTRAINT `fk_ord_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `product_images`;
CREATE TABLE `product_images`  (
                                   `id` int NOT NULL AUTO_INCREMENT,
                                   `product_id` int NOT NULL,
                                   `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                                   `alt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `sort_order` int NULL DEFAULT 0,
                                   `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                                   PRIMARY KEY (`id`) USING BTREE,
                                   INDEX `fk_img_prod`(`product_id` ASC) USING BTREE,
                                   CONSTRAINT `fk_img_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `product_reviews`;
CREATE TABLE `product_reviews`  (
                                    `id` int NOT NULL AUTO_INCREMENT,
                                    `product_id` int NOT NULL,
                                    `user_id` int NOT NULL,
                                    `rating` int NULL DEFAULT 5 COMMENT '1 đến 5 sao',
                                    `comment_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                                    `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                                    PRIMARY KEY (`id`) USING BTREE,
                                    INDEX `fk_rev_prod`(`product_id` ASC) USING BTREE,
                                    INDEX `fk_rev_user`(`user_id` ASC) USING BTREE,
                                    CONSTRAINT `fk_rev_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                    CONSTRAINT `fk_rev_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products`  (
                             `id` int NOT NULL AUTO_INCREMENT,
                             `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                             `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                             `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                             `short_description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                             `price` decimal(15, 2) NULL DEFAULT 0.00,
                             `sale_price` decimal(15, 2) NULL DEFAULT 0.00,
                             `sku` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                             `stock_quantity` int NULL DEFAULT 0,
                             `category_id` int NULL DEFAULT NULL,
                             `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Ảnh đại diện chính',
                             `is_bestseller` tinyint(1) NULL DEFAULT 0,
                             `status` enum('active','inactive','out_of_stock') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'active',
                             `ingredients` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                             `usage_instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                             `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                             PRIMARY KEY (`id`) USING BTREE,
                             UNIQUE INDEX `slug`(`slug` ASC) USING BTREE,
                             UNIQUE INDEX `sku`(`sku` ASC) USING BTREE,
                             INDEX `fk_prod_cat`(`category_id` ASC) USING BTREE,
                             CONSTRAINT `fk_prod_cat` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `promotion_items`;
CREATE TABLE `promotion_items`  (
                                    `id` int NOT NULL AUTO_INCREMENT,
                                    `promotion_id` int NOT NULL,
                                    `product_id` int NOT NULL,
                                    PRIMARY KEY (`id`) USING BTREE,
                                    INDEX `fk_promo_main`(`promotion_id` ASC) USING BTREE,
                                    INDEX `fk_promo_prod`(`product_id` ASC) USING BTREE,
                                    CONSTRAINT `fk_promo_main` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
                                    CONSTRAINT `fk_promo_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;


-- Table structure for promotions
DROP TABLE IF EXISTS `promotions`;
CREATE TABLE `promotions`  (
                               `id` int NOT NULL AUTO_INCREMENT,
                               `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'VD: Mừng lễ 8/3...',
                               `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
                               `start_date` datetime NULL DEFAULT NULL,
                               `end_date` datetime NULL DEFAULT NULL,
                               `discount_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PERCENT' COMMENT 'PERCENT hoặc FIXED_AMOUNT',
                               `discount_value` decimal(15, 2) NULL DEFAULT 0.00,
                               `image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                               `is_active` tinyint(1) NULL DEFAULT 1,
                               `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                               PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- Table structure for user_addresses
DROP TABLE IF EXISTS `user_addresses`;
CREATE TABLE `user_addresses`  (
                                   `id` int NOT NULL AUTO_INCREMENT,
                                   `user_id` int NOT NULL,
                                   `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Nhà riêng, Văn phòng...',
                                   `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `ward` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `street_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                                   `is_default` tinyint(1) NULL DEFAULT 0,
                                   PRIMARY KEY (`id`) USING BTREE,
                                   INDEX `fk_addr_user`(`user_id` ASC) USING BTREE,
                                   CONSTRAINT `fk_addr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- Records of user_addresses

-- Table structure for users
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
                          `id` int NOT NULL AUTO_INCREMENT,
                          `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                          `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                          `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
                          `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                          `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                          `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                          `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
                          `role` enum('admin','customer','editor') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'customer',
                          `dateOfBirth` datetime NULL DEFAULT NULL,
                          `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'other',
                          `is_active` tinyint(1) NULL DEFAULT 1,
                          `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
                          PRIMARY KEY (`id`) USING BTREE,
                          UNIQUE INDEX `username`(`username` ASC) USING BTREE,
                          UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
ALTER TABLE users ADD COLUMN is_vip TINYINT(1) DEFAULT 0;
ALTER TABLE promotions ADD COLUMN promotion_type ENUM('ALL', 'VIP') DEFAULT 'ALL';
CREATE TABLE vip_vouchers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(15, 2) NOT NULL,
    max_uses INT DEFAULT NULL,
    current_uses INT DEFAULT 0,
    start_date DATETIME,
    end_date DATETIME,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_vip_vouchers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    voucher_id INT NOT NULL,
    used_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (voucher_id) REFERENCES vip_vouchers(id) ON DELETE CASCADE
);
DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE `product_variants` (
                                    `id` int NOT NULL AUTO_INCREMENT,
                                    `product_id` int NOT NULL,
                                    `variant_name` varchar(255) NOT NULL, -- Ví dụ: "Hộp 10 gói", "Hộp 20 gói"
                                    `sku` varchar(50) UNIQUE,              -- SKU riêng cho từng phân loại
                                    `price` decimal(15, 2) NOT NULL,       -- Giá gốc của phân loại này
                                    `sale_price` decimal(15, 2) DEFAULT 0, -- Giá khuyến mãi
                                    `stock_quantity` int DEFAULT 0,        -- Số lượng tồn kho riêng
                                    `is_active` tinyint(1) DEFAULT 1,
                                    PRIMARY KEY (`id`),
                                    CONSTRAINT `fk_variant_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE = InnoDB;

ALTER TABLE `cart`
    ADD COLUMN `variant_id` int NULL AFTER `product_id`;

ALTER TABLE `cart`
    ADD CONSTRAINT `fk_cart_variant`
        FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
            ON DELETE CASCADE ON UPDATE RESTRICT;


ALTER TABLE `order_items`
    ADD COLUMN `variant_id` int NULL AFTER `product_id`;

-- 2. Tạo khóa ngoại
-- Lưu ý: Ở đây dùng ON DELETE SET NULL để nếu sau này bạn có xóa phân loại sản phẩm,
-- thì lịch sử đơn hàng cũ vẫn còn (chỉ là cột variant_id về null).
ALTER TABLE `order_items`
    ADD CONSTRAINT `fk_item_variant`
        FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
            ON DELETE SET NULL ON UPDATE RESTRICT;

TRUNCATE TABLE `cart`;

-- thêm giá gốc và giá khuyến mãi để lưu lại lịch sử đơn hhangfkhi xóa khuyến mãi
ALTER TABLE order_items
    ADD COLUMN original_price DECIMAL(15,2) DEFAULT 0 AFTER price,
    ADD COLUMN discount_amount DECIMAL(15,2) DEFAULT 0 AFTER original_price;

-- thay đôi phần thanh toán khi tích hợp API
ALTER TABLE orders
    MODIFY payment_status ENUM(
    'pending',
    'paid',
    'failed',
    'expired',
    'refunded'
    ) DEFAULT 'pending';

CREATE TABLE payment_transactions (
                                      id INT AUTO_INCREMENT PRIMARY KEY,
                                      order_id INT NOT NULL,
                                      payment_method VARCHAR(50) NOT NULL,
                                      provider VARCHAR(50) NOT NULL,
                                      request_id VARCHAR(100),
                                      provider_order_id VARCHAR(100),
                                      amount DECIMAL(15,2) NOT NULL,
                                      qr_code_url TEXT,
                                      pay_url TEXT,
                                      deeplink TEXT,
                                      transaction_status VARCHAR(50) DEFAULT 'pending',
                                      raw_response TEXT,
                                      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                      paid_at DATETIME NULL,
                                      FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

