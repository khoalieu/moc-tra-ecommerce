<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý Đơn hàng - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">

    <link rel="stylesheet" href="admin/assets/css/admin-orders.css">

    <style>
        .check-col {
            width: 40px;
            text-align: center;
        }

        .product-checkbox {
            width: 18px;
            height: 18px;
            cursor: pointer;
            accent-color: #107e84;
        }
    </style>
</head>
<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="orders"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Đơn hàng</h1>
            </div>
            <div class="header-right">
                <div class="header-search">
                    <i class="fa-solid fa-search"></i>
                    <input type="text" name="search" form="filterForm"
                           value="${search}"
                           placeholder="Tìm mã đơn, khách hàng, email, SĐT, mã vận đơn..."
                           autocomplete="off">
                </div>
            </div>
        </header>

        <div class="admin-content">

            <div class="page-header">
                <div class="page-title">
                    <h2>Danh sách đơn hàng</h2>
                    <p>Quản lý và xử lý các đơn đặt hàng từ khách hàng</p>
                </div>
            </div>

            <div class="filters-section">
                <div class="quick-filters">
                    <a href="admin/orders?quickFilter=need_process${quickFilterBaseQuery}"
                       class="quick-filter-btn ${quickFilter == 'need_process' ? 'active' : ''}">
                        Cần xử lý
                    </a>
                    <a href="admin/orders?quickFilter=paid_waiting_process${quickFilterBaseQuery}"
                       class="quick-filter-btn ${quickFilter == 'paid_waiting_process' ? 'active' : ''}">
                        Đã thanh toán chờ xử lý
                    </a>
                    <a href="admin/orders?quickFilter=cancelled_waiting_refund${quickFilterBaseQuery}"
                       class="quick-filter-btn ${quickFilter == 'cancelled_waiting_refund' ? 'active' : ''}">
                        Đã hủy chờ hoàn tiền
                    </a>
                    <a href="admin/orders?quickFilter=shipping${quickFilterBaseQuery}"
                       class="quick-filter-btn ${quickFilter == 'shipping' ? 'active' : ''}">
                        Đang giao
                    </a>
                    <a href="admin/orders?quickFilter=delivery_failed${quickFilterBaseQuery}"
                       class="quick-filter-btn ${quickFilter == 'delivery_failed' ? 'active' : ''}">
                        Giao thất bại
                    </a>
                </div>

                <form id="filterForm" action="admin/orders" method="GET">
                    <input type="hidden" name="quickFilter" id="quickFilterInput" value="${quickFilter}">
                    <div class="filters-grid">
                        <div class="filter-group">
                            <label>Trạng thái đơn</label>
                            <select name="status" class="form-select" onchange="clearQuickFilterAndSubmit(this.form)">
                                <option value="">Tất cả trạng thái</option>
                                <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Chờ xác nhận</option>
                                <option value="SHIPPING" ${status == 'SHIPPING' ? 'selected' : ''}>Đang giao</option>
                                <option value="COMPLETED" ${status == 'COMPLETED' ? 'selected' : ''}>Hoàn thành</option>
                                <option value="CANCELLED" ${status == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
                                <option value="DELIVERY_FAILED" ${status == 'DELIVERY_FAILED' ? 'selected' : ''}>Giao thất bại</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Trạng thái thanh toán</label>
                            <select name="paymentStatus" class="form-select" onchange="clearQuickFilterAndSubmit(this.form)">
                                <option value="">Tất cả thanh toán</option>
                                <option value="PENDING" ${paymentStatus == 'PENDING' ? 'selected' : ''}>Chưa thanh toán</option>
                                <option value="PAID" ${paymentStatus == 'PAID' ? 'selected' : ''}>Đã thanh toán</option>
                                <option value="FAILED" ${paymentStatus == 'FAILED' ? 'selected' : ''}>Thanh toán thất bại</option>
                                <option value="EXPIRED" ${paymentStatus == 'EXPIRED' ? 'selected' : ''}>Hết hạn thanh toán</option>
                                <option value="REFUNDED" ${paymentStatus == 'REFUNDED' ? 'selected' : ''}>Đã hoàn tiền</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Phương thức thanh toán</label>
                            <select name="paymentMethod" class="form-select" onchange="clearQuickFilterAndSubmit(this.form)">
                                <option value="">Tất cả phương thức</option>
                                <option value="cod" ${paymentMethod == 'cod' ? 'selected' : ''}>COD</option>
                                <option value="bank" ${paymentMethod == 'bank' ? 'selected' : ''}>Ngân hàng</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Thời gian</label>
                            <select name="time" class="form-select" onchange="handleTimeFilterChange(this)">
                                <option value="">Toàn thời gian</option>
                                <option value="today" ${time == 'today' ? 'selected' : ''}>Hôm nay</option>
                                <option value="last_7_days" ${time == 'last_7_days' ? 'selected' : ''}>7 ngày gần đây</option>
                                <option value="last_30_days" ${time == 'last_30_days' ? 'selected' : ''}>30 ngày gần đây</option>
                                <option value="custom" ${time == 'custom' ? 'selected' : ''}>Tùy chọn</option>
                            </select>
                        </div>

                        <div class="filter-group custom-date-filter" style="${time == 'custom' ? '' : 'display:none;'}">
                            <label>Từ ngày</label>
                            <input type="date" name="dateFrom" class="form-select" value="${dateFrom}"
                                   onchange="document.querySelector('#filterForm select[name=time]').value='custom'; this.form.submit()">
                        </div>

                        <div class="filter-group custom-date-filter" style="${time == 'custom' ? '' : 'display:none;'}">
                            <label>Đến ngày</label>
                            <input type="date" name="dateTo" class="form-select" value="${dateTo}"
                                   onchange="document.querySelector('#filterForm select[name=time]').value='custom'; this.form.submit()">
                        </div>

                        <div class="filter-group">
                            <label>Sắp xếp</label>
                            <select name="sort" class="form-select" onchange="this.form.submit()">
                                <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                <option value="oldest" ${sort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                                <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Tổng tiền: Cao - Thấp</option>
                                <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Tổng tiền: Thấp - Cao</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>&nbsp;</label>
                            <a href="admin/orders" class="admin-filter-reset">
                                Xóa bộ lọc
                            </a>
                        </div>
                    </div>
                </form>
            </div>

            <div class="bulk-actions-bar" id="bulkBar">
                <div class="bulk-actions-info">
                    Đã chọn <span id="countSelected">0</span> đơn hàng
                </div>
                <div class="bulk-actions-buttons">
                    <a href="#" id="btnSingleView" class="btn-bulk btn-bulk-cancel"
                       style="display: none; background: rgba(255,255,255,0.1);">
                        <i class="fa-regular fa-eye"></i> Xem
                    </a>

                    <button class="btn-bulk btn-bulk-activate" onclick="bulkAction('completed')">
                        <i class="fa-solid fa-check"></i> Hoàn tất
                    </button>
                    <button class="btn-bulk btn-bulk-delete" onclick="bulkAction('cancelled')">
                        <i class="fa-solid fa-ban"></i> Hủy đơn
                    </button>
                </div>
            </div>

            <div class="orders-container">
                <div class="table-header">
                    <div class="orders-count">Tổng cộng: <strong>${totalOrders}</strong> đơn hàng</div>
                </div>

                <div class="table-responsive">
                    <table class="orders-table">
                        <thead>
                        <tr>
                            <th class="check-col">
                                <input type="checkbox" id="selectAll" class="product-checkbox">
                            </th>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Sản phẩm</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th>Thanh toán</th>
                            <th>Ngày đặt</th>
                            <th>Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="o" items="${orders}">
                            <tr>
                                <td class="check-col">
                                    <input type="checkbox" class="product-checkbox order-check" value="${o.id}">
                                </td>
                                <td>
                                    <span class="order-id">#${o.orderNumber}</span>
                                </td>
                                <td>
                                    <div class="customer-info">
                                        <span class="customer-name">${o.notes.split('-')[0]}</span>
                                        <span class="customer-phone"
                                              style="font-size: 12px; color: #888;">${o.notes.split('-')[1]}</span>
                                    </div>
                                </td>
                                <td>
                                    <div class="order-items">
                                        <c:forEach var="item" items="${o.items}" end="0">
                                            <div class="order-item">
                                                <strong>${item.quantity}x</strong> ${item.product.name}
                                            </div>
                                        </c:forEach>
                                        <c:if test="${o.items.size() > 1}">
                                            <small style="color: #107e84;">+${o.items.size() - 1} món khác</small>
                                        </c:if>
                                    </div>
                                </td>
                                <td>
                                    <div class="order-amount">
                                        <fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/>đ
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${o.status == 'PENDING'}"><span
                                                class="status-badge status-pending">Chờ xử lý</span></c:when>
                                        <c:when test="${o.status == 'SHIPPING'}"><span
                                                class="status-badge status-pending">Đang giao</span></c:when>
                                        <c:when test="${o.status == 'COMPLETED'}"><span
                                                class="status-badge status-active">Hoàn tất</span></c:when>
                                        <c:when test="${o.status == 'CANCELLED'}"><span
                                                class="status-badge status-inactive">Đã hủy</span></c:when>
                                        <c:when test="${o.status == 'DELIVERY_FAILED'}"><span
                                                class="status-badge status-inactive">Giao thất bại</span></c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="display:flex; flex-direction:column; gap:6px;">
                                        <span>${o.paymentMethod == 'cod' ? 'COD' : o.paymentMethod}</span>
                                        <c:choose>
                                            <c:when test="${o.paymentStatus == 'PAID'}">
                                                <span class="status-badge status-active">Đã thanh toán</span>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'FAILED'}">
                                                <span class="status-badge status-inactive">Thất bại</span>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'EXPIRED'}">
                                                <span class="status-badge status-inactive">Hết hạn</span>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'REFUNDED'}">
                                                <span class="status-badge status-active">Đã hoàn tiền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-pending">Chưa thanh toán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                                <td>
                                    <div class="order-date">
                                        <div><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy"/></div>
                                        <small><fmt:formatDate value="${o.createdAt}" pattern="HH:mm"/></small>
                                    </div>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <a href="admin/order/detail?id=${o.id}" class="btn-action" title="Xem chi tiết">
                                            <i class="fa-regular fa-eye"></i>
                                        </a>
                                        <c:if test="${o.status == 'PENDING'}">
                                            <button class="btn-action danger" title="Hủy nhanh"
                                                    onclick="if(confirm('Hủy đơn này?')) updateStatus(${o.id}, 'cancelled')">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-container">
                    <div class="pagination-info">
                        <c:set var="startIdx" value="${(currentPage - 1) * 10 + 1}" />
                        <c:set var="endIdx" value="${startIdx + orders.size() - 1}" />
                        <c:if test="${totalOrders == 0}">
                            <c:set var="startIdx" value="0" />
                            <c:set var="endIdx" value="0" />
                        </c:if>

                        Hiển thị <strong>${startIdx}-${endIdx}</strong> trong tổng số <strong>${totalOrders}</strong> đơn hàng
                    </div>

                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="admin/orders?page=${currentPage - 1}${filterQuery}"
                               class="page-btn">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </c:if>
                        <c:if test="${currentPage <= 1}">
                            <span class="page-btn disabled"><i class="fas fa-chevron-left"></i></span>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="i">
                            <a href="admin/orders?page=${i}${filterQuery}"
                               class="page-btn ${currentPage == i ? 'active' : ''}">${i}</a>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a href="admin/orders?page=${currentPage + 1}${filterQuery}"
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
    const checkboxes = document.querySelectorAll('.order-check');
    const selectAll = document.getElementById('selectAll');
    const bulkBar = document.getElementById('bulkBar');
    const countSpan = document.getElementById('countSelected');
    const btnSingleView = document.getElementById('btnSingleView');

    function clearQuickFilterAndSubmit(form) {
        const quickFilterInput = document.getElementById('quickFilterInput');
        if (quickFilterInput) {
            quickFilterInput.value = '';
        }
        form.submit();
    }
    function handleTimeFilterChange(select) {
        const customDateFilters = document.querySelectorAll('.custom-date-filter');
        customDateFilters.forEach(group => {
            group.style.display = select.value === 'custom' ? 'flex' : 'none';
        });

        if (select.value !== 'custom') {
            const form = select.form;
            form.querySelector('input[name="dateFrom"]').value = '';
            form.querySelector('input[name="dateTo"]').value = '';
            form.submit();
        }
    }

    function toggleBulkBar() {
        const selectedCount = document.querySelectorAll('.order-check:checked').length;
        countSpan.innerText = selectedCount;

        if (selectedCount > 0) {
            bulkBar.classList.add('active');

            if (selectedCount === 1) {
                btnSingleView.style.display = 'inline-flex';
                const id = document.querySelector('.order-check:checked').value;
                btnSingleView.href = 'admin/order/detail?id=' + id;
            } else {
                btnSingleView.style.display = 'none';
            }
        } else {
            bulkBar.classList.remove('active');
        }
    }

    selectAll.addEventListener('change', function () {
        checkboxes.forEach(cb => cb.checked = this.checked);
        toggleBulkBar();
    });

    checkboxes.forEach(cb => {
        cb.addEventListener('change', toggleBulkBar);
    });

    // Bulk Action Fetch
    function bulkAction(status) {
        const selected = document.querySelectorAll('.order-check:checked');
        if (selected.length === 0) return;

        if (!confirm("Cập nhật trạng thái cho " + selected.length + " đơn hàng?")) return;

        const ids = Array.from(selected).map(cb => cb.value).join(',');
        updateStatus(ids, status, 'bulk');
    }

    // Unified Update Function
    function updateStatus(idOrIds, status, action = 'single') {
        const params = new URLSearchParams();
        params.append('action', action);
        params.append('status', status);

        if (action === 'bulk') params.append('orderIds', idOrIds);
        else params.append('orderId', idOrIds);

        fetch('admin/order/update', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        }).then(res => {
            if (res.ok) {
                alert("Cập nhật thành công!");
                location.reload();
            } else {
                alert("Lỗi cập nhật!");
            }
        });
    }
</script>

</body>
</html>
