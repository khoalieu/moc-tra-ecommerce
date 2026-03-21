<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trà Thảo Mộc & Trà Sữa DIY</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<section class="section-content">
    <div class="container">
        <div class="policy-header">
            <h1>Chính Sách Bán Hàng</h1>
            <p class="policy-intro">Chúng tôi cam kết mang đến cho khách hàng trải nghiệm mua sắm tốt nhất với các chính sách minh bạch và hỗ trợ tận tình.</p>
        </div>

        <div class="policy-section">
            <div class="policy-item">
                <h2><i class="fas fa-exchange-alt"></i>Chính Sách Đổi Trả</h2>
                <div class="policy-content">
                    <p>Chúng tôi chấp nhận đổi trả sản phẩm trong vòng 7 ngày kể từ ngày nhận hàng nếu sản phẩm bị lỗi do nhà sản xuất hoặc không đúng với mô tả trên website.</p>
                    <ul>
                        <li>Sản phẩm còn nguyên vẹn, chưa sử dụng</li>
                        <li>Có hóa đơn mua hàng và tem niêm phong</li>
                        <li>Liên hệ trước khi đổi trả qua hotline hoặc email</li>
                    </ul>
                </div>
            </div>
            <div class="policy-footer">
                <p><em>Chính sách có hiệu lực từ ngày 01/01/2025 và có thể được cập nhật theo thời gian.</em></p>
            </div>
        </div>
</section>
<!-- Footer -->
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script>
    window.addEventListener('scroll', function() {
        const backToTopButton = document.getElementById('backToTop');
        if (window.pageYOffset > 300) {
            backToTopButton.classList.add('show');
        } else {
            backToTopButton.classList.remove('show');
        }
    });
    document.getElementById('backToTop').addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
</script>
</body>
</html>