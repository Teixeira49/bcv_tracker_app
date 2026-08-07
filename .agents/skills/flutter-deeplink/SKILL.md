---
name: "configuring-deep-links"
description: "Configures deep linking in Flutter using Android App Links (assetlinks.json) and iOS Universal Links (apple-app-site-association) integrated with GoRouter v17.x navigation. Use this skill when setting up HTTPS domain association, handling magic links or email verification links, routing marketing campaign URLs (Google Ads, Facebook Ads) into the app, implementing password reset or invite flows via deep links, fixing deep link verification failures, troubleshooting GoRouter deep link integration, or any time the words 'deep link', 'universal link', 'app link', 'assetlinks', 'AASA', 'magic link', or 'deeplinking' appear in the request. Avoids deprecated custom URL schemes (myapp://)."
metadata:
  last_modified: "2026-04-01 14:35:00 (GMT+8)"
---

# Flutter Deep Linking (with GoRouter v17.x)

## Goal
Implement secure, professional Deep Links (HTTPS Domain Association) to successfully route organic URLs, marketing campaigns (Google Ads), and Magic Link auth payloads directly into a Flutter application. Avoid older Custom URL Schemes (`myapp://`) whenever possible, guaranteeing a seamless fallback to web browsers if the app is currently uninstalled.

## Instructions

### 1. Android App Links Setup

#### **`AndroidManifest.xml`**
Insert the `intent-filter` explicitly instructing Android to `autoVerify` the HTTPS domain. This lives directly inside the core `<activity>` tag (usually `.MainActivity`):

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Replace with the actual requested domain -->
    <data android:scheme="https" android:host="yourdomain.com" />
</intent-filter>
```

#### **Web Hosting (`assetlinks.json`)**
You must host a JSON payload securely proving ownership at exactly:
`https://yourdomain.com/.well-known/assetlinks.json`

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.yourapp",
    "sha256_cert_fingerprints": [
      "YOUR_SHA256_CERT_FINGERPRINT_1"
    ]
  }
}]
```
*Constraints*: 
- The file must be served strictly over HTTPS.
- Must return a `Content-Type: application/json` header natively.

### 2. iOS Universal Links Setup

#### **Xcode Entitlements**
1. Open `ios/Runner.xcworkspace` utilizing Xcode.
2. Select the Runner Target -> "Signing & Capabilities".
3. Add the **Associated Domains** capability.
4. Add the exact required string entry: `applinks:yourdomain.com`

#### **Web Hosting (`apple-app-site-association`)**
You must host an AASA (Apple App Site Association) file proving ownership at exactly:
`https://yourdomain.com/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.com.yourcompany.yourapp",
        "paths": ["*"]
      }
    ]
  }
}
```
*Constraints*: 
- The file **MUST NOT** possess a `.json` extension physically.
- Must return a `Content-Type: application/json` header natively.
- **Must not be gzipped** by the server (Apple's CDN rejects compresses formats silently).

### 3. Flutter Integration (GoRouter)
By default, the Flutter Framework natively captures validated `Intents`/`NSUserActivity` payloads triggered by the operating systems. If your application uses `go_router`, it will intercept the path and autonomously navigate if a matching `GoRoute` exists.

```dart
final router = GoRouter(
  routes: [
    // A Deep Link opening "https://yourdomain.com/events/123" maps here natively!
    GoRoute(
      path: '/events/:id',
      builder: (context, state) => EventScreen(id: state.pathParameters['id']!),
    ),
  ],
);
```
**No external third-party plugins (like `uni_links` or `app_links`) are required** strictly for navigation if `go_router` governs the `MaterialApp.router`. 

*Constraint*: If migrating an older codebase heavily utilizing legacy plugins, verify `flutter_deeplinking_enabled` is NOT manually disabled natively inside `AndroidManifest.xml` or `Info.plist`.

## Verification & Testing

### **CLI Testing**
Simulate clicking a Deep Link from totally outside the app environment natively checking if the OS launches the sandbox:

**Android (adb):**
```bash
adb shell am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "https://yourdomain.com/events/123" com.yourcompany.yourapp
```

**iOS (xcrun):**
```bash
xcrun simctl openurl booted "https://yourdomain.com/events/123"
```

### **DevTools Validator**
The absolute best practice for heavily debugging failing configuration domains is exclusively launching the **Flutter Deeplinking Validator** built directly inside Dart DevTools. It strictly verifies your `assetlinks.json` and `apple-app-site-association` cloud deployments, explicitly flagging missing headers or misaligned App IDs easily.
