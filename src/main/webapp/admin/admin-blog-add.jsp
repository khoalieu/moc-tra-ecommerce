<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Blog - Mộc Trà Admin</title>

    <!-- ROOT assets -->
    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">

    <!-- ADMIN assets (nằm trong /admin/assets/...) -->
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${ctx}/admin/assets/css/admin-add-product.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">
</head>

<body>
<div class="admin-container">
    <!-- Sidebar -->
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="blog"/>
    </jsp:include>


    <!-- Main Content -->
    <main class="admin-main">
        <!-- Header -->
        <header class="admin-header">
            <div class="header-left">
                <h1>Thêm bài viết mới</h1>
            </div>

            <div class="header-right">
                <a href="admin-blog.jsp" class="btn btn-outline">
                    <i class="fas fa-arrow-left"></i>
                    <span>Quay lại danh sách</span>
                </a>

                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <!-- Content -->
        <div class="admin-content">
            <form class="form-container" action="${pageContext.request.contextPath}/admin/blog/add" method="POST"
                  enctype="multipart/form-data">

                <input type="hidden" id="formAction" name="formAction" value="save">

                <div class="form-header">
                    <c:if test="${not empty error}">
                        <p style="color:#c00; margin:10px 0;">${error}</p>
                    </c:if>

                    <h2>Tạo bài viết mới</h2>
                    <p>Viết và xuất bản nội dung blog cho website</p>
                </div>

                <div class="form-content">
                    <div class="form-grid">
                        <!-- Left Column -->
                        <div class="form-left">
                            <!-- Nội dung chính -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-edit"></i>
                                    Nội dung bài viết
                                </h3>

                                <div class="form-group">
                                    <label for="title">Tiêu đề bài viết <span class="">*</span></label>
                                    <input type="text" id="title" name="title" class="form-control"
                                           value="${param.title}">
                                    <div class="help-text">Tiêu đề hấp dẫn sẽ thu hút nhiều người đọc hơn</div>
                                </div>

                                <div class="form-group">
                                    <label for="slug">Slug (URL thân thiện)</label>
                                    <input type="text" id="slug" name="slug" class="form-control" value="${param.slug}">
                                    <div class="help-text">Để trống sẽ tự động tạo từ tiêu đề</div>
                                </div>

                                <div class="form-group">
                                    <label for="excerpt">Mô tả ngắn (Excerpt) <span class="">*</span></label>
                                    <textarea id="excerpt" name="excerpt" class="form-control textarea"
                                              rows="4">${param.excerpt}</textarea>
                                    <div class="word-count">
                                        <span id="excerpt-count">0</span>/160 ký tự
                                    </div>
                                    <div class="help-text">Mô tả ngắn gọn về nội dung bài viết (hiển thị trong danh
                                        sách)
                                    </div>
                                </div>
                            </div>

                            <!-- Detail content -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-align-left"></i>
                                    Nội dung chi tiết
                                </h3>

                                <div class="form-group">
                                    <label for="content">Nội dung bài viết <span class="">*</span></label>

                                    <!-- Simple Editor Toolbar -->
                                    <div class="editor-toolbar">
                                        <button type="button" class="editor-btn" data-command="bold" title="In đậm">
                                            <i class="fas fa-bold"></i>
                                        </button>
                                        <button type="button" class="editor-btn" data-command="italic"
                                                title="In nghiêng">
                                            <i class="fas fa-italic"></i>
                                        </button>
                                        <button type="button" class="editor-btn" data-command="underline"
                                                title="Gạch chân">
                                            <i class="fas fa-underline"></i>
                                        </button>
                                        <button type="button" class="editor-btn" data-command="insertOrderedList"
                                                title="Danh sách số">
                                            <i class="fas fa-list-ol"></i>
                                        </button>
                                        <button type="button" class="editor-btn" data-command="insertUnorderedList"
                                                title="Danh sách dấu chấm">
                                            <i class="fas fa-list-ul"></i>
                                        </button>
                                        <button type="button" class="editor-btn" data-command="createLink"
                                                title="Chèn liên kết">
                                            <i class="fas fa-link"></i>
                                        </button>
                                    </div>

                                    <textarea id="content" name="content" class="form-control textarea xlarge"
                                              rows="15">${param.content}</textarea>
                                    <div class="word-count">
                                        <span id="content-count">0</span> từ
                                    </div>
                                    <div class="help-text">Nội dung chi tiết của bài viết. Hỗ trợ HTML cơ bản.</div>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div class="form-right">
                            <!-- Xuất bản -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-cog"></i>
                                    Cài đặt xuất bản
                                </h3>

                                <div class="form-group">
                                    <label for="status">Trạng thái <span class="">*</span></label>
                                    <select id="status" name="status" class="form-control">
                                        <option value="">-- Chọn trạng thái --</option>
                                        <option value="draft" ${param.status == 'draft' ? 'selected' : ''}>Bản nháp
                                        </option>
                                        <option value="published" ${param.status == 'published' ? 'selected' : ''}>Xuất
                                            bản ngay
                                        </option>
                                        <option value="archived" ${param.status == 'archived' ? 'selected' : ''}>Lưu
                                            trữ
                                        </option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="author_id">Tác giả <span class="">*</span></label>
                                    <select id="author_id" name="author_id" class="form-control">
                                        <option value="">-- Chọn tác giả --</option>
                                        <c:forEach var="a" items="${allAuthors}">
                                            <option value="${a.id}" ${param.author_id == a.id ? 'selected' : ''}>
                                                    ${a.displayName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="created_at">Ngày xuất bản</label>
                                    <input type="datetime-local" id="created_at" name="created_at" class="form-control"
                                           value="${param.created_at}">
                                    <div class="help-text">Để trống sẽ sử dụng thời gian hiện tại</div>
                                </div>
                            </div>

                            <!-- Phân loại -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-folder"></i>
                                    Phân loại
                                </h3>

                                <div class="form-group">
                                    <label for="category_id">Danh mục <span class="">*</span></label>
                                    <select id="category_id" name="category_id" class="form-control">
                                        <option value="">-- Chọn danh mục --</option>
                                        <c:forEach var="c" items="${allCategories}">
                                            <option value="${c.id}" ${param.category_id == c.id ? 'selected' : ''}>
                                                    ${c.name}
                                            </option>
                                        </c:forEach>
                                    </select>

                                </div>
                            </div>

                            <!-- Images -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-image"></i>
                                    Hình ảnh đại diện
                                </h3>

                                <div class="form-group">
                                    <label for="featured_image">Hình ảnh chính <span class="">*</span></label>
                                    <div class="image-upload"
                                         onclick="document.getElementById('featured_image').click()">
                                        <img id="imagePreview"
                                             alt="Preview"
                                             style="max-width:100%; border-radius:10px; display:none; margin:0 auto 10px;">
                                        <i class="fas fa-cloud-upload-alt"></i>
                                        <p>Nhấp để tải lên hình ảnh</p>
                                        <small>JPG, PNG, GIF tối đa 2MB<br>Khuyến nghị: 800x450px</small>
                                    </div>
                                    <input type="file" id="featured_image" name="featured_image" accept="image/*"
                                           style="display: none;">

                                    <div class="help-text">Hình ảnh sẽ hiển thị ở đầu bài viết và trong danh sách</div>
                                </div>
                            </div>

                            <!-- SEO -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-search"></i>
                                    Tối ưu SEO
                                </h3>

                                <div class="form-group">
                                    <label for="meta_title">Meta Title</label>
                                    <input type="text" id="meta_title" name="meta_title" class="form-control"
                                           value="${param.meta_title}">
                                    <div class="word-count">
                                        <span id="meta-title-count">0</span>/60 ký tự
                                    </div>
                                    <div class="help-text">Tiêu đề hiển thị trên Google (để trống sẽ dùng tiêu đề bài
                                        viết)
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="meta_description">Meta Description</label>
                                    <textarea id="meta_description" name="meta_description"
                                              class="form-control textarea"
                                              rows="3">${param.meta_description}</textarea>
                                    <div class="word-count">
                                        <span id="meta-desc-count">0</span>/160 ký tự
                                    </div>
                                    <div class="help-text">Mô tả hiển thị trên Google (để trống sẽ dùng excerpt)</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-actions">
                    <div class="help-text">
                        <i class="fas fa-info-circle"></i>
                        Các trường có dấu <span class="">*</span> là bắt buộc
                    </div>

                    <div class="btn-group">
                        <a href="${ctx}/admin/blog" class="btn btn-outline">
                            <i class="fas fa-times"></i>
                            Hủy bỏ
                        </a>

                        <button type="submit" class="btn btn-success" name="action" value="preview">
                            <i class="fas fa-eye"></i>
                            Lưu & Xem
                        </button>

                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i>
                            Xuất bản
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </main>
</div>
</body>
<script>
    (function () {
        const fileInput = document.getElementById('featured_image');
        const box = document.querySelector('.image-upload');
        const preview = document.getElementById('imagePreview');

        if (!fileInput || !box || !preview) return;

        fileInput.addEventListener('change', function () {
            const f = this.files && this.files[0];
            if (!f) {
                preview.src = '';
                preview.style.display = 'none';
                return;
            }

            if (!f.type || !f.type.startsWith('image/')) {
                alert('Vui lòng chọn đúng file ảnh.');
                this.value = '';
                preview.src = '';
                preview.style.display = 'none';
                return;
            }
            if (f.size > 2 * 1024 * 1024) {
                alert('Ảnh tối đa 2MB. Vui lòng chọn ảnh nhỏ hơn.');
                this.value = '';
                preview.src = '';
                preview.style.display = 'none';
                return;
            }

            preview.src = URL.createObjectURL(f);
            preview.style.display = 'block';

            const icon = box.querySelector('i');
            if (icon) icon.style.display = 'none';

            const p = box.querySelector('p');
            if (p) p.textContent = 'Đã chọn ảnh. Nhấp để đổi ảnh';
        });
    })();
</script>

</html>
