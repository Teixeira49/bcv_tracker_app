---
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# Observability (`firebase_analytics`, `firebase_crashlytics`)

## Goal
Implement a robust observability layer to track user engagement metrics (Analytics) and automatically trap and report fatal/non-fatal errors before they reach production users (Crashlytics).

## Instructions

### Firebase Crashlytics (Global Error Trapping)
You must configure Crashlytics to catch both Flutter UI errors and underlying asynchronous Isolate errors. Do this immediately in `main.dart`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. Catch all errors thrown by the Flutter framework (UI rendering, layout errors)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // 2. Catch asynchronous errors (Promises/Futures that weren't awaited)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // Return true to indicate the error was handled
  };

  runApp(const MyApp());
}
```
*Note: Crashlytics automatically captures native Android (Java/Kotlin) and iOS (Swift/ObjC) crashes without extra Dart code once the package is installed.*

### Firebase Analytics (Event Tracking)
Analytics tracks user journeys. While screen routing can be tracked automatically (via `FirebaseAnalyticsObserver`), custom business events require manual logging.

```dart
final analytics = FirebaseAnalytics.instance;

// Log a custom event (e.g., when a user adds an item to their cart)
Future<void> logAddToCart(String itemId, String itemName, double price) async {
  await analytics.logEvent(
    name: "add_to_cart",
    parameters: {
      "item_id": itemId,
      "item_name": itemName,
      "value": price,
      "currency": "USD",
    },
  );
}

// Log standard user properties to segment audiences in the console
Future<void> setUserProperties(String userId, String userTier) async {
  await analytics.setUserId(id: userId);
  await analytics.setUserProperty(name: "subscription_tier", value: userTier);
}
```

### Route Tracking (AnalyticsObserver)
To automatically see which screens users visit the most, attach the `FirebaseAnalyticsObserver` to your `MaterialApp` or GoRouter instance.

```dart
MaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  home: const HomeScreen(),
)
```

## Constraints
*   **PII (Personally Identifiable Information):** NEVER log emails, physical addresses, phone numbers, or passwords as raw text into Firebase Analytics event parameters. Google will aggressively suspend your Analytics account if PII is detected.
*   **Development Masking:** Crashlytics can quickly become noisy during local development. Consider wrapping the `recordError` calls in `if (!kDebugMode)` checks so you only receive reports from TestFlight or Production.
