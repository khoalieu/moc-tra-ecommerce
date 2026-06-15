<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liên Hệ - Mộc Trà</title>
    <base href="${pageContext.request.contextPath}/">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/contact.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>

<jsp:include page="/common/header.jsp"></jsp:include>

<div class="breadcrumb-area">
    <div class="container">
        <ul class="breadcrumb">
            <li><a href="${pageContext.request.contextPath}/">Trang chủ</a></li>
            <li>/</li>
            <li class="active">Liên hệ</li>
        </ul>
    </div>
</div>

<section class="contact-section">
    <div class="container">
        <div class="contact-header">
            <h1>LIÊN HỆ VỚI CHÚNG TÔI</h1>
            <p>Nếu bạn có bất kỳ câu hỏi, thắc mắc hay góp ý nào, vui lòng điền thông tin vào form bên dưới hoặc liên hệ qua các kênh hỗ trợ của chúng tôi. Chúng tôi sẽ phản hồi sớm nhất có thể.</p>
        </div>

        <c:if test="${not empty sessionScope.flashMsg}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${sessionScope.flashMsg}
            </div>
            <c:remove var="flashMsg" scope="session" />
        </c:if>

        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle"></i> ${sessionScope.errorMsg}
            </div>
            <c:remove var="errorMsg" scope="session" />
        </c:if>

        <div class="contact-content">
            <div class="contact-info">
                <div class="info-item">
                    <div class="icon"><i class="fas fa-map-marker-alt"></i></div>
                    <div class="details">
                        <h3>Địa chỉ</h3>
                        <p>123 Đường Mộc Trà, Quận 1, TP. Hồ Chí Minh</p>
                    </div>
                </div>
                <div class="info-item">
                    <div class="icon"><i class="fas fa-phone-alt"></i></div>
                    <div class="details">
                        <h3>Điện thoại</h3>
                        <p>0888 531 015</p>
                    </div>
                </div>
                <div class="info-item">
                    <div class="icon"><i class="fas fa-envelope"></i></div>
                    <div class="details">
                        <h3>Email</h3>
                        <p>contact@moctra.com</p>
                    </div>
                </div>
                <div class="info-item">
                    <div class="icon"><i class="fas fa-clock"></i></div>
                    <div class="details">
                        <h3>Giờ làm việc</h3>
                        <p>Thứ 2 - Thứ 7: 8:00 - 18:00<br>Chủ Nhật: Nghỉ</p>
                    </div>
                </div>

                <div class="map-container">
                    <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3919.4920275825316!2d106.69670231533423!3d10.77357499232338!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752f40b2a7522d%3A0xe543e0d8b3762c95!2sBen%20Thanh%20Market!5e0!3m2!1sen!2s!4v1628154687593!5m2!1sen!2s" width="100%" height="250" style="border:0; border-radius: 8px;" allowfullscreen="" loading="lazy"></iframe>
                </div>
            </div>

            <div class="contact-form-wrapper">
                <h2>Gửi Tin Nhắn</h2>
                <form action="${pageContext.request.contextPath}/lien-he" method="POST" class="contact-form">
                    <div class="form-group">
                        <label for="name">Họ và tên <span class="required">*</span></label>
                        <input type="text" id="name" name="name" required placeholder="Nhập họ tên của bạn">
                    </div>
                    
                    <div class="form-group">
                        <label for="email">Email <span class="required">*</span></label>
                        <input type="email" id="email" name="email" required pattern="[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$" title="Vui lòng nhập định dạng email hợp lệ" placeholder="Nhập địa chỉ email của bạn">
                    </div>

                    <div class="form-group">
                        <label for="subject">Tiêu đề <span class="required">*</span></label>
                        <input type="text" id="subject" name="subject" required placeholder="Chủ đề bạn muốn liên hệ">
                    </div>

                    <div class="form-group">
                        <label for="message">Nội dung <span class="required">*</span></label>
                        <textarea id="message" name="message" rows="5" required placeholder="Nhập nội dung chi tiết..."></textarea>
                    </div>

                    <button type="submit" class="btn-submit">
                        <i class="fas fa-paper-plane"></i> Gửi Liên Hệ
                    </button>
                </form>
            </div>
        </div>
    </div>
</section>

<jsp:include page="/common/footer.jsp"></jsp:include>

</body>
</html>
