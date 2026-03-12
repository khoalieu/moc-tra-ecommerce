<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN"/>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Khách hàng - Mộc Trà Admin</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/components.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/assets/css/admin-customer-detail.css">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<div class="admin-container">

    <jsp:include page="/common/admin-sidebar.jsp">
        <jsp:param name="activePage" value="customers"/>
    </jsp:include>

    <main class="admin-main">
        <header class="admin-header">
            <div class="header-left">
                <h1>Chi tiết Khách hàng</h1>
            </div>

            <div class="header-right">
                <a href="${pageContext.request.contextPath}/index.jsp" class="view-site-btn" target="_blank">
                    <i class="fas fa-external-link-alt"></i>
                    <span>Xem trang web</span>
                </a>
            </div>
        </header>

        <div class="admin-content">

            <div class="customer-detail-header">
                <div class="customer-meta">
                    <div class="customer-avatar-large">
                        <c:choose>
                            <c:when test="${not empty customer.avatar}">
                                <img src="${pageContext.request.contextPath}/${customer.avatar}" alt="Avatar"
                                     style="width:100%; height:100%; border-radius:50%; object-fit:cover;">
                            </c:when>
                            <c:otherwise>
                                ${customer.username.substring(0, 2).toUpperCase()}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="customer-info-header">
                        <h2>${customer.lastName} ${customer.firstName}</h2>
                        <span><i class="fas fa-envelope"></i> ${customer.email}</span>
                        <span><i
                                class="fas fa-phone"></i> ${empty customer.phone ? 'Chưa cập nhật' : customer.phone}</span>

                        <c:if test="${totalSpent >= 5000000}">
                            <span style="color: #107e84; font-weight: 600; margin-left: 10px;">
                                <i class="fas fa-crown"></i> Khách hàng VIP
                            </span>
                        </c:if>
                    </div>
                </div>
                <div class="customer-actions-top">
                    <a href="${pageContext.request.contextPath}/admin/customers" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Quay lại
                    </a>

                    <a href="${pageContext.request.contextPath}/admin/customer/edit?id=${customer.id}"
                       class="btn btn-success">
                        <i class="fas fa-edit"></i> Chỉnh sửa
                    </a>

                    <button class="btn btn-danger" onclick="deleteCustomer(${customer.id})">
                        <i class="fas fa-trash"></i> Xóa
                    </button>
                </div>
            </div>

            <div class="detail-card full-width-card" style="margin-bottom: 30px;">
                <h3 class="card-title">
                    <i class="fas fa-chart-bar"></i> Thống kê tổng quan
                </h3>
                <div class="stats-grid">
                    <div class="stat-box">
                        <div class="stat-number">${totalOrders}</div>
                        <div class="stat-label">Tổng đơn hàng</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number">
                            <fmt:formatNumber value="${totalSpent}" type="currency" currencySymbol="₫"
                                              maxFractionDigits="0"/>
                        </div>
                        <div class="stat-label">Tổng chi tiêu</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number">
                            <fmt:formatNumber value="${avgOrderValue}" type="currency" currencySymbol="₫"
                                              maxFractionDigits="0"/>
                        </div>
                        <div class="stat-label">Giá trị TB/đơn</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-number" style="color: #ffc107;">
                            <fmt:formatNumber value="${avgRating}" maxFractionDigits="1" minFractionDigits="1"/>
                            <span style="font-size: 1.2rem;">⭐</span>
                        </div>
                        <div class="stat-label">Đánh giá TB</div>
                    </div>
                </div>
            </div>

            <div class="detail-grid">

                <div class="detail-card">
                    <h3 class="card-title"><i class="fas fa-user"></i> Thông tin cá nhân</h3>
                    <div class="info-row">
                        <span class="info-label">Tên đăng nhập:</span>
                        <span class="info-value">${customer.username}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Email:</span>
                        <span class="info-value">${customer.email}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Số điện thoại:</span>
                        <span class="info-value">${empty customer.phone ? '---' : customer.phone}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Họ tên:</span>
                        <span class="info-value">${customer.lastName} ${customer.firstName}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Ngày sinh:</span>
                        <span class="info-value">
                            <c:if test="${not empty customer.dateOfBirth}">
                                <fmt:parseDate value="${customer.dateOfBirth}" pattern="yyyy-MM-dd'T'HH:mm"
                                               var="parsedDate" type="both"/>
                                <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy"/>
                            </c:if>
                            <c:if test="${empty customer.dateOfBirth}">---</c:if>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Giới tính:</span>
                        <span class="info-value">${customer.gender}</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Vai trò:</span>
                        <span class="info-value"><span
                                class="status-badge status-confirmed">${customer.role}</span></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Trạng thái:</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${customer.isActive}"><span class="status-badge status-active">Đang hoạt động</span></c:when>
                                <c:otherwise><span class="status-badge status-cancelled">Đã khóa</span></c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="detail-card">
                    <h3 class="card-title"><i class="fas fa-info-circle"></i> Thông tin tài khoản</h3>
                    <div class="info-row">
                        <span class="info-label">Ngày đăng ký:</span>
                        <span class="info-value">
                            <c:if test="${not empty customer.createdAt}">
                                <fmt:parseDate value="${customer.createdAt}" pattern="yyyy-MM-dd'T'HH:mm"
                                               var="createDate" type="both"/>
                                <fmt:formatDate value="${createDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </c:if>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Thời gian hoạt động:</span>
                        <span class="info-value" style="color: #28a745;">${monthsActive} tháng</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Tần suất mua hàng:</span>
                        <span class="info-value">
                            <fmt:formatNumber value="${purchaseFrequency}" maxFractionDigits="1"/> đơn/tháng
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Số lượng đánh giá:</span>
                        <span class="info-value">${reviews.size()} đánh giá</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Số lượng bình luận:</span>
                        <span class="info-value">${commentCount} bình luận</span>
                    </div>
                </div>

                <div class="detail-card full-width-card">
                    <h3 class="card-title"><i class="fas fa-map-marker-alt"></i> Địa chỉ giao hàng (${addresses.size()}
                        địa chỉ)</h3>
                    <div class="addresses-list">
                        <c:if test="${empty addresses}"><p style="color:#666; padding:10px;">Chưa có địa chỉ
                            nào.</p></c:if>
                        <c:forEach var="addr" items="${addresses}">
                            <div class="address-item ${addr.isDefault ? 'default' : ''}">
                                <div class="address-label">
                                    <i class="fas fa-home"></i> ${addr.label}
                                    <c:if test="${addr.isDefault}"><span
                                            class="address-default-badge">Mặc định</span></c:if>
                                </div>
                                <div class="address-text">${addr.streetAddress}, ${addr.ward}, ${addr.province}</div>
                                <div class="address-contact"><i class="fas fa-user"></i> ${addr.fullName} | <i
                                        class="fas fa-phone"></i> ${addr.phoneNumber}</div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="detail-card full-width-card">
                    <h3 class="card-title"><i class="fas fa-shopping-cart"></i> Giỏ hàng hiện tại</h3>
                    <c:choose>
                        <c:when test="${not empty cartItems}">
                            <div class="cart-items-list">
                                <c:forEach var="item" items="${cartItems}">
                                    <div class="cart-item">
                                        <img src="${pageContext.request.contextPath}/${item.productImage}" alt="Product"
                                             class="cart-item-image">
                                        <div class="cart-item-info">
                                            <div class="cart-item-name">${item.productName}</div>
                                            <div class="cart-item-price">
                                                <fmt:formatNumber value="${item.price}" type="currency"
                                                                  currencySymbol="₫" maxFractionDigits="0"/>
                                            </div>
                                            <div class="cart-item-quantity">Số lượng: ${item.quantity}</div>
                                        </div>
                                        <div style="text-align: right;">
                                            <div style="font-weight: 600; color: #107e84; font-size: 16px;">
                                                <fmt:formatNumber value="${item.price * item.quantity}" type="currency"
                                                                  currencySymbol="₫" maxFractionDigits="0"/>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="cart-items-list">
                                <div style="padding: 20px; text-align: center; color: #888; background: #f9f9f9; border-radius: 8px;">
                                    <i class="fas fa-shopping-basket"
                                       style="font-size: 2rem; margin-bottom: 10px; color: #ccc;"></i>
                                    <p>Khách hàng hiện không có sản phẩm nào trong giỏ.</p>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="detail-card full-width-card">
                    <h3 class="card-title"><i class="fas fa-history"></i> Lịch sử đơn hàng (${orders.size()} đơn)</h3>
                    <div class="table-responsive">
                        <table class="orders-table">
                            <thead>
                            <tr>
                                <th>Mã đơn</th>
                                <th>Ngày đặt</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Thanh toán</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:if test="${empty orders}">
                                <tr>
                                    <td colspan="5" style="text-align:center; padding:15px;">Chưa có đơn hàng nào</td>
                                </tr>
                            </c:if>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td><span class="order-number">#${o.orderNumber}</span></td>
                                    <td>
                                        <fmt:parseDate value="${o.createdAt}" pattern="yyyy-MM-dd'T'HH:mm"
                                                       var="orderDate" type="both"/>
                                        <fmt:formatDate value="${orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td style="font-weight: 600; color: #107e84;">
                                        <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="₫"
                                                          maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <c:set var="st" value="${o.status}"/>
                                        <span class="status-badge ${st == 'COMPLETED' ? 'status-confirmed' : (st == 'CANCELLED' ? 'status-cancelled' : 'status-pending')}">${st}</span>
                                    </td>
                                    <td><span class="status-badge published">${o.paymentStatus}</span></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="detail-card full-width-card">
                    <h3 class="card-title">
                        <i class="fas fa-star"></i> Đánh giá sản phẩm (${reviews.size()} đánh giá)
                    </h3>
                    <div class="reviews-list">
                        <c:if test="${empty reviews}">
                            <p style="padding: 15px; color: #666; font-style: italic;">Khách hàng chưa có đánh giá
                                nào.</p>
                        </c:if>
                        <c:forEach var="r" items="${reviews}">
                            <div class="review-item">
                                <div class="review-product">
                                    <span><i class="fas fa-box"></i> ${r.productName}</span>
                                    <span class="review-rating" style="color: #ffc107;">
                                        <c:forEach begin="1" end="${r.rating}"><i
                                                class="fas fa-star"></i></c:forEach> (${r.rating}.0)
                                    </span>
                                </div>
                                <div class="review-text">${r.commentText}</div>
                                <div class="review-date">
                                    <i class="far fa-clock"></i>
                                    <fmt:parseDate value="${r.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="rDate"
                                                   type="both"/>
                                    <fmt:formatDate value="${rDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div class="detail-card full-width-card">
                    <h3 class="card-title">
                        <i class="fas fa-clock"></i> Hoạt động gần đây
                    </h3>
                    <div class="activity-timeline">
                        <c:if test="${empty activities}">
                            <p style="padding: 15px; color: #666; font-style: italic;">Chưa có hoạt động nào được ghi
                                nhận.</p>
                        </c:if>
                        <c:forEach var="act" items="${activities}">
                            <div class="activity-item">
                                <div class="activity-icon">
                                    <i class="fas ${act.icon}"></i>
                                </div>
                                <div class="activity-content">
                                    <div class="activity-title">${act.title}</div>
                                    <div class="activity-description">${act.description}</div>
                                    <div class="activity-time">
                                        <i class="far fa-clock"></i>
                                        <fmt:parseDate value="${act.time}" pattern="yyyy-MM-dd'T'HH:mm" var="actDate"
                                                       type="both"/>
                                        <fmt:formatDate value="${actDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

            </div>
        </div>
    </main>
</div>

<script>
    function editCustomer(id) {
        window.location.href = "${pageContext.request.contextPath}/admin/customer/edit?id=" + id;
    }

    function deleteCustomer(id) {
        if (confirm('CẢNH BÁO: Bạn có chắc muốn xóa khách hàng này? Hành động này không thể hoàn tác!')) {
            window.location.href = "${pageContext.request.contextPath}/admin/customer/delete?id=" + id;
        }
    }
</script>
</body>
</html>