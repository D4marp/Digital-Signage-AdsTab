# 📺 Digital Signage System

Sistem Digital Signage modern untuk hotel dan restoran dengan backend Golang dan frontend Flutter.

## ✨ Features

### Admin Features
- 🔐 Authentication & User Management
- 📺 Ad Management (Create, Update, Delete, Reorder)
- 📤 Media Upload (Images & Videos)
- 📱 Device Management & Monitoring
- 📊 Analytics & Dashboard
- 🎯 Location-based Ad Targeting
- 📈 Performance Tracking

### Display Features
- 🖼️ Image & Video Playback
- 🔄 Auto-rotation & Scheduling
- 💻 Multi-device Support
- 📡 Real-time Updates
- 🔌 Offline Mode
- 📊 View Tracking

## 🏗️ Architecture

### Backend (Golang)
- **Framework**: Gin
- **Database**: PostgreSQL
- **Authentication**: JWT
- **API**: RESTful
- **File Storage**: Local filesystem

### Frontend (Flutter)
- **State Management**: Provider
- **HTTP Client**: Dio
- **UI Framework**: Material Design
- **Platform**: Cross-platform (Android, iOS, Web)

## 📋 Prerequisites

- **Backend**:
  - Go 1.21+
  - PostgreSQL 12+

- **Frontend**:
  - Flutter SDK 3.0+
  - Dart SDK

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# Make setup script executable
chmod +x setup.sh

# Run setup
./setup.sh
```

### Option 2: Manual Setup

**Backend:**
```bash
cd backend
go mod download
cp .env.example .env
# Edit .env with your settings
createdb digital_signage
go run main.go
```

**Frontend:**
```bash
flutter pub get
flutter run
```

📖 **Detailed Guide**: See [QUICKSTART.md](QUICKSTART.md)

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get started in 5 minutes
- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Full migration details from Firebase
- **[backend/README.md](backend/README.md)** - Backend API documentation

## 🔧 Configuration

### Backend (.env)
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=digital_signage

JWT_SECRET=your-secret-key
PORT=8080
```

### Frontend (lib/config/api_config.dart)
```dart
static const String baseUrl = 'http://localhost:8080/api/v1';
```

## 📡 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register
- `POST /api/v1/auth/login` - Login
- `GET /api/v1/auth/me` - Get current user

### Ads
- `GET /api/v1/ads` - List ads
- `POST /api/v1/ads` - Create ad
- `PUT /api/v1/ads/:id` - Update ad
- `DELETE /api/v1/ads/:id` - Delete ad
- `POST /api/v1/ads/upload` - Upload media

### Devices
- `GET /api/v1/devices` - List devices
- `POST /api/v1/devices/register` - Register device
- `POST /api/v1/devices/:id/heartbeat` - Heartbeat

### Analytics
- `GET /api/v1/analytics/dashboard` - Dashboard stats
- `GET /api/v1/analytics` - Analytics data
- `POST /api/v1/analytics/impressions` - Track view

Full API documentation: [backend/README.md](backend/README.md)

## 🗃️ Database Schema

```
users -> ads -> ad_analytics
      -> devices -> impressions
```

- **users**: User accounts & authentication
- **ads**: Advertisement content & metadata
- **devices**: Display device information
- **impressions**: View tracking
- **ad_analytics**: Aggregated analytics data

## 🖼️ Screenshots

### Admin Dashboard
- Overview statistics
- Device monitoring
- Quick actions

### Ads Management
- Upload media
- Configure targeting
- Reorder ads

### Analytics
- Performance charts
- View statistics
- Device analytics

### Display Screen
- Full-screen ad display
- Auto-rotation
- Video playback

## 🔐 Security

- JWT token-based authentication
- Bcrypt password hashing
- SQL injection protection
- File upload validation
- CORS configuration
- Token expiration

## 🚀 Deployment

### Backend Production

```bash
cd backend
go build -o digital-signage-backend
GIN_MODE=release ./digital-signage-backend
```

Setup with systemd and Nginx reverse proxy (see [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md))

### Frontend Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🧪 Testing

### Backend
```bash
cd backend
go test ./...
```

### API Testing
```bash
# Health check
curl http://localhost:8080/health

# Register user
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123","display_name":"Test User"}'
```

## 🛠️ Development

### Backend
```bash
cd backend

# Run with auto-reload (install air)
go install github.com/cosmtrek/air@latest
air

# Format code
go fmt ./...
```

### Frontend
```bash
# Hot reload
flutter run

# Analyze
flutter analyze

# Format
dart format .
```

## 📦 Project Structure

```
digital_signage/
├── backend/              # Golang Backend
│   ├── config/          # Configuration
│   ├── database/        # DB & migrations
│   ├── handlers/        # API handlers
│   ├── middleware/      # Middlewares
│   ├── models/          # Data models
│   ├── routes/          # API routes
│   ├── utils/           # Utilities
│   └── main.go
│
├── lib/                 # Flutter App
│   ├── config/         # Configuration
│   ├── models/         # Data models
│   ├── providers/      # State management
│   ├── screens/        # UI screens
│   ├── services/       # API services
│   ├── utils/          # Utilities
│   └── main.dart
│
├── QUICKSTART.md       # Quick start guide
├── MIGRATION_GUIDE.md  # Migration details
└── setup.sh           # Setup script
```

## 🐛 Troubleshooting

### Backend won't start
- Check PostgreSQL is running
- Verify database exists
- Check .env configuration

### Flutter connection issues
- Verify backend URL in api_config.dart
- For Android emulator use `10.0.2.2` instead of `localhost`
- Check firewall settings

### File upload fails
- Check uploads directory exists
- Verify permissions
- Check MAX_UPLOAD_SIZE setting

See [QUICKSTART.md](QUICKSTART.md) for detailed troubleshooting

## 🔄 Migration from Firebase

This project has been migrated from Firebase to a custom Golang backend. See [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) for:
- Migration steps
- Breaking changes
- API mapping
- Data migration

## 📄 License

MIT License

## 👥 Contributors

- Development Team

## 📞 Support

For issues and questions:
- Check documentation files
- Review API documentation
- Check troubleshooting guide

---

Made with ❤️ using Golang & Flutter 📱

Flutter-based Digital Signage application for hotels and restaurants, featuring ad management, analytics tracking, and multi-device support.

## 🎯 Features

### Display App (Tablet Mode)
- ✅ Full-screen slideshow with auto-play
- ✅ Support for images (JPG, PNG) and videos (MP4)
- ✅ Offline caching for uninterrupted display
- ✅ Automatic impression tracking
- ✅ Location-based ad targeting
- ✅ Kiosk mode support

### Admin Dashboard
- ✅ Firebase Authentication (Email/Password)
- ✅ Ad Management (Upload, Edit, Delete, Reorder)
- ✅ Analytics Dashboard with real-time metrics
- ✅ Device Management with remote configuration
- ✅ Multi-location support
- ✅ Export analytics (CSV/PDF)

### Analytics Tracking
- ✅ View count per ad
- ✅ View duration tracking
- ✅ Completion rate calculation
- ✅ Per-device and per-location analytics
- ✅ Real-time statistics
- ✅ Date range filtering

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Firebase account
- Android Studio / VS Code
- Git

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable the following services:
     - Authentication (Email/Password)
     - Cloud Firestore
     - Cloud Storage

2. **Configure Firebase for Flutter**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter app
   flutterfire configure
   ```

3. **Update Firebase Rules**

   **Firestore Rules:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // Ads collection
       match /ads/{adId} {
         allow read: if true; // All can read (for display app)
         allow write: if request.auth != null; // Only authenticated users can write
       }
       
       // Impressions collection
       match /impressions/{impressionId} {
         allow read: if request.auth != null; // Only admin can read
         allow create: if true; // Anyone can create (for display app)
       }
       
       // Devices collection
       match /devices/{deviceId} {
         allow read, write: if true; // All devices can register and update
       }
     }
   }
   ```

   **Storage Rules:**
   ```javascript
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /ads/{allPaths=**} {
         allow read: if true; // All can read
         allow write: if request.auth != null; // Only authenticated users can upload
       }
     }
   }
   ```

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd digital_signage
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update Firebase configuration**
   - The `flutterfire configure` command should have created `lib/firebase_options.dart`
   - If not, manually update the Firebase configuration in that file

4. **Create directories for assets**
   ```bash
   mkdir -p assets/images
   mkdir -p assets/icons
   ```

5. **Run the app**
   ```bash
   # For Android
   flutter run
   
   # For Web
   flutter run -d chrome
   
   # For iOS
   flutter run -d ios
   ```

## 📱 Usage

### First Time Setup

1. **Launch the app** - You'll see a mode selection screen
2. **Choose your mode:**
   - **Display Mode**: For tablets that will show ads
   - **Admin Mode**: For managing ads and viewing analytics

### Admin Dashboard

1. **Register/Login**
   - Create an admin account with email and password
   - Email verification is required

2. **Upload Ads**
   - Go to "Ads" tab
   - Click the "+" button
   - Select image or video file
   - Set title, duration, and target locations
   - Upload

3. **View Analytics**
   - Go to "Analytics" tab
   - Select an ad to view its performance
   - Filter by date range
   - See views, duration, completion rate, and more

4. **Manage Devices**
   - Go to "Devices" tab
   - View all registered tablets
   - Configure settings remotely
   - Monitor device status

### Display App (Tablet)

1. **Select Display Mode** on app launch
2. **Enter Location Name** (e.g., "Hotel Lobby", "Restaurant Entrance")
3. **Ads will start playing automatically**
4. **To exit**: Long press on the screen

### Kiosk Mode (Android)

For production deployment on Android tablets:

1. **Enable Developer Options** on the tablet
2. **Install the app** as a system app or use an MDM solution
3. **Configure kiosk mode** using Android Enterprise or third-party kiosk apps
4. **Set the Digital Signage app** as the launcher

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
│
├── models/                   # Data models
│   ├── ad_model.dart
│   ├── impression_model.dart
│   ├── device_model.dart
│   ├── user_model.dart
│   └── ad_analytics.dart
│
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── ad_provider.dart
│   ├── analytics_provider.dart
│   └── device_provider.dart
│
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── display/
│   │   ├── display_home_screen.dart
│   │   └── widgets/
│   │       └── video_ad_widget.dart
│   └── admin/
│       ├── admin_home_screen.dart
│       ├── tabs/
│       │   ├── dashboard_tab.dart
│       │   ├── ads_tab.dart
│       │   ├── analytics_tab.dart
│       │   ├── devices_tab.dart
│       │   └── settings_tab.dart
│       └── widgets/
│           ├── ad_upload_dialog.dart
│           └── ad_edit_dialog.dart
│
└── utils/                    # Utilities
    ├── app_theme.dart
    ├── format_helper.dart
    └── device_helper.dart
```

## 🔧 Configuration

### Slideshow Settings

Edit in `lib/screens/display/display_home_screen.dart`:
- Default duration per ad
- Auto-advance timing
- Cache settings

### Analytics Tracking

Edit in `lib/providers/analytics_provider.dart`:
- Impression tracking logic
- Analytics calculation methods
- Real-time update intervals

### Theme Customization

Edit in `lib/utils/app_theme.dart`:
- Primary colors
- Text styles
- Component themes

## 📊 Database Structure

### Firestore Collections

**ads**
```javascript
{
  title: string,
  mediaUrl: string,
  mediaType: 'image' | 'video',
  durationSeconds: number,
  orderIndex: number,
  isEnabled: boolean,
  targetLocations: string[],
  createdAt: timestamp,
  updatedAt: timestamp,
  createdBy: string,
  isDeleted: boolean
}
```

**impressions**
```javascript
{
  adId: string,
  deviceId: string,
  location: string,
  startTime: timestamp,
  endTime: timestamp,
  durationSeconds: number,
  isCompleted: boolean
}
```

**devices**
```javascript
{
  deviceId: string,
  location: string,
  isOnline: boolean,
  lastActive: timestamp,
  todayViews: number,
  settings: {
    slideshowInterval: number,
    videoAutoplay: boolean,
    enabledAds: string[]
  }
}
```

**users**
```javascript
{
  email: string,
  displayName: string,
  role: 'admin' | 'superadmin',
  createdAt: string
}
```

## 🚀 Deployment

### Android (Tablet)

1. **Build release APK**
   ```bash
   flutter build apk --release
   ```

2. **Install on tablets**
   ```bash
   flutter install
   ```

### Web (Admin Dashboard)

1. **Build for web**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase Hosting**
   ```bash
   firebase init hosting
   firebase deploy --only hosting
   ```

### iOS

1. **Build iOS app**
   ```bash
   flutter build ios --release
   ```

2. **Deploy via Xcode or TestFlight**

## 🔒 Security Considerations

1. **Firebase Rules**: Ensure proper read/write permissions
2. **Authentication**: Enable email verification
3. **Storage**: Limit file size uploads
4. **Rate Limiting**: Configure Firebase to prevent abuse
5. **Kiosk Mode**: Use Android Enterprise for production tablets

## 📈 Performance Optimization

1. **Image Caching**: Automatically caches images for offline use
2. **Video Preloading**: Videos are buffered before display
3. **Database Queries**: Optimized with proper indexing
4. **Analytics Batching**: Impressions are batched for efficiency

## 🐛 Troubleshooting

### Common Issues

1. **Firebase connection error**
   - Check internet connection
   - Verify Firebase configuration
   - Check Firebase console for service status

2. **Video playback issues**
   - Ensure video format is MP4
   - Check video file size
   - Verify internet speed for streaming

3. **Analytics not updating**
   - Check Firestore rules
   - Verify device internet connection
   - Check timestamp synchronization

## 📝 License

This project is licensed under the MIT License.

## 👨‍💻 Author

Created for Digital Signage needs in hotels and restaurants.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📧 Support

For support, email your-email@example.com

---

**Note**: Remember to update Firebase configuration with your own project credentials before deploying to production.
# Digital-Signage-AdsTab
