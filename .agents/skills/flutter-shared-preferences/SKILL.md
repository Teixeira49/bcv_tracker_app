---
name: "managing-shared-preferences"
description: "SharedPreferences (v2.5.5) for Flutter providing simple persistent key-value storage for non-sensitive user settings and app preferences. Use this skill when storing user preferences (theme mode, language selection, font size), app settings and configuration, feature flags or A/B test assignments, simple cache data, onboarding completion status, last selected values (filters, sort options), user consent flags, or any non-sensitive data that survives app restarts. Supports String, int, double, bool, and StringList types. NOT suitable for storing tokens, passwords, API keys, or any sensitive/encrypted data (use flutter_secure_storage instead). Ideal for quick persistent storage without database overhead."
metadata:
  last_modified: "2026-04-27 17:41:00 (GMT+8)"
---

# SharedPreferences Simple Storage Guide

## Goal
Implement lightweight key-value storage for non-sensitive app settings and user preferences using SharedPreferences. Best for simple configuration data that persists across app sessions.

## Process

### Phase 1: Install Dependencies

```yaml
dependencies:
  shared_preferences: ^2.5.5
```

### Phase 2: Create Static Wrapper (Best Practice)

Create a type-safe static wrapper to prevent key fragmentation:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _instance;
  
  static Future<void> init() async {
    _instance = await SharedPreferences.getInstance();
  }
  
  // Theme preference
  static bool get isDarkMode => _instance.getBool(_Keys.isDarkMode) ?? false;
  static Future<void> setDarkMode(bool value) => _instance.setBool(_Keys.isDarkMode, value);
  
  // User name
  static String? get userName => _instance.getString(_Keys.userName);
  static Future<void> setUserName(String value) => _instance.setString(_Keys.userName, value);
  
  // Onboarding completed
  static bool get hasCompletedOnboarding => _instance.getBool(_Keys.onboardingCompleted) ?? false;
  static Future<void> setOnboardingCompleted(bool value) => _instance.setBool(_Keys.onboardingCompleted, value);
  
  // Feature flags
  static bool get isFeatureXEnabled => _instance.getBool(_Keys.featureX) ?? false;
  static Future<void> setFeatureX(bool value) => _instance.setBool(_Keys.featureX, value);
  
  // Clear all preferences
  static Future<void> clear() => _instance.clear();
}

class _Keys {
  static const String isDarkMode = 'is_dark_mode';
  static const String userName = 'user_name';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String featureX = 'feature_x_enabled';
}
```

### Phase 3: Initialize in main()

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(MyApp());
}
```

### Phase 4: Usage in App

```dart
// Read
final isDark = Prefs.isDarkMode;
final name = Prefs.userName ?? 'Guest';

// Write
await Prefs.setDarkMode(true);
await Prefs.setUserName('John Doe');

// Clear all
await Prefs.clear();
```

### Phase 5: Integration with State Management

**With Riverpod**:
```dart
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier();
});

class DarkModeNotifier extends StateNotifier<bool> {
  DarkModeNotifier() : super(Prefs.isDarkMode);
  
  Future<void> toggle() async {
    state = !state;
    await Prefs.setDarkMode(state);
  }
}
```

**With BLoC**:
```dart
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(isDark: Prefs.isDarkMode));
  
  Future<void> toggleTheme() async {
    final newValue = !state.isDark;
    await Prefs.setDarkMode(newValue);
    emit(state.copyWith(isDark: newValue));
  }
}
```

---

## Constraints

* **No Sensitive Data**: NEVER store passwords, tokens, API keys, or PII. Use SecureStorage instead.
* **Type Safety**: Always use static wrappers to prevent string key typos.
* **Size Limit**: Keep stored data small. Not suitable for large datasets or complex objects.
* **Synchronous After Init**: After initialization, getters are synchronous. Only setters are async.
* **Platform Limits**: iOS has NSUserDefaults limits (~1MB recommended).
