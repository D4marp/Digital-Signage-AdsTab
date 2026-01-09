# Setup Instructions

## Quick Start Guide

Follow these steps to get your Digital Signage app up and running:

### 1. Install Flutter

If you haven't installed Flutter yet:

```bash
# macOS
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/macos

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:[PATH_TO_FLUTTER_DIRECTORY]/flutter/bin"

# Verify installation
flutter doctor
```

### 2. Firebase Project Setup

#### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `digital-signage-app`
4. Disable Google Analytics (optional)
5. Click "Create project"

#### Enable Firebase Services

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Save

2. **Cloud Firestore**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "production mode"
   - Choose location closest to your users
   - Click "Enable"

3. **Cloud Storage**
   - Go to Storage
   - Click "Get started"
   - Start in "production mode"
   - Click "Done"

#### Configure Firebase Rules

1. **Firestore Rules** (Database → Rules tab):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /ads/{adId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /impressions/{impressionId} {
      allow read: if request.auth != null;
      allow create: if true;
    }
    
    match /devices/{deviceId} {
      allow read, write: if true;
    }
  }
}
```

2. **Storage Rules** (Storage → Rules tab):
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /ads/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.resource.size < 50 * 1024 * 1024;
    }
  }
}
```

### 3. Connect Flutter to Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Navigate to your project
cd /Users/HCMPublic/Documents/Damar/digital_signage

# Configure Firebase
flutterfire configure
# Select your Firebase project
# Select platforms: iOS, Android, Web
```

This will automatically generate `lib/firebase_options.dart` with your Firebase configuration.

### 4. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# For iOS, install pods
cd ios
pod install
cd ..
```

### 5. Create Asset Directories

```bash
mkdir -p assets/images
mkdir -p assets/icons
```

### 6. Run the App

```bash
# Check for any issues
flutter doctor

# Run on connected device
flutter run

# Or run on specific platform
flutter run -d chrome  # Web
flutter run -d [device-id]  # Android/iOS
```

## Testing the App

### Create First Admin User

1. Launch the app
2. Select "Admin Mode"
3. Click "Register"
4. Enter:
   - Name: Test Admin
   - Email: admin@test.com
   - Password: test123
5. Check email for verification (if enabled)
6. Login

### Upload First Ad

1. Go to "Ads" tab
2. Click "+" button
3. Select an image or video
4. Enter title: "Test Ad"
5. Set duration: 5 seconds
6. Upload

### Test Display Mode

1. Open app on another device/browser
2. Select "Display Mode"
3. Enter location: "Test Location"
4. Ad should start playing

### View Analytics

1. Go back to Admin Dashboard
2. Select "Analytics" tab
3. Select the ad you uploaded
4. View impression data from the display device

## Production Deployment

### Android Tablet (Display App)

1. **Build Release APK**
```bash
flutter build apk --release --split-per-abi
```

2. **Install on Tablet**
```bash
adb install build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

3. **Configure Kiosk Mode**
   - Use Android Enterprise
   - Or install a kiosk app from Play Store
   - Set Digital Signage as default launcher

### Web (Admin Dashboard)

1. **Build for Web**
```bash
flutter build web --release
```

2. **Deploy to Firebase Hosting**
```bash
firebase init hosting
# Select 'build/web' as public directory
firebase deploy --only hosting
```

3. **Access Admin Dashboard**
   - Visit: https://your-project-id.web.app
   - Login with admin credentials

### iOS (Optional)

1. **Open in Xcode**
```bash
open ios/Runner.xcworkspace
```

2. **Configure Signing**
   - Select your team
   - Update bundle identifier

3. **Build and Archive**
   - Product → Archive
   - Distribute to App Store or TestFlight

## Environment-Specific Configuration

### Development
- Use Firebase emulators for local testing
- Enable debug mode
- Use test accounts

### Staging
- Use separate Firebase project
- Test with sample data
- Verify all features

### Production
- Use production Firebase project
- Enable email verification
- Configure proper security rules
- Monitor usage and costs

## Troubleshooting

### Firebase Connection Issues

```bash
# Check Firebase configuration
flutter packages get
flutterfire configure --force

# Verify Firebase services are enabled in console
```

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get

# For iOS
cd ios && pod install && cd ..

# Rebuild
flutter run
```

### Video Playback Issues

- Ensure videos are MP4 format
- Keep file size under 50MB
- Use H.264 codec for best compatibility

### Analytics Not Tracking

- Check Firestore rules
- Verify device has internet connection
- Check Firebase console for errors

## Security Checklist

- [ ] Firebase rules are properly configured
- [ ] Email verification is enabled
- [ ] Storage rules limit file sizes
- [ ] Authentication is required for admin features
- [ ] Display app can only write impressions
- [ ] Admin credentials are secure

## Performance Tips

1. **Image Optimization**
   - Compress images before upload
   - Recommended: 1920x1080 for landscape
   - Format: JPG for photos, PNG for graphics

2. **Video Optimization**
   - Use H.264 codec
   - Bitrate: 2-5 Mbps
   - Resolution: 1920x1080
   - Format: MP4

3. **Network**
   - Tablets should have stable WiFi
   - Minimum: 5 Mbps download
   - Cache ads for offline fallback

## Support

If you encounter any issues:

1. Check the README.md for documentation
2. Review Firebase console for errors
3. Check Flutter doctor output
4. Review app logs: `flutter logs`

## Next Steps

1. ✅ Set up Firebase project
2. ✅ Configure Firebase rules
3. ✅ Run the app locally
4. ✅ Create admin account
5. ✅ Upload test ads
6. ✅ Test display mode
7. ✅ Deploy to production
8. 📋 Monitor analytics
9. 📋 Train staff on usage
10. 📋 Set up regular backups

---

**Ready to go!** Your Digital Signage system is now set up and ready for use.
