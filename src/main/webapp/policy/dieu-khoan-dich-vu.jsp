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
            <h1>Điều Khoản Dịch Vụ</h1>
            <p class="policy-intro">Vui lòng đọc kỹ các điều khoản và điều kiện sau đây trước khi sử dụng dịch vụ của chúng tôi.</p>
        </div>

        <div class="policy-section">
            <div class="policy-item">
                <h2><i class="fas fa-file-contract"></i>Điều Khoản Chung</h2>
                <div class="policy-content">
                    <p>Bằng việc sử dụng dịch vụ của Mộc Trà, bạn đồng ý với các điều khoản sau:</p>
                    <ul>
                        <li>Tuân thủ mọi quy định và điều khoản được nêu ra</li>
                        <li>Cung cấp thông tin chính xác khi đặt hàng</li>
                        <li>Thanh toán đầy đủ theo thỏa thuận</li>
                        <li>Không sử dụng dịch vụ cho mục đích bất hợp pháp</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-shopping-cart"></i>Điều Khoản Mua Hàng</h2>
                <div class="policy-content">
                    <p>Quy định về việc mua hàng và sử dụng sản phẩm:</p>
                    <ul>
                        <li>Giá cả có thể thay đổi mà không cần báo trước</li>
                        <li>Đặt hàng được xác nhận khi thanh toán thành công</li>
                        <li>Sản phẩm có thể hết hàng mà không báo trước</li>
                        <li>Khách hàng có trách nhiệm kiểm tra sản phẩm khi nhận hàng</li>
                        <li>Mọi tranh chấp sẽ được giải quyết theo quy định pháp luật</li>
                    </ul>
                </div>
            </div>

            <div class="policy-item">
                <h2><i class="fas fa-user-shield"></i>Quyền Và Trách Nhiệm</h2>
                <div class="policy-content">
                    <p>Quyền và trách nhiệm của cả hai bên:</p>
                    <ul>
                        <li>Mộc Trà cam kết cung cấp sản phẩm chất lượng</li>
                        <li>Khách hàng có quyền khiếu nại khi sản phẩm không đạt chất lượng</li>
                        <li>Bảo mật thông tin cá nhân của khách hàng</li>
                        <li>Từ chối phục vụ trong trường hợp vi phạm điều khoản</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="policy-footer"></div>
        <p><em>Điều khoản dịch vụ có hiệu lực từ ngày 01/01/2025 và có thể được cập nhật theo thời gian. Liên hệ hotline: 0888 531 015 để được hỗ trợ.</em></p>
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