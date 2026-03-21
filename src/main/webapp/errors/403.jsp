<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>403 - Không có quyền truy cập</title>
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
    }
    .error-icon {
      font-size: 80px;
      color: #dc3545; /* Màu đỏ cảnh báo */
      margin-bottom: 20px;
    }
    .error-title {
      font-size: 36px;
      font-weight: bold;
      color: #333;
      margin-bottom: 10px;
    }
    .error-message {
      font-size: 18px;
      color: #666;
      margin-bottom: 30px;
      max-width: 500px;
    }
    .btn-home {
      padding: 12px 30px;
      background-color: #28a745; /* Màu xanh lá chủ đạo của trà */
      color: white;
      text-decoration: none;
      border-radius: 5px;
      font-weight: 600;
      transition: all 0.3s ease;
    }
    .btn-home:hover {
      background-color: #218838;
      transform: translateY(-2px);
      box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
  </style>
</head>
<body>
<div class="error-container">
  <div class="error-icon">
    <i class="fa-solid fa-user-lock"></i>
  </div>
  <h1 class="error-title">Truy cập bị từ chối!</h1>
  <p class="error-message">
    Xin lỗi, tài khoản của bạn không có quyền quản trị viên để truy cập trang này.
    Vui lòng quay lại trang chủ.
  </p>
  <a href="${pageContext.request.contextPath}/index" class="btn-home">
    <i class="fa-solid fa-house"></i> Quay về Trang chủ
  </a>
</div>
</body>
</html>