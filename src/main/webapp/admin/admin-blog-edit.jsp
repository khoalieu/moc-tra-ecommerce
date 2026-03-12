<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa bài viết - Mộc Trà Admin</title>

    <!-- ROOT assets -->
    <link rel="stylesheet" href="${ctx}/assets/css/base.css">
    <link rel="stylesheet" href="${ctx}/assets/css/components.css">

    <!-- ADMIN assets -->
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
                <h1>Sửa bài viết</h1>
            </div>

            <div class="header-right">
                <a href="${ctx}/admin/blog" class="btn btn-outline">
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
            <form class="form-container"
                  action="${ctx}/admin/blog/edit"
                  method="POST"
                  enctype="multipart/form-data">

                <!-- hidden id -->
                <input type="hidden" name="id" value="${post.id}">

                <div class="form-header">
                    <c:if test="${not empty error}">
                        <p style="color:#c00; margin:10px 0;">${error}</p>
                    </c:if>

                    <h2>Cập nhật bài viết</h2>
                    <p>Chỉnh sửa nội dung blog cho website</p>
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
                                    <label for="title">Tiêu đề bài viết <span class="required">*</span></label>
                                    <input type="text" id="title" name="title" class="form-control"
                                           value="${post.title}">
                                    <div class="help-text">Tiêu đề hấp dẫn sẽ thu hút nhiều người đọc hơn</div>
                                </div>

                                <div class="form-group">
                                    <label for="slug">Slug (URL thân thiện)</label>
                                    <input type="text" id="slug" name="slug" class="form-control"
                                           value="${post.slug}">
                                    <div class="help-text">Để trống sẽ tự động tạo từ tiêu đề</div>
                                </div>

                                <div class="form-group">
                                    <label for="excerpt">Mô tả ngắn (Excerpt) <span class="required">*</span></label>
                                    <textarea id="excerpt" name="excerpt" class="form-control textarea"
                                              rows="4">${post.excerpt}</textarea>
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
                                    <label for="content">Nội dung bài viết <span class="required">*</span></label>

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
                                              rows="15">${post.content}</textarea>
                                    <div class="word-count">
                                        <span id="content-count">0</span> từ
                                    </div>
                                    <div class="help-text">Nội dung chi tiết của bài viết. Hỗ trợ HTML cơ bản.</div>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div class="form-right">
                            <!-- Publish -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-cog"></i>
                                    Cài đặt xuất bản
                                </h3>

                                <div class="form-group">
                                    <label for="status">Trạng thái <span class="required">*</span></label>
                                    <select id="status" name="status" class="form-control">
                                        <option value="">-- Chọn trạng thái --</option>
                                        <option value="draft" ${post.status.name() == 'DRAFT' ? 'selected' : ''}>Bản
                                            nháp
                                        </option>
                                        <option value="published" ${post.status.name() == 'PUBLISHED' ? 'selected' : ''}>
                                            Xuất bản ngay
                                        </option>
                                        <option value="archived" ${post.status.name() == 'ARCHIVED' ? 'selected' : ''}>
                                            Lưu trữ
                                        </option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="author_id">Tác giả <span class="required">*</span></label>
                                    <select id="author_id" name="author_id" class="form-control">
                                        <option value="">-- Chọn tác giả --</option>
                                        <c:forEach var="a" items="${allAuthors}">
                                            <option value="${a.id}" ${post.authorId == a.id ? 'selected' : ''}>
                                                    ${a.displayName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label for="created_at">Ngày xuất bản</label>
                                    <input type="datetime-local" id="created_at" name="created_at" class="form-control"
                                           disabled>
                                    <div class="help-text">Hiện tại đang giữ nguyên created_at (chưa update trường
                                        này).
                                    </div>
                                </div>
                            </div>

                            <!-- Phân loại -->
                            <div class="form-section">
                                <h3>
                                    <i class="fas fa-folder"></i>
                                    Phân loại
                                </h3>

                                <div class="form-group">
                                    <label for="category_id">Danh mục <span class="required">*</span></label>
                                    <select id="category_id" name="category_id" class="form-control">
                                        <option value="">-- Chọn danh mục --</option>
                                        <c:forEach var="c" items="${allCategories}">
                                            <option value="${c.id}" ${post.categoryId == c.id ? 'selected' : ''}>
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
                                    <label for="featured_image">Hình ảnh chính</label>

                                    <div class="image-upload"
                                         onclick="document.getElementById('featured_image').click()">
                                        <c:choose>
                                            <c:when test="${not empty post.featuredImage}">
                                                <img id="imagePreview"
                                                     src="${ctx}/${post.featuredImage}"
                                                     alt="Preview"
                                                     style="max-width: 100%; border-radius: 10px; display:block; margin: 0 auto 10px;">
                                                <p>Nhấp để đổi hình ảnh</p>
                                            </c:when>
                                            <c:otherwise>
                                                <i class="fas fa-cloud-upload-alt"></i>
                                                <p>Nhấp để tải lên hình ảnh</p>
                                            </c:otherwise>
                                        </c:choose>

                                        <small>JPG, PNG, GIF tối đa 2MB<br>Khuyến nghị: 800x450px</small>
                                    </div>

                                    <input type="file" id="featured_image" name="featured_image" accept="image/*"
                                           style="display: none;">
                                    <div class="help-text">Không chọn ảnh mới thì giữ ảnh cũ.</div>
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
                                           value="${post.metaTitle}">
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
                                              class="form-control textarea" rows="3">${post.metaDescription}</textarea>
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
                        Các trường có dấu <span class="required">*</span> là bắt buộc
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
                            Lưu thay đổi
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </main>
</div>

<script>
    (function () {
        const fileInput = document.getElementById('featured_image');
        if (!fileInput) return;

        fileInput.addEventListener('change', function () {
            const f = this.files && this.files[0];
            if (!f) return;

            const url = URL.createObjectURL(f);

            let img = document.getElementById('imagePreview');
            if (!img) {
                img = document.createElement('img');
                img.id = 'imagePreview';
                img.style.maxWidth = '100%';
                img.style.borderRadius = '10px';
                img.style.display = 'block';
                img.style.margin = '0 auto 10px';

                const box = document.querySelector('.image-upload');
                if (box) box.prepend(img);
            }

            img.src = url;
        });
    })();

    function updateCounts() {
        const excerpt = document.getElementById('excerpt');
        const content = document.getElementById('content');
        const metaTitle = document.getElementById('meta_title');
        const metaDesc = document.getElementById('meta_description');

        const ec = document.getElementById('excerpt-count');
        const cc = document.getElementById('content-count');
        const mtc = document.getElementById('meta-title-count');
        const mdc = document.getElementById('meta-desc-count');

        if (excerpt && ec) ec.textContent = (excerpt.value || '').length;
        if (content && cc) {
            const w = (content.value || '').trim();
            cc.textContent = w ? w.split(/\s+/).length : 0;
        }
        if (metaTitle && mtc) mtc.textContent = (metaTitle.value || '').length;
        if (metaDesc && mdc) mdc.textContent = (metaDesc.value || '').length;
    }

    document.addEventListener('input', function (e) {
        const ids = ['excerpt', 'content', 'meta_title', 'meta_description'];
        if (ids.includes(e.target.id)) updateCounts();
    });
    document.addEventListener('DOMContentLoaded', updateCounts);

    function previewPost(slug) {
        if (!slug) {
            alert('Chưa có slug để xem trước.');
            return;
        }
        window.open('${ctx}/chi-tiet-blog?slug=' + encodeURIComponent(slug), '_blank');
    }

</script>

</body>
</html>
