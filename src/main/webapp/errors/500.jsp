<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>500 - Lỗi hệ thống</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

  <style>
    .error-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      text-align: center;
      background-color: #f8f9fa;
      padding: 20px;
    }
    .error-icon {
      font-size: 80px;
      color: #dc3545;
      margin-bottom: 20px;
      animation: pulse 2s infinite;
    }
    .error-title {
      font-size: 36px;
      font-weight: bold;
      color: #333;
      margin-bottom: 15px;
    }
    .error-message {
      font-size: 18px;
      color: #666;
      margin-bottom: 35px;
      max-width: 600px;
      line-height: 1.6;
    }
    .btn-home {
      padding: 12px 30px;
      background-color: #107e84; /* Màu chủ đạo của Mộc Trà */
      color: white;
      text-decoration: none;
      border-radius: 5px;
      font-weight: 600;
      transition: all 0.3s ease;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
    .btn-home:hover {
      background-color: #0b595d;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    @keyframes pulse {
      0% { transform: scale(1); }
      50% { transform: scale(1.05); }
      100% { transform: scale(1); }
    }
  </style>
</head>
<body>
<div class="error-container">
  <div class="error-icon">
    <i class="fa-solid fa-triangle-exclamation"></i>
  </div>
  <h1 class="error-title">Đã xảy ra lỗi hệ thống!</h1>
  <p class="error-message">
    Rất tiếc, hệ thống Mộc Trà đã gặp sự cố không mong muốn (Lỗi 500). <br>
    Chi tiết lỗi đã được tự động ghi nhận vào nhật ký hệ thống để quản trị viên khắc phục.<br>
    Vui lòng quay lại sau hoặc liên hệ hỗ trợ nếu sự cố tiếp diễn.
  </p>
  <a href="${pageContext.request.contextPath}/index" class="btn-home">
    <i class="fa-solid fa-house"></i> Quay về Trang chủ
  </a>
</div>
</body>
</html>
