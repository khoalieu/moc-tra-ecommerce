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
            <h1>Chính Sách Bảo Hành, Đổi Trả</h1>
            <p class="policy-intro">Chúng tôi cam kết mang đến sản phẩm chất lượng và dịch vụ hậu mãi tốt nhất để đảm bảo quyền lợi khách hàng.</p>
        </div>

        <div class="policy-section">
            <div class="policy-item">
                <h2><i class="fas fa-shield-alt"></i>Điều Kiện Bảo Hành</h2>
                <div class="policy-content">
                    <p>Sản phẩm được bảo hành khi:</p>
                    <ul>
                        <li>Sản phẩm còn nguyên vẹn, không bị hư hỏng do tác động bên ngoài</li>
                        <li>Có đầy đủ hóa đơn mua hàng và tem bảo hành (nếu có)</li>
                        <li>Sản phẩm trong thời gian bảo hành theo quy định</li>
                        <li>Lỗi do quá trình sản xuất, không phải do người dùng</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-exchange-alt"></i>Chính Sách Đổi Trả</h2>
                <div class="policy-content">
                    <p>Khách hàng có thể đổi trả sản phẩm trong các trường hợp sau:</p>
                    <ul>
                        <li>Đổi trả trong vòng 7 ngày kể từ ngày nhận hàng</li>
                        <li>Sản phẩm giao không đúng mô tả hoặc bị lỗi</li>
                        <li>Sản phẩm bị hư hỏng trong quá trình vận chuyển</li>
                        <li>Sản phẩm còn nguyên seal, chưa sử dụng (đối với thực phẩm)</li>
                        <li>Hoàn tiền 100% nếu không thể đổi sản phẩm tương đương</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-clock"></i>Thời Gian Bảo Hành</h2>
                <div class="policy-content">
                    <p>Thời gian bảo hành theo từng loại sản phẩm:</p>
                    <ul>
                        <li>Trà thảo mộc: Bảo hành chất lượng trong 12 tháng</li>
                        <li>Nguyên liệu trà sữa: Bảo hành 6 tháng kể từ ngày sản xuất</li>
                        <li>Dụng cụ pha chế: Bảo hành 24 tháng với lỗi kỹ thuật</li>
                        <li>Xử lý khiếu nại trong vòng 48h làm việc</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="policy-footer"></div>
        <p><em>Chính sách có hiệu lực từ ngày 01/01/2025 và có thể được cập nhật theo thời gian. Liên hệ hotline: 0888 531 015 để được hỗ trợ.</em></p>
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