# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Civic Issue Reporter is a Flutter mobile application that enables citizens to report civic infrastructure issues (potholes, garbage, streetlight problems) using AI-powered image validation via Google Gemini 1.5 Pro, Firebase backend services, and Google Maps integration.

## Common Development Commands

### Setup & Dependencies
```bash
# Install dependencies
flutter pub get

# Check Flutter environment and identify issues
flutter doctor

# Generate Firebase configuration (run after Firebase Console setup)
dart pub global activate flutterfire_cli
flutterfire configure

# Clean build artifacts and reinstall dependencies
flutter clean && flutter pub get
```

### Running the App
```bash
# List available devices (emulators and physical devices)
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run on iOS
flutter run -d ios

# Run with verbose logging
flutter run -v
```

### Development & Debugging
```bash
# View real-time logs
flutter logs

# Analyze code for errors and warnings
flutter analyze

# Run tests (when test files exist)
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Building
```bash
# Build APK for Android
flutter build apk

# Build release APK
flutter build apk --release

# Build app bundle for Play Store
flutter build appbundle

# Build iOS app (requires macOS + Xcode)
flutter build ios
```

### Android-Specific Commands
```bash
# Get SHA-1 certificate fingerprint (required for Firebase Google Sign-In)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# On Windows (PowerShell)
keytool -list -v -keystore $env:USERPROFILE\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Architecture Overview

### Application Flow
1. **Authentication Flow**: App starts with `AuthWrapper` that listens to Firebase auth state via `StreamBuilder`
2. **Navigation**: After login, `HomeScreen` provides bottom navigation between Map, Report, and Profile screens
3. **Report Submission Flow**:
   - User captures/selects image → GeminiService analyzes → LocationService gets coordinates → StorageService uploads image → FirestoreService saves report + updates karma
4. **Real-time Updates**: Map screen uses Firestore snapshots to display markers for all reports in real-time

### Service Layer Architecture
All business logic is isolated in service classes (singleton pattern via factory constructors implied by usage):
- **AuthService**: Firebase Authentication + Google Sign-In, creates user documents on first login
- **GeminiService**: Sends base64-encoded images to Gemini 1.5 Pro API with structured JSON prompt, handles markdown code block extraction from responses
- **FirestoreService**: CRUD operations for reports and users, implements karma system (10 points per report)
- **StorageService**: Uploads images to Firebase Storage under `reports/{userId}/{timestamp}.jpg`
- **LocationService**: Geolocator integration for current position + reverse geocoding

### State Management
- Uses simple `setState()` for local screen state (no Provider/BLoC implemented yet despite Provider being in dependencies)
- Firebase auth state managed via `StreamBuilder` in main.dart
- Firestore data exposed as `Stream<List<Report>>` for reactive UI updates

### Data Models
**Report Model** (`models/report.dart`):
- Fields: imageUrl, lat, long, issueType (pothole/garbage/streetlight), severity (low/medium/high), status (pending), userId, timestamp
- Firestore converters: `toMap()` and `fromMap()` with Timestamp handling

**User Document** (Firestore `users` collection):
- Created on first sign-in via `AuthService._createUserDocument()`
- Fields: userId, email, karmaPoints (incremented by FirestoreService), createdAt

### Gemini AI Integration
- Model: `gemini-1.5-pro`
- Temperature: 0.4 (lower = more deterministic)
- Validation logic: Rejects images with people, animals, selfies, or irrelevant content
- Returns structured JSON with validation status, issue type, severity, and description
- Response parsing handles markdown code blocks (```json...```)

## Configuration Requirements

### Critical Setup Steps
Before the app can run, these configuration steps MUST be completed (see README.md and SETUP_CHECKLIST.md for details):

1. **Firebase Setup**:
   - Run `flutterfire configure` to generate `lib/firebase_options.dart`
   - Place `google-services.json` in `android/app/`
   - Place `GoogleService-Info.plist` in `ios/Runner/` (iOS only)
   - Enable Google Sign-In in Firebase Console
   - Add SHA-1 fingerprint to Firebase Console for Android

2. **API Keys**:
   - **Gemini API Key**: Replace `YOUR_GEMINI_API_KEY_HERE` in `lib/services/gemini_service.dart` (line 7)
   - **Google Maps API Key**: Add to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`
   - Enable Maps SDK for Android, Maps SDK for iOS, Geocoding API, and Geolocation API in Google Cloud Console

3. **Permissions** (already configured in manifests):
   - Android: INTERNET, ACCESS_FINE_LOCATION, ACCESS_COARSE_LOCATION, CAMERA
   - iOS: NSLocationWhenInUseUsageDescription, NSCameraUsageDescription, NSPhotoLibraryUsageDescription

### API Key Security
⚠️ **IMPORTANT**: The Gemini API key is currently hardcoded in `gemini_service.dart`. For production:
- Never commit actual API keys to version control
- Use `flutter_dotenv` package or Firebase Remote Config for secure key management
- Consider moving API calls to a backend service to hide keys entirely

## Known Issues & Troubleshooting

- **Firebase initialization error**: Verify `firebase_options.dart` exists and is imported in `main.dart`
- **Google Sign-In fails on Android**: Check SHA-1 certificate fingerprint is added to Firebase Console
- **Blank Google Maps**: Verify API key is correctly added to AndroidManifest.xml and Maps SDK is enabled
- **Gemini API errors**: Check API key validity and quota in Google AI Studio
- **Location permission denied**: Ensure permissions are declared in AndroidManifest.xml and Info.plist

## Project Structure Reference

```
lib/
├── main.dart                     # App entry, Firebase init, AuthWrapper
├── models/report.dart            # Report data model with Firestore converters
├── screens/
│   ├── login_screen.dart         # Google Sign-In UI
│   ├── home_screen.dart          # Bottom navigation wrapper (Map/Report/Profile)
│   ├── map_screen.dart           # Google Maps with real-time report markers
│   ├── report_screen.dart        # Image capture + AI validation + submission
│   └── profile_screen.dart       # User stats and karma display
└── services/
    ├── auth_service.dart         # Firebase Auth + Google Sign-In + user document creation
    ├── firestore_service.dart    # Reports CRUD + karma system + leaderboard
    ├── storage_service.dart      # Firebase Storage image uploads
    ├── gemini_service.dart       # Gemini 1.5 Pro image analysis
    └── location_service.dart     # Geolocation + reverse geocoding
```

## Firestore Data Schema

### `users` Collection
```json
{
  "userId": "string (Firebase Auth UID)",
  "email": "string",
  "karmaPoints": "number (incremented by 10 per report)",
  "createdAt": "timestamp"
}
```

### `reports` Collection
```json
{
  "imageUrl": "string (Firebase Storage URL)",
  "lat": "number",
  "long": "number",
  "issueType": "pothole | garbage | streetlight",
  "severity": "low | medium | high",
  "status": "pending",
  "userId": "string (reporter's UID)",
  "timestamp": "timestamp"
}
```

## Code Patterns & Conventions

- **Error Handling**: Services use try-catch with `print()` for errors and `rethrow` to propagate to UI layer
- **Async Operations**: Screens show loading indicators (`CircularProgressIndicator`) during async operations
- **File Naming**: Snake_case for files (e.g., `report_screen.dart`), PascalCase for classes (e.g., `ReportScreen`)
- **Service Instantiation**: Services instantiated directly in screens (no dependency injection framework)
- **Linting**: Uses `package:flutter_lints/flutter.yaml` - run `flutter analyze` to check compliance

## Testing Notes

- No test files currently exist in `test/` directory (empty or default only)
- When adding tests, use `flutter test` or `flutter test test/<file_name>.dart`
- Consider adding widget tests for screens and unit tests for services

## Platform-Specific Notes

### Android
- minSdkVersion: 21 (required for Firebase)
- targetSdkVersion: 33
- Package name: `com.civicreporter.civic_issue_reporter`

### iOS
- Minimum iOS version: 13.0 (set in Podfile)
- Bundle ID: `com.civicreporter.civicIssueReporter`
- Requires Xcode for building and signing

### Windows (Current Development Environment)
- Use PowerShell commands for certificate fingerprint extraction
- Android development requires Android Studio with SDK installed
- iOS development not possible on Windows
