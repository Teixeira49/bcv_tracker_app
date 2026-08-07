---
name: "firebase-auth"
description: "Expert guide for Firebase Authentication covering auth state management, email/password, anonymous, phone, and social providers (Google, Apple, Facebook) credential flows with signInWithCredential pattern."
metadata:
  last_modified: "2026-03-12 11:18:17 (GMT+8)"
---

# Firebase Authentication (`firebase_auth`)

## Goal
Securely authenticate and manage users using Firebase Authentication. This covers the central auth state stream, standard login methods, and the critical credential-bridge pattern required for all native social sign-in integrations.

---

## Instructions

### Auth State (The Single Source of Truth)
Never cache a boolean `isLoggedIn`. Observe `authStateChanges()` which emits on every sign-in, sign-out, and token expiry.

```dart
// listen globally — typically in a Riverpod StreamProvider at app root
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
```

> **Constraint**: Avoid `.currentUser` — it may return `null` during SDK initialization. Always consume the stream.

---

### Email & Password
```dart
// Registration — immediately send verification email
try {
  final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  await cred.user?.sendEmailVerification();
} on FirebaseAuthException catch (e) {
  switch (e.code) {
    case 'weak-password': // ...
    case 'email-already-in-use': // ...
  }
}

// Login
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found' || e.code == 'wrong-password') {
    // Show invalid credentials message
  }
}
```

---

### Anonymous Login (Guest Mode)
```dart
final cred = await FirebaseAuth.instance.signInAnonymously();
// Can later "upgrade" to permanent account via linkWithCredential()
```

---

### Social Providers — Credential Bridge Pattern
Firebase does NOT open native OAuth sheets itself. You MUST use the native SDK to get a credential, then pass it to `signInWithCredential()`.

```
NativeSDK.login() → OAuthCredential → FirebaseAuth.signInWithCredential()
```

#### Google Sign-In (`google_sign_in ^7.2.0`)
```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithGoogle() async {
  await GoogleSignIn.instance.initialize();
  await GoogleSignIn.instance.authenticate();

  // Listen to authenticationEvents stream to get GoogleSignInAccount
  // Then get the ID token from authorizationClient:
  final account = GoogleSignIn.instance.currentUser;
  if (account == null) return null;

  final auth = await account.authorizationClient.authorizationForScopes([]);
  final credential = GoogleAuthProvider.credential(
    idToken: auth?.idToken,
    accessToken: auth?.accessToken,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
}
```

#### Apple Sign-In (`sign_in_with_apple ^7.0.1` + `crypto`)
Apple requires a `nonce` to prevent replay attacks. The raw nonce is sent to Apple; its SHA-256 hash is sent to Firebase.

```dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';

String _generateNonce([int length = 32]) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

String _sha256ofString(String input) =>
    sha256.convert(utf8.encode(input)).toString();

Future<UserCredential?> signInWithApple() async {
  final rawNonce = _generateNonce();
  final nonce = _sha256ofString(rawNonce);

  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    nonce: nonce,
  );

  final oauthCredential = OAuthProvider('apple.com').credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce, // raw (unhashed) nonce for Firebase
  );
  return FirebaseAuth.instance.signInWithCredential(oauthCredential);
}
```

#### Facebook Login (`flutter_facebook_auth ^7.1.5`)
```dart
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential?> signInWithFacebook() async {
  final result = await FacebookAuth.instance.login();
  if (result.status != LoginStatus.success) return null;

  final credential = FacebookAuthProvider.credential(
    result.accessToken!.tokenString,
  );
  return FirebaseAuth.instance.signInWithCredential(credential);
}
```

---

### Phone Authentication
```dart
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+886912345678',
  verificationCompleted: (PhoneAuthCredential credential) async {
    // Auto-resolved on Android
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) { /* handle */ },
  codeSent: (String verificationId, int? resendToken) {
    // Store verificationId, show OTP input
  },
  codeAutoRetrievalTimeout: (String verificationId) {},
);

// After user enters OTP:
final credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: userInputCode,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

---

### Sign-Out
```dart
await FirebaseAuth.instance.signOut();
// authStateChanges() emits null → router navigates to Login
```

---

## Constraints
* **`emailVerified` Quirk**: Facebook login does NOT set `user.emailVerified = true`. If you gate features behind email verification, explicitly handle Facebook users separately.
* **Account Auto-Merging**: If a user created an email/password account and then signs in with Google using the same email, Firebase automatically upgrades to Google as the auth provider (trusted provider merge).
* **Nonce is Mandatory for Apple**: Omitting the nonce in Apple Sign-In allows replay attacks. Always generate and hash it as shown above.
* **Manual Installation for Google**: `google_sign_in` requires `google-services.json` / `GoogleService-Info.plist` — Dart-only Firebase initialization is NOT supported.
