<%--
  Created by IntelliJ IDEA.
  User: Hi
  Date: 04/06/2026
  Time: 11:46 CH
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hoàn thiện thông tin - Mộc Trà</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/update-profile.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>

<div class="update-container">
    <div class="update-title">HOÀN THIỆN THÔNG TIN ĐẶT HÀNG</div>

    <form action="${pageContext.request.contextPath}/auth/update-profile" method="POST">
        <input type="hidden" name="username" value="${sessionScope.pending_update_user}">
        <input type="hidden" name="phoneFromSession" value="${sessionScope.temp_phone}">
        <div class="section-title">Thông tin cơ bản</div>
        <div class="grid-row">
            <div class="form-group">
                <label>Họ và tên đệm *</label>
                <input type="text" name="lastName" class="form-control" placeholder="Ví dụ: Trần Lê Công" required>
            </div>
            <div class="form-group">
                <label>Tên *</label>
                <input type="text" name="firstName" class="form-control" placeholder="Ví dụ: Hiếu" required>
            </div>
        </div>
        <div class="form-group">
            <label>Email liên hệ *</label>
            <input type="email" name="email" class="form-control" placeholder="abc@gmail.com" required>
        </div>
        <div class="section-title">Địa chỉ nhận hàng mặc định</div>

        <div class="form-group">
            <label>Tỉnh / Thành phố *</label>
            <select id="reg_province" name="province" class="form-control" required>
                <option value="">-- Chọn Tỉnh / Thành phố --</option>
            </select>
        </div>

        <div class="grid-row">
            <div class="form-group">
                <label>Quận / Huyện *</label>
                <select id="reg_district" name="district" class="form-control" required>
                    <option value="">-- Chọn Quận / Huyện --</option>
                </select>
            </div>
            <div class="form-group">
                <label>Phường / Xã *</label>
                <select id="reg_ward" name="ward" class="form-control" required>
                    <option value="">-- Chọn Phường / Xã --</option>
                </select>
            </div>
        </div>
        <input type="hidden" id="reg_districtId" name="districtId">
        <input type="hidden" id="reg_wardCode" name="wardCode">

        <div class="form-group">
            <label>Địa chỉ cụ thể (Số nhà, tên đường...) *</label>
            <input type="text" name="addressDetail" class="form-control" placeholder="Ví dụ: Số 23, Đường số 7" required>
        </div>

        <div class="form-group">
            <label>Gắn nhãn địa chỉ</label>
            <input type="text" name="addressLabel" class="form-control" placeholder="Ví dụ: Nhà riêng, Văn phòng">
        </div>

        <button type="submit" class="btn-update">XÁC NHẬN & ĐĂNG NHẬP</button>
    </form>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/ghn-address-selector.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        GHNAddressSelector.init({
            provinceEl:   document.getElementById('reg_province'),
            districtEl:   document.getElementById('reg_district'),
            wardEl:       document.getElementById('reg_ward'),
            districtIdEl: document.getElementById('reg_districtId'),
            wardCodeEl:   document.getElementById('reg_wardCode'),
            contextPath:  '${pageContext.request.contextPath}'
        });
    });
</script>
</body>
</html>
