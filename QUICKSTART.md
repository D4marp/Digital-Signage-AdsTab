# Digital Signage - Quick Start Guide

## 🚀 Cara Cepat Memulai

### 1. Setup Backend (5 menit)

```bash
# Masuk ke folder backend
cd backend

# Install dependencies
go mod download

# Copy file .env
cp .env.example .env

# Edit .env (gunakan text editor)
nano .env  # atau code .env
```

Edit minimal setting ini di `.env`:
```env
DB_PASSWORD=your_postgres_password
JWT_SECRET=change-this-to-random-secret
```

```bash
# Buat database
createdb digital_signage

# Jalankan server
go run main.go
```

Server akan berjalan di `http://localhost:8080`

### 2. Setup Flutter App (2 menit)

```bash
# Kembali ke root folder
cd ..

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

## 🎯 Test API Backend

### Register User Pertama

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123",
    "display_name": "Admin"
  }'
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "email": "admin@example.com",
    "display_name": "Admin",
    "role": "admin"
  }
}
```

Simpan token untuk request selanjutnya!

### Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

### Create Ad (dengan token)

```bash
curl -X POST http://localhost:8080/api/v1/ads \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "title": "Promo Spesial",
    "media_url": "https://example.com/image.jpg",
    "media_type": "image",
    "duration_seconds": 5,
    "target_locations": ["all"]
  }'
```

### Get All Ads

```bash
curl http://localhost:8080/api/v1/ads
```

## 📱 Menggunakan Flutter App

1. Jalankan aplikasi: `flutter run`
2. Pilih device (Android, iOS, atau Chrome)
3. Aplikasi akan membuka splash screen
4. Login dengan credentials yang sudah dibuat
5. Admin Dashboard akan muncul

### Screens:
- **Login/Register**: Authentication
- **Admin Dashboard**: Statistik dan overview
- **Ads Management**: Upload dan manage iklan
- **Devices**: Monitor perangkat display
- **Analytics**: Lihat performa iklan
- **Display Screen**: Tampilan untuk digital signage

## 🔧 Troubleshooting Cepat

### Backend tidak bisa start

**Error**: `connection refused`
```bash
# Check PostgreSQL running
sudo systemctl status postgresql  # Linux
brew services list               # macOS

# Start PostgreSQL jika mati
sudo systemctl start postgresql  # Linux
brew services start postgresql   # macOS
```

**Error**: `database "digital_signage" does not exist`
```bash
createdb digital_signage
```

### Flutter tidak bisa connect ke backend

**Android Emulator**: Ubah `lib/config/api_config.dart`
```dart
static const String baseUrl = 'http://10.0.2.2:8080/api/v1';
```

**iOS Simulator/Real Device**: Pastikan device dan laptop di network yang sama, lalu ubah ke IP laptop:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api/v1';
```

### Upload file tidak berfungsi

```bash
# Pastikan folder uploads ada dan writable
cd backend
mkdir -p uploads
chmod 755 uploads
```

## 📊 Database Tools

### Lihat data users
```bash
psql digital_signage -c "SELECT id, email, display_name, role FROM users;"
```

### Lihat data ads
```bash
psql digital_signage -c "SELECT id, title, media_type, is_enabled FROM ads WHERE is_deleted = false;"
```

### Reset database (HATI-HATI!)
```bash
dropdb digital_signage
createdb digital_signage
# Restart backend untuk auto-migrate
```

## 🎨 Customize

### Ubah Port Backend
Edit `backend/.env`:
```env
PORT=3000
```

Lalu update Flutter `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
```

### Ubah Upload Size Limit
Edit `backend/.env`:
```env
MAX_UPLOAD_SIZE=200  # dalam MB
```

### Ubah JWT Token Expiry
Edit `backend/utils/jwt.go`:
```go
ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour * 30)), // 30 days
```

## 🚀 Production Tips

### Backend Production

1. **Build binary**:
```bash
cd backend
CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o digital-signage-backend .
```

2. **Set production mode**:
```env
GIN_MODE=release
```

3. **Use environment variables** instead of .env file

4. **Setup SSL** dengan Nginx/Caddy

### Flutter Production

1. **Android**:
```bash
flutter build apk --release
# APK di: build/app/outputs/flutter-apk/app-release.apk
```

2. **iOS**:
```bash
flutter build ios --release
# Buka Xcode untuk sign dan distribute
```

3. **Web**:
```bash
flutter build web --release
# Output di: build/web/
```

## 📞 Need Help?

- Backend API: `backend/README.md`
- Migration Guide: `MIGRATION_GUIDE.md`
- API Endpoints: Test di `http://localhost:8080/health`

Selamat mencoba! 🎉
