# Civic Issue Reporter

A Flutter mobile application that leverages Google's Firebase, Gemini AI, and Google Maps to enable citizens to report civic infrastructure issues like potholes, garbage, and streetlight problems.

## Features

- 🔐 **Google Sign-In** - One-tap authentication with Firebase
- 📸 **Smart Image Capture** - Camera and gallery support
- 🤖 **AI-Powered Validation** - Gemini 1.5 Pro analyzes and validates civic issues
- 🗺️ **Live Issue Map** - Real-time visualization of all reported issues
- 📍 **Reverse Geocoding** - Converts coordinates to readable addresses
- ⭐ **Karma System** - Earn points for reporting issues
- 👤 **User Profiles** - Track your contributions and karma

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI**: Google Gemini 1.5 Pro
- **Maps**: Google Maps Flutter SDK
- **Location**: Geolocator & Geocoding packages

## Prerequisites

- Flutter SDK (3.10.4 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account
- Google Cloud Platform account
- Gemini API key

## Setup Instructions

### 1. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and create a new project
3. Follow the setup wizard

#### Add Android App
1. In Firebase Console, click "Add app" → Android
2. Enter your package name: `com.civicreporter.civic_issue_reporter`
3. Download `google-services.json`
4. Place it in `android/app/`

#### Add iOS App (if targeting iOS)
1. Click "Add app" → iOS
2. Enter bundle ID: `com.civicreporter.civicIssueReporter`
3. Download `GoogleService-Info.plist`
4. Add it to your iOS project in Xcode

#### Enable Firebase Services
1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Google" sign-in provider
   - Add your SHA-1 certificate fingerprint (for Android)
   
2. **Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Choose "Start in test mode" for development
   - Select your region
   
3. **Storage**:
   - Go to Storage
   - Click "Get started"
   - Use default security rules for development

#### Configure FlutterFire
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This will generate `lib/firebase_options.dart` automatically.

Update `lib/main.dart` to use the generated options:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 2. Google Maps Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Geolocation API

3. Create API credentials:
   - Go to "Credentials"
   - Create API key
   - Restrict the key to your app's package name/bundle ID

#### Android Configuration
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

#### iOS Configuration
Add to `ios/Runner/AppDelegate.swift`:
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

Also update `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location to tag civic issues</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs your location to tag civic issues</string>
```

### 3. Gemini AI Setup

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Get API Key"
3. Create a new API key for Gemini

4. Add your API key to `lib/services/gemini_service.dart`:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**⚠️ Security Note**: For production, never hardcode API keys. Use environment variables or secure storage like `flutter_dotenv` or Firebase Remote Config.

### 4. Android Configuration

Update `android/app/build.gradle`:
```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21  // Required for Firebase
        targetSdkVersion 33
        multiDexEnabled true
    }
}

dependencies {
    implementation 'com.android.support:multidex:1.0.3'
}
```

Add permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

### 5. iOS Configuration

Update `ios/Podfile`:
```ruby
platform :ios, '13.0'
```

Add permissions to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture civic issues</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

### 6. Google Sign-In Configuration

#### Android
1. Get SHA-1 certificate fingerprint:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Add SHA-1 to Firebase Console (Project Settings → Your Android App)

#### iOS
1. Add URL schemes in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner → Info → URL Types
   - Add your reversed client ID (from `GoogleService-Info.plist`)

## Installation

1. Clone the repository:
```bash
cd civic_issue_reporter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For a specific device
flutter devices
flutter run -d <device-id>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── models/
│   └── report.dart             # Report data model
├── screens/
│   ├── login_screen.dart       # Google Sign-In UI
│   ├── home_screen.dart        # Navigation wrapper
│   ├── map_screen.dart         # Google Maps with markers
│   ├── report_screen.dart      # Image capture & AI validation
│   └── profile_screen.dart     # User profile & karma
└── services/
    ├── auth_service.dart       # Firebase Authentication
    ├── firestore_service.dart  # Firestore database operations
    ├── storage_service.dart    # Firebase Storage for images
    ├── gemini_service.dart     # Gemini AI integration
    └── location_service.dart   # Geolocation & geocoding
```

## Firestore Data Schema

### `users` Collection
```json
{
  "userId": "string",
  "email": "string",
  "karmaPoints": "number",
  "createdAt": "timestamp"
}
```

### `reports` Collection
```json
{
  "imageUrl": "string",
  "lat": "number",
  "long": "number",
  "issueType": "pothole | garbage | streetlight",
  "severity": "low | medium | high",
  "status": "pending",
  "userId": "string",
  "timestamp": "timestamp"
}
```

## Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /reports/{reportId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## Firebase Storage Security Rules (Production)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /reports/{userId}/{filename} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Gemini AI Prompt

The app uses this prompt for image analysis:
```
Analyze this image. Identify if it contains a civic issue: pothole, garbage, or streetlight problem.
Return strictly JSON only with this exact format:
{
  "valid": true/false,
  "type": "pothole" | "garbage" | "streetlight" | null,
  "severity": "low" | "medium" | "high" | null,
  "description": "brief description" | null
}

Rules:
- Set "valid" to false if the image contains people, animals, selfies, or irrelevant content
- Only set "valid" to true if you detect a clear civic infrastructure issue
- For valid images, provide type, severity, and description
- For invalid images, set type, severity, and description to null
```

## Development Tips

### Hot Reload
```bash
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart
```

### Debugging
```bash
flutter logs
flutter doctor
flutter clean && flutter pub get
```

### Testing on Physical Device

#### Android
1. Enable Developer Options on your device
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter devices` to verify
5. Run `flutter run`

#### iOS
1. Connect iPhone/iPad via USB
2. Trust the computer on your device
3. Open Xcode → Signing & Capabilities
4. Select your development team
5. Run `flutter run`

## Common Issues & Solutions

### Issue: Firebase initialization error
**Solution**: Make sure you've run `flutterfire configure` and the `firebase_options.dart` file exists.

### Issue: Google Sign-In not working on Android
**Solution**: Verify SHA-1 certificate is added to Firebase Console.

### Issue: Google Maps shows blank screen
**Solution**: Check that you've enabled Maps SDK and added API key to AndroidManifest.xml / iOS configuration.

### Issue: Gemini API errors
**Solution**: Verify API key is correct and has proper permissions in Google AI Studio.

### Issue: Location permission denied
**Solution**: Check that permissions are added to AndroidManifest.xml and Info.plist.

## MVP Scope

This is an MVP (Minimum Viable Product) with the following features:
- ✅ Google Sign-In authentication
- ✅ Camera/Gallery image capture
- ✅ AI-powered image validation
- ✅ Real-time issue reporting
- ✅ Interactive map with markers
- ✅ User profiles with karma points
- ✅ Reverse geocoding for addresses

## Future Enhancements

- Admin dashboard for issue management
- Push notifications for status updates
- EXIF GPS data extraction from gallery images
- Social sharing features
- Leaderboard system
- Issue status tracking by authorities
- Multi-language support

## Demo Preparation

For hackathon demo:
1. Pre-populate some test reports in Firestore
2. Prepare 3-4 test images (potholes, garbage, streetlight issues)
3. Practice the flow: Sign in → Capture → AI validates → Submit → View on map
4. Highlight the AI validation rejecting invalid images (selfies, etc.)
5. Show karma points increasing after submission

## License

This project is created for hackathon/educational purposes.

## Support

For issues or questions, please check:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Gemini API Documentation](https://ai.google.dev/docs)
