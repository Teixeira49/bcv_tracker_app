---
name: Flutter GetX Navigation
description: Context-less navigation, named routes, and middleware using GetX. Use when adding a screen, navigating between views, passing arguments between routes, guarding a route, opening or closing dialogs and modals, configuring page transitions, or fixing navigation that leaves the stack in a wrong state. Also use when generic Flutter material suggests Navigator, MaterialPageRoute or GoRouter — this app routes with GetX named routes.
metadata:
  labels: [navigation, getx, routing, middleware]
  source: https://github.com/ngxtm/devkit (MIT) — rules/flutter/getx-navigation
  adapted: "2026-08-03 — alineada con .agents/rules/navigation-convention.md y con el binding único de esta app (DTA-001)"
  triggers:
    files: ['**/routes.dart', '**/pages.dart']
    keywords: [GetPage, Get.to, Get.off, Get.offAll, Get.toNamed, GetMiddleware, AppRoutes, AppPages]
---

# GetX Navigation

## **Priority: P0 (CRITICAL)**

Decoupled navigation system allowing UI transitions without `BuildContext`.

> **Adaptada a este repositorio.** El original venía de `ngxtm/devkit` (MIT) y asumía un `Binding` por ruta y los nombres `AppPages`/`_Paths`/`Routes`. Aquí las rutas viven en `lib/config/routes/` (`AppRoutes` para las constantes, `AppPages` para los `GetPage`) y **toda** dependencia se registra en un único `initial_bindings.dart`. La regla vinculante es [`.agents/rules/navigation-convention.md`](../../rules/navigation-convention.md); esta skill explica el cómo.

## Implementation Guidelines

- **Prefer Named Routes**: Use `Get.toNamed(AppRoutes.x)`. Never pass a widget (`Get.to(() => Page())`) — that leaves the screen out of the route table, unreachable by deep link and coupled to its constructor.
- **No Context Navigation**: Leverage `Get.toNamed()`, `Get.back()`, etc., directly from controllers. Navigation is a controller decision, not a widget one.
- **Navigation Methods**:
  - `Get.toNamed()`: push the next screen onto the stack.
  - `Get.offNamed()`: replace the current screen (e.g. Splash → Home).
  - `Get.offAllNamed()`: clear the stack and navigate (e.g. logout, or Splash → Dashboard).
  - `Get.back()`: close the current screen, dialog or bottom sheet.
- **One binding, not one per route.** ⚠️ *Changed from the original, which said "Bindings Everywhere".* This app registers the entire object graph in `lib/config/bindings/initial_bindings.dart`, wired once as `GetMaterialApp(initialBinding: InitialBinding())`. Do **not** add a `binding:` to a `GetPage` and do not create `HomeBinding`, `ConverterBinding`, etc. — see [`.agents/rules/dependency-injection.md`](../../rules/dependency-injection.md). Per-route bindings are the idiomatic GetX pattern in general; they are not the pattern here, and mixing both makes it impossible to tell where a controller comes from.
- **Middleware**: Use `GetMiddleware` for route guards instead of logic inside views. The app has no guards today; if a screen ever needs one (a market behind a setting, a first-run flow), this is where it goes rather than an early `return` inside `build`.
- **Transitions belong to the route**, not to the call site: declare `transition:` and `transitionDuration:` on the `GetPage` so every entry into that screen animates identically.

## Code Example

```dart
// lib/config/routes/routes.dart — the names
abstract class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
}

// lib/config/routes/pages.dart — the table
class AppPages {
  static const initPage = AppRoutes.splash;

  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.home,
      page: () => DashboardPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
      // no `binding:` — the graph is in InitialBinding
    ),
  ];
}

// Usage in a controller
void finishSplash() {
  Get.offAllNamed(AppRoutes.home);
}

// Route guard, when one is needed
class MarketEnabledMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) =>
      Get.find<SettingsController>().hasAnyMarket
          ? null
          : const RouteSettings(name: AppRoutes.home);
}
```

## Passing arguments

Use `arguments`, not the constructor — a route referenced by name cannot receive constructor parameters:

```dart
Get.toNamed(AppRoutes.detail, arguments: currency);

// read it in the destination controller, not in build()
final Currency currency = Get.arguments as Currency;
```

For values that must survive a cold start from a deep link, prefer route parameters (`/detail/:code` + `Get.parameters['code']`): `arguments` is in-memory only and is lost when the OS launches the app straight into that route.

## Tabs are not routes

Switching bottom-bar tabs changes `NavigationController.selectedIndex`; it does not push a route. Reserve the router for screens that stack on top of the dashboard. Calling `Get.toNamed` to change tab would grow the stack on every tap and break the back button.

## Anti-Patterns

- **Mixing Context and GetX**: Do not use `Navigator.of(context)` or `MaterialPageRoute` when GetX is the router — the resulting routes are invisible to GetX and `Get.back()` stops behaving predictably.
- **Hardcoded Strings**: Always use `AppRoutes` constants. A typo'd route string fails at runtime, not at compile time.
- **Widgets passed to the navigator**: `Get.to(() => Page())` / `Get.offAll(() => Page())`.
- **Dialogs without GetX**: Use `Get.dialog()`, `Get.bottomSheet()` and `Get.back()` to close. Mixing `showDialog` + `Navigator.pop` with GetX routing means two stacks with two ways to pop.
- **Navigation from the data layer**: a repository or datasource that redirects on error couples transport to UI. Return the error; let the controller decide.

## Deuda conocida en este repo

Corrígelas al tocar esos archivos (boy-scout), sin desviar el objetivo del PR:

- `lib/features/splash/presentation/page/splash_page.dart:24` — `Get.offAll(() => DashboardPage())` con `AppRoutes.home` ya registrado. La transición debería moverse al `GetPage`.
- `lib/shared/presentation/widgets/base_modal.dart:38` y `lib/features/converter/presentation/widget/converter_modals.dart:69` — cierran con `Navigator.pop(context)` en lugar de `Get.back()`.

## Reference & Examples

For centralized route configuration and middleware guards:
See [references/app-pages.md](references/app-pages.md) and [references/middleware-example.md](references/middleware-example.md).

> Ambas referencias son las del origen y usan la convención `AppPages`/`_Paths` con un binding por ruta. Léelas por el patrón de `GetMiddleware`, no por la estructura de bindings.

## Related Topics

`getx-architecture` (estado, ciclo de vida e inyección) | `.agents/rules/navigation-convention.md` (la regla vinculante)
