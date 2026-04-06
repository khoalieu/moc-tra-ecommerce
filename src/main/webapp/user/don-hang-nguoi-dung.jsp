<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %> <%-- Thêm thư viện Function --%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Gần Đây - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" />
    <style>
        .alert {
            padding: 15px;
            margin: 15px 0;
            border: 1px solid transparent;
            border-radius: 4px;
            font-family: Arial, sans-serif;
        }
        .alert-success {
            color: #155724;
            background-color: #d4edda;
            border-color: #c3e6cb;
        }
        .alert-danger {
            color: #721c24;
            background-color: #f8d7da;
            border-color: #f5c6cb;
        }
        .modal-overlay {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 2000; justify-content: center; align-items: center;
        }
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.4); /* Làm tối nền mịn hơn */
            backdrop-filter: blur(4px);    /* Hiệu ứng làm mờ nền phía sau */
            z-index: 2000;
            justify-content: center;
            align-items: center;
            transition: all 0.3s ease;
        }

        .modal-overlay.active {
            display: flex;
            animation: fadeIn 0.3s ease;
        }

        .modal-content {
            background: #fff;
            padding: 0; /* Để header có màu riêng */
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
            overflow: hidden;
            animation: slideDown 0.4s ease;
        }

        /* Header Modal */
        .modal-header {
            background: #f8f9fa;
            padding: 16px 24px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 1.25rem;
            color: #333;
            font-weight: 600;
        }

        .close-modal {
            font-size: 24px;
            color: #999;
            cursor: pointer;
            transition: color 0.2s;
        }

        .close-modal:hover {
            color: #d32f2f;
        }
        
        .modal-body {
            padding: 24px;
        }

        .radio-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .radio-label {
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            padding: 12px 15px;
            border: 1px solid #eee;
            border-radius: 8px;
            transition: all 0.2s ease;
        }

        .radio-label:hover {
            background-color: #f1f8e9;
            border-color: #8bc34a;
        }

        .radio-label input[type="radio"] {
            width: 18px;
            height: 18px;
            accent-color: #4caf50;
        }

        #otherReasonInput {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 8px;
            margin-top: 10px;
            resize: none;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        #otherReasonInput:focus {
            border-color: #4caf50;
            outline: none;
            box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);
        }
        .modal-footer {
            padding: 16px 24px;
            background: #f8f9fa;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            border: none;
            transition: opacity 0.2s;
        }

        .btn-secondary { background: #e0e0e0; color: #333; }
        .btn-danger { background: #d32f2f; color: #fff; }
        .btn:hover { opacity: 0.9; }
    </style>
</head>
<body class="user-dashboard-page">
<jsp:include page="/common/header.jsp"></jsp:include>
<div class="container">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="don-hang"/>
    </jsp:include>

    <main class="main-content">
        <c:if test="${not empty sessionScope.msg}">
            <div class="alert alert-${sessionScope.msgType}">
                    ${sessionScope.msg}
            </div>
            <% session.removeAttribute("msg"); session.removeAttribute("msgType"); %>
        </c:if>
        <div class="orders-header">
            <h2 class="page-title" style="margin-bottom: 0;">Đơn Hàng Gần Đây</h2>
            <div class="orders-filter">
                <button class="filter-btn active" data-status="all">Tất cả</button>
                <button class="filter-btn" data-status="pending">Chờ xử lý</button>
                <button class="filter-btn" data-status="completed">Hoàn thành</button>
                <button class="filter-btn" data-status="cancelled">Đã hủy</button>
            </div>
        </div>

        <div class="orders-list">
            <%-- KIỂM TRA DỮ LIỆU --%>
            <c:if test="${not empty orders}">
                <c:forEach var="o" items="${orders}">

                    <%-- 1. XỬ LÝ TRẠNG THÁI (So sánh với ENUM CHỮ HOA) --%>
                    <c:set var="statusStr" value="${o.status.toString()}" />
                    <c:set var="statusClass" value="status-pending" />
                    <c:set var="statusText" value="Chờ xử lý" />

                    <c:choose>
                        <c:when test="${statusStr == 'COMPLETED'}">
                            <c:set var="statusClass" value="status-completed" />
                            <c:set var="statusText" value="Hoàn thành" />
                        </c:when>
                        <c:when test="${statusStr == 'CANCELLED'}">
                            <c:set var="statusClass" value="status-cancelled" />
                            <c:set var="statusText" value="Đã hủy" />
                        </c:when>
                    </c:choose>

                    <%-- 2. RENDER CARD (Chuyển status về chữ thường cho Javascript filter) --%>
                    <div class="order-card" data-status="${fn:toLowerCase(statusStr)}">
                        <div class="order-card-header">
                            <div>
                                <div class="order-number">Đơn hàng #${o.orderNumber}</div>
                                <div class="order-date">
                                    <i class="fa-regular fa-calendar"></i>
                                        <%-- Format Date (Chỉ chạy được nếu model là Timestamp/Date) --%>
                                    <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy, HH:mm"/>
                                </div>
                            </div>
                            <div class="order-status">
                                <span class="status-badge ${statusClass}">${statusText}</span>

                                    <%-- Xử lý trạng thái thanh toán --%>
                                <c:choose>
                                    <c:when test="${o.paymentStatus.toString() == 'PAID'}">
                                        <span class="status-badge payment-paid">Đã thanh toán</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge payment-pending">Chưa thanh toán</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="order-card-body">
                            <div class="order-items">
                                <c:forEach var="item" items="${o.items}">
                                    <div class="order-item">
                                            <%-- Xử lý ảnh lỗi --%>
                                        <img src="${item.product.imageUrl}" alt="${item.product.name}"
                                             class="item-image" onerror="this.src='${pageContext.request.contextPath}/assets/images/no-image.png'">
                                        <div class="item-details">
                                            <div class="item-name">${item.product.name}</div>
                                            <div class="item-quantity">Số lượng: ${item.quantity}</div>
                                            <div class="item-price">
                                                <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="order-summary">
                                <div class="summary-row">
                                    <span>Tạm tính:</span>
                                    <span><fmt:formatNumber value="${o.totalAmount - o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                                <div class="summary-row">
                                    <span>Phí vận chuyển:</span>
                                    <span><fmt:formatNumber value="${o.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                                <div class="summary-row">
                                    <span>Tổng cộng:</span>
                                    <span style="font-weight: bold; color: #d32f2f;">
                                        <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                            </div>

                            <div class="shipping-address">
                                <strong><i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng:</strong><br>
                                    <%-- Hiển thị ghi chú địa chỉ từ DAO --%>
                                    ${o.notes}
                            </div>

                            <div class="order-footer">
                                <div style="font-size: 13px; color: #666;">
                                    <i class="fa-solid fa-credit-card"></i> Thanh toán:
                                    <strong>${o.paymentMethod == 'cod' ? 'Thanh toán khi nhận hàng (COD)' : o.paymentMethod}</strong>
                                </div>
                                <div class="order-actions">
                                    <a href="${pageContext.request.contextPath}/hoa-don?id=${o.id}" class="btn-action btn-outline">
                                        <i class="fa-solid fa-eye"></i> Chi tiết
                                    </a>

                                    <c:if test="${statusStr == 'PENDING'}">
                                        <form action="${pageContext.request.contextPath}/cancel-order" method="post" style="display:inline;" onsubmit="return confirm('Bạn có chắc muốn hủy đơn này?');">
                                            <input type="hidden" name="orderId" value="${o.id}">
                                            <button type="button" class="btn-action btn-secondary" onclick="openCancelModal(${o.id})">
                                                <i class="fa-solid fa-times"></i> Hủy đơn
                                            </button>
                                        </form>
                                    </c:if>

                                    <c:if test="${statusStr == 'COMPLETED' || statusStr == 'CANCELLED'}">
                                        <a href="${pageContext.request.contextPath}/san-pham" class="btn-action btn-primary">
                                            <i class="fa-solid fa-rotate"></i> Mua lại
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
        </div>

        <%-- Empty State --%>
        <div class="empty-state" style="display: ${empty orders ? 'flex' : 'none'}; flex-direction: column; align-items: center; padding: 40px; text-align: center;">
            <i class="fa-solid fa-cart-shopping" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
            <h3>Chưa có đơn hàng nào</h3>
            <p style="color: #666; margin-bottom: 20px;">Bạn chưa có đơn hàng nào. Hãy bắt đầu mua sắm ngay!</p>
            <a href="${pageContext.request.contextPath}/san-pham" class="btn-action btn-primary" style="text-decoration: none; padding: 10px 20px;">
                <i class="fa-solid fa-shopping-bag"></i> Mua sắm ngay
            </a>
        </div>
        <div id="cancelModal" class="modal-overlay">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Lý do hủy đơn hàng</h3>
                    <span class="close-modal" onclick="closeCancelModal()">&times;</span>
                </div>
                <form action="${pageContext.request.contextPath}/cancel-order" method="post">
                    <input type="hidden" name="orderId" id="modalOrderId">
                    <div class="radio-group">
                        <label class="radio-label">
                            <input type="radio" name="reasonOpt" value="Đổi ý, không muốn mua nữa" checked onchange="toggleReasonInput(false)">
                            <span>Đổi ý, không muốn mua nữa</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="reasonOpt" value="Tìm thấy giá rẻ hơn ở nơi khác" onchange="toggleReasonInput(false)">
                            <span>Tìm thấy giá rẻ hơn ở nơi khác</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="reasonOpt" value="Thời gian giao hàng quá lâu" onchange="toggleReasonInput(false)">
                            <span>Thời gian giao hàng quá lâu</span>
                        </label>
                        <label class="radio-label">
                            <input type="radio" name="reasonOpt" value="other" onchange="toggleReasonInput(true)">
                            <span>Lựa chọn khác</span>
                        </label>
                    </div>

                    <div id="otherReasonWrapper" style="display: none; margin-top: 15px;">
                        <textarea name="otherReason" id="otherReasonInput" class="form-input full-width" placeholder="Nhập lý do cụ thể..."></textarea>
                    </div>
                    <input type="hidden" name="cancelReason" id="finalReason">

                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" onclick="closeCancelModal()">Đóng</button>
                        <button type="submit" class="btn btn-danger" onclick="prepareSubmit(event)">Xác nhận hủy</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const filterBtns = document.querySelectorAll(".filter-btn");
        const orderCards = document.querySelectorAll(".order-card");

        filterBtns.forEach(btn => {
            btn.addEventListener("click", () => {
                filterBtns.forEach(b => b.classList.remove("active"));
                btn.classList.add("active");
                const status = btn.getAttribute("data-status");
                orderCards.forEach(card => {
                    if (status === "all" || card.getAttribute("data-status") === status) {
                        card.style.display = "block";
                    } else {
                        card.style.display = "none";
                    }
                });
            });
        });
    });
    function openCancelModal(orderId) {
        document.getElementById('modalOrderId').value = orderId;
        document.getElementById('cancelModal').classList.add('active');
    }

    function closeCancelModal() {
        document.getElementById('cancelModal').classList.remove('active');
    }

    function toggleReasonInput(isOther) {
        document.getElementById('otherReasonWrapper').style.display = isOther ? 'block' : 'none';
    }

    function prepareSubmit(e) {
        const selectedOpt = document.querySelector('input[name="reasonOpt"]:checked').value;
        let finalReason = selectedOpt;

        if (selectedOpt === 'other') {
            finalReason = document.getElementById('otherReasonInput').value.trim();
            if (finalReason === "") {
                alert("Vui lòng nhập lý do cụ thể!");
                e.preventDefault();
                return;
            }
        }
        document.getElementById('finalReason').value = finalReason;
    }
</script>
</body>
</html>