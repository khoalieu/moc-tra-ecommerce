<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Tin Người Dùng - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body class="user-dashboard-page">
<jsp:include page="/common/header.jsp"></jsp:include>
<div class="container">

    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="tong-quan"/>
    </jsp:include>

    <main class="main-content">
        <h2 class="page-title">Tổng quan</h2>

        <div class="dashboard-grid">

            <a href="${pageContext.request.contextPath}/thong-tin-nguoi-dung" class="grid-card">
                <i class="fa-regular fa-user"></i>
                <span>Tài khoản của tôi</span>
            </a>
            <a href="${pageContext.request.contextPath}/dia-chi-nguoi-dung" class="grid-card">
                <i class="fa-solid fa-location-dot"></i>
                <span>Địa chỉ</span>
            </a>

            <a href="${pageContext.request.contextPath}/don-hang-nguoi-dung" class="grid-card">
                <i class="fa-solid fa-cart-shopping"></i>
                <span>Đơn hàng của tôi</span>
            </a>
            <a href="${pageContext.request.contextPath}/san-pham-yeu-thich" class="grid-card">
                <i class="fa-solid fa-heart"></i>
                <span>Sản phẩm yêu thích</span>
            </a>
        </div>
    </main>

</div>
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
</body>
</html>