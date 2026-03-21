git<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
            <h1>Chính Sách Thanh Toán</h1>
            <p class="policy-intro">Chúng tôi cung cấp nhiều phương thức thanh toán linh hoạt và an toàn để mang đến sự thuận tiện tối đa cho khách hàng.</p>
        </div>

        <div class="policy-section">
            <div class="policy-item">
                <h2><i class="fas fa-credit-card"></i>Các Phương Thức Thanh Toán</h2>
                <div class="policy-content">
                    <p>Chúng tôi chấp nhận các phương thức thanh toán sau:</p>
                    <ul>
                        <li>Thanh toán khi nhận hàng (COD)</li>
                        <li>Chuyển khoản ngân hàng</li>
                        <li>Thanh toán qua ví điện tử (MoMo, ZaloPay, ShopeePay)</li>
                        <li>Thanh toán bằng thẻ tín dụng/ghi nợ</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-shield-alt"></i>Bảo Mật Thanh Toán</h2>
                <div class="policy-content">
                    <p>Thông tin thanh toán của khách hàng được bảo vệ bằng công nghệ mã hóa SSL 256-bit tiêu chuẩn quốc tế.</p>
                    <ul>
                        <li>Không lưu trữ thông tin thẻ tín dụng trên hệ thống</li>
                        <li>Xử lý thanh toán qua các cổng thanh toán uy tín</li>
                        <li>Cam kết bảo mật tuyệt đối thông tin cá nhân</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-clock"></i>Thời Gian Xử Lý</h2>
                <div class="policy-content">
                    <p>Đơn hàng sẽ được xử lý trong thời gian sớm nhất sau khi thanh toán thành công:</p>
                    <ul>
                        <li>Thanh toán online: Xử lý ngay sau khi nhận được xác nhận</li>
                        <li>Chuyển khoản: Xử lý trong vòng 24h sau khi nhận được tiền</li>
                        <li>COD: Xử lý sau khi xác nhận đơn hàng qua điện thoại</li>
                    </ul>
                </div>
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