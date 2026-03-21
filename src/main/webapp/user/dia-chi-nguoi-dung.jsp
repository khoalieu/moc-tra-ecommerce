<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saved Addresses - Mộc Trà</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" />

    <style>
        .btn-link-style {
            background: none;
            border: none;
            padding: 0;
            cursor: pointer;
            color: inherit;
            font: inherit;
        }
        .btn-delete {
            color: #ff4d4f;
        }
        .btn-delete:hover {
            opacity: 0.8;
        }
    </style>
</head>
<body class="user-dashboard-page">

<jsp:include page="/common/header.jsp"></jsp:include>

<div class="container">
    <jsp:include page="/common/user-sidebar.jsp">
        <jsp:param name="activePage" value="dia-chi"/>
    </jsp:include>

    <main class="main-content">
        <h2 class="page-title">Địa chỉ</h2>

        <div class="saved-address-layout">

            <section class="saved-address-left">
                <h3 class="section-subtitle">Địa chỉ đã lưu</h3>
                <p class="address-hint">
                    Chọn một địa chỉ làm <strong>mặc định</strong>. Địa chỉ mặc định sẽ dùng ở trang thanh toán.
                </p>

                <div class="address-list" id="addressList">

                    <c:if test="${not empty addressList}">
                        <c:forEach items="${addressList}" var="addr">

                            <div class="address-card ${addr.isDefault ? 'default' : ''}">

                                <c:if test="${addr.isDefault}">
                                    <span class="default-badge">Mặc định</span>
                                </c:if>

                                <div class="address-card-header">
                                    <div>
                                        <h4>${addr.label}</h4>
                                        <p><strong>${addr.fullName}</strong> · ${addr.phoneNumber}</p>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/dia-chi-nguoi-dung" method="post" class="address-default-toggle">
                                        <input type="hidden" name="action" value="set_default">
                                        <input type="hidden" name="defaultAddressId" value="${addr.id}">

                                        <input type="radio"
                                               name="radio_dummy"
                                            ${addr.isDefault ? 'checked' : ''}
                                               onchange="this.form.submit()"
                                               style="cursor: pointer;"
                                               title="Đặt làm mặc định">
                                        <span>Đặt mặc định</span>
                                    </form>
                                </div>

                                <p>${addr.streetAddress}, ${addr.ward}, ${addr.province}</p>

                                <div class="address-actions">
                                    <form action="${pageContext.request.contextPath}/dia-chi-nguoi-dung" method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${addr.id}">

                                        <button type="submit"
                                                class="btn-small btn-link-style btn-delete"
                                                title="Xóa địa chỉ này"
                                                onclick="return confirm('Bạn có chắc muốn xóa địa chỉ này?');">
                                            <i class="fa-solid fa-trash-can" aria-hidden="true"></i>
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:if>

                    <c:if test="${empty addressList}">
                        <div style="text-align: center; margin-top: 20px; color: #666;">
                            <i class="fa-regular fa-address-book" style="font-size: 2rem; margin-bottom: 10px;"></i>
                            <p>Bạn chưa lưu địa chỉ nào.</p>
                        </div>
                    </c:if>

                </div>
            </section>

            <section class="saved-address-right">
                <h3 class="section-subtitle">Thêm địa chỉ mới</h3>

                <form class="profile-form address-form" action="${pageContext.request.contextPath}/dia-chi-nguoi-dung" method="post">
                    <input type="hidden" name="action" value="add">

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text"
                                   id="fullName"
                                   name="fullName"
                                   placeholder=" "
                                   required>
                            <label for="fullName">Họ và tên*</label>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-group phone-group">
                            <div class="phone-prefix">
                                <span>+84</span>
                                <i class="fa-solid fa-chevron-down"></i>
                            </div>
                            <input type="tel"
                                   id="phoneNumber"
                                   name="phoneNumber"
                                   placeholder=" "
                                   pattern="[0-9]{9,11}"
                                   title="Số điện thoại phải từ 9-11 số"
                                   required>
                            <label for="phoneNumber">Số điện thoại*</label>
                        </div>
                    </div>

                    <div class="form-row form-row-2">
                        <div class="input-group">
                            <input type="text"
                                   id="province"
                                   name="province"
                                   placeholder=" "
                                   required>
                            <label for="province">Tỉnh / Thành phố</label>
                        </div>

                        <div class="input-group">
                            <input type="text"
                                   id="ward"
                                   name="ward"
                                   placeholder=" "
                                   required>
                            <label for="ward">Phường / Xã</label>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text"
                                   id="addressLine"
                                   name="addressLine"
                                   placeholder=" "
                                   required>
                            <label for="addressLine">Địa chỉ cụ thể (Số nhà, đường...)*</label>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="input-group">
                            <input type="text"
                                   id="addressLabel"
                                   name="addressLabel"
                                   list="label-suggestions"
                                   placeholder=" ">
                            <label for="addressLabel">Gắn nhãn (Nhà riêng, Văn phòng...)</label>

                            <datalist id="label-suggestions">
                                <option value="Nhà riêng">
                                <option value="Văn phòng">
                                <option value="Công ty">
                            </datalist>
                        </div>
                    </div>

                    <button type="submit" class="add-address-btn">
                        <i class="fa-solid fa-plus"></i>
                        Thêm địa chỉ
                    </button>
                </form>
            </section>
        </div>
    </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
    // Script nút Back to Top đơn giản
    const backToTopBtn = document.getElementById("backToTop");
    window.onscroll = function() {
        if (document.body.scrollTop > 200 || document.documentElement.scrollTop > 200) {
            backToTopBtn.style.display = "block";
        } else {
            backToTopBtn.style.display = "none";
        }
    };
    backToTopBtn.addEventListener("click", function() {
        window.scrollTo({top: 0, behavior: 'smooth'});
    });
</script>
</body>
</html>