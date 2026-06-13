/*
 Navicat Premium Dump SQL

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 100432 (10.4.32-MariaDB)
 Source Host           : 127.0.0.1:3306
 Source Schema         : moctra_db

 Target Server Type    : MySQL
 Target Server Version : 100432 (10.4.32-MariaDB)
 File Encoding         : 65001

 Date: 13/06/2026 11:30:33
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for audit_logs
-- ----------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `target_id` int NOT NULL,
  `field_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `old_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `new_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of audit_logs
-- ----------------------------

-- ----------------------------
-- Table structure for banners
-- ----------------------------
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
  `start_time` datetime NULL DEFAULT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of banners
-- ----------------------------
INSERT INTO `banners` VALUES (1, 'TRÀ ĐẬM VỊ, TẾT NHƯ Ý', 'GIẢM GIÁ CÁC MẶT HÀNG', 'assets/images/banners/1774787216879_314433373.jpg', 'XEM NGAY', 'san-pham?category=1', 'home', 1, 0, NULL, NULL, '2026-01-28 19:57:20', '2026-06-06 10:06:24');
INSERT INTO `banners` VALUES (2, 'Mộc Trà Thanh Mát', 'Giá sốc, giảm sâu', 'assets/images/banners/1774787169258_48500661.jpg', '', '', 'home', NULL, 1, NULL, NULL, '2026-03-29 19:26:09', '2026-03-29 19:26:09');

-- ----------------------------
-- Table structure for blog_categories
-- ----------------------------
DROP TABLE IF EXISTS `blog_categories`;
CREATE TABLE `blog_categories`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `is_active` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `slug`(`slug` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blog_categories
-- ----------------------------
INSERT INTO `blog_categories` VALUES (1, 'Kiến thức trà', 'kien_thuc_tra', 'Chia sẻ kiến thức về trà, cách chọn trà, bảo quản và thưởng thức.', 1);
INSERT INTO `blog_categories` VALUES (2, 'Công thức pha chế', 'cong_thuc_pha_che', 'Các công thức pha trà, trà sữa, topping và biến tấu tại nhà.', 1);
INSERT INTO `blog_categories` VALUES (3, 'Tin tức & ưu đãi', 'tin_tuc_uu_dai', 'Tin tức cửa hàng, chương trình khuyến mãi, sự kiện theo mùa.', 1);

-- ----------------------------
-- Table structure for blog_comments
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blog_comments
-- ----------------------------
INSERT INTO `blog_comments` VALUES (1, 3, 57, 'hihi', '2026-01-29 07:02:51');

-- ----------------------------
-- Table structure for blog_posts
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of blog_posts
-- ----------------------------
INSERT INTO `blog_posts` VALUES (1, 'Cách phân biệt trà ô long chất lượng chỉ trong 3 phút', 'cach_phan_biet_tra_o_long_chat_luong_chi_trong_3_phut', 'Một vài dấu hiệu đơn giản giúp bạn nhận biết ô long ngon: mùi hương, màu nước, hậu vị và độ bền nước.', 'Ô long ngon thường có mùi hương rõ nhưng không gắt, lớp hương bền và sạch. Khi pha, màu nước trong, không đục, vị đầu êm và hậu ngọt kéo dài. Bạn có thể quan sát lá trà sau khi nở: lá đều, ít vụn, không có mùi lạ. Nếu trà cho nhiều nước (pha 4–6 lần vẫn còn vị) thì chất lượng thường ổn hơn. Ngoài ra, bảo quản cũng quan trọng: nên để kín, tránh ẩm, tránh nắng và mùi mạnh trong bếp. Khi mua trà, hãy ưu tiên nơi có nguồn gốc rõ ràng và thử pha mẫu để cảm nhận độ sạch của hương.', 'assets/images/o_long_chat_luong.png', 15, 1, 'published', 0, 'Cách phân biệt trà ô long chất lượng', 'Hướng dẫn nhận biết ô long ngon qua mùi hương, màu nước, hậu vị và độ bền nước khi pha.', '2025-12-05 10:15:00');
INSERT INTO `blog_posts` VALUES (2, '5 sai lầm khi bảo quản trà khiến trà nhanh mất hương', '5_sai_lam_khi_bao_quan_tra_khien_tra_nhanh_mat_huong', 'Bảo quản sai cách làm trà bay hương, hút ẩm và biến vị. Dưới đây là 5 lỗi phổ biến và cách khắc phục.', 'Trà rất dễ hút ẩm và hút mùi. Sai lầm thường gặp là để trà trong hũ không kín, đặt gần gia vị hoặc khu vực có mùi mạnh. Một lỗi khác là mở hũ nhiều lần và để lâu ngoài không khí, khiến trà oxy hóa nhanh. Bạn nên dùng hũ kín, ưu tiên thủy tinh tối màu hoặc túi zip có van, để nơi khô ráo và mát. Nếu mua nhiều, hãy chia nhỏ theo từng lần dùng để giảm số lần mở nắp và giữ hương tốt hơn. Tránh để trà cạnh bếp nấu và hạn chế dùng muỗng ướt khi lấy trà.', 'assets/images/bao_quan_tra_mat_huong.png', 16, 1, 'published', 42, '5 sai lầm bảo quản trà', 'Các lỗi bảo quản khiến trà mất hương và cách xử lý để trà giữ mùi vị lâu hơn.', '2025-12-12 19:40:00');
INSERT INTO `blog_posts` VALUES (3, 'Thưởng trà đúng cách: nhiệt độ nước và thời gian ủ cho từng loại trà', 'thuong_tra_dung_cach_nhiet_do_nuoc_va_thoi_gian_u_cho_tung_loai_tra', 'Nhiệt độ và thời gian ủ quyết định 70% chất lượng ly trà. Mỗi loại trà có “ngưỡng đẹp” riêng.', 'Với trà xanh, nhiệt độ nước thường phù hợp khoảng 75–85°C để tránh chát gắt; thời gian ủ ngắn 30–60 giây cho nước đầu. Trà ô long có thể dùng nước nóng hơn (85–95°C) và ủ 20–40 giây cho những lần đầu, tăng dần theo số nước. Trà đen thường “chịu nhiệt” tốt hơn, có thể 90–100°C và ủ 2–4 phút tùy khẩu vị. Bạn nên thử điều chỉnh theo loại trà cụ thể và cảm nhận hậu vị để chốt công thức pha phù hợp. Nếu dùng ấm nhỏ, tăng số lần rót để giữ vị ổn định.', 'assets/images/nhiet_do_thoi_gian_u_tra.png', 17, 1, 'published', 11, 'Nhiệt độ nước và thời gian ủ trà', 'Hướng dẫn nhiệt độ nước và thời gian ủ tối ưu cho trà xanh, ô long và trà đen để tránh đắng chát.', '2026-01-08 09:20:00');
INSERT INTO `blog_posts` VALUES (4, 'Công thức trà sữa ô long chuẩn vị, ít ngọt nhưng thơm béo', 'cong_thuc_tra_sua_o_long_chuan_vi_it_ngot_nhung_thom_beo', 'Trà sữa ô long cân bằng giữa hương trà và độ béo của sữa. Công thức này dễ làm tại nhà.', 'Để trà sữa ô long thơm nhưng không bị chát, hãy pha trà ở 90°C, ủ 30–45 giây cho nước đầu, sau đó lọc ngay. Dùng sữa tươi và một ít kem béo để tạo độ mượt, thêm syrup đường nâu theo mức ngọt mong muốn. Nếu thích vị “đậm trà”, có thể tăng lượng trà nhưng giảm thời gian ủ. Khi lắc với đá, bạn sẽ có lớp bọt mịn và mùi hương bùng lên rõ rệt. Có thể thêm chút muối biển để vị béo nổi bật hơn.', 'assets/images/tra_sua_o_long_it_ngot.png', 18, 2, 'published', 92, 'Công thức trà sữa ô long ít ngọt', 'Cách làm trà sữa ô long tại nhà: thơm hương trà, béo mượt, ít ngọt và không bị chát.', '2025-12-18 14:05:00');
INSERT INTO `blog_posts` VALUES (5, 'Pha trà đào cam sả tại nhà: thơm mát, dễ uống', 'pha_tra_dao_cam_sa_tai_nha_thom_mat_de_uong', 'Trà đào cam sả có vị chua ngọt nhẹ, mùi sả thoang thoảng, phù hợp ngày nóng.', 'Bạn chuẩn bị trà đen hoặc ô long, đào ngâm, cam tươi và sả đập dập. Pha trà đậm hơn bình thường một chút để khi thêm đá không bị nhạt. Đun sả cùng một ít nước đường để lấy hương, sau đó hòa với trà, thêm nước cam vắt và miếng đào. Chỉnh lại vị bằng đường hoặc mật ong. Khi uống, mùi sả và cam nổi rõ, hậu trà nhẹ, rất dễ “ghiền”. Nếu muốn thanh hơn, giảm syrup và tăng cam tươi.', 'assets/images/tra_dao_cam_sa.png', 19, 2, 'published', 16, 'Trà đào cam sả tại nhà', 'Công thức trà đào cam sả: cân bằng chua ngọt, thơm sả và cam, pha nhanh tại nhà.', '2025-12-25 16:30:00');
INSERT INTO `blog_posts` VALUES (6, '3 cách làm topping trân châu mềm dai không bị cứng', '3_cach_lam_topping_tran_chau_mem_dai_khong_bi_cung', 'Trân châu ngon là mềm dai, không bở, không cứng lõi. Đây là 3 mẹo quan trọng khi nấu.', 'Đầu tiên, đun nước thật sôi rồi mới thả trân châu để không bị dính và không bị cứng lõi. Thứ hai, luộc đúng thời gian theo loại trân châu và ủ thêm trong nồi để hạt chín đều. Thứ ba, sau khi vớt ra, ngâm ngay vào nước đường (hoặc mật ong) để giữ độ mềm, tránh khô. Nếu bảo quản lâu, hãy đậy kín và dùng trong ngày để chất lượng ngon nhất. Khi thấy trân châu hơi khô, có thể hâm nhẹ với chút nước đường cho mềm lại.', 'assets/images/tran_chau_mem_dai.png', 20, 2, 'published', 31, 'Cách nấu trân châu mềm dai', 'Mẹo luộc và ủ trân châu để mềm dai, không cứng lõi, giữ ngon lâu với nước đường.', '2026-01-03 11:10:00');
INSERT INTO `blog_posts` VALUES (7, 'Matcha latte kiểu dễ: giữ mùi matcha, không bị tanh', 'matcha_latte_kieu_de_giu_mui_matcha_khong_bi_tanh', 'Matcha latte ngon phụ thuộc vào bước đánh tan matcha và tỷ lệ sữa phù hợp.', 'Để matcha không bị vón và không tanh, bạn rây bột matcha trước khi pha. Dùng nước nóng khoảng 70–80°C, đánh matcha bằng chổi hoặc whisk đến khi bọt mịn. Sau đó thêm sữa tươi lạnh hoặc sữa nóng tùy thích. Có thể thêm một chút syrup vani hoặc đường để làm tròn vị. Nếu muốn “đậm matcha”, tăng bột nhưng giữ nhiệt độ nước vừa phải để mùi thơm lên rõ. Với phiên bản đá, nên dùng sữa lạnh và matcha đậm để không bị nhạt.', 'assets/images/matcha_latte_khong_tanh.png', 21, 2, 'published', 67, 'Matcha latte không tanh', 'Cách pha matcha latte tại nhà: rây bột, đánh bọt đúng nhiệt độ để thơm và không bị tanh.', '2026-01-10 20:45:00');
INSERT INTO `blog_posts` VALUES (8, 'Trà gừng mật ong ấm bụng: pha thế nào để không bị hăng', 'tra_gung_mat_ong_am_bung_pha_the_nao_de_khong_bi_hang', 'Gừng tốt nhưng dễ hăng. Pha đúng cách sẽ ấm bụng, thơm dịu và dễ uống hơn.', 'Bạn có thể nướng sơ hoặc đập dập gừng rồi hãm với nước nóng 90–95°C khoảng 5–7 phút để mùi thơm dịu hơn. Khi nước gừng bớt nóng (dưới khoảng 60°C) mới cho mật ong để giữ hương. Nếu thích vị trà, thêm một ít trà đen/ô long đã pha sẵn để tạo nền. Điều chỉnh lượng gừng theo khẩu vị để tránh cay nồng quá mức. Có thể thêm lát chanh mỏng để vị sáng hơn nhưng nhớ cho khi nước nguội bớt.', 'assets/images/tra_gung_mat_ong.png', 22, 2, 'published', 14, 'Trà gừng mật ong không hăng', 'Hướng dẫn pha trà gừng mật ong ấm bụng, thơm dịu, tránh bị hăng và cay nồng quá mức.', '2025-12-28 08:55:00');
INSERT INTO `blog_posts` VALUES (9, 'Lịch hoạt động tháng 12: combo quà tặng và ưu đãi cuối năm', 'lich_hoat_dong_thang_12_combo_qua_tang_va_uu_dai_cuoi_nam', 'Tổng hợp ưu đãi, combo quà tặng và khung giờ flash sale trong tháng 12.', 'Trong tháng 12, cửa hàng tập trung các combo quà tặng cho mùa lễ hội: set trà, hũ thủy tinh và gói topping. Mỗi tuần sẽ có khung giờ ưu đãi theo danh mục: trà ô long, trà thảo mộc và nguyên liệu DIY. Bạn nên theo dõi lịch đăng trên website để săn deal đúng thời điểm. Ngoài ra, một số sản phẩm giới hạn số lượng sẽ mở bán theo đợt để đảm bảo chất lượng mới. Nếu bạn mua làm quà, hãy đặt sớm để kịp đóng gói và giao hàng.', 'assets/images/uu_dai_thang_12.png', 23, 3, 'published', 97, 'Ưu đãi tháng 12 và combo quà tặng', 'Lịch ưu đãi tháng 12: combo quà tặng, flash sale theo tuần và các sản phẩm mở bán giới hạn.', '2025-12-02 12:00:00');
INSERT INTO `blog_posts` VALUES (10, 'Chương trình đầu năm 2026: mua 2 tặng 1 cho nhóm trà thảo mộc', 'chuong_trinh_dau_nam_2026_mua_2_tang_1_cho_nhom_tra_thao_moc', 'Ưu đãi đầu năm cho dòng trà thảo mộc: mua 2 tặng 1 trong thời gian giới hạn.', 'Đầu năm 2026, cửa hàng triển khai chương trình mua 2 tặng 1 áp dụng cho một số sản phẩm trà thảo mộc được chọn. Mục tiêu là giúp bạn dễ trải nghiệm nhiều hương vị mới và chọn ra set hợp nhất với nhu cầu. Bạn có thể kết hợp các vị khác nhau trong cùng nhóm ưu đãi. Khi thanh toán, hệ thống sẽ tự động áp dụng theo điều kiện, bạn chỉ cần chọn đúng sản phẩm thuộc danh sách. Chương trình có thể kết thúc sớm nếu hết số lượng quà tặng.', 'assets/images/mua_2_tang_1_2026.png', 24, 3, 'published', 15, 'Ưu đãi đầu năm 2026 mua 2 tặng 1', 'Chương trình đầu năm 2026: mua 2 tặng 1 áp dụng cho nhóm trà thảo mộc trong thời gian giới hạn.', '2026-01-15 18:25:00');
INSERT INTO `blog_posts` VALUES (11, 'Khoalieu', 'hahahaha', 'hahhhahahahhah', 'hahahahah', 'assets/images/blog/1780711299419.jpg', 70, 2, 'draft', 0, NULL, NULL, '2026-06-05 09:05:00');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int NULL DEFAULT NULL,
  `quantity` int NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_cart_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_cart_prod`(`product_id` ASC) USING BTREE,
  INDEX `fk_cart_variant`(`variant_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (14, 68, 101, 1, 6, '2026-05-28 14:11:36', '2026-06-12 13:18:41');
INSERT INTO `cart` VALUES (21, 70, 101, 1, 14, '2026-05-31 22:34:37', '2026-06-12 15:28:12');

-- ----------------------------
-- Table structure for categories
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, 'Trà Thảo Mộc', 'tra-thao-moc', NULL, 1);
INSERT INTO `categories` VALUES (2, 'Nguyên Liệu Trà Sữa', 'nguyen-lieu-tra-sua', NULL, 1);
INSERT INTO `categories` VALUES (16, 'Danh mục test', 'danh-muc-test', 2, 1);

-- ----------------------------
-- Table structure for coupons
-- ----------------------------
DROP TABLE IF EXISTS `coupons`;
CREATE TABLE `coupons`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `discount_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `discount_value` decimal(15, 2) NOT NULL,
  `max_discount_amount` decimal(15, 2) NULL DEFAULT NULL,
  `min_order_amount` decimal(15, 2) NULL DEFAULT 0.00,
  `claim_limit` int NULL DEFAULT NULL,
  `current_claims` int NULL DEFAULT 0,
  `max_uses` int NULL DEFAULT NULL,
  `current_uses` int NULL DEFAULT 0,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `is_active` tinyint(1) NULL DEFAULT 1,
  `approval_status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of coupons
-- ----------------------------

-- ----------------------------
-- Table structure for favorite_products
-- ----------------------------
DROP TABLE IF EXISTS `favorite_products`;
CREATE TABLE `favorite_products`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `product_id` int NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_product`(`user_id` ASC, `product_id` ASC) USING BTREE,
  INDEX `fk_fav_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_fav_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_fav_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorite_products
-- ----------------------------
INSERT INTO `favorite_products` VALUES (1, 70, 113, '2026-06-04 15:22:16');
INSERT INTO `favorite_products` VALUES (2, 70, 114, '2026-06-04 15:22:17');
INSERT INTO `favorite_products` VALUES (3, 68, 105, '2026-06-12 16:50:16');
INSERT INTO `favorite_products` VALUES (4, 68, 108, '2026-06-12 16:50:17');
INSERT INTO `favorite_products` VALUES (5, 68, 111, '2026-06-12 16:50:19');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NULL DEFAULT NULL,
  `recipient_role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `target_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `entity_id` int NULL DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` datetime NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_notifications_user_read_created`(`user_id` ASC, `is_read` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_notifications_role_read_created`(`recipient_role` ASC, `is_read` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_notifications_entity`(`entity_type` ASC, `entity_id` ASC) USING BTREE,
  CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `chk_notifications_recipient` CHECK (`user_id` is not null or `recipient_role` is not null)
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------
INSERT INTO `notifications` VALUES (1, NULL, 'ADMIN', 'admin_promotion_expired', 'Chương trình khuyến mãi đã hết hạn', 'Chương trình \"sale 8-3\" đã hết hạn.', 'admin/promotions?tab=promotion', 'promotion', 1, 1, '2026-06-06 10:15:10', '2026-06-06 10:15:05');
INSERT INTO `notifications` VALUES (2, 74, NULL, 'order_created', 'Đặt hàng thành công', 'Đơn hàng #ORD1780718285587 đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.', 'don-hang', 'order', 23, 1, '2026-06-06 10:58:11', '2026-06-06 10:58:05');
INSERT INTO `notifications` VALUES (3, NULL, 'ADMIN', 'admin_order_created', 'Có đơn hàng mới', 'Đơn hàng #ORD1780718285587 vừa được tạo. Admin cần kiểm tra và xử lý đơn.', 'admin/order/detail?id=23', 'order', 23, 1, '2026-06-06 11:35:53', '2026-06-06 10:58:05');
INSERT INTO `notifications` VALUES (4, 68, NULL, 'order_created', 'Đặt hàng thành công', 'Đơn hàng #ORD1781245447042 đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.', 'don-hang', 'order', 24, 1, '2026-06-12 16:50:52', '2026-06-12 13:24:07');
INSERT INTO `notifications` VALUES (5, NULL, 'ADMIN', 'admin_order_created', 'Có đơn hàng mới', 'Đơn hàng #ORD1781245447042 vừa được tạo. Admin cần kiểm tra và xử lý đơn.', 'admin/order/detail?id=24', 'order', 24, 1, '2026-06-12 13:24:39', '2026-06-12 13:24:07');
INSERT INTO `notifications` VALUES (6, 70, NULL, 'order_created', 'Đặt hàng thành công', 'Đơn hàng #ORD1781248201968 đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.', 'don-hang', 'order', 25, 0, NULL, '2026-06-12 14:10:01');
INSERT INTO `notifications` VALUES (7, NULL, 'ADMIN', 'admin_order_created', 'Có đơn hàng mới', 'Đơn hàng #ORD1781248201968 vừa được tạo. Admin cần kiểm tra và xử lý đơn.', 'admin/order/detail?id=25', 'order', 25, 0, NULL, '2026-06-12 14:10:01');
INSERT INTO `notifications` VALUES (8, 70, NULL, 'order_created', 'Đặt hàng thành công', 'Đơn hàng #ORD1781249967982 đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.', 'don-hang', 'order', 26, 0, NULL, '2026-06-12 14:39:28');
INSERT INTO `notifications` VALUES (9, NULL, 'ADMIN', 'admin_order_created', 'Có đơn hàng mới', 'Đơn hàng #ORD1781249967982 vừa được tạo. Admin cần kiểm tra và xử lý đơn.', 'admin/order/detail?id=26', 'order', 26, 0, NULL, '2026-06-12 14:39:28');
INSERT INTO `notifications` VALUES (10, 70, NULL, 'order_created', 'Đặt hàng thành công', 'Đơn hàng #ORD1781250692295 đã được tạo. Bạn có thể theo dõi trạng thái đơn trong tài khoản.', 'don-hang', 'order', 27, 1, '2026-06-12 15:48:06', '2026-06-12 14:51:32');
INSERT INTO `notifications` VALUES (11, NULL, 'ADMIN', 'admin_order_created', 'Có đơn hàng mới', 'Đơn hàng #ORD1781250692295 vừa được tạo. Admin cần kiểm tra và xử lý đơn.', 'admin/order/detail?id=27', 'order', 27, 0, NULL, '2026-06-12 14:51:32');
INSERT INTO `notifications` VALUES (12, 70, NULL, 'order_shipping', 'Đơn hàng đang được giao', 'Đơn hàng #ORD1781250692295 đang trên đường giao đến bạn.', 'don-hang', 'order', 27, 0, NULL, '2026-06-12 14:51:55');
INSERT INTO `notifications` VALUES (13, 70, NULL, 'order_completed', 'Đơn hàng đã giao thành công', 'Đơn hàng #ORD1781250692295 đã giao thành công. Cảm ơn bạn đã mua hàng.', 'don-hang', 'order', 27, 1, '2026-06-12 15:48:15', '2026-06-12 14:53:53');
INSERT INTO `notifications` VALUES (14, 68, NULL, 'order_cancelled', 'Đơn hàng đã bị hủy', 'Đơn hàng #ORD1781245447042 đã bị hủy. Bạn có thể xem chi tiết trong đơn hàng.', 'don-hang', 'order', 24, 1, '2026-06-12 16:52:07', '2026-06-12 16:51:54');

-- ----------------------------
-- Table structure for order_items
-- ----------------------------
DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int NULL DEFAULT NULL,
  `quantity` int NOT NULL,
  `price` decimal(15, 2) NOT NULL COMMENT 'Giá tại thời điểm mua',
  `original_price` decimal(15, 2) NULL DEFAULT 0.00,
  `discount_amount` decimal(15, 2) NULL DEFAULT 0.00,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_item_ord`(`order_id` ASC) USING BTREE,
  INDEX `fk_item_prod`(`product_id` ASC) USING BTREE,
  INDEX `fk_item_variant`(`variant_id` ASC) USING BTREE,
  CONSTRAINT `fk_item_ord` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_prod` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_item_variant` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of order_items
-- ----------------------------
INSERT INTO `order_items` VALUES (1, 21, 101, 1, 7, 120000.00, 120000.00, 0.00);
INSERT INTO `order_items` VALUES (2, 22, 102, 2, 2, 75000.00, 85000.00, 10000.00);
INSERT INTO `order_items` VALUES (3, 23, 101, 1, 5, 120000.00, 120000.00, 0.00);
INSERT INTO `order_items` VALUES (4, 24, 111, 11, 1, 85000.00, 85000.00, 0.00);
INSERT INTO `order_items` VALUES (5, 25, 105, 5, 2, 50000.00, 65000.00, 15000.00);
INSERT INTO `order_items` VALUES (6, 26, 114, 355, 1, 95000.00, 95000.00, 0.00);
INSERT INTO `order_items` VALUES (7, 27, 111, 11, 2, 85000.00, 85000.00, 0.00);

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `shipping_address_id` int NULL DEFAULT NULL,
  `order_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` enum('pending','processing','shipping','completed','cancelled','delivery_failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
  `subtotal_amount` decimal(15, 2) NULL DEFAULT 0.00,
  `total_amount` decimal(15, 2) NOT NULL,
  `shipping_fee` decimal(15, 2) NULL DEFAULT 0.00,
  `coupon_id` int NULL DEFAULT NULL,
  `coupon_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `coupon_discount_amount` decimal(15, 2) NULL DEFAULT 0.00,
  `vip_discount_amount` decimal(12, 2) NULL DEFAULT 0.00,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `payment_status` enum('pending','paid','failed','expired','refunded') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancel_reason` varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `is_remitted` tinyint(1) NULL DEFAULT 0,
  `shipping_provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Đơn vị vận chuyển (GHN)',
  `tracking_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Mã vận đơn GHN',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `order_number`(`order_number` ASC) USING BTREE,
  INDEX `fk_ord_user`(`user_id` ASC) USING BTREE,
  INDEX `fk_ord_addr`(`shipping_address_id` ASC) USING BTREE,
  INDEX `fk_orders_coupon`(`coupon_id` ASC) USING BTREE,
  CONSTRAINT `fk_ord_addr` FOREIGN KEY (`shipping_address_id`) REFERENCES `user_addresses` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_ord_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_orders_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of orders
-- ----------------------------
INSERT INTO `orders` VALUES (1, 68, 21, 'ORD1778149758049', 'shipping', 0.00, 340000.00, 20000.00, NULL, NULL, 0.00, 0.00, NULL, 'pending', '', '2026-05-07 17:29:18', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (2, 68, 21, 'ORD1778149787010', 'delivery_failed', 0.00, 210000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'momo', 'pending', '', '2026-05-07 17:29:47', 'Sai số điện thoại/địa chỉ', 0, NULL, NULL);
INSERT INTO `orders` VALUES (3, 68, 21, 'ORD1778208940678', 'completed', 0.00, 260000.00, 20000.00, NULL, NULL, 0.00, 0.00, NULL, 'paid', '', '2026-05-08 09:55:40', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (4, 68, 21, 'ORD1778208999144', 'completed', 0.00, 170000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'cod', 'paid', '', '2026-05-08 09:56:39', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (5, 68, 21, 'ORD1778209199838', 'shipping', 0.00, 120000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-08 09:59:59', NULL, 0, 'GHN', 'GHTK123');
INSERT INTO `orders` VALUES (6, 68, 22, 'ORD1778212646202', 'delivery_failed', 0.00, 920000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-08 10:57:26', 'Sai số điện thoại/địa chỉ', 0, 'GHN', 'GHTK123');
INSERT INTO `orders` VALUES (7, 68, 22, 'ORD1778213096071', 'delivery_failed', 0.00, 320000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'bank', 'pending', '', '2026-05-08 11:04:56', 'Sai số điện thoại/địa chỉ', 0, 'GHTK', 'GHTK123');
INSERT INTO `orders` VALUES (8, 66, 23, 'ORD1778213575183', 'completed', 0.00, 95000.00, 20000.00, NULL, NULL, 0.00, 0.00, 'cod', 'paid', '', '2026-05-08 11:12:55', NULL, 0, 'GHTK', '123');
INSERT INTO `orders` VALUES (9, 68, 21, 'ORD1778314525980', 'cancelled', 0.00, 130000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'bank', 'pending', '', '2026-05-09 15:15:25', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (10, 68, 22, 'ORD1779523909880', 'shipping', 0.00, 1230000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-23 15:11:49', NULL, 0, 'GHN', 'MOC-70DDBC73');
INSERT INTO `orders` VALUES (11, 68, 22, 'ORD1779614640254', 'cancelled', 0.00, 2230000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-24 16:24:00', 'Thời gian giao hàng quá lâu', 0, NULL, NULL);
INSERT INTO `orders` VALUES (12, 68, 22, 'ORD1779896598532', 'cancelled', 0.00, 330000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-27 22:43:18', 'Đặt nhầm sản phẩm', 0, NULL, NULL);
INSERT INTO `orders` VALUES (13, 68, 24, 'ORD1779896780721', 'pending', 0.00, 622000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-27 22:46:20', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (14, 70, 25, 'ORD1779954786508', 'pending', 0.00, 150000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-28 14:53:06', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (15, 70, 26, 'ORD1779959772483', 'shipping', 0.00, 262000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-28 16:16:12', NULL, 0, 'GHN', 'LXNTUP');
INSERT INTO `orders` VALUES (16, 70, 26, 'ORD1779960565789', 'completed', 0.00, 172000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-28 16:29:25', NULL, 0, 'GHN', 'LXNTD4');
INSERT INTO `orders` VALUES (17, 70, 28, 'ORD1780148576568', 'pending', 150000.00, 172000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-30 20:42:56', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (21, 70, 28, 'ORD1780239746246', 'pending', 840000.00, 862000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-31 22:02:26', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (22, 70, 29, 'ORD1780241579896', 'pending', 150000.00, 180000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-05-31 22:32:59', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (23, 74, 34, 'ORD1780718285587', 'pending', 600000.00, 630000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-06-06 10:58:05', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (24, 68, 22, 'ORD1781245447042', 'cancelled', 85000.00, 115000.00, 30000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-06-12 13:24:07', 'Đổi ý, không muốn mua nữa', 0, NULL, NULL);
INSERT INTO `orders` VALUES (25, 70, 35, 'ORD1781248201968', 'pending', 100000.00, 122000.00, 22000.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-06-12 14:10:01', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (26, 70, 25, 'ORD1781249967982', 'pending', 95000.00, 177500.00, 82500.00, NULL, NULL, 0.00, 0.00, 'cod', 'pending', '', '2026-06-12 14:39:27', NULL, 0, NULL, NULL);
INSERT INTO `orders` VALUES (27, 70, 36, 'ORD1781250692295', 'completed', 170000.00, 208500.00, 38500.00, NULL, NULL, 0.00, 0.00, 'cod', 'paid', '', '2026-06-12 14:51:32', NULL, 0, 'GHN', 'LXTQ67');

-- ----------------------------
-- Table structure for payment_transactions
-- ----------------------------
DROP TABLE IF EXISTS `payment_transactions`;
CREATE TABLE `payment_transactions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `payment_method` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `provider` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `request_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `provider_order_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `amount` decimal(15, 2) NOT NULL,
  `qr_code_url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `pay_url` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `deeplink` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `transaction_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending',
  `raw_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `paid_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `order_id`(`order_id` ASC) USING BTREE,
  CONSTRAINT `payment_transactions_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of payment_transactions
-- ----------------------------
INSERT INTO `payment_transactions` VALUES (1, 2, 'momo', 'momo', 'ORD1778149787010_1778149787125', 'ORD1778149787010', 210000.00, '00020101021226110007vn.momo38620010A00000072701320006970454011899MM26127O000001370208QRIBFTTA530370454062100005802VN62530515MMTUjZHCqdJ9pQR070100825Thanh toan don hang ORD1763049d63', 'https://test-payment.momo.vn/v2/gateway/pay?t=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&s=a906c19ee2b2a68df97ed945124db5283a8b3ece0ee83c3c7ece1258091c149a', 'momo://app?action=payWithApp&isScanQR=false&scanQR=false&serviceType=app&sid=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&v=3.0', 'pending', '{\"partnerCode\":\"MOMOBKUN20180529\",\"orderId\":\"ORD1778149787010\",\"requestId\":\"ORD1778149787010_1778149787125\",\"amount\":210000,\"responseTime\":1778149777820,\"message\":\"Thành công.\",\"resultCode\":0,\"payUrl\":\"https://test-payment.momo.vn/v2/gateway/pay?t=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&s=a906c19ee2b2a68df97ed945124db5283a8b3ece0ee83c3c7ece1258091c149a\",\"deeplink\":\"momo://app?action=payWithApp&isScanQR=false&scanQR=false&serviceType=app&sid=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&v=3.0\",\"qrCodeUrl\":\"00020101021226110007vn.momo38620010A00000072701320006970454011899MM26127O000001370208QRIBFTTA530370454062100005802VN62530515MMTUjZHCqdJ9pQR070100825Thanh toan don hang ORD1763049d63\",\"applink\":\"https://test-applinks.momo.vn/payment/v2?action=payWithApp&isScanQR=false&scanQR=false&serviceType=app&sid=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&v=3.0&deeplinkCallback=https%3A%2F%2Fflashing-unease-grandson.ngrok-free.dev%2Fmomo-return&callBackUrl=https%3A%2F%2Fflashing-unease-grandson.ngrok-free.dev%2Fmomo-return\",\"deeplinkMiniApp\":\"momo://app?action=payWithApp&isScanQR=false&scanQR=false&serviceType=miniapp&sid=TU9NT0JLVU4yMDE4MDUyOXxPUkQxNzc4MTQ5Nzg3MDEw&v=3.0\",\"signature\":\"272157ae95a4a0af7d2fb8e2d911dae878bfa8939e86d2163470751a7e73439b\"}', '2026-05-07 17:29:48', NULL);
INSERT INTO `payment_transactions` VALUES (2, 7, 'bank', 'payos', 'PAYOS_7_1778213098660', '7', 320000.00, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUAAAAFAAQAAAADl65gHAAACgklEQVR4Xu2ZsXHkMAxFoXGg0CVsKSpNKm1LUQkbbrAj+j8Asnn2nMaBMxDB8kw+KfgDfIA6a78M+77xvxjgZQzwMgZ4GQO8DMCXEVN7vrf7Or3mh9l6mPGXn9haG5z106bWHrH/vi8tl4mTe3UQ5SbJeZOOzrP407E5QB09zZbN3p4IeCDoMsAObI+bNmxuu9nx1sivAQLqp7lJNQk4i9/86Z9VWBIkpQzzvqFcv/iJ1QYzIqNUhZSfP718HRYGndC+J5ap/PZliwnAsjRrg040epvMGw+XSQG27UhVK4PqbbIlWpwW6YhJqQpl5WcxlgZfnlEhZ04AZ5q5qgsvKwzOnxPAfT1bP4fxdKdjYTDLj0Fgj9a/f06TA1zdw/u6czmjGEuDEQfuRFNzOVWFihB34bguyHh99/lRJuVWLh1jXPpehSVBmj3XDuouGx6q6jEsq9OxJKhQYlFwbHhibb6LuCFnddB7vkbFLVTd0sNDTn9BaRDzRjIjsZqbN+X3w8MLghCqO6rQuLtGmvGJGivvPbwmOOd9IwYB5urVr7CIO6NqabA9837KBJDF6AJqEPh3VKgJNr5ucPsQzxip8sOr9hiQOh1rgnxujSpczkEgBNx4SWhcF6T8dB3zCSBaXHi4MU2Se2tpMO8b0eyP+FJmIWcsMHXB8Gn2tAC6cixm4eilwQxvcenhDVANj5d0gpcEX5xx+8gvH5LTUlUfKv01hcGZf3UEHu4TwJqdrjh4CqiMcpC/LKow5oEB5oAU2YajI6f7+9IGGMppAoien0l3xKfY4qB+EJA0A9QR/y9mOUZWB42IumMvzBsdWfoqLAn+KgZ4GQO8jAFexgAv4+/BDwv4Kbu4AoFiAAAAAElFTkSuQmCC', 'https://pay.payos.vn/web/2e5adc35ed294bb08eb3b45fcfcf525c', NULL, 'pending', '{\"code\":\"00\",\"desc\":\"success\",\"data\":{\"bin\":\"970418\",\"accountNumber\":\"V3CAS6354086018\",\"accountName\":\"TA VAN HUY\",\"amount\":320000,\"description\":\"CSLS9UTTZ56 MOCTRA7\",\"orderCode\":7,\"currency\":\"VND\",\"paymentLinkId\":\"2e5adc35ed294bb08eb3b45fcfcf525c\",\"status\":\"PENDING\",\"expiredAt\":null,\"checkoutUrl\":\"https://pay.payos.vn/web/2e5adc35ed294bb08eb3b45fcfcf525c\",\"qrCode\":\"00020101021238590010A000000727012900069704180115V3CAS63540860180208QRIBFTTA530370454063200005802VN62230819CSLS9UTTZ56 MOCTRA76304139F\"},\"signature\":\"89420b7804c07f7f62e3aeba1c640b08d65a2c64f9d57bc00148e8b5b8317018\"}', '2026-05-08 11:04:58', NULL);
INSERT INTO `payment_transactions` VALUES (3, 9, 'bank', 'payos', 'PAYOS_9_1778314527894', NULL, 130000.00, 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUAAAAFAAQAAAADl65gHAAACj0lEQVR4Xu2ZPXLrMAyE4UnhMkfwUXQ06mg+io+Q0oVHePgWpH/naVKkA1FYifjJxQ52Ccrmvyx7v/G/muBuTXC3JrhbE9wtwJtRB79++9nsy3/M2mYW/zWtWKsNHuPDDw4R4PX7snj8weXAyrk6iHKHkPMUyqWOIuLpvDnBWLqaLWvXcUPSZYJPoP+c4oYd/WK2fTn9NUHA+HCFlIeAx+BXPf3pwpIgLWWHWDqh3PNFK1Yb7JUdFS7Efnp6eSwWBkXEfTVWZLhfljUnAOvWrA2GC8/WldvI8AgpQF+3rmplMPa2brhIJyaAuIQLI8qHGUuDN/prSJYTwGgzqbrwZYVBJOT0gZxj62eR3nvRsSiYvtNkxCBwya3/cp8ma4OEVFOG2xgEWEPONGNxkFjS4HhOHZXhUe3DrgVBdnkIJ6u6GbGmLkPVwqDeCLHTGfa7stNtnPAJdswIUxnU1h8h5RA01srtePr17FoTvCmdFOVB3DQ49gxPOXmoLqhYamk/4/ThCm/s95rhdUGOHY6c9zaTNRkjX+xaEdT5VI0lOYNoOsKadPSHXWuCV8OF1IjyVQIOVVkpDPbTqjqq20+RlQPSm+AVQYt7+WKoR/ndjC8ZXhLMLU7289ji5DvkNKZJZstWGiTD0dGYH52D/uKMS6FjXmDqgiiHC3tcMwj0C88+ubAm2Eux9NjzCfbGlzwJXhKkscKFMmMjymOn01kEM8bpQ19TGKTNHDAaaxw7NAG0FLcVB4eA0VGm90MpoOR8D/uqoCMg7+w1P+qVx+rk++ITbGozTQCMRJnopqnpo82qgfHhvc228cMPg2OOkdVBozKkGv2l8EbHFPfhwpLgr2qCuzXB3Zrgbk1wt/4e/AcQ7fxy7rEIjQAAAABJRU5ErkJggg==', 'https://pay.payos.vn/web/6defb9f9846f4faebfbf4b18e645d28b', NULL, 'pending', NULL, '2026-05-09 15:15:27', NULL);

-- ----------------------------
-- Table structure for permissions
-- ----------------------------
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Định dạng: resource.action — vd: product.view',
  `display_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `group_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Nhóm hiển thị UI: product, order, blog...',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 28 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of permissions
-- ----------------------------
INSERT INTO `permissions` VALUES (1, 'dashboard.view', 'Xem Dashboard', NULL, 'dashboard', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (2, 'product.view', 'Xem sản phẩm', NULL, 'product', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (3, 'product.create', 'Thêm sản phẩm', NULL, 'product', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (4, 'product.edit', 'Sửa sản phẩm', NULL, 'product', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (5, 'product.delete', 'Xóa sản phẩm', NULL, 'product', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (6, 'product.import', 'Import sản phẩm hàng loạt', NULL, 'product', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (7, 'order.view', 'Xem đơn hàng', NULL, 'order', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (8, 'order.edit', 'Cập nhật đơn hàng', NULL, 'order', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (9, 'order.delete', 'Xóa đơn hàng', NULL, 'order', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (10, 'order.refund', 'Duyệt hoàn tiền', NULL, 'order', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (11, 'customer.view', 'Xem khách hàng', NULL, 'customer', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (12, 'customer.edit', 'Sửa thông tin khách hàng', NULL, 'customer', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (13, 'customer.vip', 'Quản lý VIP', NULL, 'customer', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (14, 'blog.view', 'Xem bài viết', NULL, 'blog', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (15, 'blog.create', 'Tạo bài viết', NULL, 'blog', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (16, 'blog.edit', 'Sửa bài viết', NULL, 'blog', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (17, 'blog.delete', 'Xóa bài viết', NULL, 'blog', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (18, 'blog.publish', 'Xuất bản bài viết', NULL, 'blog', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (19, 'category.manage', 'Quản lý danh mục', NULL, 'category', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (20, 'banner.manage', 'Quản lý banner', NULL, 'banner', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (21, 'promotion.manage', 'Quản lý khuyến mãi', NULL, 'promotion', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (22, 'coupon.manage', 'Quản lý mã giảm giá', NULL, 'coupon', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (23, 'role.manage', 'Quản lý vai trò & quyền', NULL, 'rbac', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (24, 'system.logs', 'Xem System Logs', NULL, 'system', '2026-06-04 22:33:31');
INSERT INTO `permissions` VALUES (25, 'promotion.create', 'Tạo khuyến mãi/mã giảm giá', NULL, 'promotion', '2026-06-06 08:37:06');
INSERT INTO `permissions` VALUES (26, 'promotion.approve', 'Phê duyệt khuyến mãi/mã giảm giá', NULL, 'promotion', '2026-06-06 08:37:06');

-- ----------------------------
-- Table structure for product_images
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 573 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_images
-- ----------------------------
INSERT INTO `product_images` VALUES (1, 2, 'assets/images/bot_cacao_2.png', 'Bột Cacao - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (2, 2, 'assets/images/bot_cacao_3.png', 'Bột Cacao - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (3, 3, 'assets/images/bot_ca_cao_thuong_hang_2.png', 'Cacao Premium - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (4, 3, 'assets/images/bot_ca_cao_thuong_hang_3.png', 'Cacao Premium - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (5, 4, 'assets/images/bot_frappe_dans_2.png', 'Frappe Dans - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (6, 4, 'assets/images/bot_frappe_dans_3.png', 'Frappe Dans - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (7, 5, 'assets/images/bot_kem_beo_creamerX_2.png', 'Creamer X - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (8, 5, 'assets/images/bot_kem_beo_creamerX_3.png', 'Creamer X - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (9, 5, 'assets/images/bot_kem_beo_creamerX_4.png', 'Creamer X - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (10, 6, 'assets/images/bot_kem_beo_halan_2.png', 'Kievit - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (11, 6, 'assets/images/bot_kem_beo_halan_3.png', 'Kievit - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (12, 6, 'assets/images/bot_kem_beo_halan_4.png', 'Kievit - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (13, 7, 'assets/images/bot_kem_beo_koera_2.png', 'Frima - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (14, 7, 'assets/images/bot_kem_beo_koera_3.png', 'Frima - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (15, 7, 'assets/images/bot_kem_beo_koera_4.png', 'Frima - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (16, 8, 'assets/images/bot_kem_beo_thai_lan_2.png', 'B-One - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (17, 8, 'assets/images/bot_kem_beo_thai_lan_3.png', 'B-One - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (18, 8, 'assets/images/bot_kem_beo_thai_lan_4.png', 'B-One - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (19, 9, 'assets/images/bot_kem_chung_2.png', 'Egg Pudding - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (20, 9, 'assets/images/bot_kem_chung_3.png', 'Egg Pudding - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (21, 10, 'assets/images/bot_khuc_bach_2.png', 'Khúc Bạch - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (22, 10, 'assets/images/bot_khuc_bach_3.png', 'Khúc Bạch - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (23, 11, 'assets/images/bot_la_gelatin_2.png', 'Gelatin - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (24, 11, 'assets/images/bot_la_gelatin_3.png', 'Gelatin - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (25, 12, 'assets/images/bot_matcha_2.png', 'Matcha - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (26, 12, 'assets/images/bot_matcha_3.png', 'Matcha - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (27, 13, 'assets/images/bot_milkFoam_vang_sua_2.png', 'Milk Foam - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (28, 13, 'assets/images/bot_milkFoam_vang_sua_3.png', 'Milk Foam - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (29, 14, 'assets/images/bot_pho_mai_2.png', 'Phô Mai - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (30, 14, 'assets/images/bot_pho_mai_3.png', 'Phô Mai - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (31, 15, 'assets/images/bot_rau_cau_2.png', 'Agar - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (32, 15, 'assets/images/bot_rau_cau_3.png', 'Agar - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (33, 16, 'assets/images/bot_rau_cau_ca_thai_2.png', 'Rau Câu Thái - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (34, 16, 'assets/images/bot_rau_cau_ca_thai_3.png', 'Rau Câu Thái - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (35, 17, 'assets/images/bot_rau_cau_con_ca_2.png', 'Cá Dẻo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (36, 17, 'assets/images/bot_rau_cau_con_ca_3.png', 'Cá Dẻo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (37, 18, 'assets/images/bot_sua_beo_kievit_2.png', 'Indo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (38, 18, 'assets/images/bot_sua_beo_kievit_3.png', 'Indo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (39, 18, 'assets/images/bot_sua_beo_kievit_4.png', 'Indo - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (40, 19, 'assets/images/bot_sua_khoai_mon_2.png', 'Pudding Môn - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (41, 19, 'assets/images/bot_sua_khoai_mon_3.png', 'Pudding Môn - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (42, 20, 'assets/images/bot_suong_sao_2.png', 'Sương Sáo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (43, 20, 'assets/images/bot_suong_sao_3.png', 'Sương Sáo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (64, 21, 'assets/images/dao_hong_thai_mieng_2.png', 'Đào Hồng - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (65, 21, 'assets/images/dao_hong_thai_mieng_3.png', 'Đào Hồng - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (66, 21, 'assets/images/dao_hong_thai_mieng_4.png', 'Đào Hồng - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (67, 22, 'assets/images/dao_ngam_2.png', 'Đào Ngâm - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (68, 22, 'assets/images/dao_ngam_3.png', 'Đào Ngâm - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (69, 22, 'assets/images/dao_ngam_4.png', 'Đào Ngâm - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (70, 23, 'assets/images/kem_beo_thuc_vat_2.png', 'Kem Béo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (71, 23, 'assets/images/kem_beo_thuc_vat_3.png', 'Kem Béo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (72, 23, 'assets/images/kem_beo_thuc_vat_4.png', 'Kem Béo - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (73, 24, 'assets/images/siro_bac_ha_2.png', 'Siro Bạc Hà - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (74, 24, 'assets/images/siro_bac_ha_3.png', 'Siro Bạc Hà - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (75, 25, 'assets/images/siro_cam_2.png', 'Siro Cam - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (76, 25, 'assets/images/siro_cam_3.png', 'Siro Cam - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (77, 26, 'assets/images/siro_chanh_day_2.png', 'Chanh Dây - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (78, 26, 'assets/images/siro_chanh_day_3.png', 'Chanh Dây - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (79, 27, 'assets/images/siro_dau_2.png', 'Siro Dâu - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (80, 27, 'assets/images/siro_dau_3.png', 'Siro Dâu - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (81, 28, 'assets/images/siro_dua_2.png', 'Siro Dừa - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (82, 28, 'assets/images/siro_dua_3.png', 'Siro Dừa - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (83, 29, 'assets/images/siro_dua_luoi_2.png', 'Dưa Lưới - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (84, 29, 'assets/images/siro_dua_luoi_3.png', 'Dưa Lưới - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (85, 30, 'assets/images/siro_duong_den_2.png', 'Đường Đen - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (86, 30, 'assets/images/siro_duong_den_3.png', 'Đường Đen - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (87, 31, 'assets/images/siro_kiwi_2.png', 'Siro Kiwi - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (88, 31, 'assets/images/siro_kiwi_3.png', 'Siro Kiwi - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (89, 32, 'assets/images/siro_mang_cut_2.png', 'Măng Cụt - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (90, 32, 'assets/images/siro_mang_cut_3.png', 'Măng Cụt - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (91, 33, 'assets/images/siro_nho_2.png', 'Siro Nho - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (92, 33, 'assets/images/siro_nho_3.png', 'Siro Nho - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (93, 34, 'assets/images/siro_oi_2.png', 'Siro Ổi - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (94, 34, 'assets/images/siro_oi_3.png', 'Siro Ổi - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (95, 36, 'assets/images/tep_buoi_hong_2.png', 'Bưởi Hồng - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (96, 36, 'assets/images/tep_buoi_hong_3.png', 'Bưởi Hồng - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (97, 36, 'assets/images/tep_buoi_hong_4.png', 'Bưởi Hồng - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (98, 37, 'assets/images/thach_ca_4_mau_douxian_2.png', 'Thạch Cá - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (99, 37, 'assets/images/thach_ca_4_mau_douxian_3.png', 'Thạch Cá - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (100, 38, 'assets/images/thach_dua_coco_2.png', 'Thạch Dừa - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (101, 38, 'assets/images/thach_dua_coco_3.png', 'Thạch Dừa - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (102, 40, 'assets/images/thach_rau_cau_cat_2.png', 'Thạch Cắt - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (103, 40, 'assets/images/thach_rau_cau_cat_3.png', 'Thạch Cắt - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (127, 41, 'assets/images/thach_tran_chau_trang_den_2.png', 'TC Trắng Đen - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (128, 41, 'assets/images/thach_tran_chau_trang_den_3.png', 'TC Trắng Đen - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (129, 42, 'assets/images/thach_vi_ca_phe_2.png', 'Thạch Cafe - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (130, 42, 'assets/images/thach_vi_ca_phe_3.png', 'Thạch Cafe - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (131, 43, 'assets/images/thach_vi_dao_2.png', 'Thạch Đào - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (132, 43, 'assets/images/thach_vi_dao_3.png', 'Thạch Đào - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (133, 44, 'assets/images/thach_vi_dau_2.png', 'Thạch Dâu - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (134, 44, 'assets/images/thach_vi_dau_3.png', 'Thạch Dâu - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (135, 45, 'assets/images/thach_vi_nho_2.png', 'Thạch Nho - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (136, 45, 'assets/images/thach_vi_nho_3.png', 'Thạch Nho - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (137, 46, 'assets/images/thach_vi_socola_2.png', 'Thạch Socola - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (138, 46, 'assets/images/thach_vi_socola_3.png', 'Thạch Socola - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (139, 47, 'assets/images/thach_vi_tao_2.png', 'Thạch Táo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (140, 47, 'assets/images/thach_vi_tao_3.png', 'Thạch Táo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (141, 48, 'assets/images/thach_vi_tra_xanh_2.png', 'Thạch Matcha - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (142, 48, 'assets/images/thach_vi_tra_xanh_3.png', 'Thạch Matcha - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (143, 49, 'assets/images/thach_vi_viet_quat_2.png', 'Thạch Việt Quất - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (144, 49, 'assets/images/thach_vi_viet_quat_3.png', 'Thạch Việt Quất - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (145, 50, 'assets/images/tran_chau_andes_dailoan_2.png', 'TC Andes - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (146, 50, 'assets/images/tran_chau_andes_dailoan_3.png', 'TC Andes - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (147, 51, 'assets/images/tran_chau_boduo_caramel_2.png', 'TC Boduo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (148, 51, 'assets/images/tran_chau_boduo_caramel_3.png', 'TC Boduo - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (149, 52, 'assets/images/tran_chau_douxian_2.png', 'TC Douxian - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (150, 52, 'assets/images/tran_chau_douxian_3.png', 'TC Douxian - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (151, 53, 'assets/images/tran_trau_3q_wingszion_2.png', '3Q Wings - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (152, 53, 'assets/images/tran_trau_3q_wingszion_3.png', '3Q Wings - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (153, 54, 'assets/images/tran_trau_soi_2.png', 'TC Sợi - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (154, 54, 'assets/images/tran_trau_soi_3.png', 'TC Sợi - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (155, 55, 'assets/images/tran_trau_wonderfull_2.png', 'TC Wonderfull - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (156, 55, 'assets/images/tran_trau_wonderfull_3.png', 'TC Wonderfull - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (157, 55, 'assets/images/tran_trau_wonderfull_4.png', 'TC Wonderfull - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (158, 56, 'assets/images/vai_thieu_ngam_2.png', 'Vải Thiều - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (159, 56, 'assets/images/vai_thieu_ngam_3.png', 'Vải Thiều - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (160, 56, 'assets/images/vai_thieu_ngam_4.png', 'Vải Thiều - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (161, 57, 'assets/images/xi_muoi_do_2.png', 'Xí Muội - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (162, 57, 'assets/images/xi_muoi_do_3.png', 'Xí Muội - Ảnh 3', 2, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (163, 57, 'assets/images/xi_muoi_do_4.png', 'Xí Muội - Ảnh 4', 3, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (190, 58, 'assets/images/bot-sua_khoai_mon_2.png', 'Khoai Môn - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (191, 59, 'assets/images/bot_cacao_2.png', 'Cacao Dark - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (192, 60, 'assets/images/bot_frappe_dans_2.png', 'Bột Mix - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (193, 61, 'assets/images/bot_kem_beo_halan_2.png', 'Kievit New - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (194, 62, 'assets/images/bot_kem_chung_2.png', 'Pudding Phô Mai - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (195, 63, 'assets/images/bot_matcha_2.png', 'Matcha Uji - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (196, 64, 'assets/images/bot_milkFoam_vang_sua_2.png', 'Macchiato - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (197, 65, 'assets/images/bot_pho_mai_2.png', 'Phô Mai Cay - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (198, 66, 'assets/images/bot_rau_cau_2.png', 'Agar Vịt - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (199, 67, 'assets/images/dao_ngam_2.png', 'Đào Nam Phi - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (200, 68, 'assets/images/kem_beo_thuc_vat_2.png', 'Whipping Rich - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (201, 69, 'assets/images/siro_bac_ha_2.png', 'Snow Mint - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (202, 70, 'assets/images/siro_chanh_day_2.png', 'Mứt Chanh Dây - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (203, 71, 'assets/images/siro_duong_den_2.png', 'Sốt Đường Nâu - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (204, 72, 'assets/images/siro_dau_2.png', 'Mứt Dâu Boduo - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (205, 73, 'assets/images/thach_dua_coco_2.png', 'Dừa Sợi - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (206, 74, 'assets/images/thach_tran_chau_trang_den_2.png', 'Konjac 3Q - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (207, 75, 'assets/images/tran_chau_andes_dailoan_2.png', 'TC Đường Đen - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (208, 76, 'assets/images/tran_trau_3q_wingszion_2.png', '3Q Ngọc Trai - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (209, 77, 'assets/images/vai_thieu_ngam_2.png', 'Vải Lục Ngạn - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (221, 78, 'assets/images/bot_matcha_2.png', 'Matcha 3in1 - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (222, 79, 'assets/images/siro_bac_ha_2.png', 'Blue Curacao - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (223, 80, 'assets/images/siro_duong_den_2.png', 'Hazelnut - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (224, 81, 'assets/images/siro_duong_den_2.png', 'Caramel Mặn - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (225, 82, 'assets/images/siro_kiwi_2.png', 'Táo Xanh - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (226, 83, 'assets/images/vai_thieu_ngam_2.png', 'Vải Hoa Hồng - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (227, 84, 'assets/images/tran_chau_boduo_caramel_2.png', 'Hoàng Kim Mini - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (228, 85, 'assets/images/thach_rau_cau_cat_2.png', 'Nha Đam - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (229, 86, 'assets/images/bot_khuc_bach_2.png', 'Tàu Hũ Sing - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (230, 87, 'assets/images/thach_vi_dau_2.png', 'Thủy Tinh Dâu - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (231, 88, 'assets/images/thach_tran_chau_trang_den_2.png', 'Thủy Tinh Yogurt - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (232, 89, 'assets/images/siro_nho_2.png', 'Mứt Việt Quất - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (233, 90, 'assets/images/bot_kem_beo_thai_lan_2.png', 'Cốt Dừa - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (234, 91, 'assets/images/bot_suong_sao_2.png', 'Than Tre - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (235, 92, 'assets/images/thach_rau_cau_cat_2.png', 'Củ Năng - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (236, 93, 'assets/images/bot_kem_chung_2.png', 'Kem Trứng Nướng - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (237, 94, 'assets/images/bot_suong_sao_2.png', 'Sương Sáo Hạt Chia - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (238, 95, 'assets/images/thach_dua_coco_2.png', 'Dừa Thô - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (239, 96, 'assets/images/siro_dua_luoi_2.png', 'Bí Đao - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (240, 97, 'assets/images/tran_trau_3q_wingszion_2.png', '3Q Tuyết - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (241, 98, 'assets/images/bot_kem_chung_2.png', 'Combo Tàu Hũ - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (242, 99, 'assets/images/bot_khuc_bach_2.png', 'Khúc Bạch Phô Mai - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (243, 100, 'assets/images/bot_rau_cau_2.png', 'Sơn Thủy - Ảnh 2', 1, '2026-01-28 19:44:08');
INSERT INTO `product_images` VALUES (252, 101, 'assets/images/che_day_sapa_2.png', 'Chè Dây Sapa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (253, 101, 'assets/images/che_day_sapa_3.png', 'Chè Dây Sapa - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (254, 102, 'assets/images/luc_tra_lai_2.png', 'Lục Trà Lài - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (255, 102, 'assets/images/luc_tra_lai_3.png', 'Lục Trà Lài - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (256, 103, 'assets/images/mat_o_long_tra_2.png', 'Mật Ong Long Trà - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (257, 103, 'assets/images/mat_o_long_tra_3.png', 'Mật Ong Long Trà - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (258, 104, 'assets/images/tra_an_than_ngu_ngon_2.png', 'Trà An Thần - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (259, 104, 'assets/images/tra_an_than_ngu_ngon_3.png', 'Trà An Thần - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (260, 105, 'assets/images/tra_atiso_tui_loc_2.png', 'Atiso Túi Lọc - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (261, 105, 'assets/images/tra_atiso_tui_loc_3.png', 'Atiso Túi Lọc - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (262, 106, 'assets/images/tra_bac_ha_2.png', 'Trà Bạc Hà - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (263, 106, 'assets/images/tra_bac_ha_3.png', 'Trà Bạc Hà - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (264, 107, 'assets/images/tra_bac_thai_nguyen_2.png', 'Trà Bắc Thái Nguyên - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (265, 107, 'assets/images/tra_bac_thai_nguyen_3.png', 'Trà Bắc Thái Nguyên - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (266, 108, 'assets/images/tra_bo_ty_vi_2.png', 'Trà Bổ Tỳ Vị - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (267, 108, 'assets/images/tra_bo_ty_vi_3.png', 'Trà Bổ Tỳ Vị - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (268, 109, 'assets/images/tra_cay_co_mau_2.png', 'Trà Cây Cỏ Máu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (269, 109, 'assets/images/tra_cay_co_mau_3.png', 'Trà Cây Cỏ Máu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (270, 110, 'assets/images/tra_ca_gai_leo_2.png', 'Trà Cà Gai Leo - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (271, 110, 'assets/images/tra_ca_gai_leo_3.png', 'Trà Cà Gai Leo - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (272, 111, 'assets/images/tra_cung_dinh_hue_2.png', 'Trà Cung Đình Huế - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (273, 111, 'assets/images/tra_cung_dinh_hue_3.png', 'Trà Cung Đình Huế - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (274, 112, 'assets/images/tra_dau_den_orihiro_2.png', 'Trà Đậu Đen - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (275, 112, 'assets/images/tra_dau_den_orihiro_3.png', 'Trà Đậu Đen - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (276, 113, 'assets/images/tra_den_dalatfarm_2.png', 'Trà Đen DalatFarm - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (277, 113, 'assets/images/tra_den_dalatfarm_3.png', 'Trà Đen DalatFarm - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (278, 114, 'assets/images/tra_den_ngoc_quy_2.png', 'Trà Đen Ngọc Quý - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (279, 115, 'assets/images/tra_dinh_lang_2.png', 'Trà Đinh Lăng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (280, 115, 'assets/images/tra_dinh_lang_3.png', 'Trà Đinh Lăng - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (281, 116, 'assets/images/tra_doi_than_tim_2.png', 'Trà Dồi Thân Tím - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (282, 116, 'assets/images/tra_doi_than_tim_3.png', 'Trà Dồi Thân Tím - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (283, 117, 'assets/images/tra_dong_tu_vi_2.png', 'Trà Đông Tử Vị - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (284, 117, 'assets/images/tra_dong_tu_vi_3.png', 'Trà Đông Tử Vị - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (285, 118, 'assets/images/tra_duong_nau_nguyen_chat_2.png', 'Trà Đường Nâu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (286, 118, 'assets/images/tra_duong_nau_nguyen_chat_3.png', 'Trà Đường Nâu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (287, 119, 'assets/images/tra_duong_nhan_2.png', 'Trà Dưỡng Nhan - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (288, 119, 'assets/images/tra_duong_nhan_3.png', 'Trà Dưỡng Nhan - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (289, 120, 'assets/images/tra_du_du_duc_2.png', 'Trà Đu Đủ Đực - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (290, 120, 'assets/images/tra_du_du_duc_3.png', 'Trà Đu Đủ Đực - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (291, 121, 'assets/images/tra_fitne_herbal_2.png', 'Trà Fitne Herbal - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (292, 121, 'assets/images/tra_fitne_herbal_3.png', 'Trà Fitne Herbal - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (293, 122, 'assets/images/tra_gao_luc_2.png', 'Trà Gạo Lứt - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (294, 122, 'assets/images/tra_gao_luc_3.png', 'Trà Gạo Lứt - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (295, 123, 'assets/images/tra_genpi_orihiro_2.png', 'Trà Genpi Orihiro - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (296, 123, 'assets/images/tra_genpi_orihiro_3.png', 'Trà Genpi Orihiro - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (297, 124, 'assets/images/tra_giao_co_lam_2.png', 'Trà Giảo Cổ Lam - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (298, 124, 'assets/images/tra_giao_co_lam_3.png', 'Trà Giảo Cổ Lam - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (299, 125, 'assets/images/tra_gung_2.png', 'Trà Gừng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (300, 126, 'assets/images/tra_ha_thu_o_tui_loc_2.png', 'Trà Hà Thủ Ô - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (301, 126, 'assets/images/tra_ha_thu_o_tui_loc_3.png', 'Trà Hà Thủ Ô - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (302, 127, 'assets/images/tra_hoang_thao_moc_2.png', 'Trà Hoàng Thảo Mộc - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (303, 127, 'assets/images/tra_hoang_thao_moc_3.png', 'Trà Hoàng Thảo Mộc - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (304, 128, 'assets/images/tra_hoa_cuc_que_hoa_ky_tu_2.png', 'Trà Hoa Cúc - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (305, 128, 'assets/images/tra_hoa_cuc_que_hoa_ky_tu_3.png', 'Trà Hoa Cúc - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (306, 129, 'assets/images/tra_hong_sam_2.png', 'Trà Hồng Sâm - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (307, 129, 'assets/images/tra_hong_sam_3.png', 'Trà Hồng Sâm - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (308, 130, 'assets/images/tra_hong_sam_han_quoc_2.png', 'Hồng Sâm HQ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (309, 130, 'assets/images/tra_hong_sam_han_quoc_3.png', 'Hồng Sâm HQ - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (310, 131, 'assets/images/tra_hut_am_2.png', 'Trà Hút Ẩm - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (311, 131, 'assets/images/tra_hut_am_3.png', 'Trà Hút Ẩm - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (312, 132, 'assets/images/tra_kho_qua_2.png', 'Trà Khổ Qua - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (313, 132, 'assets/images/tra_kho_qua_3.png', 'Trà Khổ Qua - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (314, 133, 'assets/images/tra_lai_tan_cuong_2.png', 'Trà Lài Tân Cương - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (315, 133, 'assets/images/tra_lai_tan_cuong_3.png', 'Trà Lài Tân Cương - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (316, 134, 'assets/images/tra_la_nam_2.png', 'Trà Lá Nam - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (317, 134, 'assets/images/tra_la_nam_3.png', 'Trà Lá Nam - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (318, 135, 'assets/images/tra_la_oi_2.png', 'Trà Lá Ổi - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (319, 135, 'assets/images/tra_la_oi_3.png', 'Trà Lá Ổi - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (320, 136, 'assets/images/tra_lipton_xi_muoi_2.png', 'Lipton Xí Muội - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (321, 136, 'assets/images/tra_lipton_xi_muoi_3.png', 'Lipton Xí Muội - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (322, 137, 'assets/images/tra_mam_xoi_2.png', 'Trà Mâm Xôi - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (323, 137, 'assets/images/tra_mam_xoi_3.png', 'Trà Mâm Xôi - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (324, 138, 'assets/images/tra_mang_cau_slim_2.png', 'Trà Mãng Cầu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (325, 138, 'assets/images/tra_mang_cau_slim_3.png', 'Trà Mãng Cầu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (326, 139, 'assets/images/tra_mix_vi_cam_que_2.png', 'Trà Mix Cam Quế - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (327, 139, 'assets/images/tra_mix_vi_cam_que_3.png', 'Trà Mix Cam Quế - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (328, 140, 'assets/images/tra_moc_cau_2.png', 'Trà Móc Câu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (329, 140, 'assets/images/tra_moc_cau_3.png', 'Trà Móc Câu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (330, 141, 'assets/images/tra_moc_hoa_tay_bac_2.png', 'Trà Mộc Hoa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (331, 141, 'assets/images/tra_moc_hoa_tay_bac_3.png', 'Trà Mộc Hoa - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (332, 142, 'assets/images/tra_nhai_dalatfarm_2.png', 'Trà Nhài Dalat - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (333, 142, 'assets/images/tra_nhai_dalatfarm_3.png', 'Trà Nhài Dalat - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (334, 143, 'assets/images/tra_nhai_huong_2.png', 'Trà Nhài Hương - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (335, 143, 'assets/images/tra_nhai_huong_3.png', 'Trà Nhài Hương - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (336, 144, 'assets/images/tra_nhai_layla_2.png', 'Trà Nhài Layla - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (337, 144, 'assets/images/tra_nhai_layla_3.png', 'Trà Nhài Layla - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (338, 145, 'assets/images/tra_nhan_tran_cam_thao_2.png', 'Nhân Trần Cam Thảo - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (339, 145, 'assets/images/tra_nhan_tran_cam_thao_3.png', 'Nhân Trần Cam Thảo - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (340, 146, 'assets/images/tra_non_tom_2.png', 'Trà Nõn Tôm - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (341, 146, 'assets/images/tra_non_tom_3.png', 'Trà Nõn Tôm - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (342, 147, 'assets/images/tra_o_long_lai_chau_2.png', 'Oolong Lai Châu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (343, 147, 'assets/images/tra_o_long_lai_chau_3.png', 'Oolong Lai Châu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (344, 148, 'assets/images/tra_o_long_len_men_2.png', 'Oolong Lên Men - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (345, 148, 'assets/images/tra_o_long_len_men_3.png', 'Oolong Lên Men - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (346, 149, 'assets/images/tra_pho_nhi_2.png', 'Trà Phổ Nhĩ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (347, 149, 'assets/images/tra_pho_nhi_3.png', 'Trà Phổ Nhĩ - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (348, 150, 'assets/images/tra_que_hoa_2.png', 'Trà Quế Hoa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (349, 150, 'assets/images/tra_que_hoa_3.png', 'Trà Quế Hoa - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (350, 151, 'assets/images/tra_que_thao_moc_2.png', 'Trà Quế Thảo Mộc - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (351, 151, 'assets/images/tra_que_thao_moc_3.png', 'Trà Quế Thảo Mộc - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (352, 152, 'assets/images/tra_sam_dua_2.png', 'Trà Sâm Dứa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (353, 152, 'assets/images/tra_sam_dua_3.png', 'Trà Sâm Dứa - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (354, 153, 'assets/images/tra_sam_hong_2.png', 'Trà Sâm Hồng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (355, 153, 'assets/images/tra_sam_hong_3.png', 'Trà Sâm Hồng - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (356, 154, 'assets/images/tra_sam_ky_hai_duong_2.png', 'Sâm Kỳ Hải Dương - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (357, 154, 'assets/images/tra_sam_ky_hai_duong_3.png', 'Sâm Kỳ Hải Dương - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (358, 155, 'assets/images/tra_sam_to_nu_2.png', 'Sâm Tố Nữ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (359, 155, 'assets/images/tra_sam_to_nu_3.png', 'Sâm Tố Nữ - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (360, 156, 'assets/images/tra_tam_sen_2.png', 'Trà Tâm Sen - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (361, 156, 'assets/images/tra_tam_sen_3.png', 'Trà Tâm Sen - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (362, 157, 'assets/images/tra_tam_vun_2.png', 'Trà Tấm Vụn - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (363, 157, 'assets/images/tra_tam_vun_3.png', 'Trà Tấm Vụn - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (364, 158, 'assets/images/tra_thai_nguyen_2.png', 'Trà Thái Nguyên - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (365, 158, 'assets/images/tra_thai_nguyen_3.png', 'Trà Thái Nguyên - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (366, 159, 'assets/images/tra_thai_xanh_2.png', 'Trà Thái Xanh - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (367, 159, 'assets/images/tra_thai_xanh_3.png', 'Trà Thái Xanh - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (368, 160, 'assets/images/tra_thao_moc_ba_kich_2.png', 'Ba Kích - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (369, 160, 'assets/images/tra_thao_moc_ba_kich_3.png', 'Ba Kích - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (370, 161, 'assets/images/tra_thao_moc_ngu_tra_an_nu_2.png', 'Ngự Trà An Nữ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (371, 161, 'assets/images/tra_thao_moc_ngu_tra_an_nu_3.png', 'Ngự Trà An Nữ - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (372, 162, 'assets/images/tra_thao_moc_xuan_thu_2.png', 'Xuân Thu - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (373, 162, 'assets/images/tra_thao_moc_xuan_thu_3.png', 'Xuân Thu - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (374, 163, 'assets/images/tra_tia_to_2.png', 'Trà Tía Tô - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (375, 163, 'assets/images/tra_tia_to_3.png', 'Trà Tía Tô - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (376, 164, 'assets/images/tra_tui_loc_cay_rau_muong_2.png', 'Rau Mương - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (377, 164, 'assets/images/tra_tui_loc_cay_rau_muong_3.png', 'Rau Mương - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (378, 165, 'assets/images/tra_uop_hoa_nhai_2.png', 'Trà Ướp Nhài - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (379, 165, 'assets/images/tra_uop_hoa_nhai_3.png', 'Trà Ướp Nhài - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (380, 167, 'assets/images/tra_xanh_co_thu_2.png', 'Trà Xanh Cổ Thụ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (381, 167, 'assets/images/tra_xanh_co_thu_3.png', 'Trà Xanh Cổ Thụ - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (382, 168, 'assets/images/tra_xanh_shan_tuyet_2.png', 'Shan Tuyết - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (383, 168, 'assets/images/tra_xanh_shan_tuyet_3.png', 'Shan Tuyết - Ảnh 3', 2, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (507, 169, 'assets/images/che_day_sapa_2.png', 'Chè Dây Rừng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (508, 170, 'assets/images/luc_tra_lai_2.png', 'Lục Trà Lài - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (509, 171, 'assets/images/mat_o_long_tra_2.png', 'Oolong Mật Ong - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (510, 172, 'assets/images/tra_an_than_ngu_ngon_2.png', 'An Thần - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (511, 173, 'assets/images/tra_bac_ha_2.png', 'Bạc Hà Lạnh - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (512, 174, 'assets/images/tra_bac_thai_nguyen_2.png', 'Tân Cương Xanh - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (513, 175, 'assets/images/tra_cung_dinh_hue_2.png', 'Ngự Trà - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (514, 176, 'assets/images/tra_den_dalatfarm_2.png', 'Hồng Trà Sữa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (515, 177, 'assets/images/tra_gao_luc_2.png', 'Gạo Lứt Đậu Đen - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (516, 178, 'assets/images/tra_gung_2.png', 'Gừng Sả - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (517, 179, 'assets/images/tra_hoang_thao_moc_2.png', 'Thập Toàn Đại Bổ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (518, 180, 'assets/images/tra_hong_sam_2.png', 'Hồng Sâm Lát - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (519, 181, 'assets/images/tra_kho_qua_2.png', 'Khổ Qua Rừng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (520, 182, 'assets/images/tra_lai_tan_cuong_2.png', 'Nhài Cổ Thụ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (521, 183, 'assets/images/tra_mam_xoi_2.png', 'Berry Tea - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (522, 184, 'assets/images/tra_mang_cau_slim_2.png', 'Mãng Cầu Giảm Cân - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (523, 185, 'assets/images/tra_o_long_lai_chau_2.png', 'Oolong Tứ Quý - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (524, 186, 'assets/images/tra_que_hoa_2.png', 'Mộc Quế Hoa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (525, 187, 'assets/images/tra_sam_hong_2.png', 'Sâm Hồng Bát Tiên - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (526, 188, 'assets/images/tra_xanh_shan_tuyet_2.png', 'Bạch Trà - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (538, 189, 'assets/images/tra_den_dalatfarm_2.png', 'Bá Tước - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (539, 190, 'assets/images/luc_tra_lai_2.png', 'Lài King - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (540, 191, 'assets/images/tra_gung_2.png', 'Gừng Đen - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (541, 192, 'assets/images/tra_hoa_cuc_que_hoa_ky_tu_2.png', 'Cúc Chi - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (542, 193, 'assets/images/tra_o_long_lai_chau_2.png', 'Oolong Sữa - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (543, 194, 'assets/images/tra_gao_luc_2.png', 'Gạo Lứt Xạ Đen - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (544, 195, 'assets/images/tra_tui_loc_cay_rau_muong_2.png', 'Cà Gai Leo - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (545, 196, 'assets/images/che_day_sapa_2.png', 'Dây Cao Bằng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (546, 197, 'assets/images/tra_bac_ha_2.png', 'Bạc Hà Khô - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (547, 198, 'assets/images/tra_sam_hong_2.png', 'Sơn Mật - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (548, 199, 'assets/images/tra_kho_qua_2.png', 'Chè Đắng - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (549, 200, 'assets/images/tra_uop_hoa_nhai_2.png', 'Sen Tây Hồ - Ảnh 2', 1, '2026-01-28 19:46:18');
INSERT INTO `product_images` VALUES (550, 78, 'assets/images/bot_matcha_2.png', 'Matcha 3in1 - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (551, 79, 'assets/images/siro_bac_ha_2.png', 'Blue Curacao - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (552, 80, 'assets/images/siro_duong_den_2.png', 'Hazelnut - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (553, 81, 'assets/images/siro_duong_den_2.png', 'Caramel Mặn - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (554, 82, 'assets/images/siro_kiwi_2.png', 'Táo Xanh - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (555, 83, 'assets/images/vai_thieu_ngam_2.png', 'Vải Hoa Hồng - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (556, 84, 'assets/images/tran_chau_boduo_caramel_2.png', 'Hoàng Kim Mini - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (557, 85, 'assets/images/thach_rau_cau_cat_2.png', 'Nha Đam - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (558, 86, 'assets/images/bot_khuc_bach_2.png', 'Tàu Hũ Sing - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (559, 87, 'assets/images/thach_vi_dau_2.png', 'Thủy Tinh Dâu - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (560, 88, 'assets/images/thach_tran_chau_trang_den_2.png', 'Thủy Tinh Yogurt - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (561, 89, 'assets/images/siro_nho_2.png', 'Mứt Việt Quất - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (562, 90, 'assets/images/bot_kem_beo_thai_lan_2.png', 'Cốt Dừa - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (563, 91, 'assets/images/bot_suong_sao_2.png', 'Than Tre - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (564, 92, 'assets/images/thach_rau_cau_cat_2.png', 'Củ Năng - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (565, 93, 'assets/images/bot_kem_chung_2.png', 'Kem Trứng Nướng - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (566, 94, 'assets/images/bot_suong_sao_2.png', 'Sương Sáo Hạt Chia - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (567, 95, 'assets/images/thach_dua_coco_2.png', 'Dừa Thô - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (568, 96, 'assets/images/siro_dua_luoi_2.png', 'Bí Đao - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (569, 97, 'assets/images/tran_trau_3q_wingszion_2.png', '3Q Tuyết - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (570, 98, 'assets/images/bot_kem_chung_2.png', 'Combo Tàu Hũ - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (571, 99, 'assets/images/bot_khuc_bach_2.png', 'Khúc Bạch Phô Mai - Ảnh 2', 1, '2026-03-29 19:21:51');
INSERT INTO `product_images` VALUES (572, 100, 'assets/images/bot_rau_cau_2.png', 'Sơn Thủy - Ảnh 2', 1, '2026-03-29 19:21:51');

-- ----------------------------
-- Table structure for product_reviews
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of product_reviews
-- ----------------------------

-- ----------------------------
-- Table structure for product_variants
-- ----------------------------
DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE `product_variants`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `variant_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `sku` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `price` decimal(15, 2) NOT NULL,
  `sale_price` decimal(15, 2) NULL DEFAULT 0.00,
  `stock_quantity` int NULL DEFAULT 0,
  `is_active` tinyint(1) NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `sku`(`sku` ASC) USING BTREE,
  INDEX `fk_variant_product`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_variant_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 493 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of product_variants
-- ----------------------------
INSERT INTO `product_variants` VALUES (1, 101, 'Gói 100g', 'TRA001-100G', 120000.00, 0.00, 23, 1);
INSERT INTO `product_variants` VALUES (2, 102, 'Gói 100g', 'TRA002-100G', 85000.00, 75000.00, 37, 1);
INSERT INTO `product_variants` VALUES (3, 103, 'Gói 100g', 'TRA003-100G', 150000.00, 0.00, 48, 1);
INSERT INTO `product_variants` VALUES (4, 104, 'Gói 100g', 'TRA004-100G', 95000.00, 0.00, 48, 1);
INSERT INTO `product_variants` VALUES (5, 105, 'Gói 100g', 'TRA005-100G', 65000.00, 50000.00, 44, 1);
INSERT INTO `product_variants` VALUES (6, 106, 'Gói 100g', 'TRA006-100G', 70000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (7, 107, 'Gói 100g', 'TRA007-100G', 250000.00, 220000.00, 40, 1);
INSERT INTO `product_variants` VALUES (8, 108, 'Gói 100g', 'TRA008-100G', 110000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (9, 109, 'Gói 100g', 'TRA009-100G', 135000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (10, 110, 'Gói 100g', 'TRA010-100G', 90000.00, 80000.00, 50, 1);
INSERT INTO `product_variants` VALUES (11, 111, 'Gói 100g', 'TRA011-100G', 85000.00, 0.00, 48, 1);
INSERT INTO `product_variants` VALUES (12, 112, 'Gói 100g', 'TRA012-100G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (13, 115, 'Gói 100g', 'TRA013-100G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (14, 116, 'Gói 100g', 'TRA014-100G', 115000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (15, 117, 'Gói 100g', 'TRA015-100G', 350000.00, 300000.00, 48, 1);
INSERT INTO `product_variants` VALUES (16, 119, 'Gói 100g', 'TRA016-100G', 160000.00, 140000.00, 50, 1);
INSERT INTO `product_variants` VALUES (17, 120, 'Gói 100g', 'TRA017-100G', 210000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (18, 121, 'Gói 100g', 'TRA018-100G', 130000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (19, 122, 'Gói 100g', 'TRA019-100G', 60000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (20, 123, 'Gói 100g', 'TRA020-100G', 195000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (21, 124, 'Gói 100g', 'TRA021-100G', 105000.00, 95000.00, 50, 1);
INSERT INTO `product_variants` VALUES (22, 125, 'Gói 100g', 'TRA022-100G', 55000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (23, 126, 'Gói 100g', 'TRA023-100G', 85000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (24, 127, 'Gói 100g', 'TRA024-100G', 280000.00, 250000.00, 50, 1);
INSERT INTO `product_variants` VALUES (25, 128, 'Gói 100g', 'TRA025-100G', 110000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (26, 129, 'Gói 100g', 'TRA026-100G', 320000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (27, 130, 'Gói 100g', 'TRA027-100G', 450000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (28, 131, 'Gói 100g', 'PK001-100G', 40000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (29, 132, 'Gói 100g', 'TRA028-100G', 95000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (30, 133, 'Gói 100g', 'TRA029-100G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (31, 134, 'Gói 100g', 'TRA030-100G', 80000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (32, 135, 'Gói 100g', 'TRA031-100G', 50000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (33, 137, 'Gói 100g', 'TRA032-100G', 125000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (34, 138, 'Gói 100g', 'TRA033-100G', 110000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (35, 139, 'Gói 100g', 'TRA034-100G', 15000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (36, 140, 'Gói 100g', 'TRA035-100G', 220000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (37, 141, 'Gói 100g', 'TRA036-100G', 130000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (38, 145, 'Gói 100g', 'TRA037-100G', 40000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (39, 146, 'Gói 100g', 'TRA038-100G', 450000.00, 420000.00, 50, 1);
INSERT INTO `product_variants` VALUES (40, 147, 'Gói 100g', 'TRA039-100G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (41, 149, 'Gói 100g', 'TRA040-100G', 550000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (42, 150, 'Gói 100g', 'TRA041-100G', 190000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (43, 151, 'Gói 100g', 'TRA042-100G', 80000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (44, 152, 'Gói 100g', 'TRA043-100G', 60000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (45, 153, 'Gói 100g', 'TRA044-100G', 75000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (46, 154, 'Gói 100g', 'TRA045-100G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (47, 155, 'Gói 100g', 'TRA046-100G', 200000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (48, 156, 'Gói 100g', 'TRA047-100G', 150000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (49, 157, 'Gói 100g', 'TRA048-100G', 40000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (50, 158, 'Gói 100g', 'TRA049-100G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (51, 160, 'Gói 100g', 'TRA050-100G', 160000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (52, 161, 'Gói 100g', 'TRA051-100G', 145000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (53, 162, 'Gói 100g', 'TRA052-100G', 125000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (54, 163, 'Gói 100g', 'TRA053-100G', 60000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (55, 164, 'Gói 100g', 'TRA054-100G', 75000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (56, 165, 'Gói 100g', 'TRA055-100G', 200000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (57, 166, 'Gói 100g', 'TRA056-100G', 50000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (58, 167, 'Gói 100g', 'TRA057-100G', 350000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (59, 168, 'Gói 100g', 'TRA058-100G', 300000.00, 280000.00, 50, 1);
INSERT INTO `product_variants` VALUES (60, 169, 'Gói 100g', 'TRA069-100G', 135000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (61, 170, 'Gói 100g', 'TRA070-100G', 95000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (62, 171, 'Gói 100g', 'TRA071-100G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (63, 172, 'Gói 100g', 'TRA072-100G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (64, 173, 'Gói 100g', 'TRA073-100G', 75000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (65, 174, 'Gói 100g', 'TRA074-100G', 150000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (66, 175, 'Gói 100g', 'TRA075-100G', 250000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (67, 177, 'Gói 100g', 'TRA076-100G', 70000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (68, 178, 'Gói 100g', 'TRA077-100G', 60000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (69, 179, 'Gói 100g', 'TRA078-100G', 300000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (70, 180, 'Gói 100g', 'TRA079-100G', 350000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (71, 181, 'Gói 100g', 'TRA080-100G', 100000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (72, 182, 'Gói 100g', 'TRA081-100G', 220000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (73, 183, 'Gói 100g', 'TRA082-100G', 140000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (74, 184, 'Gói 100g', 'TRA083-100G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (75, 185, 'Gói 100g', 'TRA084-100G', 190000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (76, 186, 'Gói 100g', 'TRA085-100G', 210000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (77, 187, 'Gói 100g', 'TRA086-100G', 90000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (78, 188, 'Gói 100g', 'TRA087-100G', 500000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (79, 191, 'Gói 100g', 'TRA091-100G', 65000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (80, 192, 'Gói 100g', 'TRA092-100G', 150000.00, 135000.00, 50, 1);
INSERT INTO `product_variants` VALUES (81, 193, 'Gói 100g', 'TRA093-100G', 210000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (82, 194, 'Gói 100g', 'TRA094-100G', 75000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (83, 195, 'Gói 100g', 'TRA095-100G', 60000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (84, 196, 'Gói 100g', 'TRA096-100G', 110000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (85, 197, 'Gói 100g', 'TRA097-100G', 80000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (86, 198, 'Gói 100g', 'TRA098-100G', 85000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (87, 199, 'Gói 100g', 'TRA099-100G', 160000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (88, 200, 'Gói 100g', 'TRA100-100G', 400000.00, 380000.00, 50, 1);
INSERT INTO `product_variants` VALUES (128, 101, 'Gói 250g', 'TRA001-250G', 288000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (129, 102, 'Gói 250g', 'TRA002-250G', 204000.00, 180000.00, 45, 1);
INSERT INTO `product_variants` VALUES (130, 103, 'Gói 250g', 'TRA003-250G', 360000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (131, 104, 'Gói 250g', 'TRA004-250G', 228000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (132, 105, 'Gói 250g', 'TRA005-250G', 156000.00, 120000.00, 50, 1);
INSERT INTO `product_variants` VALUES (133, 106, 'Gói 250g', 'TRA006-250G', 168000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (134, 107, 'Gói 250g', 'TRA007-250G', 600000.00, 528000.00, 50, 1);
INSERT INTO `product_variants` VALUES (135, 108, 'Gói 250g', 'TRA008-250G', 264000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (136, 109, 'Gói 250g', 'TRA009-250G', 324000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (137, 110, 'Gói 250g', 'TRA010-250G', 216000.00, 192000.00, 50, 1);
INSERT INTO `product_variants` VALUES (138, 111, 'Gói 250g', 'TRA011-250G', 204000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (139, 112, 'Gói 250g', 'TRA012-250G', 432000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (140, 115, 'Gói 250g', 'TRA013-250G', 288000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (141, 116, 'Gói 250g', 'TRA014-250G', 276000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (142, 117, 'Gói 250g', 'TRA015-250G', 840000.00, 720000.00, 50, 1);
INSERT INTO `product_variants` VALUES (143, 119, 'Gói 250g', 'TRA016-250G', 384000.00, 336000.00, 50, 1);
INSERT INTO `product_variants` VALUES (144, 120, 'Gói 250g', 'TRA017-250G', 504000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (145, 121, 'Gói 250g', 'TRA018-250G', 312000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (146, 122, 'Gói 250g', 'TRA019-250G', 144000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (147, 123, 'Gói 250g', 'TRA020-250G', 468000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (148, 124, 'Gói 250g', 'TRA021-250G', 252000.00, 228000.00, 50, 1);
INSERT INTO `product_variants` VALUES (149, 125, 'Gói 250g', 'TRA022-250G', 132000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (150, 126, 'Gói 250g', 'TRA023-250G', 204000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (151, 127, 'Gói 250g', 'TRA024-250G', 672000.00, 600000.00, 50, 1);
INSERT INTO `product_variants` VALUES (152, 128, 'Gói 250g', 'TRA025-250G', 264000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (153, 129, 'Gói 250g', 'TRA026-250G', 768000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (154, 130, 'Gói 250g', 'TRA027-250G', 1080000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (155, 131, 'Gói 250g', 'PK001-250G', 96000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (156, 132, 'Gói 250g', 'TRA028-250G', 228000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (157, 133, 'Gói 250g', 'TRA029-250G', 432000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (158, 134, 'Gói 250g', 'TRA030-250G', 192000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (159, 135, 'Gói 250g', 'TRA031-250G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (160, 137, 'Gói 250g', 'TRA032-250G', 300000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (161, 138, 'Gói 250g', 'TRA033-250G', 264000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (162, 139, 'Gói 250g', 'TRA034-250G', 36000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (163, 140, 'Gói 250g', 'TRA035-250G', 528000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (164, 141, 'Gói 250g', 'TRA036-250G', 312000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (165, 145, 'Gói 250g', 'TRA037-250G', 96000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (166, 146, 'Gói 250g', 'TRA038-250G', 1080000.00, 1008000.00, 50, 1);
INSERT INTO `product_variants` VALUES (167, 147, 'Gói 250g', 'TRA039-250G', 432000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (168, 149, 'Gói 250g', 'TRA040-250G', 1320000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (169, 150, 'Gói 250g', 'TRA041-250G', 456000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (170, 151, 'Gói 250g', 'TRA042-250G', 192000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (171, 152, 'Gói 250g', 'TRA043-250G', 144000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (172, 153, 'Gói 250g', 'TRA044-250G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (173, 154, 'Gói 250g', 'TRA045-250G', 288000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (174, 155, 'Gói 250g', 'TRA046-250G', 480000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (175, 156, 'Gói 250g', 'TRA047-250G', 360000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (176, 157, 'Gói 250g', 'TRA048-250G', 96000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (177, 158, 'Gói 250g', 'TRA049-250G', 432000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (178, 160, 'Gói 250g', 'TRA050-250G', 384000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (179, 161, 'Gói 250g', 'TRA051-250G', 348000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (180, 162, 'Gói 250g', 'TRA052-250G', 300000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (181, 163, 'Gói 250g', 'TRA053-250G', 144000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (182, 164, 'Gói 250g', 'TRA054-250G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (183, 165, 'Gói 250g', 'TRA055-250G', 480000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (184, 166, 'Gói 250g', 'TRA056-250G', 120000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (185, 167, 'Gói 250g', 'TRA057-250G', 840000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (186, 168, 'Gói 250g', 'TRA058-250G', 720000.00, 672000.00, 50, 1);
INSERT INTO `product_variants` VALUES (187, 169, 'Gói 250g', 'TRA069-250G', 324000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (188, 170, 'Gói 250g', 'TRA070-250G', 228000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (189, 171, 'Gói 250g', 'TRA071-250G', 432000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (190, 172, 'Gói 250g', 'TRA072-250G', 288000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (191, 173, 'Gói 250g', 'TRA073-250G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (192, 174, 'Gói 250g', 'TRA074-250G', 360000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (193, 175, 'Gói 250g', 'TRA075-250G', 600000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (194, 177, 'Gói 250g', 'TRA076-250G', 168000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (195, 178, 'Gói 250g', 'TRA077-250G', 144000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (196, 179, 'Gói 250g', 'TRA078-250G', 720000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (197, 180, 'Gói 250g', 'TRA079-250G', 840000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (198, 181, 'Gói 250g', 'TRA080-250G', 240000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (199, 182, 'Gói 250g', 'TRA081-250G', 528000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (200, 183, 'Gói 250g', 'TRA082-250G', 336000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (201, 184, 'Gói 250g', 'TRA083-250G', 288000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (202, 185, 'Gói 250g', 'TRA084-250G', 456000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (203, 186, 'Gói 250g', 'TRA085-250G', 504000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (204, 187, 'Gói 250g', 'TRA086-250G', 216000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (205, 188, 'Gói 250g', 'TRA087-250G', 1200000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (206, 191, 'Gói 250g', 'TRA091-250G', 156000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (207, 192, 'Gói 250g', 'TRA092-250G', 360000.00, 324000.00, 50, 1);
INSERT INTO `product_variants` VALUES (208, 193, 'Gói 250g', 'TRA093-250G', 504000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (209, 194, 'Gói 250g', 'TRA094-250G', 180000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (210, 195, 'Gói 250g', 'TRA095-250G', 144000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (211, 196, 'Gói 250g', 'TRA096-250G', 264000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (212, 197, 'Gói 250g', 'TRA097-250G', 192000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (213, 198, 'Gói 250g', 'TRA098-250G', 204000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (214, 199, 'Gói 250g', 'TRA099-250G', 384000.00, 0.00, 50, 1);
INSERT INTO `product_variants` VALUES (215, 200, 'Gói 250g', 'TRA100-250G', 960000.00, 912000.00, 50, 1);
INSERT INTO `product_variants` VALUES (255, 1, 'Túi 500g', 'NL101-500G', 145000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (256, 2, 'Túi 500g', 'NL102-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (257, 3, 'Túi 500g', 'NL103-500G', 180000.00, 160000.00, 98, 1);
INSERT INTO `product_variants` VALUES (258, 4, 'Túi 500g', 'NL104-500G', 110000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (259, 5, 'Túi 500g', 'NL105-500G', 75000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (260, 6, 'Túi 500g', 'NL106-500G', 85000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (261, 7, 'Túi 500g', 'NL107-500G', 90000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (262, 8, 'Túi 500g', 'NL108-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (263, 9, 'Túi 500g', 'NL109-500G', 120000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (264, 10, 'Túi 500g', 'NL110-500G', 135000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (265, 11, 'Túi 500g', 'NL111-500G', 50000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (266, 12, 'Túi 500g', 'NL112-500G', 160000.00, 140000.00, 100, 1);
INSERT INTO `product_variants` VALUES (267, 13, 'Túi 500g', 'NL113-500G', 115000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (268, 14, 'Túi 500g', 'NL114-500G', 60000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (269, 15, 'Túi 500g', 'NL115-500G', 40000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (270, 16, 'Túi 500g', 'NL116-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (271, 17, 'Túi 500g', 'NL117-500G', 35000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (272, 18, 'Túi 500g', 'NL118-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (273, 19, 'Túi 500g', 'NL119-500G', 130000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (274, 20, 'Túi 500g', 'NL120-500G', 55000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (275, 21, 'Túi 500g', 'NL121-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (276, 22, 'Túi 500g', 'NL122-500G', 70000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (277, 23, 'Túi 500g', 'NL123-500G', 85000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (278, 24, 'Túi 500g', 'NL124-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (279, 25, 'Túi 500g', 'NL125-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (280, 26, 'Túi 500g', 'NL126-500G', 85000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (281, 27, 'Túi 500g', 'NL127-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (282, 28, 'Túi 500g', 'NL128-500G', 90000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (283, 29, 'Túi 500g', 'NL129-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (284, 30, 'Túi 500g', 'NL130-500G', 110000.00, 95000.00, 100, 1);
INSERT INTO `product_variants` VALUES (285, 31, 'Túi 500g', 'NL131-500G', 90000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (286, 32, 'Túi 500g', 'NL132-500G', 120000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (287, 33, 'Túi 500g', 'NL133-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (288, 34, 'Túi 500g', 'NL134-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (289, 35, 'Túi 500g', 'NL135-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (290, 36, 'Túi 500g', 'NL136-500G', 130000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (291, 37, 'Túi 500g', 'NL137-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (292, 38, 'Túi 500g', 'NL138-500G', 40000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (293, 39, 'Túi 500g', 'NL139-500G', 50000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (294, 40, 'Túi 500g', 'NL140-500G', 35000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (295, 41, 'Túi 500g', 'NL141-500G', 50000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (296, 42, 'Túi 500g', 'NL142-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (297, 43, 'Túi 500g', 'NL143-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (298, 44, 'Túi 500g', 'NL144-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (299, 45, 'Túi 500g', 'NL145-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (300, 46, 'Túi 500g', 'NL146-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (301, 47, 'Túi 500g', 'NL147-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (302, 48, 'Túi 500g', 'NL148-500G', 48000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (303, 49, 'Túi 500g', 'NL149-500G', 48000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (304, 50, 'Túi 500g', 'NL150-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (305, 51, 'Túi 500g', 'NL151-500G', 70000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (306, 52, 'Túi 500g', 'NL152-500G', 40000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (307, 53, 'Túi 500g', 'NL153-500G', 150000.00, 135000.00, 100, 1);
INSERT INTO `product_variants` VALUES (308, 54, 'Túi 500g', 'NL154-500G', 55000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (309, 55, 'Túi 500g', 'NL155-500G', 50000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (310, 56, 'Túi 500g', 'NL156-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (311, 57, 'Túi 500g', 'NL157-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (312, 59, 'Túi 500g', 'NL159-500G', 105000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (313, 60, 'Túi 500g', 'NL160-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (314, 61, 'Túi 500g', 'NL161-500G', 85000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (315, 62, 'Túi 500g', 'NL162-500G', 125000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (316, 63, 'Túi 500g', 'NL163-500G', 180000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (317, 64, 'Túi 500g', 'NL164-500G', 115000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (318, 65, 'Túi 500g', 'NL165-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (319, 66, 'Túi 500g', 'NL166-500G', 40000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (320, 67, 'Túi 500g', 'NL167-500G', 75000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (321, 68, 'Túi 500g', 'NL168-500G', 80000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (322, 69, 'Túi 500g', 'NL169-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (323, 70, 'Túi 500g', 'NL170-500G', 90000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (324, 71, 'Túi 500g', 'NL171-500G', 120000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (325, 72, 'Túi 500g', 'NL172-500G', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (326, 73, 'Túi 500g', 'NL173-500G', 42000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (327, 74, 'Túi 500g', 'NL174-500G', 52000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (328, 75, 'Túi 500g', 'NL175-500G', 68000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (329, 76, 'Túi 500g', 'NL176-500G', 155000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (330, 77, 'Túi 500g', 'NL177-500G', 70000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (331, 78, 'Túi 500g', 'NL178-500G', 150000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (332, 79, 'Túi 500g', 'NL179-500G', 110000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (333, 80, 'Túi 500g', 'NL180-500G', 120000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (334, 81, 'Túi 500g', 'NL181-500G', 125000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (335, 82, 'Túi 500g', 'NL182-500G', 90000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (336, 83, 'Túi 500g', 'NL183-500G', 130000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (337, 84, 'Túi 500g', 'NL184-500G', 75000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (338, 85, 'Túi 500g', 'NL185-500G', 55000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (339, 86, 'Túi 500g', 'NL186-500G', 140000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (340, 87, 'Túi 500g', 'NL187-500G', 160000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (341, 88, 'Túi 500g', 'NL188-500G', 165000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (342, 89, 'Túi 500g', 'NL189-500G', 100000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (343, 90, 'Túi 500g', 'NL190-500G', 70000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (344, 91, 'Túi 500g', 'NL191-500G', 250000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (345, 92, 'Túi 500g', 'NL192-500G', 60000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (346, 93, 'Túi 500g', 'NL193-500G', 135000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (347, 94, 'Túi 500g', 'NL194-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (348, 95, 'Túi 500g', 'NL195-500G', 150000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (349, 96, 'Túi 500g', 'NL196-500G', 85000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (350, 97, 'Túi 500g', 'NL197-500G', 155000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (351, 98, 'Túi 500g', 'NL198-500G', 99000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (352, 99, 'Túi 500g', 'NL199-500G', 145000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (353, 100, 'Túi 500g', 'NL200-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (354, 113, 'Túi 500g', 'NL001-500G', 100000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (355, 114, 'Túi 500g', 'NL002-500G', 95000.00, 0.00, 99, 1);
INSERT INTO `product_variants` VALUES (356, 118, 'Túi 500g', 'NL003-500G', 140000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (357, 136, 'Túi 500g', 'NL004-500G', 45000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (358, 142, 'Túi 500g', 'NL005-500G', 105000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (359, 143, 'Túi 500g', 'NL006-500G', 70000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (360, 144, 'Túi 500g', 'NL007-500G', 140000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (361, 148, 'Túi 500g', 'NL008-500G', 160000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (362, 159, 'Túi 500g', 'NL009-500G', 65000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (363, 176, 'Túi 500g', 'NL010-500G', 180000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (364, 189, 'Túi 500g', 'TRA089-500G', 115000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (365, 190, 'Túi 500g', 'NL011-500G', 145000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (382, 1, 'Túi 1kg', 'NL101-1KG', 275500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (383, 2, 'Túi 1kg', 'NL102-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (384, 3, 'Túi 1kg', 'NL103-1KG', 342000.00, 304000.00, 100, 1);
INSERT INTO `product_variants` VALUES (385, 4, 'Túi 1kg', 'NL104-1KG', 209000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (386, 5, 'Túi 1kg', 'NL105-1KG', 142500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (387, 6, 'Túi 1kg', 'NL106-1KG', 161500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (388, 7, 'Túi 1kg', 'NL107-1KG', 171000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (389, 8, 'Túi 1kg', 'NL108-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (390, 9, 'Túi 1kg', 'NL109-1KG', 228000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (391, 10, 'Túi 1kg', 'NL110-1KG', 256500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (392, 11, 'Túi 1kg', 'NL111-1KG', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (393, 12, 'Túi 1kg', 'NL112-1KG', 304000.00, 266000.00, 100, 1);
INSERT INTO `product_variants` VALUES (394, 13, 'Túi 1kg', 'NL113-1KG', 218500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (395, 14, 'Túi 1kg', 'NL114-1KG', 114000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (396, 15, 'Túi 1kg', 'NL115-1KG', 76000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (397, 16, 'Túi 1kg', 'NL116-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (398, 17, 'Túi 1kg', 'NL117-1KG', 66500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (399, 18, 'Túi 1kg', 'NL118-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (400, 19, 'Túi 1kg', 'NL119-1KG', 247000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (401, 20, 'Túi 1kg', 'NL120-1KG', 104500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (402, 21, 'Túi 1kg', 'NL121-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (403, 22, 'Túi 1kg', 'NL122-1KG', 133000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (404, 23, 'Túi 1kg', 'NL123-1KG', 161500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (405, 24, 'Túi 1kg', 'NL124-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (406, 25, 'Túi 1kg', 'NL125-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (407, 26, 'Túi 1kg', 'NL126-1KG', 161500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (408, 27, 'Túi 1kg', 'NL127-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (409, 28, 'Túi 1kg', 'NL128-1KG', 171000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (410, 29, 'Túi 1kg', 'NL129-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (411, 30, 'Túi 1kg', 'NL130-1KG', 209000.00, 180500.00, 100, 1);
INSERT INTO `product_variants` VALUES (412, 31, 'Túi 1kg', 'NL131-1KG', 171000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (413, 32, 'Túi 1kg', 'NL132-1KG', 228000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (414, 33, 'Túi 1kg', 'NL133-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (415, 34, 'Túi 1kg', 'NL134-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (416, 35, 'Túi 1kg', 'NL135-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (417, 36, 'Túi 1kg', 'NL136-1KG', 247000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (418, 37, 'Túi 1kg', 'NL137-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (419, 38, 'Túi 1kg', 'NL138-1KG', 76000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (420, 39, 'Túi 1kg', 'NL139-1KG', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (421, 40, 'Túi 1kg', 'NL140-1KG', 66500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (422, 41, 'Túi 1kg', 'NL141-1KG', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (423, 42, 'Túi 1kg', 'NL142-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (424, 43, 'Túi 1kg', 'NL143-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (425, 44, 'Túi 1kg', 'NL144-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (426, 45, 'Túi 1kg', 'NL145-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (427, 46, 'Túi 1kg', 'NL146-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (428, 47, 'Túi 1kg', 'NL147-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (429, 48, 'Túi 1kg', 'NL148-1KG', 91200.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (430, 49, 'Túi 1kg', 'NL149-1KG', 91200.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (431, 50, 'Túi 1kg', 'NL150-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (432, 51, 'Túi 1kg', 'NL151-1KG', 133000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (433, 52, 'Túi 1kg', 'NL152-1KG', 76000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (434, 53, 'Túi 1kg', 'NL153-1KG', 285000.00, 256500.00, 100, 1);
INSERT INTO `product_variants` VALUES (435, 54, 'Túi 1kg', 'NL154-1KG', 104500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (436, 55, 'Túi 1kg', 'NL155-1KG', 95000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (437, 56, 'Túi 1kg', 'NL156-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (438, 57, 'Túi 1kg', 'NL157-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (439, 59, 'Túi 1kg', 'NL159-1KG', 199500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (440, 60, 'Túi 1kg', 'NL160-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (441, 61, 'Túi 1kg', 'NL161-1KG', 161500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (442, 62, 'Túi 1kg', 'NL162-1KG', 237500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (443, 63, 'Túi 1kg', 'NL163-1KG', 342000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (444, 64, 'Túi 1kg', 'NL164-1KG', 218500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (445, 65, 'Túi 1kg', 'NL165-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (446, 66, 'Túi 1kg', 'NL166-1KG', 76000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (447, 67, 'Túi 1kg', 'NL167-1KG', 142500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (448, 68, 'Túi 1kg', 'NL168-1KG', 152000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (449, 69, 'Túi 1kg', 'NL169-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (450, 70, 'Túi 1kg', 'NL170-1KG', 171000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (451, 71, 'Túi 1kg', 'NL171-1KG', 228000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (452, 72, 'Túi 1kg', 'NL172-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (453, 73, 'Túi 1kg', 'NL173-1KG', 79800.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (454, 74, 'Túi 1kg', 'NL174-1KG', 98800.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (455, 75, 'Túi 1kg', 'NL175-1KG', 129200.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (456, 76, 'Túi 1kg', 'NL176-1KG', 294500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (457, 77, 'Túi 1kg', 'NL177-1KG', 133000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (458, 78, 'Túi 1kg', 'NL178-1KG', 285000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (459, 79, 'Túi 1kg', 'NL179-1KG', 209000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (460, 80, 'Túi 1kg', 'NL180-1KG', 228000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (461, 81, 'Túi 1kg', 'NL181-1KG', 237500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (462, 82, 'Túi 1kg', 'NL182-1KG', 171000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (463, 83, 'Túi 1kg', 'NL183-1KG', 247000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (464, 84, 'Túi 1kg', 'NL184-1KG', 142500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (465, 85, 'Túi 1kg', 'NL185-1KG', 104500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (466, 86, 'Túi 1kg', 'NL186-1KG', 266000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (467, 87, 'Túi 1kg', 'NL187-1KG', 304000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (468, 88, 'Túi 1kg', 'NL188-1KG', 313500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (469, 89, 'Túi 1kg', 'NL189-1KG', 190000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (470, 90, 'Túi 1kg', 'NL190-1KG', 133000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (471, 91, 'Túi 1kg', 'NL191-1KG', 475000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (472, 92, 'Túi 1kg', 'NL192-1KG', 114000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (473, 93, 'Túi 1kg', 'NL193-1KG', 256500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (474, 94, 'Túi 1kg', 'NL194-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (475, 95, 'Túi 1kg', 'NL195-1KG', 285000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (476, 96, 'Túi 1kg', 'NL196-1KG', 161500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (477, 97, 'Túi 1kg', 'NL197-1KG', 294500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (478, 98, 'Túi 1kg', 'NL198-1KG', 188100.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (479, 99, 'Túi 1kg', 'NL199-1KG', 275500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (480, 100, 'Túi 1kg', 'NL200-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (481, 113, 'Túi 1kg', 'NL001-1KG', 190000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (482, 114, 'Túi 1kg', 'NL002-1KG', 180500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (483, 118, 'Túi 1kg', 'NL003-1KG', 266000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (484, 136, 'Túi 1kg', 'NL004-1KG', 85500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (485, 142, 'Túi 1kg', 'NL005-1KG', 199500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (486, 143, 'Túi 1kg', 'NL006-1KG', 133000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (487, 144, 'Túi 1kg', 'NL007-1KG', 266000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (488, 148, 'Túi 1kg', 'NL008-1KG', 304000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (489, 159, 'Túi 1kg', 'NL009-1KG', 123500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (490, 176, 'Túi 1kg', 'NL010-1KG', 342000.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (491, 189, 'Túi 1kg', 'TRA089-1KG', 218500.00, 0.00, 100, 1);
INSERT INTO `product_variants` VALUES (492, 190, 'Túi 1kg', 'NL011-1KG', 275500.00, 0.00, 100, 1);

-- ----------------------------
-- Table structure for products
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 202 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of products
-- ----------------------------
INSERT INTO `products` VALUES (1, 'Bột Sữa Khoai Môn Cao Cấp', 'bot-sua-khoai-mon', 'Bột sữa khoai môn (Taro Milk Powder) là nguyên liệu không thể thiếu để pha chế món trà sữa khoai môn \"thần thánh\". Sản phẩm có màu tím nhạt tự nhiên đẹp mắt, hương thơm khoai môn nồng nàn quyến rũ và vị béo ngậy đặc trưng. Bột mịn, dễ hòa tan, không bị vón cục, giúp ly trà sữa của bạn chuẩn vị quán.', 'Hương khoai môn nồng nàn, màu tím đẹp mắt.', 145000.00, 0.00, 'NL101', 200, 2, 'assets/images/bot-sua_khoai_mon_2.png', 1, 'active', 'Bột kem béo, tinh chất khoai môn, đường, màu thực phẩm tự nhiên.', 'Hòa tan 30g bột với 100ml nước nóng, thêm trà và sữa đặc.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (2, 'Bột Cacao Nguyên Chất', 'bot-cacao', 'Bột Cacao được nghiền từ những hạt cacao lên men chất lượng cao. Vị đắng đậm đà, hậu ngọt nhẹ, không pha tạp chất. Thích hợp để làm Chocolate đá xay, Cacao nóng, rắc mặt Tiramisu hoặc pha chế các loại đồ uống đá xay (Ice Blended).', 'Vị đắng đậm đà, làm đá xay cực ngon.', 95000.00, 0.00, 'NL102', 200, 2, 'assets/images/bot_cacao_1.png', 0, 'active', '100% hạt cacao nghiền mịn.', 'Pha 2 thìa bột với sữa đặc và nước nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (3, 'Bột Cacao Thượng Hạng (Premium)', 'bot-ca-cao-thuong-hang', 'Dòng Cacao cao cấp với hàm lượng bơ cacao cao hơn, mang lại độ béo ngậy và hương thơm nồng nàn hơn hẳn loại thường. Sản phẩm tan nhanh trong nước lạnh, rất tiện lợi cho các Barista chuyên nghiệp. Màu nâu đỏ sang trọng, vị đắng dịu tinh tế.', 'Hàm lượng bơ cacao cao, tan nhanh, béo ngậy.', 180000.00, 160000.00, 'NL103', 200, 2, 'assets/images/bot_ca_cao_thuong_hang_1.png', 1, 'active', 'Bột cacao nguyên chất tách béo một phần.', 'Dùng làm sốt socola hoặc pha đồ uống cao cấp.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (4, 'Bột Frappe (Bột Mix) Dans', 'bot-frappe-dans', 'Bí quyết để món đá xay (Smoothie/Ice Blended) lâu tan và sánh mịn như kem. Bột Frappe Dans giúp liên kết các nguyên liệu, chống tách lớp nước và đá, tạo độ dẻo dai cho đồ uống. Hàng Việt Nam chất lượng cao, giá thành hợp lý cho các chủ quán.', 'Chống tách lớp, giúp đá xay sánh mịn.', 110000.00, 0.00, 'NL104', 200, 2, 'assets/images/bot_frappe_dans_1.png', 0, 'active', 'Maltodextrin, chất ổn định thực phẩm.', 'Sử dụng 10-15g cho một ly đá xay 500ml.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (5, 'Bột Kem Béo Thực Vật Creamer X', 'bot-kem-beo-creamer-x', 'Dòng bột kem béo chuyên dụng để pha trà sữa Đài Loan. Creamer X tôn lên vị trà đậm đà mà không làm mất đi mùi hương đặc trưng của trà. Độ béo vừa phải (32%), vị ngọt thanh, giúp ly trà sữa có độ sánh và ngậy hoàn hảo.', 'Tôn vị trà, độ béo 32%, chuyên pha trà sữa.', 75000.00, 0.00, 'NL105', 200, 2, 'assets/images/bot_kem_beo_creamerX_1.png', 1, 'active', 'Sirô glucose, dầu cọ tinh luyện, chất nhũ hóa.', 'Pha trực tiếp vào cốt trà nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (6, 'Bột Sữa Béo Hà Lan (Kievit)', 'bot-kem-beo-ha-lan', 'Nhập khẩu từ Hà Lan (Indo), đây là \"tượng đài\" trong làng nguyên liệu trà sữa. Bột sữa Kievit có độ béo cao, vị sữa thơm lừng nhưng không ngấy. Khi pha với hồng trà sẽ cho ra màu nâu sữa sáng đẹp mắt, vị béo quyện với vị chát của trà tạo nên hương vị trà sữa truyền thống chuẩn mực.', 'Nhập khẩu Hà Lan, vị béo thơm lừng, chuẩn vị truyền thống.', 85000.00, 0.00, 'NL106', 200, 2, 'assets/images/bot_kem_beo_halan_1.png', 1, 'active', 'Tinh bột sắn, dầu hạt cọ hydro hóa.', 'Tỷ lệ vàng: 1 trà : 3 bột sữa : 2 đường.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (7, 'Bột Kem Béo Hàn Quốc (Frima)', 'bot-kem-beo-korea', 'Dòng bột kem không sữa (Non-dairy creamer) nổi tiếng của tập đoàn Dongsuh Hàn Quốc. Frima có vị sữa thanh hơn, ít béo hơn dòng Hà Lan, phù hợp với gu trà sữa hiện đại, nhẹ nhàng (Light milk tea). Rất hợp để pha cà phê sữa hoặc trà sữa gạo rang.', 'Vị sữa thanh nhẹ, gu Hàn Quốc, pha cà phê ngon.', 90000.00, 0.00, 'NL107', 200, 2, 'assets/images/bot_kem_beo_koera_1.png', 0, 'active', 'Dầu thực vật, đường, casein.', 'Dùng thay thế sữa tươi trong pha chế.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (8, 'Bột Kem Béo Thái Lan (B-One)', 'bot-kem-beo-thai-lan', 'Nguyên liệu chính để làm nên ly trà sữa Thái Xanh/Thái Đỏ đậm đà béo ngậy. Bột B-One có độ béo cực cao, giúp đồ uống sánh đặc, dậy mùi. Ngoài ra còn dùng để nấu súp, làm bánh hoặc sốt kem.', 'Độ béo cực cao, chuyên trị trà sữa Thái.', 65000.00, 0.00, 'NL108', 200, 2, 'assets/images/bot_kem_beo_thai_lan_1.png', 0, 'active', 'Chất béo thực vật, đường kính.', 'Hòa tan trong nước nóng, không cần đun sôi.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (9, 'Bột Làm Kem Trứng (Egg Pudding)', 'bot-kem-chung', 'Tự làm Pudding trứng núng nính, mềm tan ngay tại nhà chỉ trong 10 phút. Bột đã được pha sẵn tỷ lệ chuẩn, chỉ cần nấu sôi với đường và nước. Pudding thành phẩm có màu vàng tươi, thơm mùi trứng sữa, là topping \"best seller\" của mọi quán trà sữa.', 'Làm pudding trứng núng nính, mềm tan.', 120000.00, 0.00, 'NL109', 200, 2, 'assets/images/bot_kem_chung_1.png', 1, 'active', 'Bột trứng, bột sữa, carrageenan.', 'Tỷ lệ 100g bột : 1 lít nước : 100g đường.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (10, 'Bột Làm Chè Khúc Bạch (Panna Cotta)', 'bot-khuc-bach', 'Giải pháp làm chè khúc bạch nhanh gọn, không cần gelatin lá lỉnh kỉnh. Bột tạo đông tốt, kết cấu mềm dẻo, dai nhẹ, thơm mùi phô mai và hạnh nhân. Có thể biến tấu thành Panna Cotta kiểu Ý dễ dàng.', 'Làm khúc bạch nhanh gọn, dẻo dai, thơm hạnh nhân.', 135000.00, 0.00, 'NL110', 200, 2, 'assets/images/bot_khuc_bach_1.png', 0, 'active', 'Gelatin bột, bột kem béo, hương hạnh nhân.', 'Nấu với sữa tươi và kem whipping.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (11, 'Bột Gelatin (Thay Thế Lá)', 'bot-la-gelatin', 'Gelatin dạng bột tiện lợi, dễ cân đo, dùng để làm đông các loại bánh mousse, cheesecake, thạch, kẹo dẻo. Độ đông (Bloom) tiêu chuẩn 250, giúp bánh đứng form tốt mà vẫn mềm mịn, tan trong miệng.', 'Tạo đông bánh Mousse, thạch, kẹo dẻo.', 50000.00, 0.00, 'NL111', 200, 2, 'assets/images/bot_la_gelatin_1.png', 0, 'active', '100% Gelatin chiết xuất từ da động vật.', 'Ngâm nước lạnh 15 phút cho nở rồi đun chảy.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (12, 'Bột Matcha Đài Loan', 'bot-matcha', 'Bột trà xanh Matcha chuyên dùng cho pha chế (Cooking grade). Màu xanh tươi sáng, vị chát nhẹ đặc trưng, hương thơm thoang thoảng. Dùng làm Matcha đá xay, Matcha Latte hoặc làm bánh bông lan trà xanh màu lên rất đẹp.', 'Màu xanh tươi, chuyên làm đá xay, làm bánh.', 160000.00, 140000.00, 'NL112', 200, 2, 'assets/images/bot_matcha_1.png', 0, 'active', 'Lá trà xanh nghiền mịn.', 'Rây bột trước khi dùng để tránh vón cục.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (13, 'Bột Milk Foam Vị Vàng Sữa (Cheese)', 'bot-milkfoam-vang-sua', 'Tạo lớp kem mặn (Macchiato) thần thánh chỉ trong 2 phút đánh bông. Bột Milk Foam vị Vàng Sữa (Phô mai mặn) có vị béo ngậy, mặn nhẹ, sánh đặc, không bị chìm khi rót lên mặt trà. Giải pháp thay thế whipping cream đắt đỏ cho các quán.', 'Tạo lớp kem mặn phô mai, sánh đặc, đánh bông nhanh.', 115000.00, 0.00, 'NL113', 200, 2, 'assets/images/bot_milkFoam_vang_sua_2.png', 1, 'active', 'Bột kem béo, bột phô mai, muối biển.', 'Đánh bông 100g bột với 160ml nước lạnh.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (14, 'Bột Phô Mai Lắc (Cheese Powder)', 'bot-pho-mai', 'Bột phô mai màu cam đậm, vị mặn ngọt béo ngậy. Chuyên dùng để rắc lên khoai tây lách (khoai tây lắc), khoai lang lắc hoặc làm lớp foam phô mai cho trà sữa. Hương vị phô mai Cheddar đậm đà kích thích vị giác.', 'Rắc khoai tây lắc, làm sốt phô mai.', 60000.00, 0.00, 'NL114', 200, 2, 'assets/images/bot_pho_mai_1.png', 0, 'active', 'Bột phô mai, đường, muối, gia vị.', 'Rắc trực tiếp lên đồ ăn nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (15, 'Bột Rau Câu Giòn (Agar Agar)', 'bot-rau-cau', 'Bột rau câu Agar nguyên chất, tạo độ giòn sần sật. Thích hợp làm thạch rau câu truyền thống, thạch sơn thủy, hoặc topping trà sữa dạng giòn. Độ đông kết cao, chỉ cần lượng nhỏ bột là đông được nhiều nước.', 'Làm thạch giòn sần sật, độ đông cao.', 40000.00, 0.00, 'NL115', 200, 2, 'assets/images/bot_rau_cau_1.png', 0, 'active', '100% chiết xuất rong câu chỉ vàng.', 'Ngâm nước 30 phút trước khi nấu.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (16, 'Bột Rau Câu Con Cá Thái (Jelly)', 'bot-rau-cau-ca-thai', 'Thương hiệu rau câu nổi tiếng của Thái Lan. Tạo ra loại thạch vừa giòn vừa dẻo, ít bị tách nước (chảy nước) sau khi đông. Rất được ưa chuộng để làm thạch trái cây, thạch phô mai viên.', 'Thạch vừa giòn vừa dẻo, ít tách nước, hàng Thái.', 45000.00, 0.00, 'NL116', 200, 2, 'assets/images/bot_rau_cau_ca_thai_1.png', 0, 'active', 'Bột rau câu, bột konjac.', 'Nấu sôi tan hết bột là được.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (17, 'Bột Rau Câu Con Cá Dẻo', 'bot-rau-cau-con-ca', 'Chuyên dùng để làm thạch dẻo, thạch dừa (rau câu dừa). Thành phẩm trong suốt, núng nính, có độ dai nhẹ rất ngon miệng. Có thể dùng làm lớp bao bên ngoài cho thạch phô mai, thạch củ năng.', 'Làm thạch dẻo, thạch dừa trong suốt.', 35000.00, 0.00, 'NL117', 200, 2, 'assets/images/bot_rau_cau_con_ca_1.png', 1, 'active', 'Carrageenan, bột konjac.', 'Trộn đều với đường trước khi cho vào nước sôi.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (18, 'Bột Sữa Béo Indo (Vana Blanca)', 'bot-sua-beo-kievit', 'Một dòng bột sữa khác từ Indonesia (Vana Blanca), cạnh tranh trực tiếp với Kievit. Vị sữa thanh hơn, ít ngậy hơn, giúp làm nổi bật vị trà. Phù hợp cho các dòng trà sữa Nhài (Jasmine Milk Tea) hoặc Oolong sữa.', 'Vị thanh, tôn vị trà nhài/oolong.', 80000.00, 0.00, 'NL118', 200, 2, 'assets/images/bot_sua_beo_kievit_1.png', 0, 'active', 'Chất béo thực vật, đường.', 'Hòa tan trong nước nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (19, 'Bột Làm Pudding Khoai Môn', 'bot-sua-khoai-mon-pudding', 'Bột Pudding hương khoai môn tím lịm tìm sim. Dùng làm topping trà sữa cực \"cuốn\". Pudding mềm mượt, thơm nức mũi, ăn vào tan ngay trong miệng. Màu tím pastel lên hình cực đẹp.', 'Làm topping pudding khoai môn tím lịm.', 130000.00, 0.00, 'NL119', 200, 2, 'assets/images/bot_sua_khoai_mon_1.png', 0, 'active', 'Bột sữa, bột khoai môn, chất làm đông.', 'Nấu sôi với nước và đường.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (20, 'Bột Sương Sáo Đen (Grass Jelly)', 'bot-suong-sao', 'Bột làm thạch sương sáo (thạch đen) giải nhiệt mùa hè. Mùi thảo mộc đặc trưng, thạch dai giòn, đen bóng. Ăn cùng nước cốt dừa, hạt é hoặc làm topping trà sữa đều tuyệt vời. Sản phẩm đóng gói tiện lợi, dễ nấu tại nhà.', 'Thạch đen giải nhiệt, dai giòn, thơm thảo mộc.', 55000.00, 0.00, 'NL120', 200, 2, 'assets/images/bot_suong_sao_1.png', 1, 'active', 'Lá sương sáo cô đặc, bột năng.', 'Khuấy đều tay khi nấu để tránh vón cục.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (21, 'Đào Hồng Ngâm Nước Đường (Thái Miếng)', 'dao-hong-thai-mieng', 'Những miếng đào hồng tươi ngon, giòn sần sật được ngâm trong nước đường đậm đặc. Đào có màu hồng cam tự nhiên, vị ngọt thanh, không bị bở. Đây là topping \"quốc dân\" cho món Trà Đào Cam Sả huyền thoại.', 'Đào miếng giòn sần sật, chuyên làm trà đào.', 65000.00, 0.00, 'NL121', 200, 2, 'assets/images/dao_hong_thai_mieng_1.png', 1, 'active', 'Đào tươi 57%, nước, đường, acid citric.', 'Ăn trực tiếp hoặc trang trí trà đào.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (22, 'Đào Ngâm Nước Đường (Đào Vàng)', 'dao-ngam', 'Đào vàng (Yellow Peach) bổ đôi, thịt dày, màu vàng óng ả cực kỳ đẹp mắt. Vị đào ngọt đậm, hương thơm nồng nàn hơn đào hồng. Thích hợp để làm Bingsu, trang trí bánh kem hoặc pha trà đào phong cách cổ điển.', 'Đào vàng bổ đôi, thịt dày, ngọt đậm.', 70000.00, 0.00, 'NL122', 200, 2, 'assets/images/dao_ngam_1.png', 0, 'active', 'Đào vàng, nước đường ngô.', 'Cắt lát trang trí đồ uống/bánh ngọt.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (23, 'Kem Béo Thực Vật (Topping Cream)', 'kem-beo-thuc-vat', 'Dòng kem chuyên dụng để đánh bông (Whipping) làm lớp foam sữa, trang trí bánh kem hoặc pha cà phê cốt dừa. Độ nở cao gâp 4 lần, vị vani thơm béo, đứng kem lâu và không bị chảy nước ở nhiệt độ phòng.', 'Độ nở cao, vị vani, làm foam hoặc trang trí bánh.', 85000.00, 0.00, 'NL123', 200, 2, 'assets/images/kem_beo_thuc_vat_1.png', 0, 'active', 'Nước, dầu hạt cọ hydro hóa, đường.', 'Đánh bông bằng máy ở tốc độ trung bình.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (24, 'Siro Bạc Hà (Mint Syrup)', 'siro-bac-ha', 'Màu xanh ngọc bích tuyệt đẹp cùng cảm giác mát lạnh tê đầu lưỡi. Siro Bạc Hà là nguyên liệu chính cho các món Soda Blue Ocean, Mojito hoặc Trà sữa Bạc Hà. Vị ngọt sâu, hương menthol sảng khoái đánh bay cái nóng mùa hè.', 'Màu xanh ngọc, mát lạnh, pha Soda/Mojito.', 95000.00, 0.00, 'NL124', 200, 2, 'assets/images/siro_bac_ha_1.png', 0, 'active', 'Đường mía, tinh chất bạc hà, màu thực phẩm.', 'Tỷ lệ 1:7 (1 phần siro : 7 phần nước).', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (25, 'Siro Cam (Orange Syrup)', 'siro-cam', 'Hương vị cam tươi mọng nước được cô đặc trong chai siro. Vị chua ngọt cân bằng, màu cam tươi sáng. Dùng để pha trà cam quế, soda cam hoặc rưới lên đá bào đều rất ngon. Bổ sung hương vị trái cây tự nhiên cho menu quán.', 'Vị cam tươi, chua ngọt cân bằng.', 80000.00, 0.00, 'NL125', 200, 2, 'assets/images/siro_cam_1.png', 0, 'active', 'Nước cốt cam cô đặc, đường.', 'Pha chế đồ uống đá xay, trà trái cây.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (26, 'Siro Chanh Dây (Passion Fruit)', 'siro-chanh-day', 'Vị chua thanh đặc trưng và hương thơm quyến rũ của chanh dây (mắc mát). Sản phẩm có màu vàng tươi, giúp kích thích vị giác mạnh mẽ. Là \"best seller\" trong các dòng siro trái cây nhờ tính ứng dụng cao: từ trà chanh dây, soda đến sữa chua đánh đá.', 'Chua thanh, thơm nồng, làm trà chanh dây cực đỉnh.', 85000.00, 0.00, 'NL126', 200, 2, 'assets/images/siro_chanh_day_1.png', 1, 'active', 'Cốt chanh dây, đường.', 'Lắc đều trước khi sử dụng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (27, 'Siro Dâu Tây (Strawberry Syrup)', 'siro-dau', 'Màu đỏ quyến rũ và hương thơm ngọt ngào của dâu tây Đà Lạt. Siro có độ sánh tốt, vị ngọt đậm đà. Chuyên dùng cho món Trà sữa dâu, Sữa tươi lắc dâu hoặc làm lớp sốt chảy trên thành ly (wall cup) đẹp mắt.', 'Màu đỏ đẹp, ngọt ngào, pha trà sữa dâu.', 80000.00, 0.00, 'NL127', 200, 2, 'assets/images/siro_dau_1.png', 1, 'active', 'Nước ép dâu tây, đường fructose.', 'Dùng 20ml cho ly 500ml.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (28, 'Siro Dừa (Coconut Syrup)', 'siro-dua', 'Hương vị béo ngậy, thơm lừng của cốt dừa tươi. Không cần lích kích nạo dừa, chỉ cần một chút siro là có ngay ly cà phê cốt dừa hay cacao dừa thơm ngon. Vị ngọt dịu, không gắt, hòa quyện tốt với sữa và cà phê.', 'Thơm béo mùi dừa, pha cà phê cốt dừa.', 90000.00, 0.00, 'NL128', 200, 2, 'assets/images/siro_dua_1.png', 0, 'active', 'Hương dừa tự nhiên, đường.', 'Pha chế cà phê, cacao, đá xay.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (29, 'Siro Dưa Lưới (Melon Syrup)', 'siro-dua-luoi', 'Mang hương thơm ngọt mát, thanh khiết của dưa lưới xanh. Màu xanh lá nhẹ nhàng rất \"chill\". Thường được dùng để pha Trà sữa dưa lưới (Melon Milk Tea) hoặc Soda dưa lưới. Hương vị lạ miệng, dễ gây nghiện.', 'Hương dưa lưới thanh mát, màu xanh lá.', 95000.00, 0.00, 'NL129', 200, 2, 'assets/images/siro_dua_luoi_1.png', 0, 'active', 'Chiết xuất dưa lưới, đường.', 'Pha với trà nhài hoặc soda.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (30, 'Siro Đường Đen (Brown Sugar)', 'siro-duong-den', 'Linh hồn của món \"Sữa tươi trân châu đường đen\". Siro đường đen có độ đậm đặc cao, màu nâu cánh gián, hương thơm caramel cháy cạnh đặc trưng. Khi rót vào ly tạo hiệu ứng đường chảy (tiger stripe) cực đẹp và bám thành ly tốt.', 'Đậm đặc, tạo vân hổ đẹp, chuyên pha sữa tươi đường đen.', 110000.00, 95000.00, 'NL130', 200, 2, 'assets/images/siro_duong_den_1.png', 1, 'active', 'Đường mía nâu cô đặc, hương caramel.', 'Rót quanh thành ly trước khi cho sữa.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (31, 'Siro Kiwi (Kiwi Syrup)', 'siro-kiwi', 'Vị chua dịu và màu xanh bắt mắt của trái Kiwi nhiệt đới. Siro Kiwi rất hợp khi mix cùng trà xanh hoặc sữa chua. Tạo nên ly đồ uống vừa ngon miệng vừa giàu vitamin, giải nhiệt cực tốt.', 'Vị chua dịu, màu xanh, pha trà trái cây.', 90000.00, 0.00, 'NL131', 200, 2, 'assets/images/siro_kiwi_1.png', 0, 'active', 'Nước ép kiwi, đường.', 'Pha Soda Kiwi hoặc sinh tố.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (32, 'Siro Măng Cụt (Mangosteen)', 'siro-mang-cut', 'Hương vị \"Nữ hoàng trái cây\" độc đáo. Vị chua ngọt thanh tao, màu tím hồng lạ mắt. Đây là hương vị \"hot trend\" mới nổi, dùng để pha món Trà Măng Cụt đang làm mưa làm gió trên thị trường.', 'Hot trend trà măng cụt, vị chua ngọt thanh tao.', 120000.00, 0.00, 'NL132', 200, 2, 'assets/images/siro_mang_cut_1.png', 1, 'active', 'Cốt măng cụt, đường phèn.', 'Pha với trà xanh nhài.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (33, 'Siro Nho Đen (Grape Syrup)', 'siro-nho', 'Mùi thơm nồng nàn như kẹo nho, màu tím đậm quyến rũ. Siro nho rất được trẻ em yêu thích. Dùng để pha trà sữa nho, soda nho hoặc làm thạch rau câu vị nho.', 'Thơm mùi kẹo nho, màu tím đậm.', 80000.00, 0.00, 'NL133', 200, 2, 'assets/images/siro_nho_1.png', 0, 'active', 'Hương nho tổng hợp, màu thực phẩm.', 'Pha chế đồ uống giải khát.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (34, 'Siro Ổi Hồng (Pink Guava)', 'siro-oi', 'Hương thơm ngào ngạt của ổi xá lị chín. Màu hồng san hô tuyệt đẹp (Pink Guava). Vị chát nhẹ vỏ ổi và ngọt lịm ruột ổi được tái hiện hoàn hảo. Món Trà Ổi Hồng là best seller tại nhiều chuỗi cửa hàng lớn.', 'Thơm lừng ổi chín, màu hồng san hô, pha trà ổi.', 95000.00, 0.00, 'NL134', 200, 2, 'assets/images/siro_oi_1.png', 1, 'active', 'Mứt ổi hồng, đường, hương liệu.', 'Pha với trà Oolong hoặc trà nhài.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (35, 'Siro Đào (Peach Syrup)', 'si_ro_dao', 'Nguyên liệu nền tảng cho ly trà đào đậm vị. Nếu chỉ dùng đào ngâm thì nước sẽ nhạt, thêm 20ml siro đào này sẽ giúp ly trà dậy mùi thơm nức mũi và có màu vàng cam đẹp mắt hơn hẳn.', 'Dậy mùi trà đào, màu vàng cam đẹp.', 80000.00, 0.00, 'NL135', 200, 2, 'assets/images/si_ro_dao_1.png', 1, 'active', 'Cốt đào cô đặc, đường.', 'Kết hợp với đào ngâm để pha trà đào.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (36, 'Tép Bưởi Hồng (Pomelo Pulp)', 'tep-buoi-hong', 'Topping cao cấp dạng tép (pulp) tự nhiên. Tép bưởi hồng mọng nước, khi cắn vào nổ tanh tách trong miệng rất thú vị. Vị chua nhẹ, không bị đắng. Chuyên dùng cho món Trà Bưởi Mật Ong hoặc Trà Dương Chi Cam Lộ.', 'Tép bưởi mọng nước, không đắng, topping cao cấp.', 130000.00, 0.00, 'NL136', 200, 2, 'assets/images/tep_buoi_hong_1.png', 0, 'active', 'Tép bưởi tươi 80%, đường.', 'Múc trực tiếp vào ly trà.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (37, 'Thạch Cá 4 Màu (Jelly Fish)', 'thach-ca-4-mau-douxian', 'Những chú cá thạch nhỏ xinh với 4 màu sắc rực rỡ. Thạch dai dai, dẻo dẻo, nhai vui miệng. Là topping yêu thích của học sinh, sinh viên. Giúp ly trà sữa thêm phần sinh động và bắt mắt.', 'Hình cá dễ thương, 4 màu rực rỡ, dai dẻo.', 45000.00, 0.00, 'NL137', 200, 2, 'assets/images/thach_ca_4_mau_douxian_1.png', 0, 'active', 'Bột rau câu, đường, màu thực phẩm.', 'Dùng trực tiếp (đã ngâm nước đường).', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (38, 'Thạch Dừa Thô (Nata De Coco)', 'thach-dua-coco', 'Thạch dừa Bến Tre lên men tự nhiên. Cắt vuông hạt lựu, màu trắng trong, vị ngọt thanh, giòn sần sật. Đây là topping truyền thống nhưng chưa bao giờ hết hot, hợp với mọi loại trà sữa và trà trái cây.', 'Thạch dừa Bến Tre, giòn sần sật, ngọt thanh.', 40000.00, 0.00, 'NL138', 200, 2, 'assets/images/thach_dua_coco_1.png', 1, 'active', 'Nước dừa già lên men.', 'Múc ăn liền (bỏ nước ngâm nếu muốn giảm ngọt).', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (39, 'Thạch Rau Câu Vị Kiwi', 'thach-huong-kiwi', 'Thạch rau câu có sẵn vị Kiwi chua ngọt, cắt hạt lựu tiện lợi. Màu xanh lá trong suốt đẹp mắt. Khi nhai cảm nhận được độ giòn và hương thơm kiwi lan tỏa. Tiết kiệm thời gian nấu thạch cho chủ quán.', 'Thạch làm sẵn vị kiwi, màu xanh, giòn ngon.', 50000.00, 0.00, 'NL139', 200, 2, 'assets/images/thach_huong_kiwi_1.png', 0, 'active', 'Rau câu, hương kiwi, đường.', 'Dùng làm topping trà sữa, trà trái cây.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (40, 'Thạch Rau Câu Thủy Tinh (Cắt Sẵn)', 'thach-rau-cau-cat', 'Thạch rau câu truyền thống nhưng được cắt máy đều tăm tắp. Màu trắng trong suốt như thủy tinh, vị ngọt nhẹ, giòn dai cân bằng. Dễ dàng nhuộm màu bằng siro để tạo ra nhiều phiên bản thạch sắc màu.', 'Trong suốt như thủy tinh, cắt sẵn tiện lợi.', 35000.00, 0.00, 'NL140', 200, 2, 'assets/images/thach_rau_cau_cat_1.png', 0, 'active', 'Bột rau câu dẻo, đường.', 'Có thể ngâm siro để tạo màu.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (41, 'Thạch Trân Châu Trắng Đen (Konjac)', 'thach-tran-chau-trang-den', 'Một sự đánh lừa thị giác thú vị! Nhìn giống hệt trân châu đen truyền thống nhưng thực chất là thạch Konjac giòn dai sần sật. Ưu điểm là không bị cứng khi bỏ tủ lạnh, ăn rất vui miệng. Sự kết hợp 2 màu trắng đen tạo điểm nhấn bắt mắt cho ly trà sữa.', 'Nhìn giống trân châu nhưng giòn sần sật, không bị cứng.', 50000.00, 0.00, 'NL141', 200, 2, 'assets/images/thach_tran_chau_trang_den_1.png', 0, 'active', 'Bột konjac, đường, màu thực phẩm.', 'Múc trực tiếp vào ly (ăn liền).', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (42, 'Thạch Jelly Vị Cà Phê', 'thach-vi-ca-phe', 'Những viên thạch nâu bóng loáng mang hương thơm nồng nàn của cà phê rang xay. Vị đắng nhẹ quyện với vị ngọt của thạch, là \"cặp bài trùng\" không thể thiếu cho món Trà sữa Cà phê hoặc Cacao dầm.', 'Thơm lừng cà phê, vị đắng nhẹ.', 45000.00, 0.00, 'NL142', 200, 2, 'assets/images/thach_vi_ca_phe_1.png', 0, 'active', 'Rau câu, tinh chất cà phê.', 'Dùng làm topping trà sữa.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (43, 'Thạch Jelly Vị Đào (Peach Jelly)', 'thach-vi-dao', 'Thạch rau câu vị đào thơm ngát, màu hồng cam nhẹ nhàng. Vị chua ngọt hài hòa, khi nhai cảm giác như đang ăn miếng đào tươi. Cực hợp để mix cùng Trà đào cam sả hoặc Trà sữa đào.', 'Hương đào thơm ngát, chua ngọt hài hòa.', 45000.00, 0.00, 'NL143', 200, 2, 'assets/images/thach_vi_dao_1.png', 1, 'active', 'Rau câu, hương đào.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (44, 'Thạch Jelly Vị Dâu Tây', 'thach-vi-dau', 'Viên thạch đỏ mọng như ngọc ruby, mang hương thơm ngọt ngào của dâu tây. Rất được lòng các bạn nhỏ và phái nữ. Làm topping cho Trà sữa dâu hay Sữa chua đánh đá đều tuyệt vời.', 'Màu đỏ ruby, hương dâu ngọt ngào.', 45000.00, 0.00, 'NL144', 200, 2, 'assets/images/thach_vi_dau_1.png', 0, 'active', 'Rau câu, cốt dâu tây.', 'Topping trà sữa, sữa chua.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (45, 'Thạch Jelly Vị Nho', 'thach-vi-nho', 'Thạch nho màu tím biếc, vị chua dịu đặc trưng. Kết cấu dai giòn, bóng bẩy. Thường được dùng trong các món trà trái cây hiện đại hoặc soda nho.', 'Màu tím biếc, vị nho chua dịu.', 45000.00, 0.00, 'NL145', 200, 2, 'assets/images/thach_vi_nho_1.png', 0, 'active', 'Rau câu, hương nho đen.', 'Dùng trực tiếp.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (46, 'Thạch Jelly Vị Socola', 'thach-vi-socola', 'Dành cho tín đồ hảo ngọt. Thạch socola đậm đà, mềm dẻo. Ăn cùng với trà sữa truyền thống hoặc Milo dầm là \"hết nước chấm\".', 'Vị socola đậm đà, mềm dẻo.', 45000.00, 0.00, 'NL146', 200, 2, 'assets/images/thach_vi_socola_1.png', 0, 'active', 'Rau câu, bột cacao.', 'Topping trà sữa.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (47, 'Thạch Jelly Vị Táo Xanh (Green Apple)', 'thach-vi-tao', 'Màu xanh lá tươi mát mắt, hương táo xanh chua thanh kích thích vị giác. Loại thạch này giúp cân bằng độ béo của trà sữa, tạo cảm giác đỡ ngán khi uống.', 'Màu xanh tươi mát, vị táo chua thanh.', 45000.00, 0.00, 'NL147', 200, 2, 'assets/images/thach_vi_tao_1.png', 0, 'active', 'Rau câu, hương táo xanh.', 'Topping trà trái cây.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (48, 'Thạch Jelly Vị Trà Xanh (Matcha)', 'thach-vi-tra-xanh', 'Thơm mùi lá trà xanh, vị chát nhẹ tinh tế. Thạch Matcha là sự lựa chọn healthy, ít ngọt, phù hợp với các dòng trà sữa Nhật Bản hoặc Latte.', 'Thơm mùi trà, chát nhẹ tinh tế.', 48000.00, 0.00, 'NL148', 200, 2, 'assets/images/thach_vi_tra_xanh_1.png', 0, 'active', 'Rau câu, bột matcha Đài Loan.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (49, 'Thạch Jelly Vị Việt Quất (Blueberry)', 'thach-vi-viet-quat', 'Màu xanh tím than sang trọng, vị chua ngọt đậm đà của quả việt quất. Đây là loại topping cao cấp thường thấy ở các chuỗi trà sữa lớn.', 'Màu xanh tím sang trọng, vị chua ngọt.', 48000.00, 0.00, 'NL149', 200, 2, 'assets/images/thach_vi_viet_quat_1.png', 0, 'active', 'Rau câu, hương việt quất.', 'Dùng trực tiếp.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (50, 'Trân Châu Đen Andes (Hàng Đài Loan)', 'tran-chau-andes-dailoan', 'Thương hiệu trân châu số 1 Đài Loan. Hạt trân châu Andes khi nấu lên có độ bóng đẹp, dẻo dai vừa phải, để lâu không bị cứng. Hương vị caramel thơm lừng, thấm đẫm vào từng hạt trân châu.', 'Hàng chuẩn Đài Loan, dẻo dai, thơm caramel.', 65000.00, 0.00, 'NL150', 200, 2, 'assets/images/tran_chau_andes_dailoan_1.png', 1, 'active', 'Tinh bột sắn, nước, màu caramel.', 'Nấu 30 phút, ủ 30 phút.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (51, 'Trân Châu Hoàng Kim Boduo', 'tran-chau-boduo-caramel', 'Trân châu màu vàng kim óng ánh (Golden Pearl). Khác với trân châu đen, loại này có vị ngọt thanh của mật ong và đường nâu. Dai dai, dẻo dẻo, nhìn rất sang chảnh trong ly trà sữa.', 'Màu vàng kim, vị mật ong đường nâu.', 70000.00, 0.00, 'NL151', 200, 2, 'assets/images/tran_chau_boduo_caramel_1.png', 1, 'active', 'Tinh bột sắn, đường nâu.', 'Nấu kỹ trước khi dùng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (52, 'Trân Châu Đen Douxian', 'tran-chau-douxian', 'Dòng trân châu giá rẻ chất lượng ổn định. Hạt nhỏ (mini), dễ hút, độ dai tốt. Phù hợp cho các quán bình dân hoặc mô hình kinh doanh trà sữa khổng lồ.', 'Hạt nhỏ dễ hút, giá rẻ, độ dai tốt.', 40000.00, 0.00, 'NL152', 200, 2, 'assets/images/tran_chau_douxian_1.png', 0, 'active', 'Bột năng, hương liệu.', 'Nấu sôi 20 phút.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (53, 'Trân Châu 3Q Trắng (Ngọc Trai) Wings', 'tran-trau-3q-wingszion', 'Nữ hoàng topping - Trân châu 3Q (Konjac Pearl). Hạt trong suốt như ngọc trai, ăn giòn sần sật, không cần nấu (ăn liền). Vị ngọt nhẹ, thanh mát, là topping không thể thiếu của món Trà sữa trân châu trắng.', 'Ăn liền không cần nấu, giòn sần sật, hạt trong suốt.', 150000.00, 135000.00, 'NL153', 200, 2, 'assets/images/tran_trau_3q_wingszion_1.png', 1, 'active', 'Nước, đường, bột konjac, carrageenan.', 'Múc trực tiếp vào ly.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (54, 'Trân Châu Sợi (Sợi Vàng)', 'tran-trau-soi', 'Thay đổi phong cách với trân châu dạng sợi dài lạ mắt. Sợi trân châu vàng óng, mềm mượt như mì, hút lên miệng tạo cảm giác thú vị. Vị caramel đậm đà không thua kém trân châu hạt.', 'Dạng sợi lạ mắt, mềm mượt, vị caramel.', 55000.00, 0.00, 'NL154', 200, 2, 'assets/images/tran_trau_soi_1.png', 0, 'active', 'Bột sắn, màu caramel.', 'Nấu như trân châu hạt.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (55, 'Trân Châu Đen Wonderfull', 'tran-trau-wonderfull', 'Hạt trân châu size lớn (Big size), chuyên dùng cho món Sữa tươi trân châu đường đen. Hạt to, dai, nhai rất \"đã\". Khả năng thấm đường đen cực tốt, tạo độ dẻo quánh đặc trưng.', 'Size lớn, chuyên làm sữa tươi trân châu đường đen.', 50000.00, 0.00, 'NL155', 200, 2, 'assets/images/tran_trau_wonderfull_1.png', 0, 'active', 'Tinh bột sắn cao cấp.', 'Nấu kỹ để hạt chín đều.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (56, 'Vải Thiều Ngâm Nước Đường (Lon)', 'vai-thieu-ngam', 'Những trái vải thiều trắng nõn, dày cùi, bỏ hạt, ngâm trong nước đường thanh mát. Vải giữ được độ giòn và hương thơm đặc trưng. Nguyên liệu chính cho món Trà Vải (Lychee Tea) giải nhiệt mùa hè.', 'Trái vải trắng nõn, dày cùi, làm trà vải.', 65000.00, 0.00, 'NL156', 200, 2, 'assets/images/vai_thieu_ngam_1.png', 1, 'active', 'Vải thiều 56%, nước, đường.', 'Dùng cả cái và nước ngâm.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (57, 'Xí Muội Đỏ (Salted Plum)', 'xi-muoi-do', 'Xí muội (ô mai) mặn ngọt, màu đỏ tươi. Dùng để pha chế món Trà Lipton xí muội hoặc Tắc xí muội huyền thoại. Vị mặn của xí muội giúp cân bằng vị ngọt của đường, tạo nên thức uống bù khoáng cực tốt.', 'Vị mặn ngọt, pha Lipton xí muội/Tắc xí muội.', 80000.00, 0.00, 'NL157', 200, 2, 'assets/images/xi_muoi_do_1.png', 0, 'active', 'Quả mơ, muối, đường.', 'Dầm nát trong ly nước.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (58, 'Bột Khoai Môn Tím (Premium)', 'bot-khoai-mon-tim-premium', 'Dòng bột khoai môn cao cấp với hàm lượng khoai môn thật lên đến 60%. Màu tím đậm đà hơn, vị béo ngậy và thơm mùi khoai môn nướng đặc trưng. Chuyên dùng cho các món Taro Milk Tea thượng hạng.', 'Hàm lượng khoai thật cao, màu tím đậm.', 160000.00, 0.00, 'NL158', 50, 2, 'assets/images/bot-sua_khoai_mon_2.png', 0, 'inactive', 'Bột khoai môn nguyên chất, bột sữa.', 'Pha chế trà sữa khoai môn.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (59, 'Cacao Đắng Nguyên Chất (Dark)', 'cacao-dang-nguyen-chat', 'Dành cho những ai yêu thích vị đắng của Chocolate đen. Sản phẩm không chứa đường, độ đắng 70%, cực kỳ đậm vị. Thích hợp để làm cốt bánh Brownie hoặc pha cacao nóng đậm đà.', 'Vị đắng 70%, không đường, đậm đà.', 105000.00, 0.00, 'NL159', 200, 2, 'assets/images/bot_cacao_1.png', 0, 'active', '100% bột cacao tách béo.', 'Pha chế hoặc làm bánh.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (60, 'Bột Chống Tách Lớp (Mix Powder)', 'bot-chong-tach-lop', 'Giải pháp kinh tế cho các quán cà phê take-away. Bột Mix giúp đá xay lâu tan hơn, hỗn hợp sánh dẻo hơn mà không làm thay đổi hương vị gốc của đồ uống. Hàng nội địa chất lượng cao.', 'Giúp đá xay lâu tan, hỗn hợp sánh dẻo.', 95000.00, 0.00, 'NL160', 200, 2, 'assets/images/bot_frappe_dans_1.png', 0, 'active', 'Chất ổn định, Maltodextrin.', '10g cho 1 ly đá xay.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (61, 'Bột Sữa Béo Kievit (Bao Bì Mới)', 'bot-sua-beo-kievit-new', 'Phiên bản bao bì mới của bột sữa Kievit Hà Lan huyền thoại. Chất lượng vẫn giữ nguyên độ béo 35%, giúp ly trà sữa tròn vị, tôn lên hương trà và hậu vị béo ngậy khó quên.', 'Độ béo 35%, bao bì mới, hàng nhập khẩu.', 85000.00, 0.00, 'NL161', 200, 2, 'assets/images/bot_kem_beo_halan_1.png', 1, 'active', 'Tinh bột sắn, dầu thực vật.', 'Pha trà sữa truyền thống.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (62, 'Pudding Trứng Phô Mai', 'pudding-trung-pho-mai', 'Sự kết hợp giữa vị trứng béo ngậy và chút mặn nhẹ của phô mai. Bột Pudding này tạo ra thành phẩm núng nính, mềm tan, vị lạ miệng hơn so với pudding trứng truyền thống.', 'Vị trứng mix phô mai, mềm tan.', 125000.00, 0.00, 'NL162', 200, 2, 'assets/images/bot_kem_chung_1.png', 0, 'active', 'Bột trứng, bột phô mai, gelatin.', 'Nấu sôi với nước và đường.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (63, 'Matcha Uji Nhật Bản (Vụ Xuân)', 'matcha-uji-nhat-ban', 'Bột trà xanh Matcha thu hoạch vào vụ Xuân cho màu xanh ngọc bích rực rỡ nhất và vị chát dịu nhất. Dòng Matcha cao cấp này thích hợp để làm Latte Art hoặc pha chế các món Matcha lạnh.', 'Thu hoạch vụ Xuân, màu xanh ngọc bích.', 180000.00, 0.00, 'NL163', 200, 2, 'assets/images/bot_matcha_1.png', 1, 'active', '100% Matcha Nhật Bản.', 'Rây mịn trước khi dùng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (64, 'Macchiato Cheese Foam (Mặn)', 'macchiato-cheese-foam', 'Bột váng sữa vị phô mai mặn đậm đà. Lớp foam đánh lên bông xốp, đứng form lâu, vị mặn rõ rệt giúp cân bằng độ ngọt của trà sữa. Là lớp phủ hoàn hảo cho Hồng trà kem mặn.', 'Vị phô mai mặn đậm đà, đứng form lâu.', 115000.00, 0.00, 'NL164', 200, 2, 'assets/images/bot_milkFoam_vang_sua_2.png', 1, 'active', 'Bột kem, muối biển, phô mai.', 'Đánh bông với nước lạnh.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (65, 'Phô Mai Lắc Vị Cay (Spicy Cheese)', 'pho-mai-lac-vi-cay', 'Biến tấu thú vị với chút bột ớt cay nhẹ trong bột phô mai. Sản phẩm chuyên dùng cho gà rán lắc phô mai hoặc khoai tây lắc, tạo cảm giác kích thích vị giác cực mạnh.', 'Vị phô mai cay nhẹ, rắc gà rán/khoai tây.', 65000.00, 0.00, 'NL165', 200, 2, 'assets/images/bot_pho_mai_1.png', 0, 'active', 'Bột phô mai, bột ớt, gia vị.', 'Rắc trực tiếp lên đồ ăn.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (66, 'Agar Agar Giòn (Con Vịt)', 'agar-agar-gion', 'Thương hiệu rau câu Con Vịt nổi tiếng. Chuyên làm thạch giòn, thạch dừa. Độ đông kết cực nhanh và cứng cáp, thích hợp làm các loại thạch cắt hạt lựu topping.', 'Thương hiệu Con Vịt, thạch giòn cứng.', 40000.00, 0.00, 'NL166', 200, 2, 'assets/images/bot_rau_cau_1.png', 0, 'active', 'Bột rau câu nguyên chất.', 'Ngâm 30p trước khi nấu.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (67, 'Đào Ngâm Rhodes (Nam Phi)', 'dao-ngam-rhodes', 'Đào ngâm nhập khẩu từ Nam Phi. Trái đào to, thịt dày, độ giòn cao và nước ngâm rất thơm. Lon lớn 825g tiết kiệm, phù hợp cho các quán kinh doanh trà đào chuyên nghiệp.', 'Nhập khẩu Nam Phi, trái to, giòn sần sật.', 75000.00, 0.00, 'NL167', 200, 2, 'assets/images/dao_ngam_1.png', 1, 'active', 'Đào vàng, nước đường.', 'Pha trà đào.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (68, 'Whipping Cream Thực Vật (Rich\'s)', 'whipping-cream-thuc-vat', 'Kem làm bánh và pha chế đa năng. Có sẵn đường, vị ngọt nhẹ, hương vani. Đánh bông nhanh gấp 3 lần kem động vật. Dùng làm kem trang trí bánh hoặc dollop bông kem trên ly đá xay.', 'Có đường sẵn, đánh bông nhanh, đa năng.', 80000.00, 0.00, 'NL168', 200, 2, 'assets/images/kem_beo_thuc_vat_1.png', 0, 'active', 'Nước, dầu thực vật, đường.', 'Bảo quản đông lạnh.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (69, 'Siro Bạc Hà Tuyết (Snow Mint)', 'siro-bac-ha-tuyet', 'Dòng siro bạc hà trắng (trong suốt), không màu. Vẫn giữ nguyên vị the mát cực mạnh nhưng không làm đổi màu đồ uống. Thích hợp để pha chế các loại cocktail layer hoặc soda trong suốt.', 'Màu trong suốt, vị the mát mạnh.', 95000.00, 0.00, 'NL169', 200, 2, 'assets/images/siro_bac_ha_1.png', 0, 'active', 'Tinh chất bạc hà trắng.', 'Pha chế cocktail/soda.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (70, 'Mứt Sinh Tố Chanh Dây (Jam)', 'mut-sinh-to-chanh-day', 'Khác với siro (dạng lỏng), đây là mứt sinh tố đậm đặc có chứa cả hạt chanh dây tươi. Khi pha chế tạo cảm giác như dùng trái cây tươi thật. Vị chua ngọt tự nhiên, thơm nồng nàn.', 'Dạng mứt sệt, có hạt chanh dây tươi.', 90000.00, 0.00, 'NL170', 200, 2, 'assets/images/siro_chanh_day_1.png', 1, 'active', 'Cốt chanh dây 60%, đường.', 'Làm sinh tố, soda.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (71, 'Sốt Đường Nâu Hàn Quốc (Syrup)', 'sot-duong-nau-han-quoc', 'Phiên bản sốt đường nâu đậm đặc hơn, độ bám thành ly (walling) cực tốt. Vị đường cháy (Smoky) rõ rệt, chuẩn phong cách The Alley. Không bị tan nhanh trong sữa tươi.', 'Sốt đậm đặc, bám ly tốt, vị đường cháy.', 120000.00, 0.00, 'NL171', 200, 2, 'assets/images/siro_duong_den_1.png', 0, 'active', 'Đường đen cô đặc.', 'Trang trí thành ly.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (72, 'Mứt Dâu Tây Boduo (Có Xác)', 'mut-dau-tay-boduo', 'Mứt dâu tây cao cấp của hãng Boduo. Chứa 80% xác dâu tây nghiền, cho màu đỏ tự nhiên và vị chua ngọt chân thật. Thích hợp làm món Sữa tươi lắc dâu hoặc đá xay dâu.', 'Có xác dâu thật, hãng Boduo cao cấp.', 95000.00, 0.00, 'NL172', 200, 2, 'assets/images/siro_dau_1.png', 0, 'active', 'Dâu tây nghiền, đường.', 'Pha chế đồ uống đá xay.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (73, 'Thạch Dừa Sợi (Coconut Slice)', 'thach-dua-soi', 'Thay vì cắt hạt lựu, thạch dừa này được thái dạng sợi dài như sợi mì. Ăn rất vui miệng, dai dai giòn giòn. Thường dùng trong món Chè Thái hoặc Trà sữa thạch dừa sợi.', 'Dạng sợi dài lạ miệng, dai giòn.', 42000.00, 0.00, 'NL173', 200, 2, 'assets/images/thach_dua_coco_1.png', 0, 'active', 'Thạch dừa lên men.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (74, 'Thạch Konjac Trân Châu (3Q)', 'thach-konjac-tran-chau', 'Tên gọi khác của thạch trân châu trắng. Được làm từ củ Konjac (khoai nưa) nên rất ít calo, phù hợp cho người ăn kiêng (Low carb) mà vẫn thèm topping trà sữa.', 'Ít calo, giòn dai, hỗ trợ giảm cân.', 52000.00, 0.00, 'NL174', 200, 2, 'assets/images/thach_tran_chau_trang_den_1.png', 0, 'active', 'Bột Konjac, chất tạo ngọt.', 'Topping giảm cân.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (75, 'Trân Châu Đen Đường Đen (Black Sugar)', 'tran-chau-den-duong-den', 'Trân châu được tẩm ướp hương đường đen ngay từ trong lõi. Khi nấu lên tỏa mùi thơm đường cháy nồng nàn, màu đen bóng bẩy. Kết hợp hoàn hảo với sữa tươi.', 'Hương đường đen thấm trong lõi, đen bóng.', 68000.00, 0.00, 'NL175', 200, 2, 'assets/images/tran_chau_andes_dailoan_1.png', 1, 'active', 'Bột sắn, hương đường đen.', 'Nấu kỹ và ủ đường đen.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (76, 'Thạch 3Q Ngọc Trai (Magic Pearl)', 'thach-3q-ngoc-trai', 'Loại thạch trân châu 3Q cao cấp với độ giòn vượt trội. Hạt trong veo lấp lánh như ngọc trai dưới đáy ly. Vị ngọt thanh nhẹ, không làm gắt cổ.', 'Độ giòn vượt trội, hạt trong veo lấp lánh.', 155000.00, 0.00, 'NL176', 200, 2, 'assets/images/tran_trau_3q_wingszion_1.png', 1, 'active', 'Konjac, đường, nước.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (77, 'Vải Thiều Lục Ngạn (Lon)', 'vai-thieu-luc-ngan', 'Tuyển chọn từ vùng vải Lục Ngạn nổi tiếng. Trái vải to đều, hạt nhỏ, cơm dày và trắng muốt. Nước ngâm vải ngọt thanh, thơm lừng mùi vải chín, dùng để pha trà rất ngon.', 'Đặc sản Lục Ngạn, trái to, cơm dày.', 70000.00, 0.00, 'NL177', 200, 2, 'assets/images/vai_thieu_ngam_1.png', 0, 'active', 'Vải thiều tươi, nước đường.', 'Pha trà vải.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (78, 'Bột Matcha Latte 3in1', 'bot-matcha-latte-3in1', 'Giải pháp tiện lợi cho người nghiện Matcha. Bột đã được mix sẵn gồm Matcha Nhật Bản, bột sữa và đường theo tỷ lệ vàng. Chỉ cần pha với nước nóng là có ngay ly Matcha Latte thơm béo chuẩn vị quán.', 'Pha sẵn 3in1, tiện lợi, vị béo ngọt.', 150000.00, 0.00, 'NL178', 200, 2, 'assets/images/bot_matcha_1.png', 0, 'active', 'Matcha, bột kem, đường.', 'Pha 20g bột với 150ml nước nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (79, 'Siro Vỏ Cam Xanh (Blue Curacao)', 'siro-blue-curacao', 'Màu xanh đại dương tuyệt đẹp (Deep Blue). Hương vị vỏ cam đắng nhẹ đặc trưng. Nguyên liệu không thể thiếu để pha chế các món Soda Blue Ocean, Cocktail hay trà sữa đám mây.', 'Màu xanh đại dương, vị vỏ cam, pha Soda.', 110000.00, 0.00, 'NL179', 200, 2, 'assets/images/siro_bac_ha_1.png', 1, 'active', 'Tinh chất vỏ cam, màu xanh thực phẩm.', 'Tạo màu và hương cho đồ uống.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (80, 'Siro Hạt Dẻ (Hazelnut Syrup)', 'siro-hat-de', 'Hương thơm bùi béo, nồng nàn của hạt dẻ nướng. Rất hợp khi kết hợp với cà phê (Hazelnut Coffee) hoặc Trà sữa nướng. Vị ngọt ấm áp, thích hợp cho menu đồ uống mùa đông.', 'Thơm mùi hạt dẻ nướng, pha cà phê/trà sữa.', 120000.00, 0.00, 'NL180', 200, 2, 'assets/images/siro_duong_den_1.png', 0, 'active', 'Hương hạt dẻ, đường caramel.', 'Pha Latte hoặc Trà sữa.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (81, 'Siro Caramel Mặn (Salted Caramel)', 'siro-caramel-man', 'Sự cân bằng hoàn hảo giữa vị ngọt của đường cháy và chút mặn của muối biển. Tạo chiều sâu hương vị cho các món đá xay hoặc Macchiato. Vị mặn nhẹ kích thích vị giác cực mạnh.', 'Vị ngọt mặn hài hòa, caramel muối.', 125000.00, 0.00, 'NL181', 200, 2, 'assets/images/siro_duong_den_1.png', 0, 'active', 'Caramel, muối biển.', 'Pha chế đá xay, cafe.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (82, 'Siro Táo Xanh (Green Apple)', 'siro-tao-xanh', 'Vị chua thanh và hương thơm tươi mát của táo xanh. Thường dùng để pha Soda Apple, Trà thạch táo hoặc làm lớp thạch rau câu màu xanh ngọc bích.', 'Chua thanh, thơm mát mùi táo.', 90000.00, 0.00, 'NL182', 200, 2, 'assets/images/siro_kiwi_1.png', 0, 'active', 'Cốt táo xanh, đường.', 'Pha soda giải nhiệt.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (83, 'Siro Vải Hoa Hồng (Lychee Rose)', 'siro-vai-hoa-hong', 'Sự kết hợp lãng mạn giữa hương vải ngọt ngào và hương hoa hồng quyến rũ. Tạo nên món Trà Vải Hoa Hồng sang chảnh, thơm nức mũi. (Hình ảnh minh họa là vải ngâm, tượng trưng cho thành phần chính).', 'Hương vải mix hoa hồng, sang chảnh.', 130000.00, 0.00, 'NL183', 200, 2, 'assets/images/vai_thieu_ngam_1.png', 1, 'active', 'Hương vải, hương hoa hồng.', 'Pha trà trái cây cao cấp.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (84, 'Trân Châu Hoàng Kim Mini (Hạt Nhỏ)', 'tran-chau-hoang-kim-mini', 'Phiên bản hạt nhỏ (baby) của trân châu hoàng kim. Hạt nhỏ dễ hút, cảm giác nhai \"đã\" miệng hơn vì số lượng hạt nhiều hơn trong mỗi lần hút. Vẫn giữ độ dẻo dai và vị mật ong đặc trưng.', 'Hạt nhỏ (baby), dẻo dai, dễ hút.', 75000.00, 0.00, 'NL184', 200, 2, 'assets/images/tran_chau_boduo_caramel_1.png', 0, 'active', 'Bột sắn, mật ong.', 'Nấu nhanh chín hơn loại hạt to.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (85, 'Thạch Nha Đam (Aloe Vera)', 'thach-nha-dam', 'Thạch nha đam tự nhiên cắt hạt lựu, giòn sần sật, thanh mát. Đã được xử lý kỹ không còn nhớt và đắng. Topping dưỡng nhan tuyệt vời cho các món trà trái cây và sữa chua.', 'Nha đam tự nhiên, giòn, không đắng.', 55000.00, 0.00, 'NL185', 200, 2, 'assets/images/thach_rau_cau_cat_1.png', 0, 'active', 'Nha đam 100%, nước đường.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (86, 'Bột Làm Tàu Hũ Singapore', 'bot-tau-hu-singapore', 'Bột làm tàu hũ (pudding đậu nành) mềm mịn, béo ngậy, tan trong miệng. Không cần dùng thạch cao. Hương đậu nành thơm lừng, kết hợp với trân châu đường đen là chuẩn bài.', 'Làm tàu hũ mềm mịn, thơm đậu nành.', 140000.00, 0.00, 'NL186', 200, 2, 'assets/images/bot_khuc_bach_1.png', 1, 'active', 'Bột đậu nành, bột kem, chất làm đông.', 'Nấu sôi để nguội là đông.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (87, 'Hạt Thủy Tinh Dâu (Strawberry Popping Boba)', 'hat-thuy-tinh-dau', 'Loại topping \"phát nổ\" trong miệng. Vỏ ngoài mỏng dai, bên trong chứa nước cốt dâu tây. Khi cắn nhẹ sẽ vỡ òa vị chua ngọt bất ngờ. Trẻ em cực kỳ yêu thích.', 'Hạt nổ trong miệng, vị dâu tây.', 160000.00, 0.00, 'NL187', 200, 2, 'assets/images/thach_vi_dau_1.png', 0, 'active', 'Nước ép dâu, màng bọc rong biển.', 'Múc nhẹ tay, ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (88, 'Hạt Thủy Tinh Yaourt (Yogurt Popping)', 'hat-thuy-tinh-yaourt', 'Hạt thủy tinh nhân sữa chua chua ngọt ngọt. Màu trắng đục như ngọc trai. Kết hợp với các món đá xay hoặc trà trái cây nhiệt đới rất hợp.', 'Hạt nổ vị sữa chua, lạ miệng.', 165000.00, 0.00, 'NL188', 200, 2, 'assets/images/thach_tran_chau_trang_den_1.png', 0, 'active', 'Sữa chua, màng bọc thực phẩm.', 'Topping cao cấp.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (89, 'Mứt Việt Quất (Blueberry Jam)', 'mut-viet-quat', 'Mứt trái cây có xác việt quất nghiền. Dùng để làm Soda Blueberry hoặc phết lên bánh mì, làm nhân bánh kem. Vị chua dịu, màu tím sẫm đẹp mắt.', 'Mứt có xác trái cây, chua dịu.', 100000.00, 0.00, 'NL189', 200, 2, 'assets/images/siro_nho_1.png', 0, 'active', 'Việt quất nghiền, đường.', 'Làm soda hoặc đá xay.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (90, 'Bột Cốt Dừa Béo (Coconut Powder)', 'bot-cot-dua-beo', 'Thay thế nước cốt dừa lon. Bột cốt dừa có ưu điểm dễ bảo quản, độ béo cao và hương thơm ổn định. Dùng pha Cacao dừa, Cà phê dừa hoặc nấu chè.', 'Thay thế cốt dừa lon, béo ngậy.', 70000.00, 0.00, 'NL190', 200, 2, 'assets/images/bot_kem_beo_thai_lan_1.png', 0, 'active', 'Cơm dừa sấy phun, bột kem.', 'Hòa tan với nước nóng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (91, 'Bột Tinh Than Tre (Takesumi)', 'bot-tinh-than-tre', 'Bột than tre Nhật Bản siêu mịn, không mùi, không vị, tạo màu đen huyền bí cho thực phẩm. Dùng làm Trà sữa than tre, bánh cuộn than tre hoặc kem đen. Có tác dụng thải độc cơ thể.', 'Tạo màu đen huyền bí, thải độc.', 250000.00, 0.00, 'NL191', 200, 2, 'assets/images/bot_suong_sao_1.png', 0, 'active', '100% than tre hoạt tính thực phẩm.', 'Dùng lượng rất nhỏ để tạo màu.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (92, 'Thạch Củ Năng (Water Chestnut)', 'thach-cu-nang', 'Giả lập món thạch củ năng bọc bột lọc. Thạch dai bên ngoài, bên trong giòn sần sật vị củ năng. Topping quen thuộc của món chè khúc bạch hoặc trà sữa.', 'Giòn sần sật, dai ngoài giòn trong.', 60000.00, 0.00, 'NL192', 200, 2, 'assets/images/thach_rau_cau_cat_1.png', 0, 'active', 'Củ năng, bột năng.', 'Luộc chín trước khi dùng.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (93, 'Bột Kem Trứng Nướng (Brulee)', 'bot-kem-trung-nuong', 'Phiên bản nâng cấp dùng để làm lớp kem trứng cháy trên mặt trà sữa (Crème Brûlée). Vị trứng đậm đà hơn, có thể dùng đèn khò để đốt lớp đường phía trên tạo màu caramen đẹp mắt.', 'Làm lớp kem trứng cháy, vị đậm đà.', 135000.00, 0.00, 'NL193', 200, 2, 'assets/images/bot_kem_chung_1.png', 1, 'active', 'Bột trứng, bột phô mai, đường.', 'Đánh bông và khò lửa.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (94, 'Bột Sương Sáo Hạt Chia', 'bot-suong-sao-hat-chia', 'Sự kết hợp giữa thạch đen giải nhiệt và siêu thực phẩm hạt chia. Khi nấu xong, hạt chia lơ lửng trong thạch nhìn rất đẹp và tăng giá trị dinh dưỡng.', 'Thạch đen mix hạt chia, bổ dưỡng.', 65000.00, 0.00, 'NL194', 200, 2, 'assets/images/bot_suong_sao_1.png', 0, 'active', 'Bột sương sáo, hạt chia.', 'Nấu như sương sáo thường.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (95, 'Thạch Dừa Thô (Chưa Nấu)', 'thach-dua-tho', 'Dành cho khách muốn tự tay chế biến. Thạch dừa khô ép nước, khi ngâm sẽ nở ra rất nhiều. Có thể nấu với đường phèn, lá dứa tùy khẩu vị. Rất kinh tế.', 'Thạch thô chưa nấu, nở nhiều, kinh tế.', 150000.00, 0.00, 'NL195', 200, 2, 'assets/images/thach_dua_coco_1.png', 0, 'active', 'Phôi thạch dừa sấy.', 'Ngâm xả nước nhiều lần rồi nấu.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (96, 'Siro Trà Bí Đao (Winter Melon)', 'siro-tra-bi-dao', 'Cốt bí đao cô đặc thơm lừng. Dùng để pha trà bí đao hạt chia giải nhiệt cấp tốc mà không cần nấu bí tươi lỉnh kỉnh. Vị ngọt thanh, mùi thơm bí đao nấu đường phèn đặc trưng.', 'Cốt bí đao cô đặc, giải nhiệt.', 85000.00, 0.00, 'NL196', 200, 2, 'assets/images/siro_dua_luoi_1.png', 1, 'active', 'Cốt bí đao, đường phèn.', 'Pha loãng với nước và đá.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (97, 'Trân Châu Tuyết (Snow Pearl)', 'tran-chau-tuyet', 'Dòng trân châu 3Q cao cấp với độ trong suốt tuyệt đối và độ giòn dai vượt trội. Hạt to đều, không bị vụn. Là topping \"must-have\" cho các dòng trà trái cây hiện đại.', 'Trong suốt như tuyết, giòn dai.', 155000.00, 0.00, 'NL197', 200, 2, 'assets/images/tran_trau_3q_wingszion_1.png', 1, 'active', 'Konjac cao cấp.', 'Ăn liền.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (98, 'Set Nguyên Liệu Tàu Hũ Trân Châu', 'set-tau-hu-tran-chau', 'Combo tiện lợi gồm: Bột tàu hũ, Trân châu đường đen và Đường nâu Hàn Quốc. Giúp bạn tự làm món Tàu hũ trân châu đường đen nổi tiếng tại nhà dễ dàng.', 'Combo tiện lợi, tự làm tàu hũ tại nhà.', 99000.00, 0.00, 'NL198', 200, 2, 'assets/images/bot_kem_chung_1.png', 1, 'active', 'Bột tàu hũ, trân châu, đường đen.', 'Đủ nguyên liệu cho 5-6 chén.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (99, 'Bột Chè Khúc Bạch Vị Phô Mai', 'bot-khuc-bach-pho-mai', 'Bột làm chè khúc bạch được bổ sung thêm bột phô mai, giúp viên khúc bạch béo ngậy hơn, thơm hơn. Món chè giải nhiệt sang chảnh.', 'Vị phô mai béo ngậy, làm chè khúc bạch.', 145000.00, 0.00, 'NL199', 200, 2, 'assets/images/bot_khuc_bach_1.png', 0, 'active', 'Gelatin, bột kem, bột phô mai.', 'Nấu với sữa tươi.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (100, 'Bột Rau Câu Sơn Thủy', 'bot-rau-cau-son-thuy', 'Bột rau câu dẻo chuyên dùng đổ thạch sơn thủy (loang màu). Độ trong cao, dẻo dai, dễ tạo vân đẹp mắt. Gói lớn tiết kiệm cho gia đình.', 'Làm thạch loang màu nghệ thuật.', 45000.00, 0.00, 'NL200', 200, 2, 'assets/images/bot_rau_cau_1.png', 0, 'active', 'Bột rau câu dẻo.', 'Nấu thạch nghệ thuật.', '2026-01-28 19:44:08');
INSERT INTO `products` VALUES (101, 'Chè Dây Sapa Thượng Hạng', 'che-day-sapa', 'Được mệnh danh là \"thần dược\" của vùng núi Tây Bắc, Chè Dây Sapa sinh trưởng tự nhiên trong sương mù dày đặc, hấp thụ tinh hoa đất trời để tạo nên dược tính tuyệt vời. Sản phẩm có vị ngọt đắng đặc trưng, nổi tiếng với khả năng trung hòa axit dạ dày, tiêu diệt vi khuẩn HP và hỗ trợ làm lành các vết loét dạ dày tá tràng. Một tách chè dây mỗi sáng không chỉ giúp hệ tiêu hóa khỏe mạnh mà còn mang lại cảm giác an thần, ngủ ngon.', 'Khắc tinh của dạ dày, diệt khuẩn HP, hỗ trợ tiêu hóa tốt.', 120000.00, 0.00, 'TRA001', 100, 1, 'assets/images/che_day_sapa_1.png', 1, 'active', '100% thân và lá Chè Dây (Ampelopsis cantoniensis) thu hái tự nhiên tại Sapa, sấy khô theo phương pháp thủ công giữ nguyên phấn trắng (kết tinh dược liệu).', 'hahahahaha', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (102, 'Lục Trà Lài Thơm Ngát', 'luc-tra-lai', 'Sự giao thoa tinh tế giữa những búp trà xanh (Lục trà) tươi non mơn mởn và hoa lài (hoa nhài) trắng muốt ngát hương. Trà được ướp hương theo phương pháp thủ công tỉ mỉ, cứ một lớp trà lại đan xen một lớp hoa, ủ kín để hương hoa thấm sâu vào từng tế bào lá trà. Khi pha, nước trà có màu vàng xanh trong trẻo, hương lài bung tỏa nồng nàn quyến rũ, vị chát nhẹ đầu lưỡi và hậu ngọt sâu lắng, mang lại cảm giác thư thái tuyệt đối.', 'Hương hoa lài tự nhiên nồng nàn, cốt trà xanh thanh khiết.', 85000.00, 75000.00, 'TRA002', 100, 1, 'assets/images/luc_tra_lai_1.png', 0, 'active', '90% Lục trà (Trà xanh) sơ chế, 9% Hoa lài tự nhiên sấy khô, 1% Hương hoa lài tổng hợp cao cấp.', '1. Dùng 5g trà cho vào ấm dung tích 200ml.\n2. Nhiệt độ nước lý tưởng: 80-85 độ C (không dùng nước quá sôi sẽ làm cháy trà).\n3. Ủ trà trong 3-5 phút.\n4. Rót ra chén và thưởng thức hương thơm lan tỏa.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (103, 'Mật Ong Long Trà', 'mat-o-long-tra', 'Một thức uống \"chữa lành\" tâm hồn với sự kết hợp giữa Trà Oolong cao cấp và Mật ong hoa rừng nguyên chất. Vị chát thanh tao, sang trọng của Oolong được làm mềm bởi vị ngọt ngào, ấm áp của mật ong, tạo nên một tổng thể hài hòa khó cưỡng. Sản phẩm không chỉ là thức uống giải khát mà còn giúp làm đẹp da, thanh lọc cơ thể và bổ sung năng lượng tức thì cho ngày dài mệt mỏi.', 'Sự kết hợp hoàn hảo giữa Oolong đậm vị và mật ong ngọt ngào.', 150000.00, 0.00, 'TRA003', 100, 1, 'assets/images/mat_o_long_tra_1.png', 1, 'active', 'Trà Oolong (búp trà lên men bán phần), Bột mật ong hoa rừng tự nhiên, Tinh chất cam thảo.', 'Pha nóng: Hãm 5g trà với 200ml nước sôi 90 độ C trong 3 phút.\r\nPha lạnh: Hãm trà đậm, thêm đá viên và có thể vắt thêm một chút chanh tươi để tăng hương vị.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (104, 'Trà An Thần Ngủ Ngon', 'tra-an-than-ngu-ngon', 'Giải pháp tuyệt vời cho những đêm trằn trọc, khó ngủ. Trà An Thần là bài thuốc dân gian được phối trộn từ những thảo dược có tính bình, giúp dưỡng tâm, an thần như Tâm sen, Lạc tiên, Táo đỏ. Vị trà ngọt dịu, không đắng gắt, giúp xoa dịu hệ thần kinh, giảm căng thẳng âu lo (stress) và đưa bạn vào giấc ngủ sâu, tự nhiên, không gây mệt mỏi khi thức dậy.', 'Xua tan âu lo, tìm lại giấc ngủ ngon tự nhiên.', 95000.00, 0.00, 'TRA004', 100, 1, 'assets/images/tra_an_than_ngu_ngon_1.png', 0, 'active', 'Tâm sen (Tim sen) sao vàng hạ thổ, Lạc tiên (Chùm bao), Táo đỏ, Hoa cúc, Cỏ ngọt.', '1. Cho 1 túi lọc hoặc 10g trà vào cốc.\r\n2. Rót 300ml nước sôi, đậy nắp kín và đợi 10-15 phút để thảo dược tiết ra dưỡng chất.\r\n3. Nên uống ấm trước khi đi ngủ khoảng 30-60 phút để đạt hiệu quả tốt nhất.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (105, 'Trà Atiso Túi Lọc', 'tra-atiso-tui-loc', 'Đặc sản nổi tiếng từ vùng đất Đà Lạt ngàn hoa. Trà Atiso được xem là \"thần dược cho lá gan\", giúp thanh nhiệt, giải độc, làm mát gan và giảm mụn nhọt hiệu quả. Sản phẩm được chế biến dưới dạng túi lọc tiện lợi nhưng vẫn giữ trọn vẹn hương vị thơm ngon và dược tính của cây Atiso. Thích hợp cho người hay sử dụng rượu bia hoặc nóng trong người.', 'Mát gan, giải độc, trị mụn, đặc sản Đà Lạt.', 65000.00, 50000.00, 'TRA005', 100, 1, 'assets/images/tra_atiso_tui_loc_1.png', 0, 'active', '50% Bông Atiso, 40% Rễ Atiso, 10% Hoa cúc và Cỏ ngọt (tạo vị ngọt tự nhiên).', 'Nhúng 1-2 túi lọc vào ly nước sôi (150-200ml). Chờ 3-5 phút cho trà ngấm. Có thể thêm đường phèn hoặc mật ong tùy khẩu vị. Uống nóng hoặc đá đều ngon.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (106, 'Trà Bạc Hà The Mát', 'tra-bac-ha', 'Cảm giác sảng khoái bùng nổ ngay từ ngụm đầu tiên! Những lá bạc hà tươi xanh nhất được sấy lạnh theo công nghệ hiện đại để giữ nguyên tinh dầu Menthol quý giá. Trà Bạc Hà không chỉ giúp hơi thở thơm mát, thông mũi mát họng mà còn có tác dụng tuyệt vời trong việc hỗ trợ tiêu hóa, giảm đầy hơi và tăng cường sự tập trung khi làm việc.', 'The mát cực đỉnh, sảng khoái tinh thần, hỗ trợ tiêu hóa.', 70000.00, 0.00, 'TRA006', 100, 1, 'assets/images/tra_bac_ha_1.png', 0, 'active', '100% Lá Bạc Hà (Peppermint) nguyên chất sấy lạnh, không chất bảo quản.', 'Lấy một nhúm nhỏ lá bạc hà (khoảng 3-5g) cho vào ấm. Hãm với nước sôi 90 độ C trong 5 phút. Thêm một lát chanh và chút mật ong để tạo thành ly trà giải cảm tuyệt vời.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (107, 'Trà Bắc Thái Nguyên Đặc Biệt', 'tra-bac-thai-nguyen', 'Danh trà đất Việt - \"Thái Nguyên Đệ Nhất Danh Trà\". Những búp chè 1 tôm 2 lá được hái vào sáng sớm tinh mơ khi còn ngậm sương, sau đó trải qua quá trình sao tay điêu luyện của các nghệ nhân. Cánh trà săn nhỏ, cong như móc câu, phủ một lớp tuyết nhẹ. Nước trà xanh ong ánh vàng, tiền vị chát dịu nhưng hậu vị ngọt sâu lắng đọng mãi trong cổ họng.', 'Vị chát tiền ngọt hậu, chuẩn vị trà Bắc truyền thống.', 250000.00, 220000.00, 'TRA007', 100, 1, 'assets/images/tra_bac_thai_nguyen_1.png', 1, 'active', '100% Búp chè xanh Tân Cương - Thái Nguyên loại thượng hạng.', '1. Tráng ấm chén bằng nước sôi.\r\n2. Cho trà vào ấm, tráng nhanh qua nước sôi để rửa trà.\r\n3. Hãm với nước 85-90 độ C (không dùng nước sôi già) trong 1-2 phút.\r\n4. Rót hết nước ra tống rồi chia đều ra các chén quân.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (108, 'Trà Bổ Tỳ Vị', 'tra-bo-ty-vi', 'Dựa trên bài thuốc Đông y cổ truyền, Trà Bổ Tỳ Vị là sự cứu cánh cho những ai có hệ tiêu hóa kém, hay ăn không tiêu, đầy bụng hoặc chán ăn. Sự phối hợp của các vị thuốc quý giúp kiện tỳ, ích khí, làm ấm bụng và kích thích vị giác, giúp bạn ăn ngon miệng hơn và hấp thu dưỡng chất tốt hơn.', 'Kiện tỳ ích khí, giúp ăn ngon, tiêu hóa khỏe.', 110000.00, 0.00, 'TRA008', 100, 1, 'assets/images/tra_bo_ty_vi_1.png', 0, 'active', 'Bạch truật, Đảng sâm, Cam thảo, Trần bì (vỏ quýt khô), Gừng sẻ, Đại táo.', 'Cho 1 gói trà vào ấm, đun sôi với 500ml nước trong khoảng 10-15 phút để ra hết chất thuốc. Chia làm 3 lần uống trong ngày, uống sau khi ăn 30 phút.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (109, 'Trà Cây Cỏ Máu', 'tra-cay-co-mau', 'Thảo dược bí truyền của người Rục, Quảng Bình. Cây Cỏ Máu (Kê Huyết Đằng) nổi tiếng với công dụng bổ máu, hành huyết, giúp da dẻ hồng hào, căng mịn. Đặc biệt tốt cho phụ nữ sau sinh giúp nhanh lại sức, lợi sữa và người gầy yếu muốn tăng cân, ăn ngủ kém. Nước trà có màu đỏ tươi đẹp mắt, vị chát ngọt lạ miệng.', 'Bổ máu, đẹp da, tăng cân, lợi sữa cho mẹ bầu.', 135000.00, 0.00, 'TRA009', 100, 1, 'assets/images/tra_cay_co_mau_1.png', 0, 'active', 'Thân cây Cỏ Máu (Kê Huyết Đằng) thái lát mỏng, phơi khô tự nhiên.', 'Rửa sạch 100g cỏ máu, đun sôi với 2 lít nước trong khoảng 20-30 phút. Nước sau khi nấu có màu đỏ đẹp, uống thay nước lọc hàng ngày. Bã trà có thể bảo quản tủ lạnh để nấu tiếp lần 2.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (110, 'Trà Cà Gai Leo Giải Độc', 'tra-ca-gai-leo', 'Lá chắn thép bảo vệ lá gan của bạn. Cà Gai Leo là thảo dược duy nhất được chứng minh có khả năng ức chế virus viêm gan B, ngăn chặn xơ gan và giải độc gan cực mạnh. Sản phẩm là lựa chọn hàng đầu cho cánh mày râu hay phải tiếp khách, uống bia rượu, hoặc người bị men gan cao, nóng trong, mẩn ngứa.', 'Giải độc gan, hạ men gan, giải rượu hiệu quả.', 90000.00, 80000.00, 'TRA010', 100, 1, 'assets/images/tra_ca_gai_leo_1.png', 1, 'active', 'Cà gai leo nguyên chất (thân, lá, rễ) sấy khô, Diệp hạ châu (Chó đẻ răng cưa).', 'Hãm 10-20g trà với 1 lít nước sôi, uống thay nước lọc trong ngày. Với người uống rượu bia, nên uống một cốc trà đặc trước và sau khi nhậu để giảm tác hại của cồn.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (111, 'Trà Cung Đình Huế', 'tra-cung-dinh-hue', 'Tinh hoa ẩm thực Cố Đô, từng là thức uống chỉ dành cho Vua Chúa. Trà Cung Đình là sự tổng hòa của hàng chục loại thảo mộc quý hiếm, tạo nên hương vị ngọt thanh tao nhã, vừa giải khát vừa bồi bổ long thể. Trà giúp thanh nhiệt, mát gan, sáng mắt, ngủ ngon và ổn định huyết áp.', 'Đặc sản Cố Đô, thanh nhiệt, bổ dưỡng, quà biếu sang trọng.', 85000.00, 0.00, 'TRA011', 100, 1, 'assets/images/tra_cung_dinh_hue_1.png', 1, 'active', 'Atiso, Cúc hoa, Cỏ ngọt, Hoài sơn, Đẳng sâm, Đại táo, Hồng táo, Hồi hoa, Cam thảo bắc, Hoa lài, Hoa hòe...', 'Trộn đều gói trà. Lấy 30g trà hãm với 500ml nước sôi. Có thể thêm đường phèn, uống nóng hoặc thêm đá lạnh đều rất ngon. Thích hợp đãi khách.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (112, 'Trà Đậu Đen Orihiro', 'tra-dau-den-orihiro', 'Sản phẩm nhập khẩu chính hãng từ Nhật Bản, được tin dùng bởi hàng triệu phụ nữ Á Đông. Đậu đen được rang theo công nghệ đặc biệt giúp hạt nở đều, thơm phức mà không bị cháy. Trà giúp thanh lọc cơ thể (Detox), hỗ trợ giảm cân an toàn, làm đen tóc và giúp da dẻ mịn màng, chống lão hóa từ bên trong.', 'Hàng Nhật nội địa, detox cơ thể, hỗ trợ giảm cân, đẹp da.', 180000.00, 0.00, 'TRA012', 100, 1, 'assets/images/tra_dau_den_orihiro_1.png', 0, 'active', '100% Đậu đen Hokkaido Nhật Bản rang sấy công nghệ cao.', 'Pha 1 túi lọc với 500ml nước sôi. Ủ khoảng 20-30 phút cho trà ra hết dưỡng chất. Uống ấm hoặc để nguội cho vào tủ lạnh dùng dần trong ngày.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (113, 'Trà Đen DalatFarm', 'tra-den-dalatfarm', 'Nguyên liệu \"linh hồn\" cho những ly trà sữa đậm vị. Được trồng tại các nông trại trên cao nguyên Lâm Đồng, lá trà đen được lên men (oxy hóa) hoàn toàn, cho ra màu nước hồng ngọc đẹp mắt và vị chát đậm đà, không bị át vị khi pha chung với bột sữa. Đây là lựa chọn số 1 cho các quán trà sữa chuyên nghiệp.', 'Chuyên pha trà sữa, vị đậm đà, màu nước đẹp.', 100000.00, 0.00, 'NL001', 200, 2, 'assets/images/tra_den_dalatfarm_1.png', 1, 'active', 'Lá trà đen (Hồng trà) lên men 100%, không hương liệu nhân tạo.', 'Ủ 50g trà với 1 lít nước sôi 100 độ C trong 15-20 phút (đậy kín nắp). Lọc bã trà lấy nước cốt. Pha với bột sữa và đường theo tỷ lệ công thức để có ly trà sữa truyền thống.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (114, 'Trà Đen Ngọc Quý', 'tra-den-ngoc-quy', 'Dòng trà đen truyền thống của Bảo Lộc, hương thơm nồng nàn quyến rũ. Khác với dòng DalatFarm đậm vị, Trà Đen Ngọc Quý có hương thơm hoa quả tự nhiên nhẹ nhàng hơn, thích hợp để pha các loại trà trái cây (Trà đào, Trà vải) hoặc trà chanh, mang lại cảm giác tươi mát, sảng khoái.', 'Hương thơm nồng, chuyên pha trà trái cây, trà đào.', 95000.00, 0.00, 'NL002', 200, 2, 'assets/images/tra_den_ngoc_quy_1.png', 0, 'active', 'Búp trà xanh lên men, hương liệu thực phẩm an toàn.', 'Ủ 10g trà với 200ml nước sôi trong 10 phút. Lấy nước cốt pha thêm syrup đào, miếng đào ngâm và đá viên để có ly trà đào chuẩn vị.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (115, 'Trà Đinh Lăng Lợi Sữa', 'tra-dinh-lang', 'Được ví như \"Nhân sâm của người nghèo\", Đinh Lăng có tác dụng bồi bổ cực tốt. Đặc biệt, sản phẩm là cứu tinh cho các mẹ bỉm sữa bị tắc tia sữa hoặc ít sữa. Ngoài ra, uống trà Đinh Lăng còn giúp tăng cường trí nhớ, giảm đau đầu, chóng mặt và cải thiện tình trạng đau lưng mỏi gối ở người lớn tuổi.', 'Lợi sữa cho mẹ bầu, tăng cường trí nhớ, giảm đau lưng.', 120000.00, 0.00, 'TRA013', 100, 1, 'assets/images/tra_dinh_lang_1.png', 0, 'active', 'Rễ củ và lá cây Đinh Lăng lá nhỏ sao vàng hạ thổ.', 'Cho 20g trà vào ấm, đổ nước sôi ngập trà rồi chắt bỏ nước đầu. Đổ tiếp 500ml nước sôi, hãm 15 phút rồi uống. Nước trà có vị ngọt nhẹ, mùi thơm đặc trưng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (116, 'Trà Dồi Thân Tím', 'tra-doi-than-tim', 'Một loại thảo dược quý hiếm mọc ở vùng núi đá, ít người biết đến nhưng công dụng lại vô cùng thần kỳ. Trà Dồi Thân Tím chuyên trị các vấn đề về dạ dày, đường ruột, giúp giảm đau bụng, đầy hơi. Ngoài ra, theo kinh nghiệm dân gian, loại cây này còn hỗ trợ giảm đau nhức xương khớp khi thay đổi thời tiết.', 'Hỗ trợ tiêu hóa, giảm đau xương khớp, thảo dược vùng cao.', 115000.00, 0.00, 'TRA014', 100, 1, 'assets/images/tra_doi_than_tim_1.png', 0, 'active', 'Thân và lá cây Dồi Tím sấy khô tự nhiên.', 'Rửa sạch, đun sôi với nước uống thay trà hàng ngày. Vị trà hơi chát nhẹ, tính mát, rất dễ uống.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (117, 'Trà Đông Tử Vị', 'tra-dong-tu-vi', 'Thức uống thượng hạng dành cho sức khỏe vàng. Sự kết hợp xa xỉ giữa Đông Trùng Hạ Thảo và các vị thuốc bổ như Kỷ Tử, Táo Đỏ. Trà giúp tăng cường hệ miễn dịch, bồi bổ phổi, thận và phục hồi sức khỏe nhanh chóng cho người mới ốm dậy. Món quà sức khỏe đẳng cấp để biếu tặng ông bà, cha mẹ.', 'Bồi bổ toàn diện, tăng cường miễn dịch, bổ phổi thận.', 350000.00, 300000.00, 'TRA015', 100, 1, 'assets/images/tra_dong_tu_vi_1.png', 0, 'active', 'Đông Trùng Hạ Thảo sấy thăng hoa, Kỷ tử đỏ, Táo đỏ Tân Cương, Long nhãn Hưng Yên.', 'Cho một gói trà vào ly, rót 300ml nước sôi 90 độ. Đậy nắp kín 10 phút. Sau khi uống hết nước, có thể ăn luôn cả cái (xác trà) để hấp thu trọn vẹn dinh dưỡng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (118, 'Trà Đường Nâu Nguyên Chất', 'tra-duong-nau-nguyen-chat', 'Viên trà đường nâu cô đặc - giải pháp tiện lợi cho cuộc sống bận rộn. Mỗi viên đường là sự kết hợp của đường mía thô nguyên chất nấu cùng gừng già, táo đỏ, long nhãn... Chỉ cần thả vào nước nóng là tan ngay, tạo thành ly trà thơm lừng, ngọt ấm. Cực tốt cho chị em phụ nữ vào \"ngày đèn đỏ\" giúp giảm đau bụng và làm ấm cơ thể.', 'Giảm đau bụng kinh, làm ấm cơ thể, tiện lợi dễ dùng.', 140000.00, 0.00, 'NL003', 200, 2, 'assets/images/tra_duong_nau_nguyen_chat_1.png', 0, 'active', 'Đường mía thô, Gừng sẻ, Táo đỏ, Kỷ tử, Hoa hồng (tùy vị).', 'Lấy 1 viên đường nâu cho vào cốc. Rót 200ml nước sôi 100 độ C. Khuấy nhẹ cho đường tan hết và thưởng thức khi còn nóng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (119, 'Trà Dưỡng Nhan 7 Vị', 'tra-duong-nhan', 'Bí quyết \"trẻ mãi không già\" của các cung tần mỹ nữ xưa. Set trà gồm 7 vị thảo mộc quý (Thất vị) giúp bổ sung Collagen thực vật, làm đẹp da, mờ nám sạm và thanh nhiệt cơ thể. Nước trà nấu lên có độ sánh nhẹ của tuyết yến và nhựa đào, vị ngọt thanh của đường phèn, ăn giòn sần sật rất vui miệng.', 'Bổ sung Collagen, đẹp da, mờ nám, thanh nhiệt.', 160000.00, 140000.00, 'TRA016', 100, 1, 'assets/images/tra_duong_nhan_1.png', 1, 'active', 'Tuyết yến, Nhựa đào, Bồ mễ (Hạt sen tuyết), Kỷ tử, Táo đỏ, Long nhãn, Hạt chia, Đường phèn.', 'Ngâm Tuyết yến, Nhựa đào, Bồ mễ qua đêm cho nở mềm. Rửa sạch tạp chất. Đun sôi nước với đường phèn và táo đỏ, long nhãn. Cuối cùng cho các nguyên liệu đã ngâm vào đun sôi lại 5-10 phút. Để nguội ăn như chè.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (120, 'Trà Hoa Đu Đủ Đực', 'tra-du-du-duc', 'Hoa đu đủ đực từ lâu đã là bài thuốc dân gian quý hiếm, đặc biệt trong việc hỗ trợ điều trị ho, viêm họng và các bệnh về đường hô hấp. Ngoài ra, nhiều nghiên cứu còn chỉ ra công dụng hỗ trợ ngăn ngừa khối u và cải thiện hệ tiêu hóa. Hoa được thu hái thủ công, phơi trong bóng râm để giữ nguyên dược tính.', 'Trị ho, bổ phổi, hỗ trợ ngăn ngừa khối u.', 210000.00, 0.00, 'TRA017', 100, 1, 'assets/images/tra_du_du_duc_1.png', 0, 'active', '100% Hoa đu đủ đực phơi khô tự nhiên.', 'Cách 1: Hãm trà uống hàng ngày (vị hơi đắng).\nCách 2: Hấp cách thủy với mật ong hoặc đường phèn để trị ho (ngọt dễ uống hơn).\nCách 3: Ngâm với mật ong trong bình thủy tinh 1 tháng rồi dùng dần.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (121, 'Trà Fitne Herbal Thái Lan', 'tra-fitne-herbal', 'Sản phẩm trà thảo mộc \"quốc dân\" của Thái Lan, nổi tiếng khắp Đông Nam Á. Trà Fitne Herbal tận dụng sức mạnh nhuận tràng tự nhiên của lá sen và vỏ đại để hỗ trợ đào thải độc tố đường ruột, giảm táo bón và ngăn ngừa tích tụ mỡ thừa. Hương vị thơm nhẹ, dễ uống, là người bạn đồng hành không thể thiếu cho những ai muốn duy trì vóc dáng thon gọn mà không cần ăn kiêng quá khắt khe.', 'Trà giảm cân, thải độc ruột nổi tiếng Thái Lan.', 130000.00, 0.00, 'TRA018', 100, 1, 'assets/images/tra_fitne_herbal_1.png', 1, 'active', 'Lá sen (Senna leaves), Vỏ đại (Senna pods), Hương liệu thảo mộc tự nhiên.', 'Ngâm 1 túi trà vào cốc nước nóng (150ml) trong khoảng 10-20 phút. Nên uống vào buổi tối trước khi đi ngủ. Tác dụng đào thải thường xuất hiện sau 8-10 tiếng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (122, 'Trà Gạo Lứt Huyết Rồng', 'tra-gao-luc', 'Thức uống dân dã nhưng mang lại giá trị sức khỏe phi thường. Những hạt gạo lứt huyết rồng đỏ au được tuyển chọn, rang tay thủ công trên lửa củi sao cho hạt gạo bung nở vừa tới, dậy mùi thơm nồng nàn như mùi cốm mới. Nước trà đỏ thẫm, vị ngọt thanh, uống vào mát gan, thanh nhiệt, giúp da dẻ hồng hào và hỗ trợ xương khớp cực tốt.', 'Gạo lứt rang tay thủ công, thơm nồng, mát gan, đẹp da.', 60000.00, 0.00, 'TRA019', 100, 1, 'assets/images/tra_gao_luc_1.png', 0, 'active', '100% Gạo lứt huyết rồng rang mộc, có thể mix thêm đậu đen xanh lòng (tùy mẻ).', 'Cho 2-3 muỗng gạo lứt vào bình giữ nhiệt hoặc ấm trà. Chế 500ml nước sôi, ủ kín trong 15-20 phút cho gạo nở bung. Chắt lấy nước uống cả ngày. Xác gạo có thể ăn được, rất bùi và ngon.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (123, 'Trà Genpi Orihiro Nhật Bản', 'tra-genpi-orihiro', 'Bí quyết tiêu mỡ bụng của người Nhật. Genpi Tea là sự phối trộn tinh tế của các loại thảo mộc phương Đông, tập trung vào khả năng đốt cháy mỡ thừa vùng bụng và bắp tay. Không gây mệt mỏi, không gây mất nước, Genpi giúp cơ thể nhẹ nhàng, thanh thoát hơn mỗi ngày. Sản phẩm đặc biệt phù hợp cho dân văn phòng ngồi nhiều, ít vận động.', 'Hỗ trợ giảm mỡ bụng, nhập khẩu Nhật Bản.', 195000.00, 0.00, 'TRA020', 100, 1, 'assets/images/tra_genpi_orihiro_1.png', 1, 'active', 'Trà Pu’er (Phổ Nhĩ), Trà Ô Long, Hồng trà Nam Phi (Rooibos), Hạt ý dĩ, Lá dây thìa canh.', 'Pha 1 gói trà với 500ml nước sôi. Để trà ngấm trong 3-5 phút. Có thể uống nóng hoặc để nguội uống lạnh thay nước lọc. Một gói có thể pha được 2-3 lần nước.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (124, 'Trà Giảo Cổ Lam 7 Lá', 'tra-giao-co-lam', 'Được mệnh danh là \"Cỏ Trường Thọ\", Giảo Cổ Lam là thảo dược quý giúp ổn định huyết áp, hạ mỡ máu và ngăn ngừa các biến chứng tim mạch. Sản phẩm sử dụng loại Giảo Cổ Lam 7 lá (loại có dược tính cao nhất), thu hái từ vùng núi đá vôi Hòa Bình. Vị trà đắng trước ngọt sau, uống quen sẽ thấy rất nghiền, người nhẹ nhõm, ăn ngủ tốt.', 'Hạ mỡ máu, ổn định huyết áp, tốt cho tim mạch.', 105000.00, 95000.00, 'TRA021', 100, 1, 'assets/images/tra_giao_co_lam_1.png', 0, 'active', '100% thân và lá Giảo Cổ Lam 7 lá sấy khô.', 'Lấy 10-15g trà hãm với nước sôi như pha trà mạn. Uống vào buổi sáng hoặc đầu giờ chiều giúp tỉnh táo. Lưu ý: Người huyết áp thấp nên uống lúc no và thêm vài lát gừng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (125, 'Trà Gừng Mật Ong Hòa Tan', 'tra-gung', 'Vị cứu tinh cho những ngày gió lạnh hoặc khi bị cảm lạnh, đau bụng. Bột trà gừng được làm từ gừng sẻ già cay nồng, kết hợp với mật ong hoa nhãn ngọt ngào. Chỉ cần 1 phút pha chế là bạn đã có ngay ly trà nóng hổi, làm ấm cơ thể từ bên trong, giúp lưu thông khí huyết và giảm cảm giác buồn nôn, khó chịu.', 'Làm ấm cơ thể, giải cảm, giảm đau bụng, tiện lợi.', 55000.00, 0.00, 'TRA022', 100, 1, 'assets/images/tra_gung_1.png', 0, 'active', 'Tinh chất gừng già, Bột mật ong, Đường phèn.', 'Hòa tan 1 gói trà vào 150ml nước nóng (80-90 độ C). Khuấy đều và thưởng thức. Có thể vắt thêm chanh để tăng đề kháng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (126, 'Trà Hà Thủ Ô Túi Lọc', 'tra-ha-thu-o-tui-loc', '\"Muốn cho xanh tóc đỏ da, rủ nhau lên núi tìm Hà Thủ Ô\". Nay không cần lên núi, bạn vẫn có thể tận hưởng công dụng tuyệt vời này với Trà Hà Thủ Ô túi lọc tiện lợi. Sản phẩm được chế biến kỹ (cửu chưng cửu sái) để loại bỏ độc tính, giữ lại tinh chất giúp bồi bổ khí huyết, làm đen tóc và ngăn ngừa lão hóa sớm.', 'Xanh tóc, đỏ da, bồi bổ khí huyết.', 85000.00, 0.00, 'TRA023', 100, 1, 'assets/images/tra_ha_thu_o_tui_loc_1.png', 0, 'active', 'Hà thủ ô đỏ chế đậu đen, Đương quy, Kỷ tử, Cỏ ngọt.', 'Nhúng túi trà vào 200ml nước sôi. Chờ 5 phút. Nên uống liên tục trong 2-3 tháng để thấy hiệu quả rõ rệt lên mái tóc và làn da.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (127, 'Trà Hoàng Thảo Mộc Cung Đình', 'tra-hoang-thao-moc', 'Dòng trà Signature (Thượng hạng) của Mộc Trà. Đây là sự kết hợp công phu của 12 loại thảo mộc quý hiếm nhất, tạo nên hương vị \"Vương Giả\" không nơi nào có được. Trà có vị ngọt thanh tao của táo đỏ, hương thơm nồng nàn của quế và hoa hồi, hậu vị sâu lắng của sâm. Một set trà không chỉ là thức uống mà còn là một tác phẩm nghệ thuật để biếu tặng.', 'Thượng hạng 12 vị, quà biếu sang trọng, bồi bổ toàn diện.', 280000.00, 250000.00, 'TRA024', 100, 1, 'assets/images/tra_hoang_thao_moc_1.png', 1, 'active', 'Nhân sâm, Linh chi, Đông trùng hạ thảo, Kỷ tử, Táo đỏ, Long nhãn, Hoa cúc, Nụ hồng, Cỏ ngọt...', 'Dùng bộ ấm trà thủy tinh. Cho gói trà vào, tráng qua nước nóng. Hãm với 500ml nước sôi trong 10-15 phút. Vừa thưởng trà, vừa ngắm hoa nở trong ấm.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (128, 'Trà Hoa Cúc Quế Hoa Kỳ Tử', 'tra-hoa-cuc-que-hoa-ky-tu', 'Bộ ba \"Dưỡng Nhan - Sáng Mắt - An Thần\". Bạch cúc giúp thanh nhiệt, sáng mắt; Quế hoa (Hoa mộc) mang hương thơm ngọt ngào quyến rũ; Kỷ tử bồi bổ gan thận. Sự kết hợp này tạo nên một ly trà vàng óng đẹp mắt, hương thơm vương vấn mãi không tan, giúp xua tan mệt mỏi sau những giờ làm việc căng thẳng bên máy tính.', 'Sáng mắt, đẹp da, hương thơm quyến rũ.', 110000.00, 0.00, 'TRA025', 100, 1, 'assets/images/tra_hoa_cuc_que_hoa_ky_tu_1.png', 0, 'active', 'Bạch cúc (Cúc trắng), Quế hoa (Hoa mộc), Kỷ tử đỏ.', 'Cho các nguyên liệu vào ly. Rót nước sôi, đậy nắp hãm 5 phút. Mở nắp ra là hương thơm tỏa khắp phòng. Uống nóng hoặc thêm đá đều ngon.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (129, 'Trà Hồng Sâm Nguyên Lát', 'tra-hong-sam', 'Sức mạnh từ củ sâm ngàn năm. Những củ sâm tươi 6 năm tuổi được hấp sấy thành Hồng Sâm, sau đó thái lát mỏng và tẩm mật ong. Khi hãm trà, lát sâm nở ra, tiết ra dưỡng chất saponin quý giá giúp phục hồi sinh lực, tăng cường trí nhớ và hệ miễn dịch. Thức uống vàng cho người cao tuổi và người làm việc trí óc cường độ cao.', 'Phục hồi sinh lực, tăng trí nhớ, tốt cho người già.', 320000.00, 0.00, 'TRA026', 100, 1, 'assets/images/tra_hong_sam_1.png', 0, 'active', '100% Hồng sâm 6 năm tuổi thái lát, tẩm mật ong rừng.', 'Lấy 2-3 lát sâm cho vào cốc, đổ nước sôi hãm 10 phút. Uống hết nước có thể ăn luôn lát sâm (dẻo, ngọt, hơi đắng nhẹ). Dùng vào buổi sáng để nạp năng lượng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (130, 'Trà Hồng Sâm Hàn Quốc (Hộp Gỗ)', 'tra-hong-sam-han-quoc', 'Sản phẩm nhập khẩu nguyên hộp từ Hàn Quốc - Xứ sở Nhân Sâm. Được đóng gói trong hộp gỗ sang trọng, đây là món quà sức khỏe đẳng cấp để biếu sếp, đối tác hoặc người thân. Trà dạng hòa tan tiện lợi, giữ nguyên hương vị đặc trưng của sâm Hàn Quốc, giúp bồi bổ cơ thể toàn diện.', 'Nhập khẩu Hàn Quốc, hộp gỗ sang trọng, quà biếu đẳng cấp.', 450000.00, 0.00, 'TRA027', 100, 1, 'assets/images/tra_hong_sam_han_quoc_1.png', 1, 'active', 'Tinh chất hồng sâm cô đặc, đường glucose, lactose.', 'Hòa tan 1 gói trà với nước ấm hoặc nước lạnh. Khuấy đều và thưởng thức. Ngày dùng 1-2 gói.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (131, 'Túi Trà Khô Khử Mùi (Hút Ẩm)', 'tra-hut-am', 'Tận dụng hương thơm tự nhiên của các loại trà mộc (Trà lài, Trà sen, Quế), túi trà khô là giải pháp khử mùi hoàn hảo cho ô tô, tủ quần áo, tủ giày hay phòng ngủ. Không hóa chất độc hại, túi trà tỏa hương thơm dịu nhẹ, hút ẩm mốc và mang lại cảm giác thư thái cho không gian sống của bạn.', 'Khử mùi ô tô, tủ quần áo, hút ẩm tự nhiên.', 40000.00, 0.00, 'PK001', 100, 1, 'assets/images/tra_hut_am_1.png', 0, 'active', 'Bã trà khô sấy kỹ, Hoa hồi, Quế thanh, Nụ hoa lài.', 'Treo túi trà ở nơi cần khử mùi. Sau 1-2 tháng khi mùi hương giảm, có thể thay túi mới hoặc nhỏ thêm tinh dầu vào túi trà để tiếp tục sử dụng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (132, 'Trà Khổ Qua Rừng (Mướp Đắng)', 'tra-kho-qua', '\"Thuốc đắng dã tật\". Khổ qua rừng có vị đắng đậm hơn khổ qua thường nhưng dược tính cao gấp nhiều lần. Đây là \"khắc tinh\" của bệnh tiểu đường và mỡ máu cao. Uống trà khổ qua hàng ngày giúp ổn định đường huyết, thanh nhiệt, giải độc cơ thể và ngăn ngừa mụn nhọt do nóng trong.', 'Hạ đường huyết, tốt cho người tiểu đường, thanh nhiệt.', 95000.00, 0.00, 'TRA028', 100, 1, 'assets/images/tra_kho_qua_1.png', 0, 'active', '100% trái và dây khổ qua rừng thái lát sấy khô.', 'Cho 5-7 lát khổ qua vào ly, hãm với nước sôi. Nước đầu có thể hơi đắng, từ nước thứ 2 vị sẽ ngọt hậu dễ uống hơn. Có thể kết hợp với cỏ ngọt để giảm vị đắng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (133, 'Trà Lài Tân Cương Thượng Hạng', 'tra-lai-tan-cuong', 'Sự kết hợp đỉnh cao giữa \"Đệ nhất danh trà\" Tân Cương Thái Nguyên và hoa lài Quế thơm ngát. Không dùng hương liệu, trà được ướp bằng hoa lài tươi 100% qua 4-5 lần ướp (dệt hương). Cánh trà xoăn chặt, nước xanh vàng óng, hương thơm hoa lài quyện chặt vào vị chát dịu của trà, tạo nên dư vị khó quên.', 'Trà Tân Cương ướp hoa lài tươi, hương thơm tinh tế.', 180000.00, 0.00, 'TRA029', 100, 1, 'assets/images/tra_lai_tan_cuong_1.png', 1, 'active', 'Búp chè Tân Cương 1 tôm 2 lá, Hoa lài (hoa nhài) tươi.', 'Pha với nước sôi 85-90 độ C. Thời gian hãm trà ngắn (khoảng 30-45 giây) để giữ được hương hoa tươi mới và vị trà không bị chát gắt.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (134, 'Trà Lá Nam Giảm Cân Cổ Truyền', 'tra-la-nam', 'Công thức giảm cân an toàn từ thảo dược nước Nam. Không gây mệt mỏi, không tác dụng phụ. Trà Lá Nam tập trung vào việc thanh lọc gan thận, đào thải mỡ thừa qua đường bài tiết và tiêu hóa. Kiên trì sử dụng kết hợp ăn uống điều độ, bạn sẽ sớm lấy lại vóc dáng thon gọn và làn da sáng mịn.', 'Giảm cân an toàn, thanh lọc cơ thể, tiêu mỡ.', 80000.00, 0.00, 'TRA030', 100, 1, 'assets/images/tra_la_nam_1.png', 0, 'active', 'Lá sen, Chè vằng, Phan tả diệp, Vỏ bưởi, Sơn tra, Hoa nhài.', 'Rửa sạch 1 gói trà, đun sôi với 1.5 - 2 lít nước trong 15 phút. Để nguội uống thay nước lọc cả ngày. Ngon hơn khi uống lạnh.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (135, 'Trà Lá Ổi Hỗ Trợ Giảm Cân', 'tra-la-oi', 'Xu hướng giảm cân lành mạnh từ thiên nhiên. Lá ổi chứa nhiều Polyphenol, Carotenoid, Flavonoid giúp ngăn chặn sự chuyển hóa tinh bột thành đường, từ đó hỗ trợ giảm cân và kiểm soát đường huyết hiệu quả. Trà lá ổi có vị chát nhẹ, hương thơm dịu, rất dễ uống và tốt cho hệ tiêu hóa.', 'Ngăn hấp thụ tinh bột, giảm cân, tốt cho người tiểu đường.', 50000.00, 0.00, 'TRA031', 100, 1, 'assets/images/tra_la_oi_1.png', 0, 'active', '100% búp non và lá ổi sẻ sấy khô.', 'Lấy một nhúm lá ổi (khoảng 5-7g) hãm với nước sôi 10 phút. Uống sau bữa ăn 30 phút để hạn chế hấp thụ chất béo và tinh bột từ thức ăn.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (136, 'Set Trà Lipton Xí Muội Giải Nhiệt', 'tra-lipton-xi-muoi', 'Thức uống \"tuổi thơ\" nay đã được nâng cấp với phiên bản tiện lợi. Vị chua chua mặn mặn của xí muội, ngọt thanh của cam thảo kết hợp với vị chát nhẹ của trà Lipton tạo nên ly nước giải khát \"thần thánh\" đánh bay cơn khát mùa hè. Cung cấp Vitamin C giúp tăng đề kháng.', 'Giải khát mùa hè, chua ngọt mặn mà, ngon khó cưỡng.', 45000.00, 0.00, 'NL004', 200, 2, 'assets/images/tra_lipton_xi_muoi_1.png', 1, 'active', 'Túi trà Lipton nhãn vàng, Xí muội mặn, Xí muội ngọt, Táo đỏ, Cam thảo, Đường phèn.', 'Ngâm túi trà và các nguyên liệu với 200ml nước sôi. Dầm nát xí muội để ra vị chua mặn. Thêm đường phèn khuấy tan. Thêm đá thật nhiều và thưởng thức.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (137, 'Trà Mâm Xôi (Raspberry Tea)', 'tra-mam-xoi', 'Hương vị chua ngọt quyến rũ từ những quả mâm xôi đỏ mọng. Trà Mâm Xôi chứa hàm lượng Vitamin C và chất chống oxy hóa cực cao, giúp trẻ hóa làn da và tăng cường sức đề kháng. Màu trà đỏ hồng tự nhiên rất đẹp mắt, thích hợp để pha chế các loại trà trái cây nhiệt đới (Fruit Tea) sang chảnh.', 'Vị chua ngọt tự nhiên, giàu Vitamin C, pha trà trái cây.', 125000.00, 0.00, 'TRA032', 100, 1, 'assets/images/tra_mam_xoi_1.png', 0, 'active', 'Quả mâm xôi sấy lạnh nguyên trái, Hibiscus (Atiso đỏ), Táo sấy.', 'Hãm trà với nước sôi 5 phút. Khi uống có thể dầm nát quả mâm xôi để cảm nhận vị chua thanh. Ngon tuyệt khi pha cùng trà nhài và đá lạnh.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (138, 'Trà Mãng Cầu Xiêm (Soursop Tea)', 'tra-mang-cau-slim', 'Đặc sản miền Tây sông nước. Trà được làm từ thịt quả mãng cầu xiêm già, thái sợi và sao khô. Trà có hương thơm nồng nàn đặc trưng của mãng cầu, vị ngọt dịu và hơi chát nhẹ. Công dụng tuyệt vời trong việc an thần, giúp ngủ ngon, hạ huyết áp và hỗ trợ giảm cân nhờ cơ chế đốt cháy chất béo.', 'Hương thơm nồng nàn, hỗ trợ ngủ ngon, hạ huyết áp.', 110000.00, 0.00, 'TRA033', 100, 1, 'assets/images/tra_mang_cau_slim_1.png', 0, 'active', '100% thịt trái mãng cầu xiêm gọt vỏ, bỏ hạt, thái sợi sấy khô.', 'Lấy 5-7g trà hãm với nước sôi. Màu trà vàng nhạt, rất thơm. Có thể uống nóng hoặc lạnh. Bã trà sau khi hãm có thể ăn được, dẻo dẻo bùi bùi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (139, 'Trà Detox Cam Quế Mật Ong', 'tra-mix-vi-cam-que', 'Set trà \"Chill\" cho những ngày mưa hoặc Giáng sinh. Sự kết hợp ấm áp giữa cam vàng sấy lạnh, quế thanh cay nồng và hoa hồi thơm phức. Trà giúp làm ấm cơ thể, giảm ho, thư giãn tinh thần và detox thanh lọc độc tố. Một ly trà cam quế ấm nóng trên tay là liệu pháp xả stress tuyệt vời.', 'Detox cơ thể, thư giãn tinh thần, hương vị Giáng sinh.', 15000.00, 0.00, 'TRA034', 100, 1, 'assets/images/tra_mix_vi_cam_que_1.png', 1, 'active', 'Cam vàng sấy lát, Quế thanh, Hoa hồi, Đường phèn nâu.', 'Cho 1 set trà vào cốc. Rót 250ml nước sôi. Đậy nắp ủ 10 phút cho tinh dầu quế và cam tiết ra. Thêm mật ong nếu thích ngọt hơn. Uống khi còn ấm.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (140, 'Trà Móc Câu Tân Cương Đặc Biệt', 'tra-moc-cau', 'Đỉnh cao của trà xanh Việt Nam. Những búp chè non nhất được sao suốt bởi đôi bàn tay nghệ nhân, cánh trà săn lại, cong cong như lưỡi câu. Khi pha, nước xanh sánh như mật ong, hương cốm non ngào ngạt lan tỏa. Vị chát đậm đà kích thích vị giác, sau đó là vị ngọt hậu sâu lắng, đọng lại rất lâu trong cổ họng.', 'Cánh trà cong như móc câu, vị đậm đà, hương cốm.', 220000.00, 0.00, 'TRA035', 100, 1, 'assets/images/tra_moc_cau_1.png', 0, 'active', 'Búp chè tươi vùng Tân Cương - Thái Nguyên (1 tôm 1 lá).', 'Yêu cầu nước pha trà chuẩn 85-90 độ C. Tráng ấm, tráng trà nhanh. Hãm trà 30-60 giây. Rót hết ra tống và thưởng thức từng ngụm nhỏ để cảm nhận hết tinh túy.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (141, 'Trà Mộc Hoa Tây Bắc', 'tra-moc-hoa-tay-bac', 'Gói trọn hương sắc của núi rừng Tây Bắc vào trong một tách trà. Sản phẩm là sự kết hợp của các loại hoa rừng tự nhiên và thảo mộc vùng cao, mang lại hương vị hoang dã, phóng khoáng nhưng cũng đầy tinh tế. Trà giúp thư giãn thần kinh, giảm stress và mang lại cảm giác bình yên như đang đứng giữa đại ngàn.', 'Hương vị núi rừng, thư giãn, giảm stress.', 130000.00, 0.00, 'TRA036', 100, 1, 'assets/images/tra_moc_hoa_tay_bac_1.png', 0, 'active', 'Hoa cúc rừng, Nụ vối, Cỏ ngọt, Hoa nhài, Táo mèo thái lát.', 'Tráng ấm bằng nước sôi. Cho 10g trà vào ấm, hãm với nước sôi 90 độ trong 5-7 phút. Thưởng thức khi còn nóng để cảm nhận hương thơm hoa cỏ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (142, 'Lục Trà Nhài DalatFarm (Pha Chế)', 'tra-nhai-dalatfarm', 'Dòng trà chuyên dụng cho các quán trà sữa và cà phê. Lục trà (trà xanh) được trồng tại nông trại Đà Lạt, ướp hương hoa nhài theo công nghệ mới giúp lưu hương lâu, vị chát đậm đà, không bị mất mùi khi lắc với đá hoặc pha chung với syrup trái cây. Giải pháp tối ưu chi phí cho chủ quán.', 'Nguyên liệu pha chế, hương nhài đậm, giá tốt.', 105000.00, 0.00, 'NL005', 200, 2, 'assets/images/tra_nhai_dalatfarm_1.png', 1, 'active', '98% Trà xanh cắt nhỏ, 2% Hương hoa nhài tổng hợp thực phẩm.', 'Ủ 30g trà với 1 lít nước 85 độ C trong 7 phút. Lọc lấy cốt trà. Pha với đường, chanh hoặc syrup trái cây để làm các món trà trái cây giải nhiệt.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (143, 'Trà Nhài Hương (Trà Đá)', 'tra-nhai-huong', 'Sản phẩm bình dân quen thuộc tại các quán trà đá vỉa hè Hà Nội. Trà xanh cánh to được ướp hương liệu thực phẩm an toàn, cho màu nước xanh vàng đẹp mắt và mùi thơm nồng nàn đặc trưng. Vị chát gắt sảng khoái, thích hợp để pha trà đá đường hoặc trà chanh chém gió.', 'Chuyên pha trà đá, trà chanh, giá rẻ.', 70000.00, 0.00, 'NL006', 200, 2, 'assets/images/tra_nhai_huong_1.png', 0, 'active', 'Trà xanh, hương liệu hoa lài.', 'Hãm trà với nước sôi già (100 độ). Ủ 10-15 phút để trà ra hết chất chát. Pha loãng với nước lọc và thêm đá.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (144, 'Lục Trà Nhài Layla Cao Cấp', 'tra-nhai-layla', 'Phiên bản nâng cấp dành cho các Bartender chuyên nghiệp. Trà Nhài Layla sử dụng búp trà non hơn, ít cọng, cho hậu vị ngọt và màu nước trong sáng hơn. Hương nhài được cân chỉnh tinh tế, thanh thoát, không bị hắc, rất hợp để làm nền cho các món Trà Mãng Cầu, Trà Vải, Trà Dâu đang \"hot trend\".', 'Cao cấp cho quán trà sữa, hương thanh thoát, nước trong.', 140000.00, 0.00, 'NL007', 200, 2, 'assets/images/tra_nhai_layla_1.png', 0, 'active', 'Trà xanh cao cấp, Hoa nhài sấy khô, Hương liệu tự nhiên.', 'Tỷ lệ 1:30 (1g trà : 30ml nước). Nhiệt độ 80-85 độ C. Thời gian ủ 7-9 phút. Mở nắp khi ủ để nước trà không bị đỏ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (145, 'Trà Nhân Trần Cam Thảo', 'tra-nhan-tran-cam-thao', 'Thức uống giải nhiệt \"huyền thoại\" của mùa hè Bắc Bộ. Nhân trần giúp mát gan, lợi tiểu, kết hợp với Cam thảo bắc ngọt dịu tạo nên hương vị thơm ngon khó cưỡng. Một cốc nhân trần đá lạnh không chỉ đã khát mà còn giúp thanh lọc cơ thể, giảm mụn nhọt, rôm sảy.', 'Giải nhiệt mùa hè, mát gan, vị ngọt tự nhiên.', 40000.00, 0.00, 'TRA037', 100, 1, 'assets/images/tra_nhan_tran_cam_thao_1.png', 1, 'active', 'Cây nhân trần phơi khô, Cam thảo bắc thái lát.', 'Rửa sạch nguyên liệu. Đun sôi với nước trong 10-15 phút. Để nguội hoặc thêm đá uống thay nước lọc. Phụ nữ mang thai nên hạn chế sử dụng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (146, 'Trà Nõn Tôm Tân Cương (Thượng Hạng)', 'tra-non-tom', 'Tuyệt phẩm trong giới trà đạo. Chỉ hái duy nhất 1 tôm (búp non) và 1 lá non liền kề. Cánh trà nhỏ li ti, săn chắc. Khi pha, nước trà xanh sánh như cốm, hương thơm ngào ngạt lan tỏa cả phòng. Vị chát êm dịu ban đầu nhanh chóng chuyển thành vị ngọt đậm đà nơi cuống họng. Món quà biếu đẳng cấp cho người sành trà.', '1 tôm 1 lá, nước xanh cốm, vị ngọt hậu sâu sắc.', 450000.00, 420000.00, 'TRA038', 100, 1, 'assets/images/tra_non_tom_1.png', 1, 'active', '100% Nõn trà Tân Cương Thái Nguyên tuyển chọn.', 'Dùng nước 80-85 độ C. Tráng ấm chén kỹ. Đánh thức trà nhanh. Hãm trà khoảng 20-30 giây là rót ra ngay. Có thể pha được 4-5 nước vẫn ngọt.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (147, 'Trà Oolong Lai Châu', 'tra-o-long-lai-chau', 'Được trồng trên độ cao 1200m tại Tam Đường, Lai Châu, nơi có khí hậu mát mẻ quanh năm tương tự Đài Loan. Trà Oolong tại đây có viên tròn đều, màu xanh đen bóng. Vị trà mềm mại, ít chát, hương thơm hoa cỏ tự nhiên rất dễ chịu. Đây là niềm tự hào mới của ngành chè Việt Nam.', 'Oolong Việt Nam chất lượng cao, vị mềm mại.', 180000.00, 0.00, 'TRA039', 100, 1, 'assets/images/tra_o_long_lai_chau_1.png', 0, 'active', 'Búp trà Oolong Kim Tuyên/Thanh Tâm lên men bán phần.', 'Nhiệt độ nước: 95-100 độ C. Tráng trà nhanh. Hãm 45-60 giây cho nước đầu. Hương vị ngon nhất ở nước thứ 2 và 3.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (148, 'Trà Oolong Nướng (Roasted Oolong)', 'tra-o-long-len-men', 'Bí quyết tạo nên món \"Trà Sữa Nướng\" vạn người mê. Trà Oolong được rang ở nhiệt độ cao (Roasting) tạo ra mùi hương khói (Smoky) đặc trưng và vị trà đậm đà, mạnh mẽ. Khi pha với sữa, vị trà vẫn nổi bật chứ không bị lấn át, tạo nên ly trà sữa thơm lừng, béo ngậy.', 'Hương khói đặc trưng, chuyên làm trà sữa nướng.', 160000.00, 0.00, 'NL008', 200, 2, 'assets/images/tra_o_long_len_men_1.png', 1, 'active', 'Trà Oolong rang nhiệt độ cao.', 'Ủ 40g trà với 1 lít nước sôi 100 độ C trong 10-12 phút. Lấy nước cốt pha trà sữa nướng, trà sữa kem trứng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (149, 'Trà Phổ Nhĩ (Pu-erh Tea)', 'tra-pho-nhi', 'Loại trà lên men vi sinh độc đáo, được đóng thành bánh tròn. Phổ Nhĩ càng để lâu năm càng quý, vị trà càng êm dịu và nồng nàn mùi gỗ mục, mùi đất sau mưa. Trà có tác dụng tiêu mỡ, giảm cholesterol cực tốt, được giới thượng lưu săn lùng để thưởng thức và sưu tầm.', 'Trà bánh lên men lâu năm, vị gỗ đặc trưng, giảm mỡ máu.', 550000.00, 0.00, 'TRA040', 100, 1, 'assets/images/tra_pho_nhi_1.png', 0, 'active', 'Lá trà Shan Tuyết cổ thụ lên men ép bánh.', 'Dùng dao tách một miếng nhỏ (5-7g). Tráng trà 2 lần nước sôi để loại bỏ tạp chất và đánh thức trà. Hãm nước sôi 100 độ. Nước trà màu đỏ nâu rất đẹp.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (150, 'Trà Quế Hoa (Hoa Mộc)', 'tra-que-hoa', 'Những bông hoa mộc (Osmanthus) nhỏ li ti màu vàng cam nhưng chứa đựng hương thơm ngọt ngào như trái chín. Trà Quế Hoa không chỉ thơm mà còn giúp dưỡng nhan, làm sáng da, trị ho và giảm đờm. Thường được dùng để ướp trà, làm thạch Quế Hoa hoặc nấu chè dưỡng nhan.', 'Hương thơm trái chín ngọt ngào, dưỡng nhan, làm bánh/thạch.', 190000.00, 0.00, 'TRA041', 100, 1, 'assets/images/tra_que_hoa_1.png', 0, 'active', '100% Nụ hoa mộc sấy khô.', 'Pha trà: Hãm 3g hoa với 200ml nước sôi. Có thể mix cùng trà Oolong hoặc trà đen để tăng hương vị.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (151, 'Trà Quế Thảo Mộc Ấm Nồng', 'tra-que-thao-moc', 'Sự kết hợp giữa vỏ quế dày nhiều tinh dầu và các loại thảo mộc phương Đông. Vị cay nồng của quế giúp làm ấm cơ thể nhanh chóng, kích thích tuần hoàn máu và giảm đau nhức xương khớp mùa lạnh. Hương thơm ấm áp của trà mang lại cảm giác an toàn, vỗ về.', 'Vị cay ấm, tốt cho tuần hoàn máu, giảm đau nhức.', 80000.00, 0.00, 'TRA042', 100, 1, 'assets/images/tra_que_thao_moc_1.png', 0, 'active', 'Quế thanh cạo vỏ, Hồi, Thảo quả, Cỏ ngọt.', 'Bẻ nhỏ quế thanh, hãm cùng các thảo mộc với nước sôi già. Nên uống nóng vào buổi sáng mùa đông hoặc khi bị cảm lạnh.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (152, 'Trà Sâm Dứa Đà Nẵng', 'tra-sam-dua', 'Đặc sản nổi tiếng của miền Trung, ai đi Đà Nẵng cũng phải mua về làm quà. Vị chát nhẹ của trà xanh được làm dịu bởi hương thơm lá dứa (lá nếp) và hoa lài. Nước trà xanh trong, ngọt hậu, mùi thơm lá dứa lan tỏa rất dễ chịu. Tuyệt vời nhất khi uống đá giải khát.', 'Đặc sản Đà Nẵng, thơm nồng mùi lá dứa.', 60000.00, 0.00, 'TRA043', 100, 1, 'assets/images/tra_sam_dua_1.png', 1, 'active', 'Búp trà xanh, Lá dứa (Lá nếp), Hoa lài, Hương thảo mộc.', 'Pha trà như bình thường. Rót ra ly đá đầy. Cảm giác mát lạnh và hương thơm lá dứa sẽ xua tan cái nóng mùa hè.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (153, 'Trà Sâm Hồng Thảo Mộc', 'tra-sam-hong', 'Thức uống thanh nhiệt từ vùng núi Tây Bắc. Trà Sâm Hồng có vị ngọt đậm đà tự nhiên từ cỏ ngọt và chè dây, hoàn toàn không cần thêm đường. Rất tốt cho người bị nóng trong, hay nổi mụn, mất ngủ hoặc người tiểu đường muốn uống ngọt mà không hại sức khỏe.', 'Vị ngọt tự nhiên, mát gan, trị mụn, tốt cho người tiểu đường.', 75000.00, 0.00, 'TRA044', 100, 1, 'assets/images/tra_sam_hong_1.png', 0, 'active', 'Chè dây, Cỏ ngọt, Hoa la hán, Kim ngân hoa.', 'Hãm 10g trà với nước sôi. Uống nóng hoặc bỏ tủ lạnh uống thay nước giải khát. Vị ngọt lưu lại rất lâu ở cổ họng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (154, 'Trà Sâm Kỳ Tử Hải Dương', 'tra-sam-ky-hai-duong', 'Sản phẩm bồi bổ khí huyết thượng hạng. Sâm (Đảng sâm hoặc Sâm Bố Chính) kết hợp với Kỷ tử đỏ tạo nên bài thuốc giúp sáng mắt, hồng da, tăng cường sinh lực. Vị trà ngọt thanh, tính bình, thích hợp cho cả nam và nữ muốn cải thiện sức khỏe.', 'Bổ khí huyết, sáng mắt, tăng cường sinh lực.', 120000.00, 0.00, 'TRA045', 100, 1, 'assets/images/tra_sam_ky_hai_duong_1.png', 0, 'active', 'Sâm thái lát sấy khô, Kỷ tử đỏ (Câu kỷ tử).', 'Hãm nước sôi uống như trà. Sau khi uống hết nước nên ăn cả cái để tận dụng hết dược chất.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (155, 'Trà Sâm Tố Nữ Hồi Xuân', 'tra-sam-to-nu', 'Bí mật của sự quyến rũ. Sâm Tố Nữ chứa hoạt chất Estrogen thực vật mạnh gấp ngàn lần mầm đậu nành, giúp cân bằng nội tiết tố nữ, làm nở nang vòng 1, giảm khô hạn và bốc hỏa ở phụ nữ tiền mãn kinh. Uống trà mỗi ngày để gìn giữ nét xuân thì rạng rỡ.', 'Cân bằng nội tiết nữ, nở ngực, đẹp da, giảm bốc hỏa.', 200000.00, 0.00, 'TRA046', 100, 1, 'assets/images/tra_sam_to_nu_1.png', 0, 'active', 'Củ Sâm Tố Nữ thái lát sấy lạnh.', 'Đun sôi 10-15g sâm với 1 lít nước trong 20 phút. Chia uống trong ngày. Không dùng cho phụ nữ mang thai hoặc người có u xơ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (156, 'Trà Tâm Sen (Tim Sen) Huế', 'tra-tam-sen', 'Vị thuốc đắng dã tật từ tâm của hạt sen. Tâm sen có tính hàn, vị đắng, tác dụng thanh tâm hỏa, trấn kinh, an thần cực mạnh. Chuyên trị chứng mất ngủ kinh niên, hay hồi hộp, tim đập nhanh, huyết áp cao. Chỉ cần một nhúm nhỏ tâm sen là bạn sẽ có một giấc ngủ ngon đến sáng.', 'Đặc trị mất ngủ, hạ huyết áp, thanh nhiệt.', 150000.00, 0.00, 'TRA047', 100, 1, 'assets/images/tra_tam_sen_1.png', 0, 'active', 'Tâm sen (Tim sen) loại 1 sao vàng hạ thổ.', 'Lấy một lượng nhỏ (khoảng 3g) rửa sạch, hãm với nước sôi 5-10 phút. Nên uống vào buổi tối. Người huyết áp thấp không nên dùng nhiều.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (157, 'Trà Tấm (Trà Cám) Thái Nguyên', 'tra-tam-vun', 'Những mảnh vụn nhỏ gãy ra từ quá trình sao chè Thái Nguyên, tuy ngoại hình không đẹp nhưng chất lượng nước vẫn rất \"đỉnh\". Trà Tấm cho màu nước xanh đậm đà, hương thơm nồng và độ chát cao, rất tiết kiệm. Đây là lựa chọn số 1 của các quán trà đá vỉa hè.', 'Giá rẻ, nước đậm đà, chuyên pha trà đá.', 40000.00, 0.00, 'TRA048', 100, 1, 'assets/images/tra_tam_vun_1.png', 0, 'active', 'Vụn chè Thái Nguyên (gồm nõn tôm và lá gãy).', 'Dùng túi vải lọc trà để pha cho nước trong. Hãm nước sôi già. Pha loãng làm trà đá.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (158, 'Trà Thái Nguyên Truyền Thống', 'tra-thai-nguyen', 'Hương vị quen thuộc của mọi gia đình Việt. Trà búp Thái Nguyên loại truyền thống với cánh trà to, chắc. Nước trà màu vàng mật ong, vị chát đậm đà, \"uống đến đâu biết đến đấy\". Thích hợp để uống hàng ngày sau bữa ăn hoặc đãi khách bình dân.', 'Vị chát đậm truyền thống, nước vàng mật ong.', 180000.00, 0.00, 'TRA049', 100, 1, 'assets/images/tra_thai_nguyen_1.png', 0, 'active', '100% Chè búp Thái Nguyên sao khô.', 'Pha với nước sôi 100 độ C. Ngâm 3-5 phút tùy khẩu vị uống đậm hay nhạt.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (159, 'Trà Thái Xanh (Cha Tra Mue)', 'tra-thai-xanh', 'Nguyên liệu nhập khẩu để làm món Trà Sữa Thái Xanh huyền thoại. Bột trà có mùi thơm thảo mộc đặc trưng, khi pha ra có màu xanh ngọc bích rất đẹp mắt. Vị trà chát nhẹ, béo ngậy khi kết hợp với sữa đặc và bột béo.', 'Nguyên liệu làm trà sữa Thái Xanh, màu đẹp.', 65000.00, 0.00, 'NL009', 200, 2, 'assets/images/tra_thai_xanh_1.png', 1, 'active', 'Bột trà xanh Thái Lan, Màu thực phẩm, Hương liệu.', 'Nấu trà với nước sôi, lọc bã. Thêm bột kem béo và sữa đặc khi nước trà còn nóng. Thêm đá và thạch rau câu để thưởng thức.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (160, 'Trà Thảo Mộc Ba Kích Tím', 'tra-thao-moc-ba-kich', '\"Ông uống bà khen\". Ba kích tím Quảng Ninh nổi tiếng với công dụng bổ thận tráng dương, mạnh gân cốt. Ngoài cách ngâm rượu truyền thống, Ba kích sấy khô có thể dùng để sắc nước uống hàng ngày, giúp giảm đau lưng mỏi gối và tăng cường sức khỏe sinh lý phái mạnh.', 'Bổ thận tráng dương, mạnh gân cốt, giảm đau lưng.', 160000.00, 0.00, 'TRA050', 100, 1, 'assets/images/tra_thao_moc_ba_kich_1.png', 0, 'active', 'Củ Ba Kích tím bỏ lõi, sấy khô.', 'Sắc 15-20g ba kích với 1 lít nước, đun nhỏ lửa 30 phút. Hoặc dùng ngâm rượu (1kg khô ngâm 4-5 lít rượu 40 độ).', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (161, 'Ngự Trà An Nữ (Điều Kinh)', 'tra-thao-moc-ngu-tra-an-nu', 'Bài thuốc quý dành riêng cho phái đẹp. Sự kết hợp của Ích Mẫu, Hương Phụ và Ngải Cứu giúp điều hòa kinh nguyệt, giảm đau bụng kinh và giúp da dẻ hồng hào hơn. Thức uống chăm sóc sức khỏe tử cung và nội tiết tố nữ từ gốc.', 'Điều hòa kinh nguyệt, giảm đau bụng, tốt cho phụ nữ.', 145000.00, 0.00, 'TRA051', 100, 1, 'assets/images/tra_thao_moc_ngu_tra_an_nu_1.png', 0, 'active', 'Ích mẫu, Hương phụ, Ngải cứu, Đương quy, Xuyên khung.', 'Hãm trà hoặc sắc uống. Nên uống trước kỳ kinh 5-7 ngày để giảm đau bụng hiệu quả. Không dùng khi đang mang thai.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (162, 'Trà Thảo Mộc Xuân Thu', 'tra-thao-moc-xuan-thu', 'Lấy cảm hứng từ sự giao mùa, trà Xuân Thu mang lại sự cân bằng cho cơ thể. Vị trà nhẹ nhàng, thanh khiết từ các loại hoa và thảo mộc tính bình, giúp thư giãn, giảm mệt mỏi và tăng cường sức đề kháng khi thời tiết thay đổi.', 'Cân bằng cơ thể, tăng đề kháng, hương vị nhẹ nhàng.', 125000.00, 0.00, 'TRA052', 100, 1, 'assets/images/tra_thao_moc_xuan_thu_1.png', 0, 'active', 'Hoa cúc, Kỷ tử, Táo đỏ, Cỏ ngọt, Nụ nhài.', 'Pha trà với nước nóng, thưởng thức vào buổi sáng sớm hoặc chiều tà để cảm nhận sự thư thái.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (163, 'Trà Tía Tô (Perilla Tea)', 'tra-tia-to', 'Bí quyết làm đẹp da của phụ nữ Nhật Bản. Lá tía tô tím chứa hoạt chất làm trắng da tự nhiên, mờ thâm nám và chống lão hóa. Ngoài ra, trà tía tô nóng còn là bài thuốc giải cảm lạnh, trừ hàn, giảm ho cực kỳ hiệu quả trong dân gian.', 'Làm trắng da, trị nám, giải cảm lạnh.', 60000.00, 0.00, 'TRA053', 100, 1, 'assets/images/tra_tia_to_1.png', 0, 'active', 'Thân và lá tía tô tím sấy khô.', 'Hãm trà uống hàng ngày thay nước để làm đẹp da. Khi bị cảm, uống một cốc trà tía tô nóng đậm đặc rồi đắp chăn cho ra mồ hôi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (164, 'Trà Rau Mương Dạ Dày', 'tra-tui-loc-cay-rau-muong', 'Khắc tinh của vi khuẩn HP dạ dày. Cây rau mương là thảo dược dân gian được lưu truyền với khả năng hỗ trợ điều trị trào ngược dạ dày, viêm loét và tiêu diệt khuẩn HP. Dạng túi lọc tiện lợi, dễ uống, giúp bạn xua tan nỗi lo đau bao tử.', 'Hỗ trợ trị trào ngược dạ dày, diệt khuẩn HP.', 75000.00, 0.00, 'TRA054', 100, 1, 'assets/images/tra_tui_loc_cay_rau_muong_1.png', 0, 'active', 'Cây rau mương (thân, lá, hoa) phơi khô xay nhỏ.', 'Nhúng 2 túi lọc vào cốc nước sôi. Uống trước bữa ăn 15-30 phút để tráng lớp niêm mạc dạ dày.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (165, 'Trà Xanh Ướp Hoa Nhài Tự Nhiên', 'tra-uop-hoa-nhai', 'Sự tinh tế của nghệ thuật ướp trà Hà Thành. Không dùng hương liệu, chỉ dùng những nụ hoa nhài trắng muốt ngắt vào buổi chiều, ủ cùng trà xanh Thái Nguyên suốt đêm để hương hoa thấm sâu vào lõi trà. Vị trà chát đượm, hương hoa thanh khiết, tao nhã.', 'Ướp hoa tươi tự nhiên 100%, hương vị tao nhã.', 200000.00, 0.00, 'TRA055', 100, 1, 'assets/images/tra_uop_hoa_nhai_1.png', 0, 'active', 'Trà xanh Thái Nguyên loại 1, Hoa nhài quế.', 'Nhiệt độ nước 80-85 độ C. Hãm nhanh để giữ hương hoa. Thưởng thức chậm rãi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (166, 'Trà Xanh Nguyên Chất (Green Tea)', 'tra-xanh', 'Lá trà xanh bánh tẻ được sấy khô đơn giản để giữ nguyên hàm lượng EGCG và chất chống oxy hóa cao nhất. Vị trà chát nhẹ, không gắt, tính mát, giúp thanh nhiệt, giải độc, chống lão hóa và ngăn ngừa ung thư.', 'Giàu EGCG, chống lão hóa, thanh nhiệt.', 50000.00, 0.00, 'TRA056', 100, 1, 'assets/images/tra_xanh_1.png', 0, 'active', 'Lá trà xanh bánh tẻ sấy khô.', 'Hãm nước uống hàng ngày. Có thể thêm chanh, đường, đá để làm trà chanh giải khát.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (167, 'Trà Xanh Cổ Thụ Suối Giàng', 'tra-xanh-co-thu', 'Thu hái từ những cây chè cổ thụ hàng trăm năm tuổi trên đỉnh núi cao, quanh năm mây phủ. Rễ cây cắm sâu vào lòng đất hút dưỡng chất nên trà có nội chất cực mạnh. Vị trà rất đậm, nước vàng óng, có thể pha được 7-8 nước mà vẫn còn vị. Dành cho người \"nghiện\" trà lâu năm.', 'Trà núi cao, nội chất mạnh, pha được nhiều nước.', 350000.00, 0.00, 'TRA057', 100, 1, 'assets/images/tra_xanh_co_thu_1.png', 0, 'active', 'Búp chè cổ thụ 1 tôm 2 lá.', 'Dùng nước sôi 100 độ. Trà cổ thụ cần nhiệt cao để đánh thức hương vị. Uống xong vị ngọt đọng lại rất lâu.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (168, 'Trà Shan Tuyết Hà Giang', 'tra-xanh-shan-tuyet', 'Danh trà lừng danh của vùng núi phía Bắc. Búp trà to, mập mạp, phủ một lớp lông tơ trắng mịn như tuyết. Khi pha, nước trà sánh vàng như mật ong rừng, hương thơm cốm non ngào ngạt, vị chát êm và hậu ngọt sâu sắc. Sản phẩm đạt tiêu chuẩn OCOP 5 sao.', 'Búp trà phủ tuyết trắng, đặc sản OCOP, vị thượng hạng.', 300000.00, 280000.00, 'TRA058', 100, 1, 'assets/images/tra_xanh_shan_tuyet_1.png', 1, 'active', '100% Chè Shan Tuyết cổ thụ Hà Giang.', 'Tráng ấm chén nóng. Dùng nước 90-95 độ C. Thưởng thức hương thơm trà bốc lên ngào ngạt trước khi uống.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (169, 'Chè Dây Rừng Mù Cang Chải', 'che-day-rung-mu-cang-chai', 'Thu hái từ vùng núi cao Mù Cang Chải, nơi có khí hậu khắc nghiệt tạo nên dược tính mạnh mẽ hơn. Chè dây ở đây có lớp phấn trắng dày, vị đắng nhẹ nhưng hậu ngọt rất sâu, hiệu quả gấp đôi trong việc hỗ trợ dạ dày.', 'Chè dây rừng nguyên chất, dược tính mạnh.', 135000.00, 0.00, 'TRA069', 100, 1, 'assets/images/che_day_sapa_1.png', 0, 'active', '100% Chè dây rừng Mù Cang Chải', 'Hãm nước sôi uống thay nước lọc.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (170, 'Lục Trà Ướp Hoa Lài (Cold Brew)', 'luc-tra-uop-hoa-lai-lanh', 'Phiên bản trà lài đặc biệt thích hợp cho phương pháp ủ lạnh (Cold Brew). Cánh trà to, không bị nát, khi ủ lạnh qua đêm sẽ cho ra nước trà ngọt lịm, không hề chát đắng, hương hoa lài giữ được trọn vẹn sự tươi mới.', 'Chuyên dùng ủ lạnh Cold Brew, vị ngọt ngào.', 95000.00, 0.00, 'TRA070', 100, 1, 'assets/images/luc_tra_lai_1.png', 1, 'active', 'Lục trà, Hoa lài tươi', 'Ủ 10g trà với 1 lít nước nguội trong tủ lạnh 8-12 tiếng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (171, 'Oolong Mật Ong Rừng', 'oolong-mat-ong-rung', 'Sự kết hợp giữa Oolong Tứ Quý và mật ong khoái rừng già. Vị trà đậm đà quyện với vị ngọt khé đặc trưng của mật ong rừng tạo nên thức uống bồi bổ sức khỏe tuyệt vời, giúp tăng cường đề kháng tự nhiên.', 'Oolong kết hợp mật ong khoái, tăng đề kháng.', 180000.00, 0.00, 'TRA071', 100, 1, 'assets/images/mat_o_long_tra_1.png', 0, 'active', 'Trà Oolong, Mật ong rừng', 'Pha nóng để thưởng thức hương vị tốt nhất.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (172, 'Thảo Mộc An Thần Cung Đình', 'thao-moc-an-than-cung-dinh', 'Công thức bí truyền từ Thái Y Viện, không chỉ giúp ngủ ngon mà còn dưỡng tâm, bổ huyết. Vị trà thanh nhẹ, thoang thoảng mùi thảo mộc cung đình, mang lại cảm giác thư thái như đang ở chốn hoàng cung.', 'Bài thuốc cung đình, dưỡng tâm an thần.', 120000.00, 0.00, 'TRA072', 100, 1, 'assets/images/tra_an_than_ngu_ngon_1.png', 0, 'active', 'Tâm sen, Long nhãn, Bá tử nhân', 'Uống 1 tách ấm trước khi ngủ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (173, 'Trà Bạc Hà Lạnh (Menthol Tea)', 'tra-bac-ha-lanh', 'Cảm giác mát lạnh sảng khoái tức thì! Hàm lượng tinh dầu Menthol được tăng cường giúp thông mũi mát họng cực nhanh. Thích hợp uống vào mùa hè hoặc khi cần sự tỉnh táo cao độ để làm việc.', 'Siêu mát lạnh, tỉnh táo tức thì.', 75000.00, 0.00, 'TRA073', 100, 1, 'assets/images/tra_bac_ha_1.png', 1, 'active', 'Lá bạc hà Nhật Bản sấy lạnh', 'Pha với đá và chanh tươi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (174, 'Chè Búp Tân Cương Xanh', 'che-bup-tan-cuong-xanh', 'Dòng chè mộc bình dân, nước xanh, vị đậm, phù hợp với gu uống trà \"nặng đô\" của các cụ cao niên. Chè được sao tay kỹ, cánh săn chắc, pha được nhiều nước mà không bị nhạt.', 'Chè mộc đậm đà, nước xanh, giá tốt.', 150000.00, 0.00, 'TRA074', 100, 1, 'assets/images/tra_bac_thai_nguyen_1.png', 0, 'active', 'Chè búp Thái Nguyên', 'Pha nước sôi già.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (175, 'Ngự Trà Hoàng Cung (Hộp Quà)', 'ngu-tra-hoang-cung', 'Phiên bản hộp quà biếu Tết sang trọng của Trà Cung Đình. Gói trọn tinh hoa ẩm thực Huế với 16 vị thảo mộc tuyển chọn. Món quà ý nghĩa mang lời chúc sức khỏe, bình an cho người nhận.', 'Hộp quà biếu sang trọng, 16 vị thảo mộc.', 250000.00, 0.00, 'TRA075', 100, 1, 'assets/images/tra_cung_dinh_hue_1.png', 1, 'active', 'Thảo mộc cung đình tuyển chọn', 'Pha ấm lớn đãi khách.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (176, 'Hồng Trà Sữa Dalat (Túi Lớn)', 'hong-tra-sua-dalat', 'Gói lớn 1kg tiết kiệm dành cho các quán trà sữa hoặc gia đình đông người. Hồng trà được lên men kỹ, cho màu nước đỏ nâu đẹp mắt và hương thơm caramel tự nhiên, pha trà sữa béo ngậy cực chuẩn.', 'Gói lớn tiết kiệm, chuyên pha trà sữa.', 180000.00, 0.00, 'NL010', 200, 2, 'assets/images/tra_den_dalatfarm_1.png', 0, 'active', 'Hồng trà Đà Lạt', 'Ủ trà lấy cốt pha trà sữa.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (177, 'Gạo Lứt Đậu Đen Xanh Lòng', 'gao-lut-dau-den-xanh-long', 'Sự kết hợp \"gấp đôi canxi\" từ gạo lứt huyết rồng và đậu đen xanh lòng hạt nhỏ. Nước trà thơm mùi đậu rang, vị ngọt bùi, giúp xương chắc khỏe và thận hoạt động tốt hơn.', 'Tốt cho xương khớp, bổ thận, thơm bùi.', 70000.00, 0.00, 'TRA076', 100, 1, 'assets/images/tra_gao_luc_1.png', 0, 'active', 'Gạo lứt, Đậu đen xanh lòng', 'Hãm nước sôi uống cả cái lẫn nước.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (178, 'Trà Gừng Sả Mật Ong', 'tra-gung-sa-mat-ong', 'Thêm hương vị sả chanh tươi mát giúp cân bằng vị cay của gừng. Thức uống detox, giải cảm tuyệt vời, giúp làm ấm bụng và thư giãn cơ bắp sau khi vận động mạnh.', 'Thêm vị sả thơm mát, detox, giải cảm.', 60000.00, 0.00, 'TRA077', 100, 1, 'assets/images/tra_gung_1.png', 0, 'active', 'Gừng, Sả, Mật ong', 'Pha nước nóng.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (179, 'Thập Toàn Đại Bổ Trà', 'thap-toan-dai-bo-tra', 'Bài thuốc \"Thập Toàn Đại Bổ\" nay đã có dạng trà tiện lợi. Giúp phục hồi sinh lực cho người mới ốm dậy, người già yếu. Vị ngọt đậm đà của các vị thuốc bắc nhưng rất dễ uống, không bị hăng.', 'Bồi bổ toàn diện, phục hồi sức khỏe.', 300000.00, 0.00, 'TRA078', 100, 1, 'assets/images/tra_hoang_thao_moc_1.png', 0, 'active', 'Đảng sâm, Bạch linh, Bạch truật...', 'Sắc uống hoặc hãm kỹ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (180, 'Hồng Sâm Thái Lát Tẩm Mật', 'hong-sam-thai-lat-tam-mat', 'Những lát hồng sâm dẻo quánh, thấm đẫm mật ong rừng. Có thể ăn trực tiếp như mứt hoặc hãm trà đều ngon. Vị đắng nhẹ của sâm hòa quyện với vị ngọt của mật ong tạo nên hương vị khó quên.', 'Ăn trực tiếp hoặc pha trà, dẻo ngọt.', 350000.00, 0.00, 'TRA079', 100, 1, 'assets/images/tra_hong_sam_1.png', 1, 'active', 'Hồng sâm, Mật ong', 'Ăn trực tiếp 2-3 lát mỗi ngày.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (181, 'Khổ Qua Rừng Sấy Khô (Vị Mộc)', 'kho-qua-rung-say-kho', 'Dành cho người thích vị đắng nguyên bản. Khổ qua rừng được phơi nắng tự nhiên, không tẩm ướp, giữ nguyên dược tính cao nhất hỗ trợ điều trị tiểu đường.', 'Vị đắng nguyên bản, hỗ trợ tiểu đường mạnh.', 100000.00, 0.00, 'TRA080', 100, 1, 'assets/images/tra_kho_qua_1.png', 0, 'active', 'Khổ qua rừng nguyên chất', 'Hãm nước sôi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (182, 'Trà Nhài Cổ Thụ', 'tra-nhai-co-thu', 'Sử dụng búp chè Shan Tuyết cổ thụ ướp hương nhài thay vì chè Tân Cương thông thường. Vị trà đậm đà hơn, chát êm hơn và pha được nhiều nước hơn. Một trải nghiệm mới lạ cho người yêu trà nhài.', 'Nền trà cổ thụ đậm đà, hương nhài thanh khiết.', 220000.00, 0.00, 'TRA081', 100, 1, 'assets/images/tra_lai_tan_cuong_1.png', 0, 'active', 'Chè Shan Tuyết, Hoa nhài', 'Pha nước 90 độ C.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (183, 'Trà Quả Mọng (Berry Tea)', 'tra-qua-mong', 'Sự bùng nổ của các loại quả mọng: Mâm xôi, Dâu tây, Việt quất. Vị chua ngọt tự nhiên, màu đỏ rực rỡ, chứa cực nhiều Vitamin C giúp đẹp da và tăng cường hệ miễn dịch.', 'Mix nhiều loại quả mọng, giàu Vitamin C.', 140000.00, 0.00, 'TRA082', 100, 1, 'assets/images/tra_mam_xoi_1.png', 1, 'active', 'Mâm xôi, Dâu tây, Việt quất sấy', 'Pha trà trái cây lạnh.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (184, 'Trà Mãng Cầu Xiêm Giảm Cân', 'tra-mang-cau-xiem-giam-can', 'Tập trung vào công dụng hỗ trợ giảm cân của mãng cầu xiêm. Trà được sấy khô kiệt nước, hương thơm nồng hơn, giúp giảm cảm giác thèm ăn và đốt cháy mỡ thừa hiệu quả.', 'Hỗ trợ giảm cân, hương thơm nồng.', 120000.00, 0.00, 'TRA083', 100, 1, 'assets/images/tra_mang_cau_slim_1.png', 0, 'active', 'Thịt mãng cầu xiêm già', 'Uống trước bữa ăn.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (185, 'Oolong Tứ Quý (Four Seasons)', 'oolong-tu-quy', 'Giống trà Oolong Tứ Quý nổi tiếng với hương thơm hoa cỏ bốn mùa. Nước trà màu vàng ánh xanh, vị chát rất nhẹ, hậu ngọt thanh, uống cả ngày không biết chán.', 'Hương hoa bốn mùa, vị thanh nhẹ.', 190000.00, 0.00, 'TRA084', 100, 1, 'assets/images/tra_o_long_lai_chau_1.png', 1, 'active', 'Trà Oolong Tứ Quý', 'Pha công phu trà.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (186, 'Mộc Quế Hoa Trà (Osmanthus)', 'moc-que-hoa-tra', 'Tên gọi mỹ miều cho loại trà hoa mộc cao cấp. Những nụ hoa vàng ươm được tuyển chọn kỹ lưỡng, không lẫn tạp chất, chuyên dùng để ướp trà sen hoặc làm thạch Quế Hoa dưỡng nhan.', 'Hoa mộc tuyển chọn, làm thạch dưỡng nhan.', 210000.00, 0.00, 'TRA085', 100, 1, 'assets/images/tra_que_hoa_1.png', 0, 'active', 'Hoa mộc thượng hạng', 'Pha trà hoặc nấu chè.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (187, 'Sâm Hồng Bát Tiên', 'sam-hong-bat-tien', 'Phiên bản cao cấp bổ sung thêm Kỷ tử và Táo đỏ vào Trà Sâm Hồng. Không chỉ mát gan mà còn bổ máu, đẹp da, thích hợp cho chị em phụ nữ văn phòng.', 'Thêm kỷ tử táo đỏ, đẹp da mát gan.', 90000.00, 0.00, 'TRA086', 100, 1, 'assets/images/tra_sam_hong_1.png', 0, 'active', 'Chè dây, Cỏ ngọt, Kỷ tử, Táo đỏ', 'Hãm uống hàng ngày.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (188, 'Bạch Trà Shan Tuyết Cổ Thụ', 'bach-tra-shan-tuyet', 'Đỉnh cao của trà Việt. Chỉ hái 1 tôm (búp non nhất) của cây chè cổ thụ, phơi khô tự nhiên trong bóng râm (không sao nhiệt). Bạch trà có lớp lông tuyết trắng muốt, hương thơm cỏ khô tinh tế, vị thanh khiết như nước suối nguồn.', 'Bạch trà quý hiếm, phơi khô tự nhiên.', 500000.00, 0.00, 'TRA087', 100, 1, 'assets/images/tra_xanh_shan_tuyet_1.png', 1, 'active', '100% búp non Shan Tuyết (1 tôm)', 'Pha nước 85 độ, thưởng thức tinh tế.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (189, 'Hồng Trà Bá Tước (Earl Grey)', 'hong-tra-ba-tuoc', 'Dòng trà quý tộc phương Tây. Hồng trà (Trà đen) hảo hạng được ướp tinh dầu vỏ cam Bergamot miền Địa Trung Hải. Hương thơm cam chanh nồng nàn quyện với vị trà đậm đà tạo nên phong cách thưởng trà kiểu Anh đích thực.', 'Hương cam Bergamot quý tộc, phong cách Anh Quốc.', 115000.00, 0.00, 'TRA089', 200, 2, 'assets/images/tra_den_dalatfarm_1.png', 1, 'active', 'Hồng trà, Tinh dầu Bergamot', 'Pha nóng, thêm đường hoặc sữa tươi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (190, 'Lục Trà Lài King (Dòng Vua)', 'luc-tra-lai-king', 'Phiên bản cao cấp nhất của dòng trà nhài pha chế. Sử dụng cốt trà xanh vùng cao ít chát, độ hương (độ thơm) cao gấp đôi loại thường. Chuyên dùng cho các món trà trái cây cao cấp (\"King\") yêu cầu độ thơm tinh tế.', 'Độ hương gấp đôi, chuyên pha trà trái cây cao cấp.', 145000.00, 0.00, 'NL011', 200, 2, 'assets/images/luc_tra_lai_1.png', 0, 'active', 'Trà xanh tuyển chọn ướp hương lài', 'Ủ trà nhiệt độ 80 độ C để giữ hương.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (191, 'Trà Gừng Đường Đen (Ô Mai)', 'tra-gung-duong-den', 'Sự kết hợp giữa vị cay nồng của gừng già và vị ngọt đậm đà, thơm mùi mật mía của đường đen (đường nâu). Thức uống lý tưởng cho phụ nữ ngày \"đèn đỏ\" hoặc người bị tụt huyết áp, lạnh bụng.', 'Vị ngọt đậm đà đường đen, làm ấm cực nhanh.', 65000.00, 0.00, 'TRA091', 100, 1, 'assets/images/tra_gung_1.png', 0, 'active', 'Bột gừng, Đường đen mật mía', 'Pha nước nóng uống liền.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (192, 'Trà Hoa Cúc Chi Hưng Yên', 'tra-hoa-cuc-chi-hung-yen', 'Đặc sản \"Cúc Tiến Vua\" nổi tiếng Hưng Yên. Bông cúc chi nhỏ, tròn xoe, màu vàng rực rỡ, được sấy lạnh nguyên bông. Vị trà hơi đắng nhẹ nhưng hậu ngọt, giúp sáng mắt, ngủ ngon và thanh nhiệt giải độc cực tốt.', 'Cúc Tiến Vua sấy lạnh nguyên bông, sáng mắt.', 150000.00, 135000.00, 'TRA092', 100, 1, 'assets/images/tra_hoa_cuc_que_hoa_ky_tu_1.png', 0, 'active', '100% Hoa cúc chi sấy lạnh', 'Hãm với nước sôi, thêm kỷ tử táo đỏ.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (193, 'Trà Oolong Sữa (Milk Oolong)', 'tra-o-long-sua', 'Dòng Oolong đặc biệt có hương thơm sữa tự nhiên (Milky) thoang thoảng dù không hề pha sữa. Vị trà mượt mà như lụa, béo ngậy nơi đầu lưỡi. Đây là giống trà lai tạo đặc biệt, rất được lòng phái nữ.', 'Hương sữa tự nhiên, vị mượt mà béo ngậy.', 210000.00, 0.00, 'TRA093', 100, 1, 'assets/images/tra_o_long_lai_chau_1.png', 1, 'active', 'Búp trà Oolong giống Kim Tuyên', 'Pha nhiệt độ 90-95 độ C.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (194, 'Trà Gạo Lứt Xạ Đen', 'tra-gao-lut-xa-den', 'Bổ sung thêm Xạ Đen - thảo dược hỗ trợ ngăn ngừa ung bướu vào trà gạo lứt truyền thống. Vị trà vẫn thơm mùi gạo rang nhưng có thêm chút nhẫn nhẹ của thảo mộc, tăng cường khả năng thải độc gan.', 'Thêm xạ đen ngừa ung bướu, thải độc gan.', 75000.00, 0.00, 'TRA094', 100, 1, 'assets/images/tra_gao_luc_1.png', 0, 'active', 'Gạo lứt, Xạ đen, Đậu đen', 'Đun sôi hoặc hãm trong bình giữ nhiệt.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (195, 'Trà Cà Gai Leo Túi Lọc', 'tra-ca-gai-leo-tui-loc', 'Phiên bản túi lọc tiện lợi của cà gai leo. Dành cho người bận rộn muốn bảo vệ gan, giải rượu bia nhưng không có thời gian đun nấu. Chỉ cần 3 phút là có ngay ly trà giải độc gan thơm ngon.', 'Giải độc gan dạng túi lọc tiện lợi.', 60000.00, 0.00, 'TRA095', 100, 1, 'assets/images/tra_tui_loc_cay_rau_muong_1.png', 0, 'active', 'Cà gai leo, Diệp hạ châu', 'Nhúng túi lọc vào nước sôi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (196, 'Trà Dây Cao Bằng (Chè Dây)', 'tra-day-cao-bang', 'Cùng là chè dây nhưng thu hái ở vùng núi Cao Bằng. Lá chè dày hơn, nhiều nhựa trắng hơn, vị chát đậm hơn một chút so với chè Sapa. Hiệu quả cắt cơn đau dạ dày rất nhanh chóng.', 'Đặc sản Cao Bằng, cắt cơn đau dạ dày nhanh.', 110000.00, 0.00, 'TRA096', 100, 1, 'assets/images/che_day_sapa_1.png', 0, 'active', 'Chè dây Cao Bằng phơi khô', 'Hãm nước sôi uống hàng ngày.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (197, 'Lá Bạc Hà Sấy Khô (Âu)', 'la-bac-ha-say-kho', 'Lá bạc hà giống Âu (Peppermint) sấy khô nguyên lá. Mùi thơm nồng nàn hơn hẳn bạc hà ta. Thường dùng để pha trà (Tea blend) hoặc làm bánh, trang trí đồ uống rất đẹp mắt.', 'Giống bạc hà Âu thơm nồng, dùng pha trà/làm bánh.', 80000.00, 0.00, 'TRA097', 100, 1, 'assets/images/tra_bac_ha_1.png', 0, 'active', 'Lá bạc hà sấy nguyên cánh', 'Pha riêng hoặc mix cùng trà đen.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (198, 'Trà Sơn Mật Hồng Sâm (Đặc Biệt)', 'tra-son-mat-hong-sam', 'Tên đầy đủ của loại trà thảo mộc nổi tiếng Tây Bắc. \"Sơn Mật\" là mật của núi rừng. Vị ngọt của trà hoàn toàn từ cỏ ngọt và mật ong rừng thấm vào cây cỏ. Không đường hóa học, an toàn tuyệt đối.', 'Vị ngọt mật núi rừng, thanh nhiệt, an thần.', 85000.00, 0.00, 'TRA098', 100, 1, 'assets/images/tra_sam_hong_1.png', 1, 'active', 'Trà dây, kim ngân, cỏ ngọt, hoa nhài', 'Uống thay nước lọc.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (199, 'Chè Đắng Cao Bằng (Thái Lát)', 'che-dang-cao-bang', 'Nhìn hình thức rất giống khổ qua thái lát nhưng đây là Chè Đắng (Chè Khổ). Vị rất đắng nhưng hậu ngọt (Khổ tận cam lai). Chỉ cần 1-2 lát nhỏ (như đinh) là đủ cho một ấm trà. Giúp tỉnh táo và tiêu mỡ cực mạnh.', 'Rất đắng nhưng hậu ngọt, tiêu mỡ mạnh.', 160000.00, 0.00, 'TRA099', 100, 1, 'assets/images/tra_kho_qua_1.png', 0, 'active', 'Lá chè đắng cuộn tròn thái lát', 'Chỉ dùng 1-2 lát pha với nước sôi.', '2026-01-28 19:46:18');
INSERT INTO `products` VALUES (200, 'Trà Sen Tây Hồ (Ướp Xổi)', 'tra-sen-tay-ho', 'Tinh hoa trà Việt. Trà xanh Tân Cương thượng hạng ướp trong bông sen Bách Diệp vùng Hồ Tây. Hương sen thơm ngát, thanh tao quyện với vị chát dịu của trà. (Hình ảnh minh họa là trà ướp hương hoa, nét tương đồng về màu sắc và cánh trà).', 'Quốc ẩm Việt Nam, ướp hương sen thanh tao.', 400000.00, 380000.00, 'TRA100', 100, 1, 'assets/images/tra_uop_hoa_nhai_1.png', 1, 'active', 'Trà xanh, Gạo sen, Nhụy sen', 'Pha nước 85 độ, thưởng thức tinh tế.', '2026-01-28 19:46:18');

-- ----------------------------
-- Table structure for promotion_items
-- ----------------------------
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
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotion_items
-- ----------------------------
INSERT INTO `promotion_items` VALUES (1, 1, 101);
INSERT INTO `promotion_items` VALUES (2, 1, 149);
INSERT INTO `promotion_items` VALUES (3, 1, 188);

-- ----------------------------
-- Table structure for promotions
-- ----------------------------
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
  `approval_status` enum('PENDING','APPROVED','REJECTED') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `promotion_type` enum('ALL','VIP') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'ALL',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of promotions
-- ----------------------------
INSERT INTO `promotions` VALUES (1, 'sale 8-3', 'sale giá rẻ', '2026-03-23 20:40:15', '2026-03-31 20:40:23', 'PERCENT', 83000.00, 'assets/images/promo_1774791654322_banner-8-3.jpg', 0, 'APPROVED', '2026-03-29 20:40:54', 'ALL');

-- ----------------------------
-- Table structure for refund_requests
-- ----------------------------
DROP TABLE IF EXISTS `refund_requests`;
CREATE TABLE `refund_requests`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `user_id` int NOT NULL,
  `amount` decimal(12, 2) NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `receive_method` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account_holder` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `account_number` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `qr_image_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'pending',
  `admin_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `processed_by` int NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `processed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_refund_requests_order_id`(`order_id` ASC) USING BTREE,
  INDEX `idx_refund_requests_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_refund_requests_status`(`status` ASC) USING BTREE,
  CONSTRAINT `fk_refund_requests_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_refund_requests_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of refund_requests
-- ----------------------------

-- ----------------------------
-- Table structure for role_permissions
-- ----------------------------
DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE `role_permissions`  (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`) USING BTREE,
  INDEX `permission_id`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role_permissions
-- ----------------------------
INSERT INTO `role_permissions` VALUES (1, 1);
INSERT INTO `role_permissions` VALUES (1, 2);
INSERT INTO `role_permissions` VALUES (1, 3);
INSERT INTO `role_permissions` VALUES (1, 4);
INSERT INTO `role_permissions` VALUES (1, 5);
INSERT INTO `role_permissions` VALUES (1, 6);
INSERT INTO `role_permissions` VALUES (1, 7);
INSERT INTO `role_permissions` VALUES (1, 8);
INSERT INTO `role_permissions` VALUES (1, 9);
INSERT INTO `role_permissions` VALUES (1, 10);
INSERT INTO `role_permissions` VALUES (1, 11);
INSERT INTO `role_permissions` VALUES (1, 12);
INSERT INTO `role_permissions` VALUES (1, 13);
INSERT INTO `role_permissions` VALUES (1, 14);
INSERT INTO `role_permissions` VALUES (1, 15);
INSERT INTO `role_permissions` VALUES (1, 16);
INSERT INTO `role_permissions` VALUES (1, 17);
INSERT INTO `role_permissions` VALUES (1, 18);
INSERT INTO `role_permissions` VALUES (1, 19);
INSERT INTO `role_permissions` VALUES (1, 20);
INSERT INTO `role_permissions` VALUES (1, 21);
INSERT INTO `role_permissions` VALUES (1, 22);
INSERT INTO `role_permissions` VALUES (1, 23);
INSERT INTO `role_permissions` VALUES (1, 24);
INSERT INTO `role_permissions` VALUES (1, 25);
INSERT INTO `role_permissions` VALUES (1, 26);
INSERT INTO `role_permissions` VALUES (2, 3);
INSERT INTO `role_permissions` VALUES (2, 20);
INSERT INTO `role_permissions` VALUES (3, 1);
INSERT INTO `role_permissions` VALUES (3, 11);
INSERT INTO `role_permissions` VALUES (3, 12);
INSERT INTO `role_permissions` VALUES (3, 13);
INSERT INTO `role_permissions` VALUES (3, 14);
INSERT INTO `role_permissions` VALUES (3, 15);
INSERT INTO `role_permissions` VALUES (3, 16);
INSERT INTO `role_permissions` VALUES (3, 18);
INSERT INTO `role_permissions` VALUES (3, 19);
INSERT INTO `role_permissions` VALUES (3, 20);
INSERT INTO `role_permissions` VALUES (3, 21);
INSERT INTO `role_permissions` VALUES (3, 22);
INSERT INTO `role_permissions` VALUES (3, 25);
INSERT INTO `role_permissions` VALUES (3, 26);

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Ví dụ: ADMIN, CUSTOMER, EDITOR',
  `display_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `max_discount_percent` decimal(5, 2) NULL DEFAULT 100.00,
  `is_system` tinyint(1) NULL DEFAULT 0 COMMENT '1 = role hệ thống, không được xóa',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of roles
-- ----------------------------
INSERT INTO `roles` VALUES (1, 'ADMIN', 'Quản trị viên', NULL, 100.00, 1, '2026-06-04 22:33:31');
INSERT INTO `roles` VALUES (2, 'CUSTOMER', 'Khách hàng', NULL, 100.00, 1, '2026-06-04 22:33:31');
INSERT INTO `roles` VALUES (3, 'EDITOR', 'Biên tập viên', NULL, 15.00, 1, '2026-06-04 22:33:31');
INSERT INTO `roles` VALUES (4, 'MANAGEGER', 'Quản lý kho', NULL, 100.00, 0, '2026-06-05 16:22:14');

-- ----------------------------
-- Table structure for shipper_transactions
-- ----------------------------
DROP TABLE IF EXISTS `shipper_transactions`;
CREATE TABLE `shipper_transactions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `shipper_id` int NOT NULL,
  `amount` decimal(15, 2) NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'pending' COMMENT 'pending: Chờ duyệt, approved: Đã nhận tiền, rejected: Từ chối',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `shipper_id`(`shipper_id` ASC) USING BTREE,
  CONSTRAINT `shipper_transactions_ibfk_1` FOREIGN KEY (`shipper_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of shipper_transactions
-- ----------------------------
INSERT INTO `shipper_transactions` VALUES (1, 60, 170000.00, 'pending', '2026-05-20 16:20:59', NULL);

-- ----------------------------
-- Table structure for systemlogs
-- ----------------------------
DROP TABLE IF EXISTS `systemlogs`;
CREATE TABLE `systemlogs`  (
  `LogID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NULL DEFAULT NULL,
  `Action` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `EntityType` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `EntityID` int NULL DEFAULT NULL,
  `Timestamp` datetime NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`LogID`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 205 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of systemlogs
-- ----------------------------
INSERT INTO `systemlogs` VALUES (1, 60, 'Đăng nhập', 'Auth', NULL, '2026-05-22 19:59:52');
INSERT INTO `systemlogs` VALUES (2, 60, 'Đăng xuất', 'Auth', NULL, '2026-05-22 20:11:01');
INSERT INTO `systemlogs` VALUES (3, 60, 'Đăng nhập', 'Auth', NULL, '2026-05-22 20:29:51');
INSERT INTO `systemlogs` VALUES (4, 60, 'Đăng xuất', 'Auth', NULL, '2026-05-22 20:30:02');
INSERT INTO `systemlogs` VALUES (5, 69, 'Đăng nhập', 'Auth', NULL, '2026-05-22 22:10:54');
INSERT INTO `systemlogs` VALUES (6, 69, 'Đăng nhập', 'Auth', NULL, '2026-05-22 22:19:16');
INSERT INTO `systemlogs` VALUES (7, 69, 'Đăng xuất', 'Auth', NULL, '2026-05-22 22:19:25');
INSERT INTO `systemlogs` VALUES (8, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-22 22:19:31');
INSERT INTO `systemlogs` VALUES (9, 69, 'Đăng nhập', 'Auth', NULL, '2026-05-22 22:30:09');
INSERT INTO `systemlogs` VALUES (10, 69, 'Đăng xuất', 'Auth', NULL, '2026-05-22 22:30:26');
INSERT INTO `systemlogs` VALUES (11, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-22 22:30:36');
INSERT INTO `systemlogs` VALUES (12, 69, 'Đăng nhập', 'Auth', NULL, '2026-05-22 23:02:40');
INSERT INTO `systemlogs` VALUES (13, 69, 'Đăng xuất', 'Auth', NULL, '2026-05-22 23:03:06');
INSERT INTO `systemlogs` VALUES (14, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-22 23:03:14');
INSERT INTO `systemlogs` VALUES (15, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-22 23:03:32');
INSERT INTO `systemlogs` VALUES (16, 60, 'Đăng nhập', 'Auth', NULL, '2026-05-22 23:03:44');
INSERT INTO `systemlogs` VALUES (17, 60, 'Đăng nhập', 'Auth', NULL, '2026-05-23 15:09:54');
INSERT INTO `systemlogs` VALUES (18, 60, 'Đăng xuất', 'Auth', NULL, '2026-05-23 15:10:32');
INSERT INTO `systemlogs` VALUES (19, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-23 15:10:37');
INSERT INTO `systemlogs` VALUES (20, 68, 'Gán shipper #69 cho đơn hàng', 'Order', 10, '2026-05-23 15:12:14');
INSERT INTO `systemlogs` VALUES (21, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-23 15:14:07');
INSERT INTO `systemlogs` VALUES (22, 60, 'Đăng nhập', 'Auth', NULL, '2026-05-23 15:14:34');
INSERT INTO `systemlogs` VALUES (23, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-23 21:51:40');
INSERT INTO `systemlogs` VALUES (24, 68, 'Đã đẩy đơn hàng sang ĐVVC (GHN)', 'Order', 10, '2026-05-23 21:52:01');
INSERT INTO `systemlogs` VALUES (25, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-24 16:04:13');
INSERT INTO `systemlogs` VALUES (26, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-24 16:16:09');
INSERT INTO `systemlogs` VALUES (27, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-24 16:45:18');
INSERT INTO `systemlogs` VALUES (28, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-24 16:54:07');
INSERT INTO `systemlogs` VALUES (29, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-24 16:54:25');
INSERT INTO `systemlogs` VALUES (30, 65, 'Đăng nhập', 'Auth', NULL, '2026-05-24 17:39:04');
INSERT INTO `systemlogs` VALUES (31, 65, 'Đăng xuất', 'Auth', NULL, '2026-05-24 17:39:12');
INSERT INTO `systemlogs` VALUES (32, 65, 'Đăng nhập', 'Auth', NULL, '2026-05-24 17:40:17');
INSERT INTO `systemlogs` VALUES (33, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-24 19:33:28');
INSERT INTO `systemlogs` VALUES (34, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-25 20:51:50');
INSERT INTO `systemlogs` VALUES (35, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-27 22:42:57');
INSERT INTO `systemlogs` VALUES (36, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-27 22:51:50');
INSERT INTO `systemlogs` VALUES (37, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-27 23:03:09');
INSERT INTO `systemlogs` VALUES (38, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 13:15:58');
INSERT INTO `systemlogs` VALUES (39, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 13:25:28');
INSERT INTO `systemlogs` VALUES (40, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 13:46:57');
INSERT INTO `systemlogs` VALUES (41, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-28 13:54:03');
INSERT INTO `systemlogs` VALUES (42, 65, 'Đăng nhập', 'Auth', NULL, '2026-05-28 13:54:21');
INSERT INTO `systemlogs` VALUES (43, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:11:24');
INSERT INTO `systemlogs` VALUES (44, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:15:09');
INSERT INTO `systemlogs` VALUES (45, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-28 14:16:13');
INSERT INTO `systemlogs` VALUES (46, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:19:26');
INSERT INTO `systemlogs` VALUES (47, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:23:32');
INSERT INTO `systemlogs` VALUES (48, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:30:42');
INSERT INTO `systemlogs` VALUES (49, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:41:59');
INSERT INTO `systemlogs` VALUES (50, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:51:39');
INSERT INTO `systemlogs` VALUES (51, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-28 14:53:09');
INSERT INTO `systemlogs` VALUES (52, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:54:37');
INSERT INTO `systemlogs` VALUES (53, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 14:57:44');
INSERT INTO `systemlogs` VALUES (54, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:05:01');
INSERT INTO `systemlogs` VALUES (55, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:14:03');
INSERT INTO `systemlogs` VALUES (56, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:23:31');
INSERT INTO `systemlogs` VALUES (57, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:35:24');
INSERT INTO `systemlogs` VALUES (58, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:52:07');
INSERT INTO `systemlogs` VALUES (59, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 15:55:46');
INSERT INTO `systemlogs` VALUES (60, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-28 16:15:28');
INSERT INTO `systemlogs` VALUES (61, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:15:37');
INSERT INTO `systemlogs` VALUES (62, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-28 16:16:15');
INSERT INTO `systemlogs` VALUES (63, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:16:24');
INSERT INTO `systemlogs` VALUES (64, 68, 'Tạo vận đơn GHN #LXNTUP cho đơn hàng', 'Order', 15, '2026-05-28 16:16:37');
INSERT INTO `systemlogs` VALUES (65, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:21:55');
INSERT INTO `systemlogs` VALUES (66, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:28:38');
INSERT INTO `systemlogs` VALUES (67, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-28 16:28:51');
INSERT INTO `systemlogs` VALUES (68, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:29:03');
INSERT INTO `systemlogs` VALUES (69, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-28 16:29:29');
INSERT INTO `systemlogs` VALUES (70, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-28 16:29:34');
INSERT INTO `systemlogs` VALUES (71, 68, 'Tạo vận đơn GHN #LXNTD4 cho đơn hàng', 'Order', 16, '2026-05-28 16:29:41');
INSERT INTO `systemlogs` VALUES (72, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-29 15:08:43');
INSERT INTO `systemlogs` VALUES (73, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 16:14:56');
INSERT INTO `systemlogs` VALUES (74, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-30 16:19:55');
INSERT INTO `systemlogs` VALUES (75, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 16:22:05');
INSERT INTO `systemlogs` VALUES (76, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-30 16:24:45');
INSERT INTO `systemlogs` VALUES (77, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 16:39:17');
INSERT INTO `systemlogs` VALUES (78, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-30 16:40:21');
INSERT INTO `systemlogs` VALUES (79, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 17:24:32');
INSERT INTO `systemlogs` VALUES (80, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-30 18:14:00');
INSERT INTO `systemlogs` VALUES (81, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 18:14:09');
INSERT INTO `systemlogs` VALUES (82, 68, 'Cập nhật trạng thái đơn hàng thành COMPLETED', 'Order', 16, '2026-05-30 18:14:15');
INSERT INTO `systemlogs` VALUES (83, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-30 18:14:25');
INSERT INTO `systemlogs` VALUES (84, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 18:14:33');
INSERT INTO `systemlogs` VALUES (85, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 18:21:55');
INSERT INTO `systemlogs` VALUES (86, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 18:26:25');
INSERT INTO `systemlogs` VALUES (87, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 18:33:31');
INSERT INTO `systemlogs` VALUES (88, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 19:02:44');
INSERT INTO `systemlogs` VALUES (89, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-30 19:06:30');
INSERT INTO `systemlogs` VALUES (90, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 19:06:36');
INSERT INTO `systemlogs` VALUES (91, 68, 'Đăng xuất', 'Auth', NULL, '2026-05-30 19:16:57');
INSERT INTO `systemlogs` VALUES (92, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 19:18:58');
INSERT INTO `systemlogs` VALUES (93, 70, 'Đăng xuất', 'Auth', NULL, '2026-05-30 19:19:43');
INSERT INTO `systemlogs` VALUES (94, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 19:19:47');
INSERT INTO `systemlogs` VALUES (95, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 19:55:33');
INSERT INTO `systemlogs` VALUES (96, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 20:21:04');
INSERT INTO `systemlogs` VALUES (97, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-30 20:41:59');
INSERT INTO `systemlogs` VALUES (98, 68, 'Đăng nhập', 'Auth', NULL, '2026-05-30 22:38:33');
INSERT INTO `systemlogs` VALUES (99, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-31 21:34:25');
INSERT INTO `systemlogs` VALUES (100, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-31 22:02:11');
INSERT INTO `systemlogs` VALUES (101, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-31 22:25:27');
INSERT INTO `systemlogs` VALUES (102, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-31 22:31:25');
INSERT INTO `systemlogs` VALUES (103, 70, 'Đăng nhập', 'Auth', NULL, '2026-05-31 22:39:16');
INSERT INTO `systemlogs` VALUES (104, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 15:21:47');
INSERT INTO `systemlogs` VALUES (105, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 16:24:46');
INSERT INTO `systemlogs` VALUES (106, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 16:28:03');
INSERT INTO `systemlogs` VALUES (107, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 16:35:43');
INSERT INTO `systemlogs` VALUES (108, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 22:34:27');
INSERT INTO `systemlogs` VALUES (109, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 22:39:31');
INSERT INTO `systemlogs` VALUES (110, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 22:48:00');
INSERT INTO `systemlogs` VALUES (111, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 22:57:11');
INSERT INTO `systemlogs` VALUES (112, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:03:28');
INSERT INTO `systemlogs` VALUES (113, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:09:50');
INSERT INTO `systemlogs` VALUES (114, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:13:06');
INSERT INTO `systemlogs` VALUES (115, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:17:33');
INSERT INTO `systemlogs` VALUES (116, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:19:53');
INSERT INTO `systemlogs` VALUES (117, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:20:01');
INSERT INTO `systemlogs` VALUES (118, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:20:14');
INSERT INTO `systemlogs` VALUES (119, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:20:35');
INSERT INTO `systemlogs` VALUES (120, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:20:50');
INSERT INTO `systemlogs` VALUES (121, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:22:02');
INSERT INTO `systemlogs` VALUES (122, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:22:23');
INSERT INTO `systemlogs` VALUES (123, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:23:43');
INSERT INTO `systemlogs` VALUES (124, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:24:05');
INSERT INTO `systemlogs` VALUES (125, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:27:54');
INSERT INTO `systemlogs` VALUES (126, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:28:23');
INSERT INTO `systemlogs` VALUES (127, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-04 23:30:35');
INSERT INTO `systemlogs` VALUES (128, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-04 23:34:00');
INSERT INTO `systemlogs` VALUES (129, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-05 16:15:29');
INSERT INTO `systemlogs` VALUES (130, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 08:17:48');
INSERT INTO `systemlogs` VALUES (131, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 08:42:07');
INSERT INTO `systemlogs` VALUES (132, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 08:47:57');
INSERT INTO `systemlogs` VALUES (133, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 08:52:19');
INSERT INTO `systemlogs` VALUES (134, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 08:59:26');
INSERT INTO `systemlogs` VALUES (135, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-06 09:01:50');
INSERT INTO `systemlogs` VALUES (136, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:01:57');
INSERT INTO `systemlogs` VALUES (137, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-06 09:07:05');
INSERT INTO `systemlogs` VALUES (138, 71, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:11:16');
INSERT INTO `systemlogs` VALUES (139, 71, 'Đăng xuất', 'Auth', NULL, '2026-06-06 09:11:34');
INSERT INTO `systemlogs` VALUES (140, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:20:00');
INSERT INTO `systemlogs` VALUES (141, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-06 09:20:01');
INSERT INTO `systemlogs` VALUES (142, 72, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:20:08');
INSERT INTO `systemlogs` VALUES (143, 72, 'Đăng xuất', 'Auth', NULL, '2026-06-06 09:22:32');
INSERT INTO `systemlogs` VALUES (144, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:28:54');
INSERT INTO `systemlogs` VALUES (145, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 09:46:46');
INSERT INTO `systemlogs` VALUES (146, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:05:47');
INSERT INTO `systemlogs` VALUES (147, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:14:40');
INSERT INTO `systemlogs` VALUES (148, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-06 10:14:50');
INSERT INTO `systemlogs` VALUES (149, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:14:55');
INSERT INTO `systemlogs` VALUES (150, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:19:04');
INSERT INTO `systemlogs` VALUES (151, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-06 10:19:22');
INSERT INTO `systemlogs` VALUES (152, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:23:08');
INSERT INTO `systemlogs` VALUES (153, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:29:55');
INSERT INTO `systemlogs` VALUES (154, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:32:06');
INSERT INTO `systemlogs` VALUES (155, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:53:04');
INSERT INTO `systemlogs` VALUES (156, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-06 10:53:36');
INSERT INTO `systemlogs` VALUES (157, 74, 'Đăng nhập', 'Auth', NULL, '2026-06-06 10:57:07');
INSERT INTO `systemlogs` VALUES (158, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-06 11:35:44');
INSERT INTO `systemlogs` VALUES (159, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 11:40:54');
INSERT INTO `systemlogs` VALUES (160, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-06 20:07:41');
INSERT INTO `systemlogs` VALUES (161, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 13:17:58');
INSERT INTO `systemlogs` VALUES (162, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:09:06');
INSERT INTO `systemlogs` VALUES (163, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:31:39');
INSERT INTO `systemlogs` VALUES (164, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:37:09');
INSERT INTO `systemlogs` VALUES (165, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:37:15');
INSERT INTO `systemlogs` VALUES (166, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:39:00');
INSERT INTO `systemlogs` VALUES (167, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:39:07');
INSERT INTO `systemlogs` VALUES (168, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:39:31');
INSERT INTO `systemlogs` VALUES (169, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:39:39');
INSERT INTO `systemlogs` VALUES (170, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:39:47');
INSERT INTO `systemlogs` VALUES (171, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:39:53');
INSERT INTO `systemlogs` VALUES (172, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:42:43');
INSERT INTO `systemlogs` VALUES (173, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:46:07');
INSERT INTO `systemlogs` VALUES (174, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:50:24');
INSERT INTO `systemlogs` VALUES (175, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:50:43');
INSERT INTO `systemlogs` VALUES (176, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:50:47');
INSERT INTO `systemlogs` VALUES (177, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:51:38');
INSERT INTO `systemlogs` VALUES (178, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:51:43');
INSERT INTO `systemlogs` VALUES (179, 68, 'Tạo vận đơn GHN #LXTQ67 cho đơn hàng', 'Order', 27, '2026-06-12 14:51:55');
INSERT INTO `systemlogs` VALUES (180, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-12 14:52:56');
INSERT INTO `systemlogs` VALUES (181, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:53:01');
INSERT INTO `systemlogs` VALUES (182, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 14:56:44');
INSERT INTO `systemlogs` VALUES (183, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 15:06:17');
INSERT INTO `systemlogs` VALUES (184, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 15:06:33');
INSERT INTO `systemlogs` VALUES (185, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 15:28:12');
INSERT INTO `systemlogs` VALUES (186, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 15:28:16');
INSERT INTO `systemlogs` VALUES (187, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 15:28:29');
INSERT INTO `systemlogs` VALUES (188, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 15:28:35');
INSERT INTO `systemlogs` VALUES (189, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 15:47:58');
INSERT INTO `systemlogs` VALUES (190, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 16:13:39');
INSERT INTO `systemlogs` VALUES (191, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:13:59');
INSERT INTO `systemlogs` VALUES (192, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 16:20:00');
INSERT INTO `systemlogs` VALUES (193, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:20:45');
INSERT INTO `systemlogs` VALUES (194, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:38:43');
INSERT INTO `systemlogs` VALUES (195, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 16:39:21');
INSERT INTO `systemlogs` VALUES (196, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:39:25');
INSERT INTO `systemlogs` VALUES (197, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:43:27');
INSERT INTO `systemlogs` VALUES (198, 68, 'Đăng xuất', 'Auth', NULL, '2026-06-12 16:52:29');
INSERT INTO `systemlogs` VALUES (199, 70, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:54:53');
INSERT INTO `systemlogs` VALUES (200, 70, 'Đăng xuất', 'Auth', NULL, '2026-06-12 16:57:42');
INSERT INTO `systemlogs` VALUES (201, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 16:57:50');
INSERT INTO `systemlogs` VALUES (202, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 17:07:25');
INSERT INTO `systemlogs` VALUES (203, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 17:12:12');
INSERT INTO `systemlogs` VALUES (204, 68, 'Đăng nhập', 'Auth', NULL, '2026-06-12 17:26:12');

-- ----------------------------
-- Table structure for user_addresses
-- ----------------------------
DROP TABLE IF EXISTS `user_addresses`;
CREATE TABLE `user_addresses`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `full_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `phone_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Nhà riêng, Văn phòng...',
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `district` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `ward` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `street_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `is_default` tinyint(1) NULL DEFAULT 0,
  `district_id` int NULL DEFAULT NULL COMMENT 'Mã Quận/Huyện theo hệ thống GHN',
  `ward_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'Mã Phường/Xã theo hệ thống GHN',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_addr_user`(`user_id` ASC) USING BTREE,
  CONSTRAINT `fk_addr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 37 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_addresses
-- ----------------------------
INSERT INTO `user_addresses` VALUES (1, 1, 'Nguyễn Văn A', '0901234567', 'Nhà riêng', 'Hà Nội', NULL, 'Phường Hàng Trống', '123 Phố Huế', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (3, 3, 'Lê Văn C', '0923456789', 'Nhà riêng', 'Đà Nẵng', NULL, 'Phường Hải Châu 1', '789 Bạch Đằng', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (4, 47, 'Phạm Minh Tuấn', '0911222333', 'Nhà riêng', 'Hà Nội', NULL, 'Q.Hoàn Kiếm', '10 Tràng Thi', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (5, 48, 'Lê Thu Hương', '0911222444', 'Công ty', 'Hồ Chí Minh', NULL, 'Q.1', 'Bitexco Tower', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (6, 50, 'Trần Ngọc Mai', '0911222666', 'Nhà riêng', 'Đà Nẵng', NULL, 'Q.Hải Châu', '15 Lê Duẩn', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (7, 52, 'Vũ Thị Lan', '0911222888', 'Cửa hàng', 'Hải Phòng', NULL, 'Q.Ngô Quyền', '20 Lạch Tray', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (8, 57, '', '', 'Địa chỉ mới', '', NULL, '', '', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (9, 57, 'Liêu Minh Khoa', '0888531015', 'Nhà riêng', 'Tây Ninh', NULL, 'Dương Minh Châu', '10 Dương Minh Châu', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (10, 57, 'Liêu Minh Khoa', '3123232131', 'Công ty', 'Khánh Hòa', NULL, 'Dương Minh Châu', 'dfasfas', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (12, 57, 'Trần Ngọc Thảo My', '0888531015', 'Văn phòng', 'Tây Ninh', NULL, 'Dương Minh Châu', '10 Dương Minh Châu, Tây Ninh', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (13, 65, 'Liêu Minh Khoa', '0888531015', 'Nhà riêng', 'Tây Ninh', NULL, 'Dương Minh Châu', '10 Dương Minh Châu, Tây Ninh', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (14, 65, 'Trần Ngọc Thảo My', '0987028657', 'Văn phòng', 'Khánh Hòa', NULL, 'Nha Trang', '132, lương định của', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (15, 69, 'Liêu Minh Khoa', '0888531015', 'Văn phòng', 'Tây Ninh', NULL, 'Dương Minh Châu', '10 Dương Minh Châu, Tây Ninh', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (16, 68, 'Liêu Minh Khoa', '0888531015', 'Nhà riêng', 'rr', NULL, 'dsffdf', 'fasfafaf', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (17, 68, '', '', 'Địa chỉ mới', '', NULL, '', '', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (18, 68, '', '', 'Địa chỉ mới', '', NULL, '', '', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (19, 68, '', '', 'Địa chỉ mới', '', NULL, '', '', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (21, 68, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Tỉnh Hà Tĩnh', NULL, 'Xã Đức Thịnh', '10 Dương Minh Châu, Tây Ninh', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (22, 68, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Tỉnh Tây Ninh', NULL, 'Xã Phước Vĩnh Tây', '10 Dương Minh Châu, Tây Ninh', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (23, 66, 'Liêu Khoa', '0888531015', 'Địa chỉ mới', 'Tỉnh Nghệ An', NULL, 'Xã Mỹ Lý', 'Khu phố 6,Phường Linh Trung', 0, NULL, NULL);
INSERT INTO `user_addresses` VALUES (24, 68, 'hahah', '0888531015', 'Địa chỉ mới', 'Thành phố Hà Nội', NULL, 'Phường Láng', '10 Dương Minh Châu', 1, NULL, NULL);
INSERT INTO `user_addresses` VALUES (25, 70, 'Liêu Minh Khoa', '0888531015', 'Nhà riêng', 'Bạc Liêu', 'Huyện Đông Hải', 'Xã An Phúc', '10 Dương Minh Châu, Tây Ninh', 0, 1926, '600602');
INSERT INTO `user_addresses` VALUES (26, 70, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Hồ Chí Minh', 'Thành Phố Thủ Đức', 'Phường Hiệp Phú', '10 Dương Minh Châu', 0, 3695, '90754');
INSERT INTO `user_addresses` VALUES (27, 70, 'Liêu Minh Khoa', '0888531015', 'Công ty', 'Sơn La', 'Huyện Yên Châu', 'Xã Chiềng Hặc', '10 Dương Minh Châu, Tây Ninh', 1, 2267, '140803');
INSERT INTO `user_addresses` VALUES (28, 70, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Hồ Chí Minh', 'Quận 11', 'Phường 8', '10 Dương Minh Châu, Tây Ninh', 0, 1453, '21108');
INSERT INTO `user_addresses` VALUES (29, 70, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Cà Mau', 'Huyện Ngọc Hiển', 'Xã Viên An Đông', '10 Dương Minh Châu, Tây Ninh', 0, 2186, '610707');
INSERT INTO `user_addresses` VALUES (30, 71, 'Liêu Minh Khoa', '0888531017', 'Công ty', 'Hòa Bình', 'Huyện Lạc Thủy', 'Xã Đồng Môn', '102 Tô Vĩnh Diện', 1, 2157, '230906');
INSERT INTO `user_addresses` VALUES (31, 71, 'Liêu Minh Khoa', '0888531017', 'Công ty', 'Hòa Bình', 'Huyện Lạc Thủy', 'Xã Đồng Môn', '102 Tô Vĩnh Diện', 1, 2157, '230906');
INSERT INTO `user_addresses` VALUES (32, 71, 'Liêu Minh Khoa', '0888531017', 'Công ty', 'Hòa Bình', 'Huyện Lạc Thủy', 'Xã Đồng Môn', '102 Tô Vĩnh Diện', 1, 2157, '230906');
INSERT INTO `user_addresses` VALUES (33, 73, 'Minh KhoA Liêu', '0888531012', 'Nhà riêng', 'Bình Thuận', 'Huyện Đức Linh', 'Xã Nam Chính', '102 Tô Vĩnh Diện', 1, 1779, '470709');
INSERT INTO `user_addresses` VALUES (34, 74, 'Liêu Minh Khoa', '0785146652', 'Văn phòng', 'Tây Ninh', 'Huyện Dương Minh Châu', 'Xã Suối Đá', '102 Tô Vĩnh Diện', 1, 1864, '460410');
INSERT INTO `user_addresses` VALUES (35, 70, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Hồ Chí Minh', 'Quận Thủ Đức', 'Phường Linh Xuân', 'Khu phố 6,Phường Linh Trung', 0, 1463, '21809');
INSERT INTO `user_addresses` VALUES (36, 70, 'Liêu Minh Khoa', '0888531015', 'Địa chỉ mới', 'Hồ Chí Minh', 'Thành Phố Thủ Đức', 'Phường Bình Trưng Đông', '10 Dương Minh Châu', 0, 3695, '90766');

-- ----------------------------
-- Table structure for user_coupons
-- ----------------------------
DROP TABLE IF EXISTS `user_coupons`;
CREATE TABLE `user_coupons`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `coupon_id` int NOT NULL,
  `claimed_at` datetime NULL DEFAULT current_timestamp(),
  `used_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_coupon`(`user_id` ASC, `coupon_id` ASC) USING BTREE,
  INDEX `fk_user_coupon_coupon`(`coupon_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_coupon_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_user_coupon_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_coupons
-- ----------------------------

-- ----------------------------
-- Table structure for user_emails
-- ----------------------------
DROP TABLE IF EXISTS `user_emails`;
CREATE TABLE `user_emails`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `is_primary` tinyint(1) NULL DEFAULT 0,
  `is_verified` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `user_emails_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_emails
-- ----------------------------

-- ----------------------------
-- Table structure for user_vip_vouchers
-- ----------------------------
DROP TABLE IF EXISTS `user_vip_vouchers`;
CREATE TABLE `user_vip_vouchers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `voucher_id` int NOT NULL,
  `used_at` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `voucher_id`(`voucher_id` ASC) USING BTREE,
  CONSTRAINT `user_vip_vouchers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_vip_vouchers_ibfk_2` FOREIGN KEY (`voucher_id`) REFERENCES `vip_vouchers` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_vip_vouchers
-- ----------------------------

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `role_id` int NULL DEFAULT NULL,
  `date_of_birth` datetime NULL DEFAULT NULL,
  `gender` enum('male','female','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'other',
  `is_active` tinyint(1) NULL DEFAULT 1,
  `failed_attempts` int NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `lock_until` timestamp NULL DEFAULT NULL,
  `is_vip` tinyint(1) NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE,
  INDEX `fk_user_role`(`role_id` ASC) USING BTREE,
  CONSTRAINT `fk_user_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 75 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'My iu', 'admin@gmail', '$2a$12$IihckfoejsrJR7vsEPioNebrRT9bzK4I7vDOtKMs3T/F0lfBYuNSy', 'Khoa', 'Tran', '1234567890', NULL, 1, NULL, 'other', 1, 0, '2026-01-17 16:44:24', NULL, 0);
INSERT INTO `users` VALUES (3, 'KHOA', 'customer@123', '$2a$12$4J740Jxf0sQJpmEgpFbS8eawovM0yRJOaP6BoTVW3CfeFMaAMJh.m', NULL, NULL, '1234567890', NULL, 2, NULL, 'other', 1, 0, '2026-01-17 19:04:26', NULL, 0);
INSERT INTO `users` VALUES (4, 'nguyenvana', 'vana@gmail.com', '123456', 'Văn A', 'Nguyễn', '0901234567', NULL, 2, NULL, 'other', 1, 0, '2026-01-23 16:05:38', NULL, 0);
INSERT INTO `users` VALUES (5, 'tranthib', 'thib@gmail.com', '123456', 'Thị B', 'Trần', '0912345678', NULL, 2, NULL, 'other', 1, 0, '2026-01-23 16:05:38', NULL, 0);
INSERT INTO `users` VALUES (6, 'levanc', 'vanc@gmail.com', '123456', 'Văn C', 'Lê', '0923456789', NULL, 2, NULL, 'other', 1, 0, '2026-01-23 16:05:38', NULL, 0);
INSERT INTO `users` VALUES (7, 'admin', 'admin@gmail.com', '123456', 'Quản Trị', 'Admin', '0999999999', NULL, 1, NULL, 'other', 1, 0, '2026-01-23 16:05:38', NULL, 0);
INSERT INTO `users` VALUES (47, 'khachhang_01', 'khach01.new@gmail.co', '123456', 'Tuấn', 'Phạm Minh', '0911222333', NULL, 2, NULL, 'male', 1, 0, '2023-02-10 08:00:00', NULL, 0);
INSERT INTO `users` VALUES (48, 'khachhang_02', 'khach02.vip@gmail.co', '123456', 'Hương', 'Lê Thu', '0911222444', NULL, 2, NULL, 'female', 1, 0, '2023-03-15 09:30:00', NULL, 0);
INSERT INTO `users` VALUES (49, 'khachhang_03', 'khach03.inactive@gma', '123456', 'Hải', 'Nguyễn Thanh', '0911222555', NULL, 2, NULL, 'male', 1, 0, '2023-04-20 10:00:00', NULL, 0);
INSERT INTO `users` VALUES (50, 'khachhang_04', 'khach04.new@gmail.co', '123456', 'Mai', 'Trần Ngọc', '0911222666', NULL, 2, NULL, 'female', 1, 0, '2026-01-23 17:23:42', NULL, 0);
INSERT INTO `users` VALUES (51, 'khachhang_05', 'khach05.test@gmail.c', '123456', 'Dũng', 'Hoàng Anh', '0911222777', NULL, 2, NULL, 'male', 1, 0, '2023-06-01 14:20:00', NULL, 0);
INSERT INTO `users` VALUES (52, 'khachhang_06', 'khach06.test@gmail.c', '123456', 'Lan', 'Vũ Thị', '0911222888', NULL, 2, NULL, 'female', 1, 0, '2023-07-10 16:45:00', NULL, 0);
INSERT INTO `users` VALUES (53, 'khachhang_07', 'khach07.test@gmail.c', '123456', 'Bảo', 'Đặng Gia', '0911222999', NULL, 2, NULL, 'male', 1, 0, '2023-08-15 11:10:00', NULL, 0);
INSERT INTO `users` VALUES (54, 'khachhang_08', 'khach08.new@gmail.co', '123456', 'Cúc', 'Bùi Kim', '0911333000', NULL, 2, NULL, 'female', 1, 0, '2026-01-23 17:23:42', NULL, 0);
INSERT INTO `users` VALUES (55, 'khachhang_09', 'khach09.test@gmail.c', '123456', 'Tùng', 'Đỗ Sơn', '0911333111', NULL, 2, NULL, 'male', 1, 0, '2023-10-05 13:30:00', NULL, 0);
INSERT INTO `users` VALUES (56, 'khachhang_10', 'khach10.inactive@gma', '123456', 'Yến', 'Hồ Hải', '0911333222', NULL, 2, NULL, 'female', 1, 0, '2023-11-20 09:15:00', NULL, 0);
INSERT INTO `users` VALUES (57, 'khoalieudz', 'khoalieu@test.com', '$2a$12$4aE5cA2jRct.EvxbX8vCHuzEX0KlBlZyYy6X4NtanwiagpFTHhPry', 'Khoa', 'Lieu', '1234567890', NULL, 2, '2026-01-07 00:00:00', 'male', 1, 1, '2026-01-26 19:44:46', NULL, 0);
INSERT INTO `users` VALUES (59, '23124121', '23124121@st.hcmuaf.e', '$2a$12$wpx4r8UrV/g/BqkJNRYXEekriHIs09gBvMvSPOyAtnnKcZ9QCJbvy', 'My', 'Trần Ngọc Thảo', NULL, 'https://lh3.googleusercontent.com/a/ACg8ocLtB1481_kh39PtI2nDT8qIvKJwkTLuyUxbIGt2g4k-WC-Yhg=s96-c', 2, NULL, 'other', 1, 0, '2026-01-27 15:36:22', NULL, 0);
INSERT INTO `users` VALUES (60, 'khoalieu2005', 'admin@test.com', '$2a$12$E2/XbWDFmAgP2mlpl4UUOe5jeezV7TqgsbjArQZGBpvoFtHu92gkC', 'Khoa', 'Tran', '1234567890', NULL, 2, NULL, 'male', 1, 0, '2026-01-28 08:32:35', NULL, 0);
INSERT INTO `users` VALUES (61, 'khoalieu123', 'khoa@123.com', '$2a$12$Wq566aOeYRDpd8yC7GXBV.szq52qEg8ywImBWu4Hnf/5NhG7iKqj2', NULL, NULL, '1234567898', NULL, 2, NULL, 'other', 1, 2, '2026-01-28 15:57:28', NULL, 0);
INSERT INTO `users` VALUES (63, 'kholieu1', 'admin123@haha.com', '$2a$12$jmXkPphpYBBmzG9d6bYT1uyu4sTrgPcA9KEtWLiCMFDYZvg1LVTum', NULL, NULL, '1234567890', NULL, 2, NULL, 'other', 1, 0, '2026-03-15 22:44:07', NULL, 0);
INSERT INTO `users` VALUES (65, 'lieuminhkhoa2005', 'admin@123.com', '$2a$12$Dn.kK2kUR49ICJb8Av.KVuAoLZjkXegJJDKpepILXob5HJnjmdIT6', NULL, NULL, '0888531015', NULL, 1, NULL, 'other', 1, 0, '2026-03-16 14:42:42', NULL, 0);
INSERT INTO `users` VALUES (66, 'kholieu2', 'admin@fake.cpm', '$2a$12$CCG376KYb.ygAm0mig8tmuNSauHhEixuHT7dC6vBmVdr1txastRDu', NULL, NULL, '1234567890', NULL, 2, NULL, 'other', 1, 0, '2026-03-16 20:45:10', NULL, 0);
INSERT INTO `users` VALUES (68, 'khoalac', 'lieuminhkhoa2005@gma', '$2a$12$lxrIbQLoGAY4GTgtKCpqHuJrrazq3mtkGMjgaHkktblDEk89z74R2', NULL, NULL, '0888531010', NULL, 1, NULL, 'other', 1, 0, '2026-03-22 08:24:21', NULL, 0);
INSERT INTO `users` VALUES (69, 'khoadeptrai', NULL, '$2a$12$GInZgukBeVYw2wFCpZCoEOxKVpN1X4NR9CSGCBvYpTTFkkNnYJCAW', 'khoa', 'Lieu', '0888531011', NULL, 2, '2026-03-10 00:00:00', 'male', 1, 0, '2026-03-23 20:19:06', NULL, 0);
INSERT INTO `users` VALUES (70, 'minhkhoa', NULL, '$2a$12$9ZSDLgeU9eEAEoIt6SGKYew/U/F86sLgwy/KDnIR5Hl7EQsGG6onW', NULL, NULL, '0833639767', NULL, 2, NULL, 'other', 1, 0, '2026-05-28 14:41:53', NULL, 0);
INSERT INTO `users` VALUES (71, 'admin123', NULL, '$2a$12$UBX6mqqb3DCOfj30mLmNMO4yrNPis1PBGR/xu6nnZAmzh6aqxfzme', NULL, NULL, '0888531017', NULL, NULL, NULL, 'other', 1, 0, '2026-06-06 09:07:45', NULL, 0);
INSERT INTO `users` VALUES (72, 'editor123', NULL, '$2a$12$yXybehgSWwxYXKds7i/AmunWjyAklUkSgWHcSYAnWytNGNtWyWLo2', NULL, NULL, '0785146651', NULL, NULL, NULL, 'other', 1, 0, '2026-06-06 09:15:11', NULL, 0);
INSERT INTO `users` VALUES (73, 'khachang123', NULL, '$2a$12$/XUwxMBX9fcLNGydfxt8VemcO.kNqh.o1rWql6wt/M4gq3U9oLgvy', NULL, NULL, '0888531012', NULL, NULL, NULL, 'other', 1, 0, '2026-06-06 09:23:10', NULL, 0);
INSERT INTO `users` VALUES (74, 'accountTest', NULL, '$2a$12$1eHPEGu57X2Qeuux505KWevwHOGQPfev1uX9x17y8Nyn0GR5..Y/2', 'Khoa', 'Liêu Minh', '0785146652', NULL, NULL, NULL, 'other', 1, 0, '2026-06-06 10:56:28', NULL, 0);

-- ----------------------------
-- Table structure for vip_vouchers
-- ----------------------------
DROP TABLE IF EXISTS `vip_vouchers`;
CREATE TABLE `vip_vouchers`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `discount_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `discount_value` decimal(15, 2) NOT NULL,
  `max_uses` int NULL DEFAULT NULL,
  `current_uses` int NULL DEFAULT 0,
  `start_date` datetime NULL DEFAULT NULL,
  `end_date` datetime NULL DEFAULT NULL,
  `is_active` tinyint(1) NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of vip_vouchers
-- ----------------------------

-- ----------------------------
-- Table structure for contacts
-- ----------------------------
DROP TABLE IF EXISTS `contacts`;
CREATE TABLE `contacts`  ();
