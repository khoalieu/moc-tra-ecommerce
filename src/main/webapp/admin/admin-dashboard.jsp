<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .dashboard-control-form { display: flex; flex-wrap: wrap; gap: 10px; align-items: end; margin-bottom: 14px; }
        .dashboard-control-form label { display: block; margin-bottom: 4px; color: #666; font-size: 12px; font-weight: 600; }
        .dashboard-control-form select,
        .dashboard-control-form input { min-height: 36px; border: 1px solid #ddd; border-radius: 6px; padding: 0 10px; background: #fff; }
        .dashboard-control-form input { width: 84px; }
        .dashboard-control-form button { display: none; }
        .dashboard-scroll-list { max-height: 360px; overflow-y: auto; padding-right: 4px; }
        .dashboard-scroll-list.compact { max-height: 300px; }
        .stat-title-link { color: inherit; text-decoration: none; }
        .stat-title-link:hover { color: #107e84; }
    </style>
</head>

<body>

<div class="admin-container">
    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="dashboard"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Dashboard</h1>
            </div>

            <div class="header-right">
                <div class="header-search">
                    <i class="fas fa-search"></i>
                    <input type="text" placeholder="Tìm kiếm nhanh...">
                </div>

                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">

            <div class="dashboard-grid">

                <div class="dashboard-card">
                    <h3>
                        <i class="fas fa-fire"></i>
                        ${currentTopMode == 'least' ? 'Sản phẩm bán ít nhất' : 'Sản phẩm bán chạy'}
                    </h3>

                    <form id="topProductsForm" action="${pageContext.request.contextPath}/admin/dashboard" method="get" class="dashboard-control-form">
                        <div>
                            <label for="topLimit">Top N</label>
                            <input type="number" id="topLimit" name="topLimit" min="1" max="50" value="${currentTopLimit}">
                        </div>
                        <div>
                            <label for="topMode">Loại</label>
                            <select id="topMode" name="topMode">
                                <option value="best" ${currentTopMode == 'best' ? 'selected' : ''}>Bán chạy nhất</option>
                                <option value="least" ${currentTopMode == 'least' ? 'selected' : ''}>Bán ít nhất</option>
                            </select>
                        </div>
                        <div>
                            <label for="topPeriod">Thời gian</label>
                            <select id="topPeriod" name="topPeriod">
                                <option value="" ${currentTopPeriod == 'all' ? 'selected' : ''}>Tất cả thời gian</option>
                                <option value="day" ${currentTopPeriod == 'day' ? 'selected' : ''}>Hôm nay</option>
                                <option value="week" ${currentTopPeriod == 'week' ? 'selected' : ''}>7 ngày</option>
                                <option value="month" ${currentTopPeriod == 'month' ? 'selected' : ''}>1 tháng</option>
                                <option value="six-months" ${currentTopPeriod == 'six-months' ? 'selected' : ''}>6 tháng</option>
                                <option value="year" ${currentTopPeriod == 'year' ? 'selected' : ''}>1 năm</option>
                            </select>
                        </div>
                        <input type="hidden" name="revenuePeriod" value="${currentRevenuePeriod}">
                        <button type="submit">Lọc</button>
                    </form>

                    <div id="topProductsList" class="stat-list dashboard-scroll-list">
                        <c:forEach var="p" items="${topProducts}" varStatus="loop">
                            <div class="stat-row">
                                <div class="stat-left">
                                    <span class="rank-badge">${loop.index + 1}</span>

                                    <div>
                                        <div class="stat-title">
                                            <a class="stat-title-link" href="${pageContext.request.contextPath}/admin/product/edit?id=${p.productId}">
                                                ${p.productName}
                                            </a>
                                        </div>
                                        <div class="stat-sub">
                                            ${currentTopMode == 'least' ? 'Sản phẩm bán ít' : 'Sản phẩm bán chạy'}
                                        </div>
                                    </div>
                                </div>

                                <div class="stat-value">
                                        ${p.totalSold}
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty topProducts}">
                            <div class="stat-row">
                                <div class="stat-title">Chưa có dữ liệu.</div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <div class="dashboard-card">
                    <h3><i class="fas fa-user-plus"></i> Người dùng mới theo tháng</h3>

                    <div class="stat-list dashboard-scroll-list compact">
                        <c:forEach var="u" items="${newUsersByMonth}">
                            <div class="stat-row">
                                <div class="stat-left">
                                    <span class="month-badge">
                                        <i class="fas fa-calendar"></i>
                                    </span>

                                    <div>
                                        <div class="stat-title">${u.month}</div>
                                        <div class="stat-sub">Người dùng đăng ký mới</div>
                                    </div>
                                </div>

                                <div class="stat-value">
                                        ${u.totalUsers}
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${empty newUsersByMonth}">
                            <div class="stat-row">
                                <div class="stat-title">Chưa có dữ liệu.</div>
                            </div>
                        </c:if>
                    </div>
                </div>

            </div>

            <div class="dashboard-bottom">

                <div class="dashboard-left">
                    <div class="widget">
                        <div class="widget-header">
                            <h3>Đơn hàng gần đây</h3>
                            <a href="admin/orders" class="widget-link">Xem tất cả</a>
                        </div>

                        <div class="widget-content">
                            <div class="item-list">
                                <c:forEach var="o" items="${recentOrders}">
                                    <div class="list-item">
                                        <div class="item-info">
                                            <a href="${pageContext.request.contextPath}/admin/order/detail?id=${o.id}"
                                               class="item-title"
                                               style="text-decoration: none;">
                                                #${o.orderNumber}
                                            </a>

                                            <div class="item-subtitle">
                                                    ${o.notes.contains('-') ? o.notes.split('-')[0] : 'Khách lẻ'}
                                            </div>

                                            <small style="color: #999; font-size: 11px;">
                                                <fmt:formatDate value="${o.createdAt}" pattern="dd/MM HH:mm"/>
                                            </small>
                                        </div>

                                        <div class="item-details">
                                            <div class="item-amount">
                                                <fmt:formatNumber value="${o.totalAmount}" pattern="#,###"/>đ
                                            </div>

                                            <c:choose>
                                                <c:when test="${o.status == 'PENDING'}">
                                                    <span class="status-badge status-pending">Chờ xử lý</span>
                                                </c:when>

                                                <c:when test="${o.status == 'COMPLETED'}">
                                                    <span class="status-badge status-active">Hoàn tất</span>
                                                </c:when>

                                                <c:when test="${o.status == 'CANCELLED'}">
                                                    <span class="status-badge status-inactive">Đã hủy</span>
                                                </c:when>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>

                                <c:if test="${empty recentOrders}">
                                    <div style="padding: 30px; text-align: center; color: #999;">
                                        <i class="fas fa-box-open" style="font-size: 30px; margin-bottom: 10px;"></i>
                                        <p>Chưa có đơn hàng nào.</p>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-right">
                    <div class="dashboard-card">
                        <h3>
                            <i class="fas fa-chart-column"></i>
                            Doanh thu theo tháng
                        </h3>


                        <form id="revenueFilterForm" action="${pageContext.request.contextPath}/admin/dashboard" method="get" class="dashboard-control-form">
                            <input type="hidden" name="topLimit" value="${currentTopLimit}">
                            <input type="hidden" name="topMode" value="${currentTopMode}">
                            <input type="hidden" name="topPeriod" value="${currentTopPeriod}">
                            <div>
                                <label for="revenuePeriod">Thống kê</label>
                                <select id="revenuePeriod" name="revenuePeriod">
                                    <option value="day" ${currentRevenuePeriod == 'day' ? 'selected' : ''}>4 ngày gần nhất</option>
                                    <option value="week" ${currentRevenuePeriod == 'week' ? 'selected' : ''}>Theo tuần</option>
                                    <option value="month" ${currentRevenuePeriod == 'month' ? 'selected' : ''}>Theo tháng</option>
                                    <option value="six-months" ${currentRevenuePeriod == 'six-months' ? 'selected' : ''}>6 tháng</option>
                                    <option value="year" ${currentRevenuePeriod == 'year' ? 'selected' : ''}>1 năm</option>
                                </select>
                            </div>
                            <button type="submit">Cập nhật</button>
                        </form>

                        <div class="chart-wrap">
                            <canvas id="revenueChart"></canvas>
                        </div>
                    </div>
                </div>

            </div>

            <div class="quick-actions">
                <h3>Thao tác nhanh</h3>

                <div class="actions-grid">
                    <a href="${pageContext.request.contextPath}/admin/product/add" class="action-card">
                        <i class="fas fa-plus-circle"></i>
                        <span>Thêm sản phẩm mới</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/orders" class="action-card">
                        <i class="fas fa-shopping-cart"></i>
                        <span>Xử lý đơn hàng</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/customers" class="action-card">
                        <i class="fas fa-users"></i>
                        <span>Quản lý khách hàng</span>
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/blog/add" class="action-card">
                        <i class="fas fa-pen-nib"></i>
                        <span>Viết bài blog</span>
                    </a>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    const revenueLabels = [
        <c:forEach var="r" items="${revenueByMonth}" varStatus="loop">
        "${r.label}"${!loop.last ? "," : ""}
        </c:forEach>
    ];

    const revenueData = [
        <c:forEach var="r" items="${revenueByMonth}" varStatus="loop">
        ${r.revenue}${!loop.last ? "," : ""}
        </c:forEach>
    ];

    const revenueChart = new Chart(document.getElementById("revenueChart"), {
        type: "bar",
        data: {
            labels: revenueLabels,
            datasets: [{
                label: "Doanh thu",
                data: revenueData,
                borderRadius: 8,
                barThickness: 40
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    ticks: {
                        callback: function(value) {
                            return value.toLocaleString("vi-VN") + "đ";
                        }
                    }
                }
            }
        }
    });

    const ctx = "${pageContext.request.contextPath}";
    const topProductsForm = document.getElementById("topProductsForm");
    const revenueFilterForm = document.getElementById("revenueFilterForm");
    const topProductsList = document.getElementById("topProductsList");

    function debounce(fn, delay) {
        let timer;
        return function () {
            clearTimeout(timer);
            timer = setTimeout(fn, delay);
        };
    }

    function escapeHtml(value) {
        return String(value || "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#39;");
    }

    function currentTopModeLabel(shortLabel) {
        const mode = document.getElementById("topMode").value;
        if (mode === "least") {
            return shortLabel ? "Sản phẩm bán ít" : "Sản phẩm bán ít nhất";
        }
        return shortLabel ? "Sản phẩm bán chạy" : "Sản phẩm bán chạy";
    }

    function loadTopProducts() {
        const params = new URLSearchParams(new FormData(topProductsForm));
        params.set("ajax", "topProducts");

        fetch(ctx + "/admin/dashboard?" + params.toString(), {
            headers: {"Accept": "application/json"}
        })
            .then(response => response.json())
            .then(products => {
                topProductsList.innerHTML = "";
                if (!products || products.length === 0) {
                    topProductsList.innerHTML = '<div class="stat-row"><div class="stat-title">Chưa có dữ liệu.</div></div>';
                    return;
                }

                products.forEach((product, index) => {
                    const row = document.createElement("div");
                    row.className = "stat-row";
                    row.innerHTML =
                        '<div class="stat-left">' +
                        '<span class="rank-badge">' + (index + 1) + '</span>' +
                        '<div>' +
                        '<div class="stat-title">' +
                        '<a class="stat-title-link" href="' + ctx + '/admin/product/edit?id=' + product.productId + '">' +
                        escapeHtml(product.productName) +
                        '</a>' +
                        '</div>' +
                        '<div class="stat-sub">' + currentTopModeLabel(true) + '</div>' +
                        '</div>' +
                        '</div>' +
                        '<div class="stat-value">' + product.totalSold + '</div>';
                    topProductsList.appendChild(row);
                });
            });
    }

    function loadRevenue() {
        const params = new URLSearchParams(new FormData(revenueFilterForm));
        params.set("ajax", "revenue");

        fetch(ctx + "/admin/dashboard?" + params.toString(), {
            headers: {"Accept": "application/json"}
        })
            .then(response => response.json())
            .then(rows => {
                revenueChart.data.labels = rows.map(row => row.label);
                revenueChart.data.datasets[0].data = rows.map(row => row.revenue);
                revenueChart.update();
            });
    }

    topProductsForm.addEventListener("submit", function (event) {
        event.preventDefault();
        loadTopProducts();
    });

    revenueFilterForm.addEventListener("submit", function (event) {
        event.preventDefault();
        loadRevenue();
    });

    document.getElementById("topLimit").addEventListener("input", debounce(loadTopProducts, 350));
    document.getElementById("topMode").addEventListener("change", loadTopProducts);
    document.getElementById("topPeriod").addEventListener("change", loadTopProducts);
    document.getElementById("revenuePeriod").addEventListener("change", loadRevenue);
</script>

</body>
</html>
