<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Khuyến Mãi - Mộc Trà Admin</title>

    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="assets/css/base.css">
    <link rel="stylesheet" href="assets/css/components.css">
    <link rel="stylesheet" href="admin/assets/css/admin.css">
    <link rel="stylesheet" href="admin/assets/css/admin-promotions.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="admin-container">

    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="promotions"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Quản lý Khuyến mãi</h1>
            </div>
            <div class="header-right">
                <a href="${pageContext.request.contextPath}/" class="view-site-btn" target="_blank">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">

            <div class="page-header">
                <div class="page-title">
                    <h2>Chương trình khuyến mãi & Voucher VIP</h2>
                    <p>Quản lý khuyến mãi sản phẩm và voucher dành cho khách hàng VIP</p>
                </div>
            </div>

            <div class="promotion-stats">
                <div class="stat-card">
                    <div class="stat-icon stat-icon-promo">
                        <i class="fas fa-bullhorn"></i>
                    </div>
                    <div class="stat-info">
                        <h3>${promotionList.size()}</h3>
                        <p>Tổng chương trình</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-voucher">
                        <i class="fas fa-ticket-alt"></i>
                    </div>
                    <div class="stat-info">
                        <h3>${voucherList.size()}</h3>
                        <p>Voucher VIP</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-vip">
                        <i class="fas fa-star"></i>
                    </div>
                    <div class="stat-info">
                        <h3>
                            <c:set var="vipPromoCount" value="0"/>
                            <c:forEach var="promo" items="${promotionList}">
                                <c:if test="${promo.promotionType == 'VIP'}">
                                    <c:set var="vipPromoCount" value="${vipPromoCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${vipPromoCount}
                        </h3>
                        <p>Khuyến mãi VIP</p>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-all">
                        <i class="fas fa-globe"></i>
                    </div>
                    <div class="stat-info">
                        <h3>
                            <c:set var="allPromoCount" value="0"/>
                            <c:forEach var="promo" items="${promotionList}">
                                <c:if test="${promo.promotionType == 'ALL'}">
                                    <c:set var="allPromoCount" value="${allPromoCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            ${allPromoCount}
                        </h3>
                        <p>Khuyến mãi toàn hệ thống</p>
                    </div>
                </div>
            </div>

            <div class="tabs-container">
                <div class="tabs-header">
                    <button class="tab-btn active" data-tab="promotionTab">
                        <i class="fas fa-tags"></i> Khuyến mãi
                    </button>
                    <button class="tab-btn" data-tab="voucherTab">
                        <i class="fas fa-ticket-alt"></i> Voucher VIP
                    </button>
                </div>

                <!-- PROMOTION TAB -->
                <div id="promotionTab" class="tab-content active">
                    <div class="table-header">
                        <div class="table-header__info">
                            <strong>Tổng cộng: ${promotionList.size()} chương trình</strong>
                        </div>
                        <button type="button" class="btn btn-create-promotion" onclick="openCreatePromotionModal()">
                            <i class="fas fa-plus"></i> Thêm khuyến mãi
                        </button>
                    </div>

                    <div class="table-responsive">
                        <table class="orders-table promotions-table">
                            <thead>
                            <tr>
                                <th>Tên chương trình</th>
                                <th>Loại</th>
                                <th>Giảm giá</th>
                                <th>Đối tượng</th>
                                <th>Thời gian</th>
                                <th>Trạng thái</th>
                                <th class="actions-col">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="promo" items="${promotionList}">
                                <tr>
                                    <td>
                                        <div class="cell-title">${promo.name}</div>
                                        <div class="cell-subtitle">${promo.description}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${promo.discountType == 'PERCENT'}">
                                                <span class="badge badge-blue">Phần trăm</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-orange">Tiền mặt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${promo.discountType == 'PERCENT'}">
                                                <strong>${promo.discountValue}%</strong>
                                            </c:when>
                                            <c:otherwise>
                                                <strong><fmt:formatNumber value="${promo.discountValue}" pattern="#,###"/>₫</strong>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${promo.promotionType == 'VIP'}">
                                                <span class="badge badge-vip">VIP</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-all">Tất cả khách hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="time-cell">
                                        <div>Bắt đầu: <span class="time-start">${fn:replace(promo.startDate, 'T', ' ')}</span></div>
                                        <div>Kết thúc: <span class="time-end">${fn:replace(promo.endDate, 'T', ' ')}</span></div>
                                    </td>
                                    <td>
                                        <span class="status-badge ${promo.active ? 'status-active' : 'status-inactive'}">
                                                ${promo.active ? 'Hoạt động' : 'Tắt'}
                                        </span>
                                    </td>
                                    <td class="actions-col">
                                        <button type="button" class="btn-action" title="Chỉnh sửa"
                                                onclick="openEditPromotionModal(this)"
                                                data-id="${promo.id}"
                                                data-name="${promo.name}"
                                                data-description="${promo.description}"
                                                data-discounttype="${promo.discountType}"
                                                data-discountvalue="${promo.discountValue}"
                                                data-promotiontype="${promo.promotionType}"
                                                data-start="${promo.startDate}"
                                                data-end="${promo.endDate}"
                                                data-imageurl="${promo.imageUrl}">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <form action="${pageContext.request.contextPath}/admin/promotions" method="post" class="inline-form">
                                            <input type="hidden" name="action" value="togglePromotion">
                                            <input type="hidden" name="id" value="${promo.id}">
                                            <input type="hidden" name="active" value="${!promo.active}">
                                            <button type="submit" class="btn-action"
                                                    title="${promo.active ? 'Tắt khuyến mãi' : 'Bật khuyến mãi'}">
                                                <i class="fas ${promo.active ? 'fa-toggle-on' : 'fa-toggle-off'}"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty promotionList}">
                                <tr>
                                    <td colspan="7" class="empty-cell">
                                        Chưa có chương trình khuyến mãi nào.
                                    </td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- VOUCHER TAB -->
                <div id="voucherTab" class="tab-content tab-hidden">
                    <div class="table-header">
                        <div class="table-header__info">
                            <strong>Tổng cộng: ${voucherList.size()} voucher VIP</strong>
                        </div>
                        <button type="button" class="btn btn-create-voucher" onclick="openCreateVoucherModal()">
                            <i class="fas fa-plus"></i> Thêm voucher VIP
                        </button>
                    </div>

                    <div class="table-responsive">
                        <table class="orders-table promotions-table">
                            <thead>
                            <tr>
                                <th>Mã voucher</th>
                                <th>Loại</th>
                                <th>Giá trị</th>
                                <th>Lượt dùng</th>
                                <th>Thời gian</th>
                                <th>Trạng thái</th>
                                <th class="actions-col">Hành động</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="voucher" items="${voucherList}">
                                <tr>
                                    <td><strong>${voucher.code}</strong></td>
                                    <td>
                                        <c:if test="${voucher.discountType == 'PERCENT'}">
                                            <span class="badge badge-blue">Phần trăm</span>
                                        </c:if>
                                        <c:if test="${voucher.discountType == 'FIXED_AMOUNT'}">
                                            <span class="badge badge-orange">Tiền mặt</span>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:if test="${voucher.discountType == 'PERCENT'}">
                                            <strong>${voucher.discountValue}%</strong>
                                        </c:if>
                                        <c:if test="${voucher.discountType == 'FIXED_AMOUNT'}">
                                            <strong><fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>₫</strong>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${voucher.maxUses != null}">
                                                ${voucher.currentUses} / ${voucher.maxUses}
                                            </c:when>
                                            <c:otherwise>
                                                ${voucher.currentUses} / Không giới hạn
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="time-cell">
                                        <div>Start: <span class="time-start">${fn:replace(voucher.startDate, 'T', ' ')}</span></div>
                                        <div>End: <span class="time-end">${fn:replace(voucher.endDate, 'T', ' ')}</span></div>
                                    </td>
                                    <td>
                                        <span class="status-badge ${voucher.active ? 'status-active' : 'status-inactive'}">
                                                ${voucher.active ? 'Hoạt động' : 'Tắt'}
                                        </span>
                                    </td>
                                    <td class="actions-col">
                                        <button type="button" class="btn-action" title="Chỉnh sửa"
                                                onclick="openEditVoucherModal(this)"
                                                data-id="${voucher.id}"
                                                data-code="${voucher.code}"
                                                data-type="${voucher.discountType}"
                                                data-value="${voucher.discountValue}"
                                                data-maxuses="${voucher.maxUses}"
                                                data-start="${voucher.startDate}"
                                                data-end="${voucher.endDate}"
                                                data-active="${voucher.active}">
                                            <i class="fas fa-edit"></i>
                                        </button>

                                        <form action="${pageContext.request.contextPath}/admin/promotions" method="post"
                                              class="inline-form"
                                              onsubmit="return confirm('Bạn có chắc muốn xóa voucher này?');">
                                            <input type="hidden" name="action" value="deleteVoucher">
                                            <input type="hidden" name="id" value="${voucher.id}">
                                            <button type="submit" class="btn-action btn-action-danger" title="Xóa">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty voucherList}">
                                <tr>
                                    <td colspan="7" class="empty-cell">
                                        Chưa có voucher VIP nào.
                                    </td>
                                </tr>
                            </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- MODAL CREATE/EDIT PROMOTION -->
            <div id="promotionModal" class="modal modal-hidden">
                <div class="modal-overlay" onclick="closePromotionModal()"></div>
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 id="promotionModalTitle">Thêm khuyến mãi</h3>
                        <button type="button" class="modal-close" onclick="closePromotionModal()">&times;</button>
                    </div>

                    <div class="modal-body">
                        <form id="promotionForm" action="${pageContext.request.contextPath}/admin/promotions" method="post">
                            <input type="hidden" name="action" id="promotionAction" value="createPromotion">
                            <input type="hidden" name="id" id="promotionId">

                            <div class="form-grid-layout">
                                <div class="form-group">
                                    <label>Tên chương trình</label>
                                    <input type="text" class="form-control" name="name" id="promotionName" required>
                                </div>

                                <div class="form-group">
                                    <label>Đối tượng</label>
                                    <select class="form-control" name="promotionType" id="promotionType" required>
                                        <option value="ALL">Tất cả khách hàng</option>
                                        <option value="VIP">Khách hàng VIP</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Loại giảm giá</label>
                                    <select class="form-control" name="discountType" id="promotionDiscountType" required>
                                        <option value="PERCENT">Phần trăm (%)</option>
                                        <option value="FIXED_AMOUNT">Tiền mặt (₫)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Giá trị giảm</label>
                                    <input type="number" step="0.01" class="form-control" name="discountValue" id="promotionDiscountValue" required>
                                </div>

                                <div class="form-group">
                                    <label>Ngày bắt đầu</label>
                                    <input type="datetime-local" class="form-control" name="startDate" id="promotionStartDate" required>
                                </div>

                                <div class="form-group">
                                    <label>Ngày kết thúc</label>
                                    <input type="datetime-local" class="form-control" name="endDate" id="promotionEndDate" required>
                                </div>

                                <div class="form-group full-width">
                                    <label>Mô tả</label>
                                    <textarea class="form-control" name="description" id="promotionDescription" rows="4"></textarea>
                                </div>

                                <div class="form-group full-width">
                                    <label>Ảnh banner / ảnh chương trình</label>
                                    <input type="text" class="form-control" name="imageUrl" id="promotionImageUrl"
                                           placeholder="vd: assets/images/promo/banner1.jpg">
                                </div>
                            </div>

                            <div class="form-actions">
                                <button type="button" class="btn btn-cancel" onclick="closePromotionModal()">Hủy</button>
                                <button type="submit" class="btn btn-save-promotion">Lưu khuyến mãi</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- MODAL CREATE/EDIT VOUCHER -->
            <div id="voucherModal" class="modal modal-hidden">
                <div class="modal-overlay" onclick="closeVoucherModal()"></div>
                <div class="modal-content">
                    <div class="modal-header">
                        <h3 id="voucherModalTitle">Thêm voucher VIP</h3>
                        <button type="button" class="modal-close" onclick="closeVoucherModal()">&times;</button>
                    </div>

                    <div class="modal-body">
                        <form id="voucherForm" action="${pageContext.request.contextPath}/admin/promotions" method="post">
                            <input type="hidden" name="action" id="voucherAction" value="createVoucher">
                            <input type="hidden" name="id" id="voucherId">

                            <div class="form-grid-layout">
                                <div class="form-group">
                                    <label>Mã voucher</label>
                                    <input type="text" class="form-control" name="code" id="voucherCode" required>
                                </div>

                                <div class="form-group">
                                    <label>Loại giảm giá</label>
                                    <select class="form-control" name="discountType" id="voucherDiscountType" required>
                                        <option value="PERCENT">Phần trăm (%)</option>
                                        <option value="FIXED_AMOUNT">Tiền mặt (₫)</option>
                                    </select>
                                </div>

                                <div class="form-group">
                                    <label>Giá trị giảm</label>
                                    <input type="number" step="0.01" class="form-control" name="discountValue" id="voucherDiscountValue" required>
                                </div>

                                <div class="form-group">
                                    <label>Số lượt dùng tối đa</label>
                                    <input type="number" class="form-control" name="maxUses" id="voucherMaxUses"
                                           placeholder="Để trống nếu không giới hạn">
                                </div>

                                <div class="form-group">
                                    <label>Ngày bắt đầu</label>
                                    <input type="datetime-local" class="form-control" name="startDate" id="voucherStartDate" required>
                                </div>

                                <div class="form-group">
                                    <label>Ngày kết thúc</label>
                                    <input type="datetime-local" class="form-control" name="endDate" id="voucherEndDate" required>
                                </div>

                                <div class="form-group full-width active-checkbox-wrap" id="voucherActiveWrap">
                                    <label class="checkbox-inline">
                                        <input type="checkbox" name="active" id="voucherActive">
                                        <span>Voucher đang hoạt động</span>
                                    </label>
                                </div>
                            </div>

                            <div class="form-actions">
                                <button type="button" class="btn btn-cancel" onclick="closeVoucherModal()">Hủy</button>
                                <button type="submit" class="btn btn-save-voucher">Lưu voucher</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>

<script>
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.classList.remove('active');
                tab.classList.add('tab-hidden');
            });

            this.classList.add('active');
            const tab = document.getElementById(this.dataset.tab);
            tab.classList.add('active');
            tab.classList.remove('tab-hidden');
        });
    });

    function openCreatePromotionModal() {
        document.getElementById('promotionModalTitle').innerText = 'Thêm khuyến mãi';
        document.getElementById('promotionAction').value = 'createPromotion';
        document.getElementById('promotionForm').reset();
        document.getElementById('promotionId').value = '';
        document.getElementById('promotionModal').classList.remove('modal-hidden');
    }

    function openEditPromotionModal(btn) {
        document.getElementById('promotionModalTitle').innerText = 'Cập nhật khuyến mãi';
        document.getElementById('promotionAction').value = 'updatePromotion';

        document.getElementById('promotionId').value = btn.dataset.id;
        document.getElementById('promotionName').value = btn.dataset.name || '';
        document.getElementById('promotionDescription').value = btn.dataset.description || '';
        document.getElementById('promotionDiscountType').value = btn.dataset.discounttype || 'PERCENT';
        document.getElementById('promotionDiscountValue').value = btn.dataset.discountvalue || '';
        document.getElementById('promotionType').value = btn.dataset.promotiontype || 'ALL';
        document.getElementById('promotionImageUrl').value = btn.dataset.imageurl || '';
        document.getElementById('promotionStartDate').value = convertToDateTimeLocal(btn.dataset.start);
        document.getElementById('promotionEndDate').value = convertToDateTimeLocal(btn.dataset.end);

        document.getElementById('promotionModal').classList.remove('modal-hidden');
    }

    function closePromotionModal() {
        document.getElementById('promotionModal').classList.add('modal-hidden');
    }

    function openCreateVoucherModal() {
        document.getElementById('voucherModalTitle').innerText = 'Thêm voucher VIP';
        document.getElementById('voucherAction').value = 'createVoucher';
        document.getElementById('voucherForm').reset();
        document.getElementById('voucherId').value = '';
        document.getElementById('voucherActiveWrap').classList.add('hidden');
        document.getElementById('voucherModal').classList.remove('modal-hidden');
    }

    function openEditVoucherModal(btn) {
        document.getElementById('voucherModalTitle').innerText = 'Cập nhật voucher VIP';
        document.getElementById('voucherAction').value = 'updateVoucher';

        document.getElementById('voucherId').value = btn.dataset.id;
        document.getElementById('voucherCode').value = btn.dataset.code || '';
        document.getElementById('voucherDiscountType').value = btn.dataset.type || 'PERCENT';
        document.getElementById('voucherDiscountValue').value = btn.dataset.value || '';
        document.getElementById('voucherMaxUses').value = (btn.dataset.maxuses === 'null' ? '' : btn.dataset.maxuses) || '';
        document.getElementById('voucherStartDate').value = convertToDateTimeLocal(btn.dataset.start);
        document.getElementById('voucherEndDate').value = convertToDateTimeLocal(btn.dataset.end);

        document.getElementById('voucherActiveWrap').classList.remove('hidden');
        document.getElementById('voucherActive').checked = (btn.dataset.active === 'true');

        document.getElementById('voucherModal').classList.remove('modal-hidden');
    }

    function closeVoucherModal() {
        document.getElementById('voucherModal').classList.add('modal-hidden');
    }

    function convertToDateTimeLocal(value) {
        if (!value) return '';
        return value.replace(' ', 'T').substring(0, 16);
    }
</script>
</body>
</html>