# BCV Tracker App — Agent Instructions

Guidance for AI coding agents working in this repository.

> **`CLAUDE.md` and `AGENTS.md` are byte-identical by design — verify with `diff CLAUDE.md AGENTS.md`.** Claude Code reads `CLAUDE.md` and [ignores `AGENTS.md`](https://code.claude.com/docs/en/memory); other agents read `AGENTS.md`. Keeping both in sync means every agent gets the same instructions. **Edit one, copy it over the other in the same commit** — a divergence here is two agents following different rules on the same codebase.

## Project Overview

BCV Tracker is a Flutter mobile app that displays real-time Venezuelan Central Bank (BCV) exchange rates, supports multi-market comparisons, currency conversion, and a 10-language UI. It consumes its own backend, [`bcv_tracker_backend`](https://github.com/Teixeira49/bcv_tracker_backend), and distributes to testers through Firebase App Distribution via Codemagic.

## Conventions — read `.agents/rules/` first

This file is the **map** of the codebase; `.agents/rules/` holds the **binding conventions**. When they disagree, the rules win — and the contradiction gets fixed in the same PR.

`.agents/` is the single source. `.claude/rules/` and `.claude/skills/` are symlinks into it, so Claude Code discovers both natively and no file exists twice. **How each loads differs, and it matters:** four rules are always in context, twelve load only when you touch the files they govern, and skills load on demand from their description. If you are about to do something a path-scoped rule covers and it has not loaded, open it.

### Always in context — the git and GitHub procedures

No file edit can trigger these, so they are unconditional. Shared verbatim with the backend, same `type → gitmoji → label` mapping.

| Rule | Applies when |
|---|---|
| `.agents/rules/issue-convention.md` | Creating a GitHub issue |
| `.agents/rules/branch-naming.md` | Creating a branch (`<type>/DTA-<n>`, linked to its issue) |
| `.agents/rules/commit-convention.md` | Every commit (Conventional Commits + gitmoji) |
| `.agents/rules/pull-request.md` | Preparing or opening a PR (reads `.claude/pr-config.json`) |

### Path-scoped — load when you touch what they govern

| Rule | Triggered by |
|---|---|
| `.agents/rules/entities-vs-models.md` | `shared/data/model/`, `shared/data/datasource/`, any `domain/entities/` |
| `.agents/rules/dependency-injection.md` | `config/bindings/`, any `controller/`, `shared/data/repositories/`, `main.dart` |
| `.agents/rules/navigation-convention.md` | `config/routes/`, any `page/` or `widget(s)/`, `navigation/` |
| `.agents/rules/i18n-convention.md` | `core/i18n/`, any `page/` or `widget(s)/` |
| `.agents/rules/constants-centralization.md` | `core/constants/`, `config/theme/`, any `page/` or `widget(s)/` |
| `.agents/rules/environment-variables.md` | `config/enviroment/`, `.env.example`, `codemagic.yaml`, `README.md` |
| `.agents/rules/test-coverage.md` | `test/`, `shared/data/`, any `controller/`, `core/helpers/` |
| `.agents/rules/documentation-convention.md` | any `.dart` under `lib/` |
| `.agents/rules/version-sources.md` | `pubspec.yaml`, `android/`, `ios/`, `codemagic.yaml` |
| `.agents/rules/release-versioning.md` | `pubspec.yaml`, `CHANGELOG.md`, `docs/release/` |
| `.agents/rules/version-value-proposal.md` | `pubspec.yaml`, `CHANGELOG.md`, `docs/release/` |
| `.agents/rules/release-notes.md` | `release_notes.json`, `CHANGELOG.md`, `docs/release/` |

`.agents/skills/` holds 24 skills from six sources, surfaced to Claude Code through per-skill symlinks in `.claude/skills/` — one source of truth, no copies. Start with **`getx-architecture`** (written for this repo) for anything reactive or structural, and **`getx-navigation`** for routing — no external catalogue covers GetX properly. For UI work: `flutter-design` (aesthetic direction and Material 3 execution), `flutter-ui` (design tokens), `flutter-fix-layout-issues` (constraints and overflow), `design-polish` (deliberate design passes on a device). Need a capability that is missing? `find-skills` looks for one — but read its note first: installing here does not end with `npx skills add`. The rest is reference material, not policy; four still carry examples in packages this app does not use, flagged as pending adaptation in `.agents/README.md`. Provenance and licences are in `.agents/ATTRIBUTION.md`. **Rules override skills.**

## Environment Setup

```bash
cp .env.example .env
```

| Variable | Notes |
|---|---|
| `CURRENCY_BACK` | Backend base URL, **no trailing slash** (paths are absolute, `/api/v1/...`) |

`Environment` (`lib/config/enviroment/enviroment.dart`) is the only place that reads `dotenv.env[...]`. Never commit `.env`, and never put a real URL in `.env.example`.

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run tests
flutter analyze          # Lint / static analysis
dart format .            # Format before committing
flutter build apk --release          # Android release build
cd ios && pod install && cd ..       # iOS CocoaPods setup
flutter build ios --release          # iOS release build
```

## Architecture

**State management**: GetX. Reactive `Rx` state lives in a **service**, not in feature controllers: `CurrencyRepository` (a `GetxService`, `permanent`) owns the observables; feature controllers expose plain unwrapped getters and bridge changes with `ever(...) => update()`; views use `GetBuilder` (17 uses) far more than `Obx` (4). If you add reactive state to a service and forget the `ever`, the screen silently stops refreshing. See `.agents/skills/getx-architecture`.

**Dependency injection**: declared in `lib/config/bindings/initial_bindings.dart` with `Get.lazyPut` / `Get.put`. This is the single place to register controllers, repositories and services — resolve with `Get.find()`, never instantiate a controller inside a widget.

**Feature-first structure under `lib/`**:
- `features/` — self-contained modules (splash, home, converter, settings, dashboard), each with `presentation/` (controller + page + widgets) and `domain/`
- `shared/` — cross-feature entities, repository interfaces (`domain/`), data implementations (`data/`), shared widgets (`presentation/`)
- `core/` — HTTP client, i18n, constants, helpers
- `config/` — routes, theme, environment, bindings
- `navigation/` — bottom tab bar controller

This is **not** Clean Architecture: there is no UseCase layer.

**Data flow**:
```
REST API
  → DollarApiRest (datasource, Dio-based)
  → DollarRepository (IDollarRepository implementation)
  → CurrencyRepository (GetxService, shared state, permanent)
  → HomeController / ConverterController (bridge Rx to update())
  → Views (GetBuilder / Obx)
```

**Key GetX services/controllers**:
- `CurrencyRepository` — persistent service holding live currency data; every feature controller observes it
- `SettingsController` — persists language, theme and followed markets via `SharedPreferences`
- `HomeController` — exposes `averageCurrencies`, `bcvCurrencies`, `isLoading`, `errorMessage`
- `ConverterController` — pivot conversion with VES as base; consolidates average + BCV rates

## Data Modeling

Entities live in `shared/domain/entities/` and `features/*/domain/entities/`. JSON deserialization happens in `shared/data/model/` via `.fromJson()`, then converts to domain entities via `.toEntity()`. Never use model classes in UI or controllers. A model *extends* its entity, so the compiler will not catch the leak — see `.agents/rules/entities-vs-models.md` for the four places a new field has to touch.

## Internationalization

10 languages via GetX `Translations`. Language maps in `lib/core/i18n/languages/` (48 keys, all ten in parity, and `AppMessages` exposes exactly those 48). Use `AppMessages.<key>` for all UI text — never a raw string, and never `'<key>'.tr` in a widget: `app_messages.dart` is the only file that calls `.tr`. A new key goes into all ten files in the same commit, or GetX renders the raw key on screen for the other nine.

## Routing

Named routes in `lib/config/routes/` — constants in `routes.dart` (`AppRoutes`), `GetPage` entries in `pages.dart` (`AppPages`). Navigate with `Get.toNamed()` / `Get.offAllNamed()` — never Flutter's `Navigator`, and never by passing a widget. Close dialogs and modals with `Get.back()`. Transitions belong on the `GetPage`, not the call site. Tabs are not routes: switching tabs changes `NavigationController.selectedIndex`.

## Theming

Light/dark/system themes in `lib/config/theme/`. Colors (`AppColors`), icons and the 8pt spacing grid (`WidthValues`) are centralized there — no `Color(0xFF...)` in widgets. `SettingsController.favBrightness` drives the active theme. The app is still **Material 2**; migration to Material 3 is decided and tracked in [#44](https://github.com/Teixeira49/bcv_tracker_app/issues/44).

## Testing

Tests live in `test/`, mirroring `lib/`. Any change to a data source, a market mapping, a GetX controller or a calculation helper ships with its tests in the same PR. Controllers are tested with `Get.testMode = true`, fakes registered in dependency order, and `Get.reset()` in `tearDown`. `codemagic.yaml` runs `flutter analyze` and `flutter test` before building.

## Versioning

`pubspec.yaml` is the **only** file where the version is edited; Android, iOS and `codemagic.yaml` derive it. Never set the version in Xcode or Gradle. See `.agents/rules/version-sources.md`.

## Known debt

Verified against the code. Fix on contact where the rule says so; do not treat as invisible:

- **GetX workers are never disposed** — `HomeController` and `ConverterController` register `ever()` without `onClose()`. `get` 4.7.3 has no automatic disposal, and `CurrencyRepository` is `permanent`, so listeners accumulate on every `fenix` recreation. Tracked in [#45](https://github.com/Teixeira49/bcv_tracker_app/issues/45).
- **`SettingsController` is registered twice** — `Get.put` in `main.dart:18` and `Get.lazyPut` in `initial_bindings.dart:30`.
- **Navigation deviations** — `splash_page.dart:24` uses `Get.offAll(() => DashboardPage())`; `base_modal.dart:38` and `converter_modals.dart:69` close with `Navigator.pop`.
- **`WidthValues` is unused** — the 8pt grid is declared but the 21 `EdgeInsets` in the app carry bare numbers.
- **Placeholder bundle identifiers** — `com.example.*` on both platforms blocks store publishing. Tracked in [#22](https://github.com/Teixeira49/bcv_tracker_app/issues/22).
- **Invalid locale codes** — `SettingsController` offers `en_EN` and `ja_JA`; `AppTranslations` registers `en_US` and `ja_JP`. It works only because GetX falls back on the language code alone. Correcting them is now **safe**: the selector resolves an unknown stored code to `SettingsController.defaultLanguage` and `restoreLanguageCode` rewrites the preference, so an install carrying the old code no longer breaks the settings screen ([#54](https://github.com/Teixeira49/bcv_tracker_app/issues/54)).
