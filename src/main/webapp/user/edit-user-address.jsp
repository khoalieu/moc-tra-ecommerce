<%--
  Created by IntelliJ IDEA.
  User: Hi
  Date: 30/05/2026
  Time: 8:30 CH
  To change this template use File | Settings | File Templates.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trà Thảo Mộc & Trà Sữa DIY</title>
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/edit-user-address.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<div class="container">
    <div class="profile-layout-container">
        <main class="address-edit-card">
            <div class="page-header-wrapper" >

                <a href="${pageContext.request.contextPath}/dia-chi-nguoi-dung" class="back-link" title="Quay lại">
                    <i class="fa-solid fa-arrow-left"></i>
                </a>

                <h2 class="page-title" >
                    Chỉnh sửa địa chỉ
                </h2>
            </div>

            <div class="address-form-wrapper">
                <form class="profile-form address-form" action="${pageContext.request.contextPath}/dia-chi-nguoi-dung" method="post">
                    <input type="hidden" name="action" value="edit">
                    <input type="hidden" name="addressId" value="${addressToEdit.id}">

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text" name="fullName" value="${addressToEdit.fullName}" required>
                            <label>Họ và tên*</label>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-group">
                            <input type="tel" name="phoneNumber" value="${addressToEdit.phoneNumber}" required>
                            <label>Số điện thoại*</label>
                        </div>
                    </div>

                    <div class="form-row" style="margin-bottom: 20px;">
                        <select id="edit_province" name="province" required></select>
                    </div>
                    <div class="form-row form-row-2" >
                        <select id="edit_district" name="district" required></select>
                        <select id="edit_ward" name="ward" required></select>
                    </div>

                    <input type="hidden" id="edit_districtId" name="districtId" value="${addressToEdit.districtId}">
                    <input type="hidden" id="edit_wardCode" name="wardCode" value="${addressToEdit.wardCode}">

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text" name="addressLine" value="${addressToEdit.streetAddress}" required>
                            <label>Địa chỉ cụ thể*</label>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text" name="addressLabel" value="${addressToEdit.label}">
                            <label>Gắn nhãn (Vd: Nhà riêng)</label>
                        </div>
                    </div>

                    <div >
                        <button type="submit" class="add-address-btn" >Lưu thay đổi</button>

                    </div>
                </form>
            </div>
        </main>

    </div>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script src="${pageContext.request.contextPath}/assets/js/ghn-address-selector.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        GHNAddressSelector.init({
            provinceEl:   document.getElementById('edit_province'),
            districtEl:   document.getElementById('edit_district'),
            wardEl:       document.getElementById('edit_ward'),
            districtIdEl: document.getElementById('edit_districtId'),
            wardCodeEl:   document.getElementById('edit_wardCode'),
            contextPath:  '${pageContext.request.contextPath}'
        });

        const selectOptionByText = (el, text) => {
            for (let option of el.options) {
                if (option.text === text) {
                    option.selected = true;
                    el.dispatchEvent(new Event('change'));
                    return true;
                }
            }
            return false;
        };

        setTimeout(() => {
            if (selectOptionByText(document.getElementById('edit_province'), "${addressToEdit.province}")) {
                setTimeout(() => {
                    if (selectOptionByText(document.getElementById('edit_district'), "${addressToEdit.district}")) {
                        setTimeout(() => {
                            selectOptionByText(document.getElementById('edit_ward'), "${addressToEdit.ward}");
                        }, 600);
                    }
                }, 600);
            }
        }, 800);
    });
</script>
</body>
</html>