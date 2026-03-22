<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Trà Sữa Nguyên Liệu | Về Chúng Tôi</title>

    <meta name="description" content="Trà Sữa Nguyên Liệu" />
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
<section class="about-hero full-height" aria-label="Ảnh hero Trà sữa nguyên liệu">
    <img src="${pageContext.request.contextPath}/assets/images/hero-tra-sua.png" alt="Không gian trà sữa nguyên liệu" loading="eager" />
    <div class="about-hero-text">
        <p>
            Em thích trà sữa, anh cũng vậy,
            Hai ta chung ly, chuyện nhỏ mà hay.
            Ngọt như ánh mắt em hôm ấy,
            Thêm chút trân châu — tim lỡ vơi đầy.
        </p>
    </div>
</section>
<main>
    <!-- Sub-nav (2 mục) -->
    <div class="subnav">
        <div class="container">
            <ul>
                <li><a href="#lua-chon" class="subnav-link ">Lựa chọn nguyên liệu</a></li>
                <li><a href="#nghe-thuat" class="subnav-link">Nghệ thuật pha chế</a></li>
            </ul>
        </div>
    </div>

    <!-- Giới thiệu ngắn -->
    <section class="section-intro">
        <div class="container">
            <h1>Trà Sữa Nguyên Liệu</h1>
            <p class="lead">
                Dựa trên nền trà tinh chọn và sữa tươi cân đối, chúng tôi ưu tiên nguyên liệu tự nhiên,
                minh bạch nguồn gốc và công thức pha chế tinh gọn để giữ vị “sạch” – êm – không gắt.
            </p>
        </div>
    </section>

    <!-- 1) Lựa chọn nguyên liệu -->
    <section id="lua-chon" class="section-block">
        <div class="container">
            <div class="two-col reverse">
                <div class="col media">
                    <img src="${pageContext.request.contextPath}/assets/images/step-lua-chon-sua.png" alt="Lựa chọn nguyên liệu cho trà sữa" loading="lazy" />
                </div>
                <div class="col text">
                    <h2>Lựa chọn nguyên liệu</h2>
                    <p>
                        Trà nền được chọn theo cấu trúc hương – vị (oolong/đen/lục) để tạo cốt vững, phối cùng sữa tươi
                        hoặc base sữa theo tỉ lệ tối ưu. Các thành phần phụ như kem béo, syrup, topping
                        đều ưu tiên thành phần tự nhiên, hạn chế hương liệu tổng hợp.
                    </p>
                    <div class="info-grid">
                        <div class="card">
                            <h4>Trà nền chuẩn</h4>
                            <p>Chọn theo độ đậm, hậu vị và độ bền hương khi phối sữa.</p>
                        </div>
                        <div class="card">
                            <h4>Sữa &amp; béo</h4>
                            <p>Sữa tươi, whipping/half-and-half tùy công thức, tối ưu độ mượt.</p>
                        </div>
                        <div class="card">
                            <h4>Độ ngọt cân bằng</h4>
                            <p>Dùng syrup đường mía/honey; canh độ Brix theo khẩu vị vùng.</p>
                        </div>
                    </div>
                    <p class="note">Gợi ý: 100% đá làm “loãng” nhanh; cân chỉnh tỉ lệ đá/đường để giữ thân vị.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- 2) Nghệ thuật pha chế -->
    <section id="nghe-thuat" class="section-block alt">
        <div class="container">
            <div class="two-col">
                <div class="col text">
                    <h2>Nghệ thuật pha chế</h2>
                    <p>
                        Mấu chốt nằm ở nhiệt độ chiết trà và tỉ lệ trà : sữa. Trà nên được ủ tách riêng ở 90–95°C (tuỳ loại),
                        sau đó làm nguội về 60–65°C trước khi phối sữa để tránh “vón” protein
                        và làm biến tính hương. Lắc/ủ lạnh giúp cấu trúc mượt và bọt mịn.
                    </p>
                    <ol class="steps">
                        <li>Ủ trà nền đúng nhiệt/đúng phút; lọc bã.</li>
                        <li>Để trà xuống ~60–65°C; phối sữa + syrup theo tỉ lệ.</li>
                        <li>Lắc với đá (hoặc ủ lạnh) để ổn định cấu trúc – rót phục vụ.</li>
                    </ol>
                    <p class="note">Mẹo: Dùng nước mềm và sữa tươi béo vừa giúp hương trà không bị “che”.</p>
                </div>
                <div class="col media">
                    <img src="${pageContext.request.contextPath}/assets/images/step-pha-che-sua.png" alt="Nghệ thuật pha chế trà sữa" loading="lazy" />
                </div>
            </div>
        </div>
    </section>

    <!-- cta sang Trà Thảo Mộc -->
    <section class="section-cta">
        <div class="container">
            <div class="cta-box">
                <h3>Khám phá Trà Thảo Mộc</h3>
                <p>Nhẹ nhàng – thanh mát – giữ trọn tinh túy thiên nhiên.</p>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/tra-thao-moc">Xem trang Trà Thảo Mộc</a>
            </div>
        </div>
    </section>
</main>

<!-- footer  -->
<jsp:include page="/common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>

<!-- JS: cuộn mượt & highlight mục đang xem -->
<script src="${pageContext.request.contextPath}//assets/js/main.js">

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
