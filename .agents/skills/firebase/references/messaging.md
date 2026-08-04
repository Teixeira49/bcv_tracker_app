---
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# 03 - Firebase Cloud Messaging (`firebase_messaging`)

## Goal
Implement reliable push notifications via FCM (Firebase Cloud Messaging). FCM requires careful handling of three distinct application states: Foreground, Background, and Terminated.

## Instructions

### 1. Prerequisites: Apple Platform Settings (CRITICAL)
FCM cannot deliver notifications to iOS devices out of the box. You *must* configure the Apple Developer Portal and Xcode.
**Rule:**
1. Generate an APNs Auth Key in the Apple Developer console and upload it to the Firebase console.
2. In Xcode, enable the "Push Notifications" capability.
3. In Xcode, enable the "Background Modes" -> "Remote notifications" capability.

### 2. Requesting Permissions
iOS and Web require explicit user permission before delivering payloads.

```dart
final messaging = FirebaseMessaging.instance;

NotificationSettings settings = await messaging.requestPermission(
  alert: true,
  announcement: false,
  badge: true,
  carPlay: false,
  criticalAlert: false,
  provisional: false, // Set to true for quiet iOS delivery
  sound: true,
);

if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  print('User granted permission');
} else {
  print('User declined or has not accepted permission');
}
```

### 3. The FCM Token
To send a message to a specific device, you need its FCM Registration Token. Whenever this token refreshes, you should save it to your Database (Firestore/Serverpod) associated with the `UserId`.

```dart
// Get the token initially
final String? token = await FirebaseMessaging.instance.getToken();
print("FCM Token: $token");

// Listen for token refreshes
FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
  // TODO: Send to your backend APIs
}).onError((err) {
  // Error handling
});
```

### 4. Handling Messages (The 3 States)

#### A. Foreground State
When the app is actively open on the screen. **By default, FCM will NOT display a visible heads-up notification in the foreground on Android.**

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    // You must manually show a local notification here using 
    // `flutter_local_notifications` if you want a visible banner.
  }
});
```

#### B. Background & Terminated State (Top-Level Function)
When the app is minimized or completely killed. You MUST define a `pragma('vm:entry-point')` top-level function outside of any class to handle these payloads.

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Register the background handler BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}
```

#### C. Handling Interaction (User Taps)
If the user taps a notification to open the app from a Terminated state, it is captured by `getInitialMessage`. If tapped from a Background state, it triggers the `onMessageOpenedApp` stream.

```dart
// 1. App completely terminated
final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
if (initialMessage != null) {
  _handleMessage(initialMessage); // Navigate to a specific screen
}

// 2. App minimized in background
FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
```

## Constraints
* **Background Isolation:** The `_firebaseMessagingBackgroundHandler` runs in a separate isolate. You CANNOT update UI state (`setState`) or access standard global variables directly from this function. If you need to alert the UI, utilize Isolate ports or write to a local database.
