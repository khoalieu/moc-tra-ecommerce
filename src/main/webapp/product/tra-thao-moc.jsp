<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Trà Thảo Mộc | Về Chúng Tôi</title>

    <meta name="description" content="Khám phá Trà Thảo Mộc" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css" />
    <link href="https://fonts.googleapis.com/css2?family=Dancing+Script:wght@400;600&display=swap" rel="stylesheet" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />
</head>
</head>
<body>
<jsp:include page="/common/header.jsp"></jsp:include>
<!-- Hero -->
<section class="about-hero full-height" aria-label="Ảnh hero Trà thảo mộc">
    <img src="${pageContext.request.contextPath}/assets/images/hero-tra-thao-moc.png" alt="Không gian trà thảo mộc" loading="eager" />
    <div class="about-hero-text">
        <p>
            Dịu êm hương cỏ lá, thanh khiết vị thiên nhiên.
            Mỗi tách trà – một hành trình lắng lại.
        </p>
    </div>
</section>

<main>
    <!-- Sub-nav (nhảy tới các mục) -->
    <div class="subnav">
        <div class="container">
            <ul>
                <li><a href="#hanh-trinh" class="subnav-link">Hành trình tách trà</a></li>
                <li><a href="#lua-chon" class="subnav-link">Lựa chọn nguyên liệu</a></li>
                <li><a href="#nghe-thuat" class="subnav-link">Nghệ thuật pha chế</a></li>
            </ul>
        </div>
    </div>

    <!-- Giới thiệu ngắn -->
    <section class="section-intro">
        <div class="container">
            <h1>Trà Thảo Mộc</h1>
            <p class="lead">
                Trà thảo mộc của chúng tôi là sự kết tinh giữa lá trà, hoa và dược thảo tinh tuyển.
                Từ hành trình tách trà chuẩn mực, khâu chọn nguyên liệu nghiêm ngặt, đến nghệ thuật pha chế tinh tế –
                tất cả nhằm gìn giữ hương vị tự nhiên và mang lại trải nghiệm cân bằng cho cơ thể lẫn tinh thần.
            </p>
        </div>
    </section>

    <!--Hành trình tách trà -->
    <section id="hanh-trinh" class="section-block">
        <div class="container">
            <div class="two-col">
                <div class="col text">
                    <h2>Hành trình tách trà</h2>
                    <p>
                        Quy trình tách trà bắt đầu từ việc làm sạch, tách cuống, chọn lọc kích cỡ lá và cánh hoa,
                        nhằm loại bỏ tạp chất và tối ưu hoá chiết xuất. Chúng tôi áp dụng sấy lạnh ở nhiệt độ kiểm soát
                        để giữ trọn hợp chất dễ bay hơi – nơi hương thơm tinh tế trú ngụ.
                    </p>
                    <ul class="checklist">
                        <li>Làm sạch – phân loại – loại tạp.</li>
                        <li>Sấy lạnh kiểm soát – giữ hương & dưỡng chất.</li>
                        <li>Đóng gói chống ẩm – bảo toàn chất lượng.</li>
                    </ul>
                </div>
                <div class="col media">
                    <img src="${pageContext.request.contextPath}/assets/images/step-tach-tra.png" alt="Quy trình tách trà thảo mộc" loading="lazy" />
                </div>
            </div>
        </div>
    </section>

    <!--Lựa chọn nguyên liệu -->
    <section id="lua-chon" class="section-block alt">
        <div class="container">
            <div class="two-col reverse">
                <div class="col media">
                    <img src="${pageContext.request.contextPath}/assets/images/step-nguyen-lieu.png" alt="Lựa chọn nguyên liệu trà thảo mộc" loading="lazy" />
                </div>
                <div class="col text">
                    <h2>Lựa chọn nguyên liệu</h2>
                    <p>
                        Mỗi nguyên liệu đều có “cá tính” riêng. Chúng tôi hợp tác với nông hộ đạt chuẩn,
                        ưu tiên canh tác sạch, thu hái đúng mùa vụ. Sự kết hợp giữa lá trà nền và thảo mộc
                        (hoa cúc, atiso, bạc hà, gừng, quế…) được thử nghiệm tỉ lệ nhiều lần để đạt cấu trúc hương – vị – hậu vị hài hoà.
                    </p>
                    <div class="info-grid">
                        <div class="card">
                            <h4>Truy nguyên nguồn gốc</h4>
                            <p>Minh bạch vùng trồng, mùa vụ, phương thức canh tác.</p>
                        </div>
                        <div class="card">
                            <h4>Chuẩn cảm quan</h4>
                            <p>Chọn theo mùi hương, sắc lá/hoa và độ tinh khiết tự nhiên.</p>
                        </div>
                        <div class="card">
                            <h4>Tối ưu tỉ lệ</h4>
                            <p>Blend nhiều vòng để đạt hương – vị – hậu vị cân bằng.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!--Nghệ thuật pha chế -->
    <section id="nghe-thuat" class="section-block">
        <div class="container">
            <div class="two-col">
                <div class="col text">
                    <h2>Nghệ thuật pha chế</h2>
                    <p>
                        Pha trà thảo mộc là sự đối thoại với nhiệt độ và thời gian. Nước quá nóng có thể “giận” các tinh dầu,
                        còn quá nguội lại khó đánh thức hương. Chúng tôi khuyến nghị 90–95°C, ủ 3–6 phút tùy blend.
                        Có thể gia giảm thời gian để điều chỉnh độ đậm nhạt theo khẩu vị.
                    </p>
                    <ol class="steps">
                        <li>Làm ấm ấm chén & teapot; tráng nhanh nguyên liệu.</li>
                        <li>Rót nước 90–95°C; ủ 3–6 phút (tuỳ loại).</li>
                        <li>Thưởng thức nguyên bản hoặc thêm lát chanh/mật ong.</li>
                    </ol>
                    <p class="note">
                        Mẹo nhỏ: Dùng nước mềm, pH trung tính giúp hương nổi bật và hậu vị “sạch” hơn.
                    </p>
                </div>
                <div class="col media">
                    <img src="${pageContext.request.contextPath}/assets/images/step-pha-che.png" alt="Nghệ thuật pha chế trà thảo mộc" loading="lazy" />
                </div>
            </div>
        </div>
    </section>

    <!--sang trang Trà Sữa Nguyên Liệu -->
    <section class="section-cta alt">
        <div class="container">
            <div class="cta-box">
                <h3>Khám phá Trà Sữa Nguyên Liệu</h3>
                <p>Từ trà nền tinh chọn, kết hợp sữa tươi & nguyên liệu tự nhiên.</p>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/tra-sua-nguyen-lieu">Xem trang Trà Sữa Nguyên Liệu</a>
            </div>
        </div>
    </section>
</main>
<!-- footer -->
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<!-- JS: cuộn mượt & highlight mục đang xem -->
<script src="${pageContext.request.contextPath}/assets/js/main.js">

</script>

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
