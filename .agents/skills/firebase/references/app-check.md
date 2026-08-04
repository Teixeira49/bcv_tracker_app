---
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# App Check Security (`firebase_app_check`)

## Goal
Protect your Firebase backend resources (Firestore, Storage, Realtime Database, Cloud Functions) from abuse, billing fraud, and unauthorized API calls originating from bots, curl scripts, or modified emulators.

## Instructions

### The Necessity of App Check
Even if you write perfect Firestore Security Rules (`if request.auth != null`), anyone who extracts an active user's auth token can still write a Python script to bombard your database and run up your billing.

App Check solves this by proving that the API request is originating from a legitimate, unmodified Apple/Android device running your authentic application.

### Initialization Matrix
You must initialize App Check *immediately* after Firebase Core initialization. You need to configure a specific provider for each platform.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    // Web: Requires a reCAPTCHA v3 site key
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Android: Use PlayIntegrity (the modern replacement for SafetyNet)
    androidProvider: AndroidProvider.playIntegrity,
    // iOS: Use DeviceCheck or AppAttest
    appleProvider: AppleProvider.deviceCheck,
  );

  runApp(const MyApp());
}
```

### Debug Providers (CRITICAL)
If you turn on App Check enforcement in the Firebase Console, your local iOS Simulators and Android Emulators **will instantly be blocked** from accessing Firestore because they are not "real" devices.

To fix this for local development, you must use the `DebugProvider`.

```dart
import 'package:flutter/foundation.dart';

// Inside main()
await FirebaseAppCheck.instance.activate(
  // Use debug providers during local kDebugMode development!
  androidProvider: kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
);
```

When you run the app on an emulator for the first time with the Debug provider, a **Secret Debug Token** will be printed into your VSCode/Android Studio terminal. 
You MUST copy this token, go to the Firebase Console -> App Check -> Apps -> Manage Debug Tokens, and paste it there to whitelist your local emulator.

## Constraints
* **Firebase Console Enforcement:** Merely initializing the package in Flutter does nothing until you press "Enforce" on the specific product (e.g., Firestore) within the Firebase Console's App Check tab.
* **Grace Period:** NEVER turn on App Check "Enforcement" for an app that is already in production without giving users a few weeks to update their apps via the App Store/Play Store. Old app versions without the App Check SDK will be completely locked out of the database.
