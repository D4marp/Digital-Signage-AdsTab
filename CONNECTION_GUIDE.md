# Digital Signage - Connection Guide

## ✅ Backend & Flutter Sudah Tersambung!

### Backend Status
- **URL**: http://localhost:8080
- **Status**: ✅ Running
- **Database**: MySQL (port 3306)
- **API Version**: v1

### API Endpoints Tersedia

#### Authentication
```bash
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/reset-password
GET  /api/v1/auth/me
```

#### Ads Management
```bash
GET    /api/v1/ads
GET    /api/v1/ads/:id
POST   /api/v1/ads
PUT    /api/v1/ads/:id
DELETE /api/v1/ads/:id
POST   /api/v1/ads/upload
POST   /api/v1/ads/reorder
```

#### Device Management
```bash
GET    /api/v1/devices
GET    /api/v1/devices/:id
POST   /api/v1/devices/register
PUT    /api/v1/devices/:id
DELETE /api/v1/devices/:id
POST   /api/v1/devices/:id/heartbeat
POST   /api/v1/devices/:id/increment-views
```

#### Analytics
```bash
POST /api/v1/analytics/impressions
GET  /api/v1/analytics
GET  /api/v1/analytics/dashboard
GET  /api/v1/analytics/ads/:id/performance
```

### Test Koneksi

#### 1. Health Check
```bash
curl http://localhost:8080/health
# Response: {"status":"ok"}
```

#### 2. Register User
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "admin123",
    "display_name": "Admin User",
    "role": "admin"
  }'
```

#### 3. Login
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@test.com",
    "password": "admin123"
  }'
```

#### 4. Get Current User (dengan token)
```bash
TOKEN="your-jwt-token-here"
curl http://localhost:8080/api/v1/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

### Menjalankan Aplikasi

#### Backend (sudah running)
```bash
cd backend
go run main.go
# Server running on http://localhost:8080
```

#### Flutter App

**Desktop (macOS):**
```bash
flutter run -d macos
```

**Web (Chrome):**
```bash
flutter run -d chrome --web-port 3000
# Access: http://localhost:3000
```

**iOS Simulator:**
```bash
flutter run -d "iPhone 16 Pro"
```

**Android Emulator:**
```bash
# Start emulator first
flutter emulators --launch <emulator_id>
flutter run -d android
```

### Flutter Configuration

File `lib/config/api_config.dart` sudah dikonfigurasi:
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
```

**Note untuk Mobile/Web:**
- Desktop/Web: Gunakan `localhost`
- iOS Simulator: Gunakan `localhost`  
- Android Emulator: Gunakan `10.0.2.2` (ganti di api_config.dart)
- Physical Device: Gunakan IP komputer (misal `192.168.1.100`)

### User Default (Test)

Setelah register, gunakan:
- **Email**: admin@test.com
- **Password**: admin123
- **Role**: admin

### Troubleshooting

#### Backend tidak konek ke MySQL
```bash
# Cek MySQL running
mysql -u root -p

# Buat database
CREATE DATABASE digital_signage;

# Update backend/.env
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=digital_signage
```

#### Flutter tidak bisa konek ke backend
1. Pastikan backend running: `curl http://localhost:8080/health`
2. Untuk Android emulator, ubah `api_config.dart`:
   ```dart
   static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
   ```
3. Untuk physical device, ubah ke IP komputer:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:8080/api/v1';
   ```

#### CORS Error di Web
Backend sudah dikonfigurasi dengan CORS middleware yang mengizinkan semua origin untuk development.

### Next Steps

1. ✅ Backend running di port 8080
2. ✅ Database MySQL ready
3. ✅ API endpoints tested dan berfungsi
4. ✅ User admin sudah terdaftar
5. 🔄 Jalankan Flutter app: `flutter run -d <device>`

### Fitur Yang Tersedia

#### Admin Panel
- Dashboard dengan statistik
- Manajemen Ads (CRUD, upload media)
- Manajemen Devices
- Analytics dan reports
- Settings

#### Display Mode
- Slideshow ads otomatis
- Video playback
- Heartbeat ke server
- Track impressions
- Device registration

Enjoy! 🚀
