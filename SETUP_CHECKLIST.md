# Setup Checklist

Use this checklist to ensure all configuration is complete before running the app.

## ☑️ Pre-Flight Checklist

### 1. Firebase Configuration
- [ ] Created Firebase project in console
- [ ] Added Android app to Firebase
- [ ] Downloaded and placed `google-services.json` in `android/app/`
- [ ] (iOS) Added iOS app and placed `GoogleService-Info.plist`
- [ ] Enabled Google Sign-In in Firebase Authentication
- [ ] Created Firestore database (test mode for development)
- [ ] Enabled Firebase Storage
- [ ] Ran `flutterfire configure` command
- [ ] Verified `lib/firebase_options.dart` exists
- [ ] Updated `lib/main.dart` with Firebase options import

### 2. Google Maps Configuration
- [ ] Enabled Maps SDK for Android in Google Cloud Console
- [ ] Enabled Maps SDK for iOS in Google Cloud Console
- [ ] Enabled Geocoding API
- [ ] Created Google Maps API key
- [ ] Added API key to `android/app/src/main/AndroidManifest.xml`
- [ ] (iOS) Added API key to `ios/Runner/AppDelegate.swift`
- [ ] Added location permissions to AndroidManifest.xml
- [ ] (iOS) Added location permissions to Info.plist

### 3. Gemini AI Configuration
- [ ] Created Gemini API key from Google AI Studio
- [ ] Replaced `YOUR_GEMINI_API_KEY_HERE` in `lib/services/gemini_service.dart`

### 4. Google Sign-In Configuration
- [ ] Generated SHA-1 certificate fingerprint (Android)
- [ ] Added SHA-1 to Firebase Console
- [ ] (iOS) Added URL schemes in Xcode

### 5. Android Specific
- [ ] Updated minSdkVersion to 21 in `android/app/build.gradle`
- [ ] Added required permissions to AndroidManifest.xml:
  - [ ] INTERNET
  - [ ] ACCESS_FINE_LOCATION
  - [ ] ACCESS_COARSE_LOCATION
  - [ ] CAMERA

### 6. iOS Specific (if targeting iOS)
- [ ] Updated platform to iOS 13.0 in `ios/Podfile`
- [ ] Added camera permission to Info.plist
- [ ] Added photo library permission to Info.plist
- [ ] Added location permissions to Info.plist

### 7. Dependencies
- [ ] Ran `flutter pub get`
- [ ] Verified no dependency conflicts

### 8. Testing
- [ ] Ran `flutter doctor` to check environment
- [ ] Connected test device (physical or emulator)
- [ ] Ran `flutter devices` to verify device connection

## 🚀 Quick Commands

```bash
# Install dependencies
flutter pub get

# Check Flutter environment
flutter doctor

# List connected devices
flutter devices

# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Clean build
flutter clean && flutter pub get
```

## ⚠️ Common First-Time Errors

1. **Firebase not initialized**: Run `flutterfire configure`
2. **Google Sign-In fails**: Add SHA-1 to Firebase Console
3. **Maps not showing**: Check API key and enable Maps SDK
4. **Camera not working**: Check permissions in manifest/Info.plist
5. **Location not working**: Enable location permissions

## 📝 Configuration Files to Modify

Before first run, update these files with your actual keys:

1. `lib/services/gemini_service.dart` - Add Gemini API key
2. `android/app/src/main/AndroidManifest.xml` - Add Google Maps API key
3. `ios/Runner/AppDelegate.swift` - Add Google Maps API key (iOS)
4. `android/app/` - Place `google-services.json`
5. `ios/Runner/` - Place `GoogleService-Info.plist` (iOS)

## ✅ Ready to Run

Once all checkboxes are complete, run:
```bash
flutter run
```

The app should now launch successfully!
