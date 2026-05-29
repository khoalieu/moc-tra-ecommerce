set -e

echo "=========================================="
echo "  🍵 Mộc Trà E-Commerce - Deploy Script"
echo "=========================================="

if [ ! -f ".env" ]; then
    echo "❌ Không tìm thấy file .env!"
    echo "   Hãy copy và chỉnh sửa: cp .env.example .env"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker chưa được cài đặt!"
    echo "   Chạy: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose chưa được cài đặt!"
    exit 1
fi

mkdir -p nginx/ssl

if [ ! -f "nginx/ssl/fullchain.pem" ]; then
    echo "⚠️  Không tìm thấy SSL certificate. Tạo self-signed cert..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout nginx/ssl/privkey.pem \
        -out nginx/ssl/fullchain.pem \
        -subj "/C=VN/ST=HCM/L=HoChiMinh/O=MocTra/CN=localhost" 2>/dev/null
    echo "✅ Đã tạo self-signed SSL certificate"
fi

echo ""
echo "📦 Bước 1: Build Docker image..."
docker compose build --no-cache app

echo ""
echo "🗄️  Bước 2: Khởi động database..."
docker compose up -d db
echo "   Chờ MySQL sẵn sàng..."
sleep 15

echo ""
echo "🚀 Bước 3: Khởi động toàn bộ stack..."
docker compose up -d

echo ""
echo "📋 Bước 4: Kiểm tra trạng thái..."
sleep 10
docker compose ps

echo ""
echo "📝 Log ứng dụng (Ctrl+C để thoát):"
docker compose logs -f app
