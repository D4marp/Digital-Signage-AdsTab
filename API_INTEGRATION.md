# API Integration Documentation

## ✅ Status Koneksi

**Backend:** ✅ Running di http://127.0.0.1:8080  
**Database:** ✅ MySQL terhubung  
**Flutter:** ✅ Terhubung dengan REST API  
**iOS Simulator:** 🔄 Sedang launching

## 📡 Konfigurasi API

### Base URLs
```dart
baseUrl: 'http://127.0.0.1:8080/api/v1'
uploadBaseUrl: 'http://127.0.0.1:8080'
```

> **Note:** Menggunakan `127.0.0.1` untuk kompatibilitas iOS simulator yang lebih baik dibanding `localhost`

### Authentication
- **Type:** JWT Bearer Token
- **Storage:** SharedPreferences
- **Header:** `Authorization: Bearer <token>`
- **Expiration:** 7 hari

## 🔌 Endpoint yang Tersedia

### 1. Authentication (`/auth`)
| Method | Endpoint | Deskripsi | Body |
|--------|----------|-----------|------|
| POST | `/auth/register` | Register user baru | email, password, display_name, role |
| POST | `/auth/login` | Login user | email, password |
| GET | `/auth/me` | Get current user | - |
| POST | `/auth/reset-password` | Reset password | email, new_password, token |

### 2. Ads Management (`/ads`)
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/ads` | Get semua ads | ❌ |
| GET | `/ads/:id` | Get ad by ID | ❌ |
| POST | `/ads` | Create ad baru | ✅ |
| PUT | `/ads/:id` | Update ad | ✅ |
| DELETE | `/ads/:id` | Delete ad | ✅ |
| POST | `/ads/upload` | Upload media file | ✅ |
| POST | `/ads/reorder` | Reorder ads | ✅ |

### 3. Devices Management (`/devices`)
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/devices` | Get semua devices | ✅ |
| GET | `/devices/:id` | Get device by ID | ✅ |
| POST | `/devices/register` | Register device baru | ❌ |
| PUT | `/devices/:id` | Update device | ✅ |
| DELETE | `/devices/:id` | Delete device | ✅ |
| POST | `/devices/:id/heartbeat` | Send heartbeat | ❌ |
| POST | `/devices/:id/increment-views` | Increment views | ❌ |

### 4. Analytics (`/analytics`)
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| POST | `/analytics/impressions` | Track impression | ❌ |
| GET | `/analytics` | Get analytics data | ✅ |
| GET | `/analytics/dashboard` | Get dashboard stats | ✅ |
| GET | `/analytics/ads/:id/performance` | Get ad performance | ✅ |

## 🔄 Provider Architecture

### AuthProvider
```dart
// Login
await authProvider.signIn(email, password);

// Register
await authProvider.signUp(email, password, displayName);

// Logout
await authProvider.signOut();

// Check auth status
bool isAuthenticated = authProvider.isAuthenticated;
UserModel? user = authProvider.user;
```

### AdProvider
```dart
// Get ads
await adProvider.fetchAds();
List<AdModel> ads = adProvider.ads;

// Create ad
await adProvider.createAd(adModel);

// Update ad
await adProvider.updateAd(id, adModel);

// Delete ad
await adProvider.deleteAd(id);

// Upload media
String url = await adProvider.uploadMedia(file);

// Stream ads (real-time)
Stream<List<AdModel>> stream = adProvider.getAdsStream();
```

### DeviceProvider
```dart
// Register device
await deviceProvider.registerDevice(deviceModel);

// Get devices
await deviceProvider.fetchDevices();
List<DeviceModel> devices = deviceProvider.devices;

// Send heartbeat
await deviceProvider.sendHeartbeat(deviceId);

// Update status
await deviceProvider.updateDeviceStatus(deviceId, isActive);

// Stream devices
Stream<List<DeviceModel>> stream = deviceProvider.getDevicesStream();
```

### AnalyticsProvider
```dart
// Track impression
await analyticsProvider.trackImpression(impressionModel);

// Get analytics
await analyticsProvider.fetchAnalytics(adId, startDate, endDate);
List<AdAnalytics> analytics = analyticsProvider.analytics;

// Get dashboard stats
await analyticsProvider.fetchDashboardStats();
DashboardStats? stats = analyticsProvider.dashboardStats;

// Get ad performance
await analyticsProvider.fetchAdPerformance(adId);
```

## 🔐 API Client Setup

### Interceptors
```dart
// Auto-inject JWT token
onRequest: (options, handler) async {
  final token = await SharedPreferences.getInstance()
      .then((prefs) => prefs.getString('auth_token'));
  if (token != null) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  return handler.next(options);
}

// Auto-handle 401 Unauthorized
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    // Clear token and navigate to login
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.remove('auth_token'));
  }
  return handler.next(error);
}
```

### Timeout Configuration
- **Connect Timeout:** 30 detik
- **Receive Timeout:** 30 detik

## 📱 Testing Flow

### 1. Manual Testing
```bash
# Test backend health
curl http://127.0.0.1:8080/health

# Login
curl -X POST http://127.0.0.1:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"admin123"}'

# Get current user (with token)
curl http://127.0.0.1:8080/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. Automated Testing
```bash
# Run integration test script
./test_connection.sh
```

### 3. Flutter App Testing
**iPhone 16 Pro:**
```bash
flutter run -d 'iPhone 16 Pro'
```

**macOS Desktop:**
```bash
flutter run -d macos
```

**Chrome Web:**
```bash
flutter run -d chrome --web-port 3000
```

## 🧪 Test Credentials

**Admin Account:**
- Email: `admin@test.com`
- Password: `admin123`
- Role: `admin`
- User ID: `c2c85e40-681b-4f57-8de5-f4125ec3b50e`

## 🐛 Troubleshooting

### iOS Simulator tidak bisa connect
**Problem:** Error "Failed to connect to localhost:8080"
**Solution:** Gunakan `127.0.0.1` instead of `localhost`
```dart
// ✅ Good
static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

// ❌ Bad
static const String baseUrl = 'http://localhost:8080/api/v1';
```

### 401 Unauthorized Error
**Problem:** API returns 401 even after login
**Solution:** Check token storage
```dart
// Debug token
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');
print('Current token: $token');
```

### CORS Error (Web only)
**Problem:** CORS policy blocking requests
**Solution:** Backend sudah configured untuk allow all origins
```go
// backend/main.go
config := cors.DefaultConfig()
config.AllowAllOrigins = true
```

### Media Upload Failed
**Problem:** File upload returns 500 error
**Solution:** Check uploads directory exists
```bash
mkdir -p backend/uploads
```

### Database Connection Error
**Problem:** "Error 1045: Access denied for user"
**Solution:** Check MySQL credentials di `.env`
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=digital_signage
```

## 📊 Model Structures

### UserModel
```dart
{
  "id": "uuid",
  "email": "string",
  "display_name": "string",
  "role": "admin|user",
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### AdModel
```dart
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "media_url": "string",
  "media_type": "image|video",
  "duration": int,
  "order_index": int,
  "is_active": bool,
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### DeviceModel
```dart
{
  "id": "uuid",
  "name": "string",
  "device_id": "string",
  "location": "string",
  "status": "online|offline",
  "last_active": "datetime",
  "total_views": int,
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

### DashboardStats
```dart
{
  "todayImpressions": int,
  "totalImpressions": int,
  "activeDevices": int,
  "totalAds": int,
  "topAds": [
    {
      "id": "uuid",
      "title": "string",
      "impressions": int
    }
  ]
}
```

### AdAnalytics
```dart
{
  "date": "string",
  "impressions": int,
  "unique_devices": int
}
```

## 🚀 Deployment Checklist

### Development Mode (Current)
- ✅ Base URL: `http://127.0.0.1:8080`
- ✅ CORS: Allow all origins
- ✅ GIN_MODE: debug
- ✅ MySQL: No password (local)

### Production Mode
- ⬜ Base URL: `https://your-domain.com`
- ⬜ CORS: Specific origins only
- ⬜ GIN_MODE: release
- ⬜ MySQL: Strong password
- ⬜ JWT_SECRET: Random secure string
- ⬜ HTTPS/SSL certificates
- ⬜ Rate limiting enabled
- ⬜ Error logging to file

## 📝 Next Steps

1. ✅ Test login flow di iPhone simulator
2. ✅ Test dashboard loading
3. ✅ Test ad CRUD operations
4. ✅ Test media upload
5. ✅ Test device registration
6. ✅ Test analytics tracking
7. ⬜ Deploy to production server
8. ⬜ Test on physical devices

---

**Last Updated:** January 9, 2026  
**Backend Version:** 1.0.0  
**Flutter Version:** 3.x  
**Database:** MySQL 8.0
