<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chỉnh sửa đơn hàng</title>
    <link rel="stylesheet" href="${ctx}/assets/css/main.css">
    <link rel="stylesheet" href="${ctx}/assets/css/my-orders.css">

</head>
<body>

<jsp:include page="/common/header.jsp"/>

<div class="container" style="display: flex; gap: 20px; padding: 20px;">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="don-hang"/>
    </jsp:include>

    <main class="main-content" style="flex: 1;">
        <c:if test="${not empty sessionScope.msg}">
            <div class="alert alert-${sessionScope.msgType}">
                    ${sessionScope.msg}
            </div>
            <c:remove var="msg" scope="session"/>
            <c:remove var="msgType" scope="session"/>
        </c:if>
        <form method="post" action="${ctx}/edit-user-order">
            <input type="hidden" name="action" value="update-quantity">
            <input type="hidden" name="orderId" value="${order.id}">
            <input type="hidden" name="changedItemId" id="changedItemId">
            <div class="order-card">
                <div class="order-card-header">
                    <div>
                        <h2>Chỉnh sửa đơn hàng #${order.orderNumber}</h2>
                    </div>
                </div>

                <div class="order-items">
                    <c:forEach var="item" items="${items}">
                        <div class="order-item">
                            <img src="${ctx}/${item.product.imageUrl}"
                                 class="item-image"
                                 alt="${item.product.name}"
                                 onerror="this.onerror=null;this.src='${ctx}/assets/images/no-image.png';">

                            <div class="item-details">
                                <div class="item-name">${item.product.name}</div>

                                <form method="post" action="${ctx}/edit-user-order" class="edit-quantity">
                                    <input type="hidden" name="action" value="update-quantity">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <input type="hidden" name="orderItemId" value="${item.id}">

                                    <span>Số lượng:</span>

                                    <input type="number"
                                           id="qty-${item.id}"
                                           name="newQuantity"
                                           value="${item.quantity}"
                                           min="1"
                                           class="qty-input"
                                           oninput="markChanged(${item.id}, this)">
                                </form>

                                <div class="item-price">
                                    <fmt:formatNumber value="${item.price * item.quantity}" type="currency" currencySymbol="đ"/>
                                </div>
                            </div>
                            <div class="item-actions">
                                <button type="button"
                                        class="btn-remove-item"
                                        onclick="removeItem(${item.id})">
                                    Xóa
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="order-footer">
                    <div style="display: flex; gap: 12px; align-items: center;">
                        <a href="${ctx}/don-hang" class="btn-action btn-back" style="text-decoration: none;">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>

                        <button type="submit"
                                id="btn-confirm-all"
                                class="btn-action btn-back"
                                style="display: none;">
                            Xác nhận thay đổi
                        </button>
                    </div>

                    <div class="order-summary">
                        <strong style="color: #666;">Tổng cộng:</strong>
                        <span class="total-price">
                        <fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ"/>
                    </span>
                    </div>
                </div>
            </div>
        </form>
    </main>
    <c:forEach var="item" items="${items}">
        <form id="form-inc-${item.id}" method="post" action="${ctx}/edit-user-order" style="display:none;">
            <input type="hidden" name="action" value="increase">
            <input type="hidden" name="orderId" value="${order.id}">
            <input type="hidden" name="orderItemId" value="${item.id}">
        </form>
        <form id="form-dec-${item.id}" method="post" action="${ctx}/edit-user-order" style="display:none;">
            <input type="hidden" name="action" value="decrease">
            <input type="hidden" name="orderId" value="${order.id}">
            <input type="hidden" name="orderItemId" value="${item.id}">
        </form>
    </c:forEach>
</div>

<jsp:include page="/common/footer.jsp"/>

<script>
    // Hàm này để hiện cái nút dưới footer
    function showGlobalConfirm() {
        const btn = document.getElementById('btn-confirm-all');
        if (btn) {
            btn.style.display = 'inline-block';
        }
    }

    function handleQtyChange(input, itemId, oldQty) {
        const newQty = parseInt(input.value);
        if (isNaN(newQty) || newQty < 1) {
            input.value = oldQty;
            return;
        }
        if (Math.abs(newQty - oldQty) === 1) {
            if (newQty > oldQty) {
                document.getElementById('form-inc-' + itemId).submit();
            } else {
                document.getElementById('form-dec-' + itemId).submit();
            }
        }
        else {
            showGlobalConfirm();
        }
    }
    function removeItem(itemId) {
        if (confirm('Xóa sản phẩm này?')) {
            const f = document.createElement('form');
            f.method = 'POST';
            f.action = '${ctx}/edit-user-order';
            f.innerHTML = `
            <input type="hidden" name="action" value="remove">
            <input type="hidden" name="orderId" value="${order.id}">
            <input type="hidden" name="orderItemId" value="` + itemId + `">
        `;
            document.body.appendChild(f);
            f.submit();
        }
    }
    function markChanged(itemId, input) {

        document.getElementById('changedItemId').value = itemId;

        const btn = document.getElementById('btn-confirm-all');

        if (btn) {
            btn.style.display = 'inline-flex';
        }
    }
</script>

</body>
</html>