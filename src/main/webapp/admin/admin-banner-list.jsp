<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quản lý Banner - Mộc Trà Admin</title>

    <link rel="stylesheet" href="../assets/css/base.css"/>
    <link rel="stylesheet" href="../assets/css/components.css"/>
    <link rel="stylesheet" href="assets/css/admin.css"/>

    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css"/>
</head>

<body>
<div class="admin-container">

    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="banners"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Banner</h1>
            </div>

            <div class="header-right">
                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <c:set var="successMsg" value="${sessionScope.successMsg}"/>
            <c:set var="errorMsg" value="${sessionScope.errorMsg}"/>
            <c:remove var="successMsg" scope="session"/>
            <c:remove var="errorMsg" scope="session"/>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" style="margin-bottom: 12px;">
                    <i class="fa-solid fa-circle-check"></i>
                        ${fn:escapeXml(successMsg)}
                </div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" style="margin-bottom: 12px;">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                        ${fn:escapeXml(errorMsg)}
                </div>
            </c:if>

            <div class="page-header">
                <div class="page-title">
                    <h2>Danh sách banner</h2>
                    <p>Quản lý banner hiển thị trên website</p>
                </div>

                <div class="page-actions">
                    <a href="${pageContext.request.contextPath}/admin/banner/add" class="btn btn-primary">
                        <i class="fas fa-plus"></i>
                        Thêm banner mới
                    </a>
                </div>
            </div>

            <div class="bulk-actions-bar" id="bulkActionsBar">
                <input type="checkbox" class="product-checkbox" id="selectAllBannersBar"/>
                <span class="bulk-actions-info">
                    <strong id="selectedCount">0</strong> banner được chọn
                </span>

                <div class="bulk-actions-buttons">
                    <button class="btn-bulk btn-bulk-activate" type="button" onclick="bulkSetActive(1)">
                        <i class="fas fa-eye"></i>
                        Hiển thị
                    </button>

                    <button class="btn-bulk btn-bulk-deactivate" type="button" onclick="bulkSetActive(0)">
                        <i class="fas fa-eye-slash"></i>
                        Ẩn
                    </button>

                    <button class="btn-bulk btn-bulk-delete" type="button" onclick="bulkDeleteBanners()">
                        <i class="fas fa-trash"></i>
                        Xóa
                    </button>

                    <button class="btn-bulk btn-bulk-cancel" type="button" onclick="cancelSelection()">
                        <i class="fas fa-times"></i>
                        Hủy
                    </button>
                </div>

            </div>

            <div class="products-container">
                <div class="table-header">
                    <div class="products-count">
                        Tổng số banner : <strong>${empty banners ? 0 : fn:length(banners)}</strong>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th style="width: 50px;">
                                <input type="checkbox" class="product-checkbox" id="selectAllCheckbox"
                                       onchange="toggleSelectAll(this)"/>
                            </th>
                            <th style="width: 90px;">Hình</th>
                            <th>Tiêu đề</th>
                            <th style="width: 140px;">Vị trí</th>
                            <th style="width: 120px;">Thứ tự</th>
                            <th style="width: 120px;">Trạng thái</th>
                            <th style="width: 140px;">Ngày tạo</th>
                            <th style="width: 140px; text-align:center;">Thao tác</th>
                        </tr>
                        </thead>

                        <tbody>
                        <c:if test="${empty banners}">
                            <tr>
                                <td colspan="8" style="text-align:center;">Chưa có banner nào</td>
                            </tr>
                        </c:if>

                        <c:forEach var="b" items="${banners}">
                            <tr>
                                <td>
                                    <input type="checkbox" class="product-checkbox row-checkbox"
                                           value="${b.id}" onchange="updateBulkActions()"/>
                                </td>

                                <td>
                                    <img src="${pageContext.request.contextPath}/${b.imageUrl}"
                                         alt="Banner"
                                         class="product-image-thumb"/>
                                </td>

                                <td>
                                    <div class="product-name-cell">${fn:escapeXml(b.title)}</div>
                                    <div class="product-description-cell">
                                            ${empty b.subtitle ? '' : fn:escapeXml(b.subtitle)}
                                    </div>

                                    <c:if test="${not empty b.buttonText}">
                                        <div style="margin-top:6px; font-size: 12px; color:#666;">
                                            <i class="fa-solid fa-link"></i>
                                            <span style="font-weight: 600;">${fn:escapeXml(b.buttonText)}</span>
                                            <span style="opacity:.8;">
                                                → ${empty b.buttonLink ? '(chưa có link)' : fn:escapeXml(b.buttonLink)}
                                            </span>
                                        </div>
                                    </c:if>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${b.section == 'home'}">
                                            <span class="category-badge health">INDEX</span>
                                        </c:when>
                                        <c:when test="${b.section == 'promotion'}">
                                            <span class="category-badge health">KHUYẾN MÃI</span>
                                        </c:when>
                                        <c:when test="${b.section == 'sidebar'}">
                                            <span class="category-badge health">SIDEBAR</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="category-badge health">${fn:escapeXml(b.section)}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${empty b.sortOrder}">
                                            <span style="color:#777; font-style: italic;">Theo thời gian</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="font-weight: 700;">#${b.sortOrder}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${b.isActive}">
                                            <span class="status-badge published">ĐANG HIỂN THỊ</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-cancelled">ĐANG ẨN</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <c:choose>
                                        <c:when test="${not empty b.createdAtDate}">
                                            <div><fmt:formatDate value="${b.createdAtDate}" pattern="dd/MM/yyyy"/></div>
                                            <small><fmt:formatDate value="${b.createdAtDate}" pattern="HH:mm"/></small>
                                        </c:when>
                                        <c:otherwise>
                                            <div>${fn:escapeXml(b.createdAt)}</div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td>
                                    <div class="action-buttons" style="justify-content: center;">
                                        <a class="btn-action" title="Chỉnh sửa"
                                           href="${pageContext.request.contextPath}/admin/banner/edit?id=${b.id}">
                                            <i class="fas fa-edit"></i>
                                        </a>

                                        <button class="btn-action danger" type="button" title="Xóa"
                                                onclick="deleteSingleBanner(${b.id})">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>

                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    function toggleSelectAll(checkbox) {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const barCheckbox = document.getElementById('selectAllBannersBar');

        rowCheckboxes.forEach(cb => cb.checked = checkbox.checked);
        barCheckbox.checked = checkbox.checked;

        updateBulkActions();
    }

    function updateBulkActions() {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const barCheckbox = document.getElementById('selectAllBannersBar');
        const bulkActionsBar = document.getElementById('bulkActionsBar');
        const selectedCount = document.getElementById('selectedCount');

        const checkedCount = Array.from(rowCheckboxes).filter(cb => cb.checked).length;
        const totalCount = rowCheckboxes.length;

        selectedCount.textContent = checkedCount;

        if (checkedCount > 0) bulkActionsBar.classList.add('active');
        else bulkActionsBar.classList.remove('active');

        if (totalCount > 0 && checkedCount === totalCount) {
            selectAllCheckbox.checked = true;
            barCheckbox.checked = true;
            selectAllCheckbox.indeterminate = false;
        } else if (checkedCount > 0) {
            selectAllCheckbox.checked = false;
            barCheckbox.checked = false;
            selectAllCheckbox.indeterminate = true;
        } else {
            selectAllCheckbox.checked = false;
            barCheckbox.checked = false;
            selectAllCheckbox.indeterminate = false;
        }
    }

    document.getElementById('selectAllBannersBar')?.addEventListener('change', function () {
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        selectAllCheckbox.checked = this.checked;
        toggleSelectAll(this);
    });

    function getSelectedIds() {
        return Array.from(document.querySelectorAll('.row-checkbox:checked'))
            .map(cb => parseInt(cb.value, 10))
            .filter(id => !isNaN(id));
    }

    function cancelSelection() {
        document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const barCheckbox = document.getElementById('selectAllBannersBar');
        selectAllCheckbox.checked = false;
        barCheckbox.checked = false;
        selectAllCheckbox.indeterminate = false;
        updateBulkActions();
    }

    function deleteSingleBanner(id) {
        if (!confirm('Bạn có chắc muốn xóa banner này?')) return;

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/banner/delete';

        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = 'ids';
        input.value = id;

        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }

    function bulkDeleteBanners() {
        const ids = getSelectedIds();
        if (ids.length === 0) return;

        if (!confirm(`CẢNH BÁO: Bạn có chắc muốn xóa ${ids.length} banner đã chọn?`)) return;

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/banner/delete';

        ids.forEach(id => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'ids';
            input.value = id;
            form.appendChild(input);
        });

        document.body.appendChild(form);
        form.submit();
    }

    function bulkSetActive(active) {
        const ids = getSelectedIds();
        if (ids.length === 0) return;

        const msg = active === 1
            ? `Bạn muốn HIỂN THỊ ${ids.length} banner đã chọn?`
            : `Bạn muốn ẨN ${ids.length} banner đã chọn?`;

        if (!confirm(msg)) return;

        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/banner/change-status';

        ids.forEach(id => {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = 'ids';
            input.value = id;
            form.appendChild(input);
        });

        const st = document.createElement('input');
        st.type = 'hidden';
        st.name = 'is_active';
        st.value = String(active);
        form.appendChild(st);

        document.body.appendChild(form);
        form.submit();
    }

</script>

</body>
</html>
