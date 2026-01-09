# Digital Signage - Migration to Golang Backend

Proyek ini telah diubah dari Firebase ke backend Golang sendiri dengan PostgreSQL database.

## 📋 Perubahan Utama

### Backend (Golang)
- ✅ REST API lengkap dengan Gin Framework
- ✅ PostgreSQL database dengan auto-migration
- ✅ JWT authentication
- ✅ File upload untuk media
- ✅ CORS enabled
- ✅ Comprehensive API endpoints

### Frontend (Flutter)
- ✅ Menghapus semua dependency Firebase
- ✅ Menggunakan Dio untuk HTTP requests
- ✅ API client dengan interceptors
- ✅ Token-based authentication
- ✅ Updated models untuk JSON serialization

## 🚀 Setup & Installation

### Prerequisites

#### Backend:
- Go 1.21 atau lebih baru
- PostgreSQL 12 atau lebih baru

#### Frontend:
- Flutter SDK 3.0 atau lebih baru
- Dart SDK

### 1. Setup Backend

```bash
# Masuk ke folder backend
cd backend

# Install dependencies
go mod download

# Setup database PostgreSQL
createdb digital_signage

# Copy dan edit file environment
cp .env.example .env
# Edit .env dengan konfigurasi Anda

# Jalankan server
go run main.go

# Atau build dulu lalu jalankan
go build -o digital-signage-backend
./digital-signage-backend
```

Server akan berjalan di `http://localhost:8080`

### 2. Setup Frontend

```bash
# Kembali ke root project
cd ..

# Install dependencies Flutter
flutter pub get

# Jalankan aplikasi
flutter run

# Atau build
flutter build apk  # untuk Android
flutter build ios  # untuk iOS
```

## 📁 Struktur Proyek

```
digital_signage/
├── backend/                  # Golang Backend
│   ├── main.go              # Entry point
│   ├── config/              # Configuration
│   ├── database/            # Database & migrations
│   ├── models/              # Data models
│   ├── handlers/            # API handlers
│   ├── middleware/          # Middlewares
│   ├── routes/              # API routes
│   ├── utils/               # Utilities
│   ├── uploads/             # Media uploads
│   ├── go.mod
│   └── README.md
│
├── lib/                     # Flutter App
│   ├── config/
│   │   └── api_config.dart # API endpoints
│   ├── services/
│   │   └── api_client.dart # HTTP client
│   ├── models/              # Data models
│   ├── providers/           # State management
│   │   ├── auth_provider.dart
│   │   ├── ad_provider_new.dart
│   │   ├── analytics_provider_new.dart
│   │   └── device_provider_new.dart
│   ├── screens/             # UI screens
│   ├── utils/               # Utilities
│   └── main.dart
│
└── pubspec.yaml
```

## 🔧 Konfigurasi

### Backend Configuration (.env)

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=digital_signage

# JWT
JWT_SECRET=your-super-secret-jwt-key

# Server
PORT=8080
GIN_MODE=debug

# Upload
UPLOAD_PATH=./uploads
MAX_UPLOAD_SIZE=100
```

### Frontend Configuration

Edit file `lib/config/api_config.dart` untuk mengubah base URL:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String uploadBaseUrl = 'http://localhost:8080';
  // ...
}
```

Untuk production, gunakan domain/IP server Anda:
```dart
static const String baseUrl = 'https://your-domain.com/api/v1';
```

## 🔐 Authentication Flow

1. User register/login melalui Flutter app
2. Backend mengembalikan JWT token
3. Token disimpan di SharedPreferences
4. Setiap request menyertakan token di header `Authorization: Bearer <token>`
5. Middleware backend memverifikasi token

## 📊 Database Schema

### users
- id (UUID, PK)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- display_name (VARCHAR)
- role (VARCHAR)
- created_at, updated_at (TIMESTAMP)

### ads
- id (UUID, PK)
- title, media_url, media_type (VARCHAR/TEXT)
- duration_seconds, order_index (INT)
- is_enabled (BOOLEAN)
- target_locations (TEXT[])
- created_by (UUID, FK -> users)
- is_deleted (BOOLEAN)
- created_at, updated_at (TIMESTAMP)

### devices
- id (UUID, PK)
- device_id (VARCHAR, UNIQUE)
- location (VARCHAR)
- is_online (BOOLEAN)
- last_active (TIMESTAMP)
- today_views (INT)
- settings (JSONB)
- created_at, updated_at (TIMESTAMP)

### impressions
- id (UUID, PK)
- ad_id (UUID, FK -> ads)
- device_id (UUID, FK -> devices)
- viewed_at (TIMESTAMP)

### ad_analytics
- id (UUID, PK)
- ad_id (UUID, FK -> ads)
- date (DATE)
- impressions (INT)
- unique_devices (INT)
- created_at, updated_at (TIMESTAMP)

## 📡 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register user baru
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/reset-password` - Reset password
- `GET /api/v1/auth/me` - Get current user (protected)

### Ads
- `GET /api/v1/ads` - Get all ads
- `GET /api/v1/ads/:id` - Get ad by ID
- `POST /api/v1/ads` - Create ad (protected)
- `PUT /api/v1/ads/:id` - Update ad (protected)
- `DELETE /api/v1/ads/:id` - Delete ad (protected)
- `POST /api/v1/ads/upload` - Upload media (protected)
- `POST /api/v1/ads/reorder` - Reorder ads (protected)

### Devices
- `GET /api/v1/devices` - Get all devices (protected)
- `GET /api/v1/devices/:id` - Get device by ID (protected)
- `POST /api/v1/devices/register` - Register device
- `PUT /api/v1/devices/:id` - Update device (protected)
- `DELETE /api/v1/devices/:id` - Delete device (protected)
- `POST /api/v1/devices/:id/heartbeat` - Device heartbeat
- `POST /api/v1/devices/:id/increment-views` - Increment views

### Analytics
- `POST /api/v1/analytics/impressions` - Track impression
- `GET /api/v1/analytics` - Get analytics (protected)
- `GET /api/v1/analytics/dashboard` - Dashboard stats (protected)
- `GET /api/v1/analytics/ads/:id/performance` - Ad performance (protected)

## 🔨 Development

### Backend Development

```bash
cd backend

# Run with auto-reload (install air first: go install github.com/cosmtrek/air@latest)
air

# Run tests
go test ./...

# Format code
go fmt ./...
```

### Frontend Development

```bash
# Run in debug mode
flutter run -d chrome  # untuk web
flutter run -d android # untuk Android

# Hot reload: tekan 'r' di terminal
# Hot restart: tekan 'R' di terminal

# Format code
dart format .

# Analyze
flutter analyze
```

## 🚀 Production Deployment

### Backend

1. Build binary:
```bash
cd backend
go build -o digital-signage-backend
```

2. Setup systemd service (Linux):
```ini
[Unit]
Description=Digital Signage Backend
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/digital-signage/backend
ExecStart=/opt/digital-signage/backend/digital-signage-backend
Restart=always

[Install]
WantedBy=multi-user.target
```

3. Setup Nginx reverse proxy:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /uploads {
        alias /opt/digital-signage/backend/uploads;
    }
}
```

### Frontend

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## 📝 Migration Notes

### Files yang Dihapus
- `lib/firebase_options.dart` - Tidak perlu lagi
- Firebase dependencies dari `pubspec.yaml`

### Files yang Diubah
- `lib/main.dart` - Hapus Firebase initialization
- `lib/models/*.dart` - Ubah dari Firestore ke JSON
- `lib/providers/*.dart` - Ubah dari Firebase SDK ke REST API

### Files Baru
- `backend/**` - Semua file backend Golang
- `lib/config/api_config.dart` - API endpoints
- `lib/services/api_client.dart` - HTTP client
- `lib/providers/*_new.dart` - Provider baru dengan REST API

## 🐛 Troubleshooting

### Backend tidak bisa connect ke database
```bash
# Check PostgreSQL service
sudo systemctl status postgresql

# Check database exists
psql -l

# Create database jika belum ada
createdb digital_signage
```

### Flutter error "Connection refused"
1. Pastikan backend berjalan di `http://localhost:8080`
2. Check `lib/config/api_config.dart` URL sudah benar
3. Untuk Android emulator, gunakan `http://10.0.2.2:8080` instead of `localhost`

### Upload file gagal
1. Check folder `backend/uploads` sudah ada dan writable
2. Check `MAX_UPLOAD_SIZE` di `.env`
3. Check file size tidak melebihi limit

## 📚 Additional Resources

- [Gin Framework Documentation](https://gin-gonic.com/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flutter HTTP/Dio](https://pub.dev/packages/dio)
- [JWT Authentication](https://jwt.io/)

## 📄 License

MIT License

## 👥 Support

Untuk bantuan lebih lanjut, hubungi tim development.
