<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Mã ưu đãi của tôi - Mộc Trà</title>

  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.0.1/css/all.min.css">

</head>

<body class="user-dashboard-page">
<jsp:include page="/common/header.jsp"></jsp:include>

<div class="container">
  <jsp:include page="/common/user-sidebar.jsp">
    <jsp:param name="activePage" value="voucher"/>
  </jsp:include>

  <main class="main-content voucher-page">
    <div class="voucher-header">
      <h2>🎟️ Mã ưu đãi của tôi</h2>
      <p>Quản lý các mã giảm giá và voucher VIP còn dùng được của bạn.</p>
    </div>

    <div class="voucher-stats">
      <div class="voucher-stat-card">
        <div class="voucher-stat-icon">
          <i class="fa-solid fa-ticket"></i>
        </div>
        <div class="voucher-stat-info">
          <h3>${couponCount}</h3>
          <p>Mã giảm giá đã nhận</p>
        </div>
      </div>

      <div class="voucher-stat-card">
        <div class="voucher-stat-icon vip">
          <i class="fa-solid fa-gem"></i>
        </div>
        <div class="voucher-stat-info">
          <h3>${vipVoucherCount}</h3>
          <p>Voucher VIP</p>
        </div>
      </div>
    </div>

    <div class="voucher-tabs">
      <div class="voucher-tab-header">
        <button type="button" class="voucher-tab-btn active" data-tab="couponTab">
          <i class="fa-solid fa-ticket"></i>
          Mã giảm giá
        </button>

        <button type="button" class="voucher-tab-btn" data-tab="vipVoucherTab">
          <i class="fa-solid fa-gem"></i>
          Voucher VIP
        </button>
      </div>

      <div id="couponTab" class="voucher-tab-content active">
        <c:choose>
          <c:when test="${not empty userCoupons}">
            <div class="voucher-grid">
              <c:forEach var="coupon" items="${userCoupons}">
                <div class="my-voucher-card">
                  <div class="my-voucher-left">
                    <div class="voucher-value">
                      <c:choose>
                        <c:when test="${coupon.discountType == 'PERCENT'}">
                          <span><fmt:formatNumber value="${coupon.discountValue}" maxFractionDigits="0"/>%</span>
                          <small>GIẢM</small>
                        </c:when>
                        <c:otherwise>
                          <span><fmt:formatNumber value="${coupon.discountValue}" pattern="#,###"/>đ</span>
                          <small>GIẢM</small>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>

                  <div class="my-voucher-body">
                    <div class="my-voucher-title">${coupon.title}</div>

                    <div class="my-voucher-code">
                      Mã: <strong class="code-text">${coupon.code}</strong>
                    </div>

                    <div class="my-voucher-desc">
                        ${coupon.description}
                    </div>

                    <div class="my-voucher-info">
                      <c:if test="${coupon.minOrderAmount > 0}">
                                                <span>
                                                    Đơn tối thiểu:
                                                    <strong><fmt:formatNumber value="${coupon.minOrderAmount}" pattern="#,###"/>đ</strong>
                                                </span>
                      </c:if>

                      <c:if test="${coupon.maxDiscountAmount != null}">
                                                <span>
                                                    Giảm tối đa:
                                                    <strong><fmt:formatNumber value="${coupon.maxDiscountAmount}" pattern="#,###"/>đ</strong>
                                                </span>
                      </c:if>

                      <span>
                                                Hạn dùng:
                                                <strong>${fn:replace(coupon.endDate, 'T', ' ')}</strong>
                                            </span>
                    </div>

                    <div class="my-voucher-actions">
                      <button type="button" class="btn-copy-code" data-code="${coupon.code}">
                        <i class="fa-regular fa-copy"></i>
                        Sao chép mã
                      </button>

                      <a href="${pageContext.request.contextPath}/gio-hang" class="btn-use-voucher">
                        <i class="fa-solid fa-cart-shopping"></i>
                        Dùng ngay
                      </a>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:when>

          <c:otherwise>
            <div class="empty-voucher">
              <i class="fa-regular fa-face-smile"></i>
              <h3>Bạn chưa có mã giảm giá nào</h3>
              <p>Hãy vào trang khuyến mãi để lấy mã ưu đãi mới nhất.</p>
              <a href="${pageContext.request.contextPath}/khuyen-mai" class="btn-use-voucher">
                Đi lấy mã
              </a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <div id="vipVoucherTab" class="voucher-tab-content">
        <c:choose>
          <c:when test="${not empty vipVouchers}">
            <div class="voucher-grid">
              <c:forEach var="voucher" items="${vipVouchers}">
                <div class="my-voucher-card">
                  <div class="my-voucher-left vip">
                    <div class="voucher-value">
                      <c:choose>
                        <c:when test="${voucher.discountType == 'PERCENT'}">
                          <span><fmt:formatNumber value="${voucher.discountValue}" maxFractionDigits="0"/>%</span>
                          <small>VIP</small>
                        </c:when>
                        <c:otherwise>
                          <span><fmt:formatNumber value="${voucher.discountValue}" pattern="#,###"/>đ</span>
                          <small>VIP</small>
                        </c:otherwise>
                      </c:choose>
                    </div>
                  </div>

                  <div class="my-voucher-body">
                    <div class="my-voucher-title">Voucher khách hàng VIP</div>

                    <div class="my-voucher-code">
                      Mã: <strong class="code-text">${voucher.code}</strong>
                    </div>

                    <div class="my-voucher-desc">
                      Voucher đặc quyền do admin cấp cho khách hàng VIP.
                    </div>

                    <div class="my-voucher-info">
                                            <span>
                                                Lượt dùng:
                                                <strong>
                                                    ${voucher.currentUses}
                                                    /
                                                    <c:choose>
                                                      <c:when test="${voucher.maxUses != null}">
                                                        ${voucher.maxUses}
                                                      </c:when>
                                                      <c:otherwise>
                                                        Không giới hạn
                                                      </c:otherwise>
                                                    </c:choose>
                                                </strong>
                                            </span>

                      <span>
                                                Hạn dùng:
                                                <strong>${fn:replace(voucher.endDate, 'T', ' ')}</strong>
                                            </span>
                    </div>

                    <div class="my-voucher-actions">
                      <button type="button" class="btn-copy-code" data-code="${voucher.code}">
                        <i class="fa-regular fa-copy"></i>
                        Sao chép mã
                      </button>

                      <a href="${pageContext.request.contextPath}/gio-hang" class="btn-use-voucher">
                        <i class="fa-solid fa-cart-shopping"></i>
                        Dùng ngay
                      </a>
                    </div>
                  </div>
                </div>
              </c:forEach>
            </div>
          </c:when>

          <c:otherwise>
            <div class="empty-voucher">
              <i class="fa-regular fa-gem"></i>

              <c:choose>
                <c:when test="${sessionScope.user != null && sessionScope.user.isVip}">
                  <h3>Bạn chưa có voucher VIP nào</h3>
                  <p>Voucher VIP sẽ hiển thị tại đây khi admin cấp cho bạn.</p>
                </c:when>

                <c:otherwise>
                  <h3>Bạn chưa phải khách hàng VIP</h3>
                  <p>Khi trở thành VIP, bạn có thể nhận thêm voucher đặc quyền.</p>
                </c:otherwise>
              </c:choose>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </main>
</div>

<jsp:include page="/common/footer.jsp"></jsp:include>

<button id="backToTop" class="back-to-top" title="Lên đầu trang">
  <i class="fa-solid fa-chevron-up"></i>
</button>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    const tabBtns = document.querySelectorAll(".voucher-tab-btn");
    const tabContents = document.querySelectorAll(".voucher-tab-content");

    tabBtns.forEach(function (btn) {
      btn.addEventListener("click", function () {
        const tabId = btn.getAttribute("data-tab");

        tabBtns.forEach(function (b) {
          b.classList.remove("active");
        });

        tabContents.forEach(function (content) {
          content.classList.remove("active");
        });

        btn.classList.add("active");

        const target = document.getElementById(tabId);
        if (target) {
          target.classList.add("active");
        }
      });
    });

    const copyBtns = document.querySelectorAll(".btn-copy-code");

    copyBtns.forEach(function (btn) {
      btn.addEventListener("click", function () {
        const code = btn.getAttribute("data-code");

        if (!code) {
          return;
        }

        navigator.clipboard.writeText(code).then(function () {
          const oldText = btn.innerHTML;
          btn.innerHTML = '<i class="fa-solid fa-check"></i> Đã sao chép';

          setTimeout(function () {
            btn.innerHTML = oldText;
          }, 1500);
        }).catch(function () {
          alert("Không thể sao chép mã. Vui lòng copy thủ công: " + code);
        });
      });
    });
  });
</script>

</body>
</html>