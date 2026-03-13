<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trà Thảo Mộc & Trà Sữa DIY</title>

    <link rel="stylesheet" href="assets/css/main.css">
    <!-- <link rel="stylesheet" href="assets/css/about-us.css"> -->

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Dancing+Script:wght@400;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css" integrity="sha512-2SwdPD6INVrV/lHTZbO2nodKhrnDdJK9/kg2XD1r9uGqPo1cUbujc+IYdlYdEErWNu69gVcYgdxlmVmzTWnetw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

</head>
<body>
<jsp:include page="common/header.jsp"></jsp:include>
<main>
    <!-- image hero and giới thiệu -->
    <section class="about-hero full-height">
        <img src="assets/images/about-tong-quan.jpg" alt="Ảnh nền">
        <div class="about-hero-text">
            <p>
                Hương trà tan giữa chiều rơi,
                Giọt trong tách nhỏ, thành lời gió ru.
                Một hơi ấm chạm hồn thu,
                Đọng trên đầu lưỡi, thiên thu dịu dàng.
            </p>
        </div>
    </section>
    <!-- SUBNAV  điều hướng tiêu đề -->
    <div class="subnav">
        <div class="container">
            <ul>
                <li><a href="#story" class="subnav-link">Câu chuyện hình thành</a></li>
                <li><a href="#mission" class="subnav-link">Mục tiêu &amp; Sứ mệnh</a></li>
                <li><a href="#values" class="subnav-link">Giá trị cốt lõi</a></li>
                <li><a href="#about-section" class="subnav-link">Tổng quan</a></li>
                <li><a href="#about-bottom" class="subnav-link">Tiêu Chuẩn Hướng Đến</a></li>

            </ul>
        </div>
    </div>
    <div class="container"></div>
    <!-- phần tổng quan về trà  -->
    <section class="section-intro">
        <div class="container">
            <h1>Tổng Quan Về Tiệm Trà</h1>
            <p class="lead">
                Từ niềm đam mê hương vị tự nhiên, chúng tôi mong muốn mang đến một không gian thưởng trà nhẹ nhàng,
                nơi mỗi tách trà là một câu chuyện, mỗi hương vị là một cảm xúc.
                Tiệm không chỉ bán trà – mà còn gìn giữ tinh hoa văn hóa thưởng trà Việt Nam.
            </p>
        </div>
    </section>
    <!-- câu chuyện hình thành  -->
    <section class="section-block" id="story">
        <div class="container">
            <div class="two-col">
                <div class="col text">
                    <h2>Câu chuyện hình thành</h2>
                    <p>
                        Tiệm trà ra đời từ khát vọng tạo nên một không gian yên bình giữa nhịp sống tất bật.
                        Mỗi sản phẩm được hình thành qua hành trình tìm hiểu, chọn lựa và thử nghiệm,
                        với mong muốn lưu giữ những hương vị thuần khiết nhất của đất trời.
                    </p>
                    <ul class="checklist">
                        <li>Khởi nguồn từ tình yêu thiên nhiên & văn hóa trà.</li>
                        <li>Chú trọng trải nghiệm khách hàng và sức khỏe cộng đồng.</li>
                        <li>Không ngừng sáng tạo trong pha chế và trình bày.</li>
                    </ul>
                </div>
                <div class="col media">
                    <img src="assets/images/about-story.png" alt="Câu chuyện hình thành tiệm trà" loading="lazy">
                </div>
            </div>
        </div>
    </section>
    <!-- mục tiêu và sứ mệnh  -->
    <section class="section-block alt" id="mission">
        <div class="container">
            <div class="two-col reverse">
                <div class="col media">
                    <img src="assets/images/about-mission.png" alt="Mục tiêu và sứ mệnh" loading="lazy">
                </div>
                <div class="col text">
                    <h2>Mục tiêu &amp; Sứ mệnh</h2>
                    <p>
                        Sứ mệnh của chúng tôi là lan tỏa năng lượng tích cực thông qua mỗi tách trà,
                        khuyến khích con người sống chậm lại, quan sát và cảm nhận.
                        Mục tiêu không chỉ là tạo ra sản phẩm chất lượng, mà còn truyền cảm hứng về lối sống cân bằng.
                    </p>
                    <div class="info-grid">
                        <div class="card">
                            <h4>Chất lượng &amp; minh bạch</h4>
                            <p>Nguyên liệu sạch, rõ nguồn gốc – tiêu chuẩn hàng đầu của tiệm.</p>
                        </div>
                        <div class="card">
                            <h4>Trải nghiệm trọn vẹn</h4>
                            <p>Không gian, âm nhạc và hương vị hòa quyện thành một trải nghiệm tinh tế.</p>
                        </div>
                        <div class="card">
                            <h4>Phát triển bền vững</h4>
                            <p>Hướng đến sản phẩm thân thiện môi trường và cộng đồng.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    <!-- giá trị cốt lõi và 3 block mô tả  -->
    <section class="section-block" id="values">
        <div class="container">
            <div class="two-col">
                <div class="col text">
                    <h2>Giá trị cốt lõi</h2>
                    <p>
                        Mỗi bước đi của tiệm đều hướng về ba giá trị: <strong>Tự nhiên – Tận tâm – Tinh tế</strong>.
                        Chúng tôi tin rằng, sự chân thành và nỗ lực mang đến giá trị thật
                        là nền tảng vững chắc để lan tỏa tình yêu trà đến mọi người.
                    </p>
                    <ol class="steps">
                        <li><strong>Tự nhiên:</strong> Nguyên liệu sạch, không pha tạp.</li>
                        <li><strong>Tận tâm:</strong> Quy trình sản xuất & phục vụ đặt trọn tâm huyết.</li>
                        <li><strong>Tinh tế:</strong> Hương vị và thẩm mỹ đều đạt chuẩn cao nhất.</li>
                    </ol>
                </div>
                <div class="col media">
                    <img src="assets/images/about-values.png" alt="Giá trị cốt lõi" loading="lazy">
                </div>
            </div>
        </div>
    </section>


    <!-- section  2 7 thẻ div -->
    <section class="about-section section-block" id="about-section">
        <!-- 1 Giới thiệu web -->
        <div class="about-row full-height ">
            <div class="about-text">
                <h2>Câu chuyện của Tiệm</h2>
                <p>
                    Tiệm trà của chúng tôi bắt nguồn từ niềm đam mê sâu sắc với văn hóa trà và mong muốn mang đến cho cộng đồng những trải nghiệm thưởng trà tinh tế.
                    Được thành lập bởi những người yêu trà, tiệm không chỉ là nơi cung cấp các loại trà thượng hạng mà còn là không gian để khách hàng khám phá và kết nối với nghệ thuật pha trà.
                    Chúng tôi cam kết sử dụng nguyên liệu tự nhiên, quy trình chế biến nghiêm ngặt và sáng tạo không ngừng để mang đến những sản phẩm trà độc đáo, phù hợp với xu hướng hiện đại nhưng vẫn giữ trọn vẹn giá trị truyền thống.
                    Hành trình của tiệm trà là hành trình lan tỏa tình yêu với trà, góp phần nâng cao chất lượng cuộc sống và xây dựng cộng đồng yêu trà ngày càng lớn mạnh.
                </p>
            </div>
        </div>

        <!--text + image target-->
        <div class="about-row">
            <div class="about-text">
                <h2>Mục tiêu của Tiệm</h2>
                <p> Tiệm trà ra đời từ niềm tin rằng, giữa nhịp sống ồn ào, con người vẫn luôn cần những phút giây lắng lại  bên một tách trà thơm, để tìm về sự an lành trong tâm hồn.
                    Chúng tôi không chỉ đơn thuần là nơi bán trà, mà là một hành trình lan tỏa năng lượng tích cực, gìn giữ những giá trị tinh khiết từ mẹ thiên nhiên.
                    Mỗi sản phẩm đều được chọn lọc kỹ lưỡng, từ từng búp trà đến từng cánh hoa, từng nhánh thảo mộc, được sấy lạnh tự nhiên để giữ trọn hương  vị và dưỡng chất.
                    Chúng mình tin rằng, trà không chỉ là thức uống, mà là cách con người giao hòa với đất trời, là cầu nối giữa bình yên và sự tỉnh thức.</p>
            </div>
            <div class="about-image">
                <img src="assets/images/image-muc-tieu.png" alt="Ảnh minh họa lớn">
            </div>
        </div>

        <!-- 4 image trà thảo mộc + 5 text -->
        <div class="about-row">
            <div class="about-image">
                <img src="assets/images/image-tra-thao-moc.png" alt="Trà thảo mộc">
            </div>
            <div class="about-text">
                <h2>Trà Thảo Mộc</h2>
                <p> Trà thảo mộc của chúng tôi là sự kết tinh từ tinh túy của thiên nhiên với
                    những lá trà, hoa và thảo dược được tuyển chọn kỹ lưỡng từ những vùng đất trong lành.
                    Mỗi tách trà là một món quà dịu nhẹ dành cho sức khỏe, giúp thư giãn tâm hồn,
                    thanh lọc cơ thể và mang lại năng lượng tươi mới mỗi ngày.
                    Chúng tôi tin rằng, khi con người sống hòa hợp với thiên nhiên,
                    từng ngụm trà cũng trở thành một hành trình chữa lành, nhẹ nhàng mà sâu sắc.</p>
            </div>
        </div>

        <!-- 6 text trà sữa nguyên liệu + 7 image trà sữa -->
        <div class="about-row">
            <div class="about-text">
                <h2>Trà Sữa Nguyên Liệu</h2>
                <p> Trà sữa nguyên liệu của chúng tôi được pha chế từ nguồn trà sạch,
                    kết hợp cùng sữa tươi và nguyên liệu tự nhiên, mang đến hương vị hài hòa, ngọt dịu mà vẫn tinh tế.
                    Từng ly trà sữa không chỉ là thức uống yêu thích của giới trẻ,
                    mà còn là sự kết hợp hoàn hảo giữa truyền thống và hiện đại, giữa tự nhiên và sáng tạo.
                    Chúng tôi mong muốn mỗi khách hàng khi thưởng thức sẽ cảm nhận được
                    tâm huyết và niềm vui mà tiệm gửi gắm trong từng hương vị.
                </p>
            </div>
            <div class="about-image">
                <img src="assets/images/image-tra-sua-nguyen-lieu.png" alt="Trà sữa nguyên liệu">
            </div>
        </div>
    </section>

    <!--div 3 -->
    <section class="about-bottom section-block" id="about-bottom">
        <!-- icon tiêu chuẩn  -->
        <div class="feature-row">
            <div class="feature"><img src="assets/images/icon-about1.png"><h4>Chất Lượng Là Hàng Đầu</h4></div>
            <div class="feature"><img src="assets/images/icon-about2.png"><h4>Cam Kết Nguồn Gốc</h4></div>
            <div class="feature"><img src="assets/images/icon-about3.png"><h4>Thân Thiện Môi Trường</h4></div>
            <div class="feature"><img src="assets/images/icon-about4.png"><h4>Lắng Nghe Khách Hàng</h4></div>
        </div>
        <!-- thơ  -->
        <div class="about-quote">
            <h2>Tràn đầy năng lượng mỗi ngày</h2>
            <p>“Cùng em nâng chén trà hương, khi ngày mới chớm khói sương mịt mờ.
                Trăm năm thu ngắn một giờ, an vui hạnh phúc bên bờ thần tiên.”</p>
        </div>
    </section>
    <!-- button chuyển sang trang giới thiệu khác -->
    <section class="section-cta alt">
        <div class="container">
            <div class="cta-box">
                <h3>Khám phá thêm</h3>
                <p>Hai dòng trà đặc trưng của tiệm:</p>
                <div style="display:flex; justify-content:center; gap:16px; flex-wrap:wrap;">
                    <a class="btn btn-primary" href="tra-thao-moc.jsp">Trà Thảo Mộc</a>
                    <a class="btn btn-primary" href="tra-sua-nguyen-lieu.jsp">Trà Sữa Nguyên Liệu</a>
                </div>
            </div>
        </div>
    </section>
    </div>
</main>


<!-- footer  -->
<jsp:include page="common/footer.jsp"></jsp:include>
<button id="backToTop" class="back-to-top" title="Lên đầu trang">
    <i class="fa-solid fa-chevron-up"></i>
</button>
<script src="assets/js/main.js">
</script>

<!-- // back to top button  -->
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