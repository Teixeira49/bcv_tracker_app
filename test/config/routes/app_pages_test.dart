import 'package:bcv_tracker_app/config/routes/pages.dart';
import 'package:bcv_tracker_app/config/routes/routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every route constant declared in [AppRoutes], read reflectively-by-hand.
/// Kept next to the routes so adding a constant without listing it here is an
/// obvious omission in the same file.
const List<String> _declaredRoutes = [AppRoutes.splash, AppRoutes.home];

void main() {
  group('AppPages', () {
    test('registers a GetPage for every declared route', () {
      final registered = AppPages.routes.map((page) => page.name).toSet();

      // The bug this guards against: a constant added to `AppRoutes` but never
      // registered in `AppPages.routes`. With named routes wired into
      // `GetMaterialApp`, `Get.toNamed` on an unregistered name fails at
      // runtime, not at compile time — exactly what #58 set out to make
      // impossible to ship silently.
      for (final route in _declaredRoutes) {
        expect(
          registered,
          contains(route),
          reason: 'No GetPage registered for "$route" in AppPages.routes.',
        );
      }
    });

    test('does not register a route name twice', () {
      final names = AppPages.routes.map((page) => page.name).toList();
      expect(
        names.length,
        names.toSet().length,
        reason: 'Duplicate route name in AppPages.routes.',
      );
    });

    test('starts on the splash', () {
      expect(AppPages.initPage, AppRoutes.splash);
      expect(
        AppPages.routes.map((page) => page.name),
        contains(AppPages.initPage),
      );
    });

    test('every registered page builds a widget', () {
      // A `GetPage` whose `page` builder throws would only surface when the
      // route is hit. Building each one here catches a broken builder up front.
      for (final page in AppPages.routes) {
        expect(
          page.page(),
          isNotNull,
          reason: 'Route "${page.name}" builds null.',
        );
      }
    });
  });
}
