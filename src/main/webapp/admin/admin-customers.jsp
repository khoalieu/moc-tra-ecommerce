<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Khách hàng - Mộc Trà Admin</title>
    <link rel="stylesheet" href="../assets/css/base.css">
    <link rel="stylesheet" href="../assets/css/components.css">
    <link rel="stylesheet" href="assets/css/admin.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">

    <style>
        .selection-alert {
            background-color: #e8f0fe;
            color: #1a73e8;
            padding: 10px 15px;
            margin-bottom: 15px;
            border-radius: 4px;
            border: 1px solid #d2e3fc;
            text-align: center;
            font-size: 14px;
        }

        .selection-alert a {
            font-weight: bold;
            color: #1a73e8;
            text-decoration: underline;
            cursor: pointer;
            margin-left: 5px;
        }

        .selection-alert-success {
            background-color: #e6fffa;
            color: #047481;
            border-color: #b2f5ea;
        }

        .selection-alert-success a {
            color: #047481;
        }
    </style>
</head>
<body>
<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="customers"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Khách hàng</h1>
            </div>

            <div class="header-right">
                <form action="customers" method="get" class="header-search">
                    <i class="fas fa-search"></i>
                    <input type="text" name="search" value="${paramSearch}" placeholder="Tìm kiếm khách hàng...">
                </form>

                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank"
                   style="margin-left: 20px;">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">
            <div class="page-header">
                <div class="page-title">
                    <h2>Danh sách khách hàng</h2>
                    <p>Quản lý thông tin và hoạt động của khách hàng</p>
                </div>
            </div>

            <form action="customers" method="get" class="filters-section">
                <input type="hidden" name="search" value="${paramSearch}">

                <div class="filters-grid">
                    <div class="filter-group">
                        <label for="status-filter">Trạng thái</label>
                        <select id="status-filter" name="status" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả trạng thái</option>
                            <option value="new" ${paramStatus == 'new' ? 'selected' : ''}>Khách hàng mới</option>
                            <option value="active" ${paramStatus == 'active' ? 'selected' : ''}>Đang hoạt động</option>
                            <option value="vip" ${paramStatus == 'vip' ? 'selected' : ''}>VIP</option>
                            <option value="inactive" ${paramStatus == 'inactive' ? 'selected' : ''}>Không hoạt động
                            </option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="orders-filter">Số đơn hàng</label>
                        <select id="orders-filter" name="orders" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả</option>
                            <option value="0" ${paramOrders == '0' ? 'selected' : ''}>Chưa mua hàng</option>
                            <option value="1-5" ${paramOrders == '1-5' ? 'selected' : ''}>1-5 đơn</option>
                            <option value="6-10" ${paramOrders == '6-10' ? 'selected' : ''}>6-10 đơn</option>
                            <option value="10+" ${paramOrders == '10+' ? 'selected' : ''}>Trên 10 đơn</option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="spending-filter">Tổng chi tiêu</label>
                        <select id="spending-filter" name="spending" class="form-select" onchange="this.form.submit()">
                            <option value="">Tất cả</option>
                            <option value="0-500000" ${paramSpending == '0-500000' ? 'selected' : ''}>Dưới 500.000₫
                            </option>
                            <option value="500000-1000000" ${paramSpending == '500000-1000000' ? 'selected' : ''}>
                                500.000₫ - 1.000.000₫
                            </option>
                            <option value="1000000+" ${paramSpending == '1000000+' ? 'selected' : ''}>Trên 1.000.000₫
                            </option>
                        </select>
                    </div>

                    <div class="filter-group">
                        <label for="sort-filter">Sắp xếp</label>
                        <select id="sort-filter" name="sort" class="form-select" onchange="this.form.submit()">
                            <option value="newest" ${paramSort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="oldest" ${paramSort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                            <option value="name-asc" ${paramSort == 'name-asc' ? 'selected' : ''}>Tên A-Z</option>
                            <option value="name-desc" ${paramSort == 'name-desc' ? 'selected' : ''}>Tên Z-A</option>
                            <option value="orders-desc" ${paramSort == 'orders-desc' ? 'selected' : ''}>Nhiều đơn hàng
                            </option>
                            <option value="spending-desc" ${paramSort == 'spending-desc' ? 'selected' : ''}>Chi tiêu
                                cao
                            </option>
                        </select>
                    </div>
                </div>
            </form>

            <div class="bulk-actions-bar" id="bulkActionsBar">
                <input type="checkbox" class="product-checkbox" id="selectAllCustomers">
                <span class="bulk-actions-info">
                    <strong id="selectedCount">0</strong> khách hàng được chọn
                </span>
                <div class="bulk-actions-buttons">
                    <button class="btn-bulk btn-bulk-activate" onclick="bulkActivate()">
                        <i class="fas fa-user-check"></i>
                        Kích hoạt
                    </button>
                    <button class="btn-bulk btn-bulk-deactivate" onclick="bulkDeactivate()">
                        <i class="fas fa-user-times"></i>
                        Vô hiệu hóa
                    </button>
                    <button class="btn-bulk btn-bulk-delete" onclick="bulkDelete()">
                        <i class="fas fa-trash"></i>
                        Xóa
                    </button>
                    <button class="btn-bulk btn-bulk-cancel" onclick="cancelSelection()">
                        <i class="fas fa-times"></i>
                        Hủy
                    </button>
                </div>
            </div>

            <div id="selectPageAlert" class="selection-alert" style="display:none;">
                Bạn đã chọn tất cả <strong><span id="currentPageCount">0</span></strong> khách hàng trên trang này.
                <c:if test="${totalCustomers > customers.size()}">
                    <a onclick="switchToSelectAllMode()">Chọn tất cả <strong>${totalCustomers}</strong> khách hàng trong
                        danh sách?</a>
                </c:if>
            </div>

            <div id="selectAllAlert" class="selection-alert selection-alert-success" style="display:none;">
                Tất cả <strong>${totalCustomers}</strong> khách hàng trong danh sách đã được chọn.
                <a onclick="cancelSelection()">Hủy chọn</a>
            </div>
            <div class="products-container">
                <div class="table-header">
                    <div class="products-count">Tổng cộng: <strong>${totalCustomers} khách hàng</strong></div>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th style="width: 50px;">
                                <input type="checkbox" class="product-checkbox" id="selectAllCheckbox"
                                       onchange="toggleSelectAll(this)">
                            </th>
                            <th>Tên khách hàng</th>
                            <th style="width: 200px;">Email / SĐT</th>
                            <th style="width: 100px;">Đơn hàng</th>
                            <th style="width: 130px;">Tổng chi tiêu</th>
                            <th style="width: 150px;">Ngày tham gia</th>
                            <th style="width: 150px;">Lần mua cuối</th>
                            <th style="width: 120px;">Trạng thái</th>
                            <th style="width: 130px; text-align: center;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="c" items="${customers}">
                            <tr>
                                <td>
                                    <input type="checkbox" class="product-checkbox row-checkbox" value="${c.id}"
                                           onchange="updateBulkActions()">
                                </td>
                                <td>
                                    <div class="product-name-cell">${c.fullName}</div>
                                    <div class="product-description-cell">Địa
                                        chỉ: ${c.province != null ? c.province : 'Chưa cập nhật'}</div>
                                </td>
                                <td>
                                    <div class="product-name-cell">${c.email}</div>
                                    <div class="product-description-cell">${c.phone}</div>
                                </td>
                                <td>
                                        <span class="${c.totalOrders > 5 ? 'product-stock-high' : 'product-stock-low'}">
                                                ${c.totalOrders}
                                        </span>
                                </td>
                                <td>
                                    <div class="product-price-main">${c.totalSpentFormatted}</div>
                                </td>
                                <td>
                                    <div class="date-info">
                                        <strong><fmt:formatDate value="${c.joinDate}" pattern="dd/MM/yyyy"/></strong>
                                    </div>
                                </td>
                                <td>
                                    <div class="date-info">
                                        <strong>
                                            <c:choose>
                                                <c:when test="${not empty c.lastOrderDate}">
                                                    <fmt:formatDate value="${c.lastOrderDate}" pattern="dd/MM/yyyy"/>
                                                </c:when>
                                                <c:otherwise>---</c:otherwise>
                                            </c:choose>
                                        </strong>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${c.statusLabel == 'VIP'}">
                                            <span class="status-badge status-vip">VIP</span>
                                        </c:when>
                                        <c:when test="${c.statusLabel == 'Mới'}">
                                            <span class="status-badge status-new">Mới</span>
                                        </c:when>
                                        <c:when test="${c.statusLabel == 'Không hoạt động'}">
                                            <span class="status-badge status-inactive">Không hoạt động</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-active">Hoạt động</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="${pageContext.request.contextPath}/admin/customer/detail?id=${c.id}"
                                           class="btn-action" title="Xem chi tiết"
                                           style="display:inline-flex; align-items:center; justify-content:center; text-decoration:none; color:inherit;">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button class="btn-action" title="Chỉnh sửa">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn-action danger" title="Xóa">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty customers}">
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 30px;">
                                    Không tìm thấy khách hàng nào phù hợp với điều kiện lọc.
                                </td>
                            </tr>
                        </c:if>

                        </tbody>
                    </table>
                </div>

                <div class="pagination-container">
                    <div class="pagination-info">
                        <%-- Tính toán số thứ tự hiển thị --%>
                        <c:set var="startIdx" value="${(currentPage - 1) * 10 + 1}"/>
                        <c:set var="endIdx" value="${startIdx + customers.size() - 1}"/>
                        <c:if test="${totalCustomers == 0}">
                            <c:set var="startIdx" value="0"/>
                            <c:set var="endIdx" value="0"/>
                        </c:if>

                        Hiển thị <strong>${startIdx}-${endIdx}</strong> trong tổng số <strong>${totalCustomers}</strong>
                        khách hàng
                    </div>

                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="customers?page=${currentPage - 1}&search=${paramSearch}&status=${paramStatus}&sort=${paramSort}"
                               class="page-btn">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage <= 1}">
                            <span class="page-btn disabled"><i class="fas fa-chevron-left"></i></span>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="customers?page=${i}&search=${paramSearch}&status=${paramStatus}&sort=${paramSort}"
                               class="page-btn ${currentPage == i ? 'active' : ''}">${i}</a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="customers?page=${currentPage + 1}&search=${paramSearch}&status=${paramStatus}&sort=${paramSort}"
                               class="page-btn">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage >= totalPages}">
                            <span class="page-btn disabled"><i class="fas fa-chevron-right"></i></span>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    const TOTAL_CUSTOMERS = ${totalCustomers};
    const CURRENT_PAGE_SIZE = document.querySelectorAll('.row-checkbox').length;

    function checkSelectAllMode() {
        const isGlobal = sessionStorage.getItem('adminCustomerSelectAllMode') === 'true';
        if (isGlobal) {
            document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = true);
            document.getElementById('selectAllCheckbox').checked = true;
            document.getElementById('selectAllCustomers').checked = true;

            document.getElementById('selectAllAlert').style.display = 'block';
            document.getElementById('selectPageAlert').style.display = 'none';

            document.getElementById('selectedCount').innerText = TOTAL_CUSTOMERS;
            document.getElementById('bulkActionsBar').classList.add('active');
        } else {
            document.getElementById('selectAllAlert').style.display = 'none';
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        checkSelectAllMode();
    });

    function toggleSelectAll(checkbox) {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const bulkActionsCheckbox = document.getElementById('selectAllCustomers');

        rowCheckboxes.forEach(cb => {
            cb.checked = checkbox.checked;
        });
        bulkActionsCheckbox.checked = checkbox.checked;

        if (checkbox.checked) {
            if (TOTAL_CUSTOMERS > CURRENT_PAGE_SIZE) {
                document.getElementById('selectPageAlert').style.display = 'block';
                document.getElementById('currentPageCount').innerText = CURRENT_PAGE_SIZE;
            }
        } else {
            cancelSelection();
        }

        updateBulkActions();
    }

    function switchToSelectAllMode() {
        sessionStorage.setItem('adminCustomerSelectAllMode', 'true');
        document.getElementById('selectPageAlert').style.display = 'none';
        document.getElementById('selectAllAlert').style.display = 'block';
        document.getElementById('selectedCount').innerText = TOTAL_CUSTOMERS;
    }

    function cancelSelection() {
        sessionStorage.removeItem('adminCustomerSelectAllMode');

        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const bulkActionsCheckbox = document.getElementById('selectAllCustomers');

        rowCheckboxes.forEach(cb => cb.checked = false);
        selectAllCheckbox.checked = false;
        bulkActionsCheckbox.checked = false;
        document.getElementById('selectPageAlert').style.display = 'none';
        document.getElementById('selectAllAlert').style.display = 'none';

        updateBulkActions();
    }

    function updateBulkActions() {
        if (sessionStorage.getItem('adminCustomerSelectAllMode') === 'true') {
            document.getElementById('bulkActionsBar').classList.add('active');
            return;
        }

        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const bulkActionsBar = document.getElementById('bulkActionsBar');
        const selectedCount = document.getElementById('selectedCount');
        const checkedCount = Array.from(rowCheckboxes).filter(cb => cb.checked).length;

        selectedCount.textContent = checkedCount;

        if (checkedCount > 0) {
            bulkActionsBar.classList.add('active');
        } else {
            bulkActionsBar.classList.remove('active');
            document.getElementById('selectPageAlert').style.display = 'none';
        }
    }

    document.getElementById('selectAllCustomers').addEventListener('change', function () {
        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        selectAllCheckbox.checked = this.checked;
        toggleSelectAll(this);
    });

    function getSelectedCustomers() {
        const rowCheckboxes = document.querySelectorAll('.row-checkbox');
        const selected = [];
        rowCheckboxes.forEach((checkbox) => {
            if (checkbox.checked) {
                selected.push(checkbox.value);
            }
        });
        return selected;
    }

    // --- XỬ LÝ GỬI REQUEST AJAX ---
    function sendBulkRequest(action, actionName) {
        const isGlobalMode = sessionStorage.getItem('adminCustomerSelectAllMode') === 'true';
        let count = 0;

        const params = new URLSearchParams();
        params.append('action', action);

        if (isGlobalMode) {
            count = TOTAL_CUSTOMERS;
            params.append('selectAll', 'true');
            params.append('search', '${paramSearch}');
            params.append('status', '${paramStatus}');
            params.append('spending', '${paramSpending}');
            params.append('orders', '${paramOrders}');
        } else {
            const selectedIds = getSelectedCustomers();
            if (selectedIds.length === 0) return;
            count = selectedIds.length;
            params.append('selectAll', 'false');
            params.append('ids', selectedIds.join(','));
        }

        if (confirm(`Bạn có chắc muốn ${actionName} ${count} khách hàng?`)) {
            fetch('customers', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params
            })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(`Đã ${actionName} thành công!`);
                        // Sau khi thành công thì nên hủy chế độ chọn tất cả
                        sessionStorage.removeItem('adminCustomerSelectAllMode');
                        location.reload();
                    } else {
                        alert('Có lỗi xảy ra: ' + (data.message || 'Lỗi không xác định'));
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi kết nối đến máy chủ.');
                });
        }
    }

    function bulkActivate() {
        sendBulkRequest('activate', 'kích hoạt');
    }

    function bulkDeactivate() {
        sendBulkRequest('deactivate', 'vô hiệu hóa');
    }

    function bulkDelete() {
        if (confirm("LƯU Ý: Khách hàng sẽ được chuyển sang trạng thái 'Vô hiệu hóa' (Xóa mềm).")) {
            sendBulkRequest('deactivate', 'vô hiệu hóa');
        }
    }
</script>
</body>
</html>