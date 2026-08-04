---
name: "integrating-sentry"
description: "Integrates Sentry error tracking and performance monitoring into Flutter apps using `sentry_flutter`. Use when setting up crash reporting in Flutter, calling `SentryFlutter.init`, adding `SentryNavigatorObserver` to GoRouter, tracing HTTP requests with `sentry_dio`, capturing handled exceptions via `Sentry.captureException`, adding breadcrumbs, configuring session replay (`replay.onErrorSampleRate`), tuning `tracesSampleRate` or `profilesSampleRate`, controlling PII with `sendDefaultPii`, or setting user context after login and logout."
metadata:
  last_modified: "2026-04-01 14:35:00 (GMT+8)"
---

# Sentry Flutter Integration Guide (`sentry_flutter`)

## Goal
Implement a robust observability and performance monitoring layer using Sentry's official Flutter SDK. This skill ensures comprehensive error tracking across the UI and Network layers, alongside performance tracking (Tracing) for application navigation and HTTP requests, without exhausting Sentry data quotas or exposing PII.

## Instructions

### 1. Core Initialization (`sentry_flutter`)
You must initialize Sentry as early as possible in your application's lifecycle, wrapping `runApp` with `SentryWidget` to capture AssetBundle transaction times and basic UI interactions natively.

```dart
import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn = '___PUBLIC_DSN___'; // Inject via --dart-define or .env
      
      // Controls the percentage of Tracing (Performance) transactions sent.
      // 1.0 = 100%. (Reduce in production to avoid quota exhaustion!)
      options.tracesSampleRate = 0.2; 
      
      // Profiles provide deep CPU-level insights. Tied to TracesSampleRate.
      options.profilesSampleRate = 1.0; 

      // Replay sessions to visually debug errors.
      options.replay.onErrorSampleRate = 1.0; 
      options.replay.sessionSampleRate = 0.1;

      // Ensure PII (Personally Identifiable Information) isn't recklessly sent
      options.sendDefaultPii = false; 
    },
    appRunner: () => runApp(
      SentryWidget(
        child: const MyApp(),
      ),
    ),
  );
}
```

### 2. Routing Instrumentation (`GoRouter`)
Sentry can automatically track how long it takes to render a screen and trace the navigation paths of users. If you are using `go_router` (the standard Flutter routing solution), you must inject the `SentryNavigatorObserver`.

```dart
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  // 1. Add the observer to the main router
  observers: [
    SentryNavigatorObserver(),
  ],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => const DetailsScreen(),
    ),
  ],
);
```
*Note: This automatically creates Spans and Breadcrumbs every time `context.go()` or `context.push()` is invoked.*

### 3. HTTP Network Instrumentation (`sentry_dio`)
To trace the time spent on backend API calls and automatically log failed HTTP requests (400s, 500s) directly to Sentry, utilize the `sentry_dio` package.

```dart
import 'package:dio/dio.dart';
import 'package:sentry_dio/sentry_dio.dart';

final dio = Dio(
  BaseOptions(baseUrl: 'https://api.yourbackend.com'),
);

// Add the Sentry interceptor. This captures all requests/responses natively.
dio.addSentry(
  captureFailedRequests: true, // Automatically logs 4xx and 5xx responses as Exceptions
);

// Now, simply make requests. Sentry tracks the latency and errors implicitly.
Future<void> fetchUsers() async {
  final response = await dio.get('/users'); 
}
```

### 4. Manual Capturing (Exceptions & Breadcrumbs)
While Sentry automatically catches unhandled UI and async errors, you often need to manually record caught exceptions or leave "Breadcrumbs" (logging hints) leading up to an error.

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> checkout(Cart cart) async {
  // 1. Leave a Breadcrumb
  Sentry.addBreadcrumb(Breadcrumb(
    message: 'User initiated checkout process',
    category: 'ecommerce.checkout',
    level: SentryLevel.info,
    data: {'cartTotal': cart.totalPrice},
  ));

  try {
    await api.processPayment(cart);
  } catch (exception, stackTrace) {
    // 2. Capture a handled Exception explicitly
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
    // Show a user-friendly error UI
  }
}

// 3. User Context (Add this after Login)
void setUserContext(String userId, String email) {
  Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId, email: email)));
}

// 4. Clear User Context (Add this after Logout)
void clearUserContext() {
  Sentry.configureScope((scope) => scope.setUser(null));
}
```

## Constraints
1. **Production Limits:** NEVER deploy a high-volume application to production with `tracesSampleRate = 1.0` unless you have an infinite budget. Start at `0.1` (10%) and adjust based on your monthly Sentry quota.
2. **PII Handling:** Be extremely careful not to put user passwords, session tokens, or raw payment details into custom `Breadcrumb` `data` dictionaries. Keep `sendDefaultPii = false` unless strictly required & vetted by security policies.
3. **Interceptor Order:** When initializing a `Dio` client with multiple interceptors (like Auth or Logging), ensure `dio.addSentry()` is initialized so it can capture the fully mutated requests (e.g., after Authorization headers are attached).
