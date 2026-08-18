# BCV Tracker App — Agent Instructions

Guidance for AI coding agents working in this repository.

> **`CLAUDE.md` and `AGENTS.md` are byte-identical by design — verify with `diff CLAUDE.md AGENTS.md`.** Claude Code reads `CLAUDE.md` and [ignores `AGENTS.md`](https://code.claude.com/docs/en/memory); other agents read `AGENTS.md`. Keeping both in sync means every agent gets the same instructions. **Edit one, copy it over the other in the same commit** — a divergence here is two agents following different rules on the same codebase.

## Project Overview

BCV Tracker is a Flutter mobile app that displays real-time Venezuelan Central Bank (BCV) exchange rates, supports multi-market comparisons, currency conversion, and a 10-language UI. It consumes its own backend, [`bcv_tracker_backend`](https://github.com/Teixeira49/bcv_tracker_backend), and distributes to testers through Firebase App Distribution via Codemagic.

## Conventions — read `.agents/rules/` first

This file is the **map** of the codebase; `.agents/rules/` holds the **binding conventions**. When they disagree, the rules win — and the contradiction gets fixed in the same PR.

`.agents/` is the single source. `.claude/rules/` and `.claude/skills/` are symlinks into it, so Claude Code discovers both natively and no file exists twice. **How each loads differs, and it matters:** four rules are always in context, fifteen load only when you touch the files they govern, and skills load on demand from their description. If you are about to do something a path-scoped rule covers and it has not loaded, open it.

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
| `.agents/rules/logging-convention.md` | `core/logging/`, `core/network/`, `shared/data/`, any `controller/` |
| `.agents/rules/navigation-convention.md` | `config/routes/`, any `page/` or `widget(s)/`, `navigation/` |
| `.agents/rules/i18n-convention.md` | `core/i18n/`, any `page/` or `widget(s)/` |
| `.agents/rules/constants-centralization.md` | `core/constants/`, `config/theme/`, any `page/` or `widget(s)/` |
| `.agents/rules/design-system.md` | `DESIGN.md`, `config/theme/`, any `page/` or `widget(s)/` |
| `.agents/rules/environment-variables.md` | `config/enviroment/`, `.env.example`, `codemagic.yaml`, `README.md` |
| `.agents/rules/test-coverage.md` | `test/`, `shared/data/`, any `controller/`, `core/helpers/` |
| `.agents/rules/documentation-convention.md` | any `.dart` under `lib/` |
| `.agents/rules/documentation-coverage.md` | any `.dart` under `lib/`, `analysis_options.yaml`, `CONTRIBUTING.md` |
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

**State management**: GetX. Reactive `Rx` state lives in a **service**, not in feature controllers: `CurrencyRepository` (a `GetxService`, `permanent`) owns the observables; feature controllers expose plain unwrapped getters and bridge changes with `ever(...) => update()`; views use `GetBuilder` (16 uses) far more than `Obx` (5). The settings screen is the exception, and for a reason: `SettingsController` is a `GetxService` since [#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59), and `GetBuilder<T>` is bound to `T extends GetxController`, so its three selectors read the service with `Obx`. They lost nothing — the service never called `update()`, so those `GetBuilder`s never rebuilt on their own. This `ever → update()` bridge is a **deliberate, retained decision** — the audit proposed migrating to granular `Obx` and it was declined in [#60](https://github.com/Teixeira49/bcv_tracker_app/issues/60), to keep the view↔service boundary (views never name the repository's `Rx` types). Its price is that disposing every worker is a permanent requirement (see below). If you add reactive state to a service and forget the `ever`, the screen silently stops refreshing. See `.agents/skills/getx-architecture`.

**Dependency injection**: declared in `lib/config/bindings/initial_bindings.dart` with `Get.lazyPut` / `Get.put`. This is the single place to register controllers, repositories and services — resolve with `Get.find()`, never instantiate a controller inside a widget.

That file has **two** entry points, and the split is not stylistic. `GetMaterialApp` calls `initialBinding?.dependencies()` from its `initState` and **does not await it** (`get_material_app.dart:226`), so an asynchronous registration declared there is fire-and-forget: the first screen builds while it is still in flight, and `Get.find` on it throws, because `Get.putAsync` only registers the instance once its builder resolves. Anything the **first frame reads** therefore goes in `InitialBinding.initServices()`, which `main` awaits before `runApp` — today that is `SettingsController` ([#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59)). Everything else stays in `dependencies()`.

**Feature-first structure under `lib/`**:
- `features/` — self-contained modules (splash, home, converter, currency_detail, settings, dashboard), each with `presentation/` (controller + page + widgets) and `domain/`
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
- `SettingsController` — a **`GetxService`** (the name is kept for continuity), `permanent`, registered through `InitialBinding.initServices()` and **awaited before the first frame** ([#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59)). Persists language, theme and followed markets via `SharedPreferences`. Startup applies the stored values by **passing** them to `GetMaterialApp` (`themeMode:`, `locale:`), not by calling `Get.changeThemeMode` / `Get.updateLocale` — `GetMaterialApp.initState` assigns `Get.locale` from its own argument, so a locale applied before `runApp` was overwritten on the spot. The setters still use the framework calls; those apply a change to a running app, which is a different job
- `HomeController` — exposes `averageCurrencies`, `bcvCurrencies`, `isLoading`, `errorMessage`
- `ConverterController` — the full converter's selection and state. The **arithmetic** is not here: it lives in `shared/domain/conversion.dart` (`CurrencyConversion`), which the embedded converter of the detail sheet calls too, so the two cannot drift ([#39](https://github.com/Teixeira49/bcv_tracker_app/issues/39))
- `CurrencyDetailController` — holds the rate the detail sheet has open. The rate is a **snapshot handed over by the tapped card**, not a re-fetch; the controller exists so the sections still to come (chart [#5](https://github.com/Teixeira49/bcv_tracker_app/issues/5), actions [#7](https://github.com/Teixeira49/bcv_tracker_app/issues/7), converter [#39](https://github.com/Teixeira49/bcv_tracker_app/issues/39)) have somewhere to keep state across the rebuilds the sheet does while being dragged

## Data Modeling

Entities live in `shared/domain/entities/` and `features/*/domain/entities/`. JSON deserialization happens in `shared/data/model/` via `.fromJson()`, then converts to domain entities via `.toEntity()`. Never use model classes in UI or controllers. A model *extends* its entity, so the compiler will not catch the leak — see `.agents/rules/entities-vs-models.md` for the four places a new field has to touch.

## Internationalization

10 languages via GetX `Translations`. Language maps in `lib/core/i18n/languages/` (79 keys, all ten in parity, and `AppMessages` exposes exactly those 79). Use `AppMessages.<key>` for all UI text — never a raw string, and never `'<key>'.tr` in a widget: `app_messages.dart` is the only file that calls `.tr`. A new key goes into all ten files in the same commit, or GetX renders the raw key on screen for the other nine.

**Which language the app starts in** is `SettingsController`'s call, and since [#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98) it **follows the device** until the user picks one. `resolveDeviceLanguage` matches the device locale against `languageOptions` — exact `xx_YY` first, then on the language code alone, then `defaultLanguage`. The second pass is the one that matters: this app's audience runs `es_VE`, not `es_ES`, so without it the primary market would fall through to the default and only *look* right. A device in a language the app does not publish gets Spanish, not `fallbackLocale`. Following the device is deliberately **not persisted** — it is a default, not a decision, and writing it down would freeze the app to whatever language the phone was in on first launch. Picking a language in the selector persists it, **including the one already displayed**: that is what turns "the phone is in English" into "the user wants English".

## Routing

Named routes in `lib/config/routes/` — constants in `routes.dart` (`AppRoutes`), `GetPage` entries in `pages.dart` (`AppPages`). Navigate with `Get.toNamed()` / `Get.offAllNamed()` — never Flutter's `Navigator`, and never by passing a widget. Close dialogs and modals with `Get.back()`. Transitions belong on the `GetPage`, not the call site. Tabs are not routes: switching tabs changes `NavigationController.selectedIndex`.

**Modals are not routes either.** `SettingsModal` is shown with `showBlurredDialog`; the currency detail ([#38](https://github.com/Teixeira49/bcv_tracker_app/issues/38)) and the converter's currency selector ([#40](https://github.com/Teixeira49/bcv_tracker_app/issues/40)) are bottom sheets. All close with `Get.back()`, none is registered in `AppPages`. The price is that a modal is not reachable by deep link; making the detail sheet reachable means adding a `GetPage` that resolves the rate from a route parameter and renders the same widget. **Open every modal through its single entry point** — `showCurrencyDetailSheet`, `showCurrencySelectorSheet` — never by constructing the widget.

**Bottom sheets share one container**: `shared/presentation/widgets/base_bottom_sheet.dart` (`BaseBottomSheet` + `showAppBottomSheet`). Its one rule is that content arrives as **slivers** — the sheet is a single `DraggableScrollableSheet` over a single `CustomScrollView`, so the drag that resizes it and the scroll that moves its content are the same gesture chain. Nesting a `ListView` inside breaks it and the sheet starts closing when the user meant to scroll. The keyboard is handled by GetX's own route, which already pads by `viewInsets.bottom`; do not pad again. `BaseModal` (an `AlertDialog`) stays for centred dialogs — see `DESIGN.md` for when each applies.

## Theming

The **source of truth for visual decisions is [`DESIGN.md`](DESIGN.md)** (root): a design-system document with machine-readable tokens (color, typography, spacing, radii, components) in the front matter and the rationale in prose. `lib/config/theme/` is its **implementation** — it must match what `DESIGN.md` declares, and a new token is declared there **first**. Before building UI, read `DESIGN.md`; see `.agents/rules/design-system.md`.

Light/dark/system themes in `lib/config/theme/`. Colors (`AppColors`), icons and the 8pt spacing grid (`WidthValues`) are centralized there — no `Color(0xFF...)` in widgets. `SettingsController.favBrightness` drives the active theme. The app is on **Material 3** (`useMaterial3: true`, [#44](https://github.com/Teixeira49/bcv_tracker_app/issues/44)): the brand palette feeds a `ColorScheme` per theme (`primary`/`secondary`/`tertiary`=accent/`error` pinned to `AppColors`), and component themes (card, dialog, tab bar, switch) keep the look on-brand rather than M3-stock — the migration was architecture-first, the product looks the same. `CustomBottomNavigatorBar` is **kept** as a custom component: it is not a `BottomNavigationBar`, so M3's `NavigationBar` migration does not apply. The colours themselves still come from `ColorValues` (four modes), not from `Theme.of(context).colorScheme`, which mainly feeds Material's own components.

**The brand navy `#08253A` is not part of that palette, and the app opens with three screens rather than two.** The first is painted by the OS while the process starts, before Flutter draws anything: it was white (the `flutter create` template) until [#102](https://github.com/Teixeira49/bcv_tracker_app/issues/102), which is what made the launch look like two apps chained together. Those native files are **maintained by hand, not with `flutter_native_splash`** — five small files against a dependency that would overwrite them and the comments explaining them. Two things measured while doing it, both contradicting what is usually written: Android 12+ does **not** ignore `windowBackground` (it falls back to it when `windowSplashScreenBackground` is absent), and `values-v31` does **not** cover dark mode, because the night qualifier outranks `vNN` — hence `values-night-v31`, the easiest of the five to forget. Full account, including where the navy is declared in four different languages, in [`assets/brand/README.md`](assets/brand/README.md).

## Testing

Tests live in `test/`, mirroring `lib/`. Any change to a data source, a market mapping, a GetX controller or a calculation helper ships with its tests in the same PR. Controllers are tested with `Get.testMode = true`, fakes registered in dependency order, and `Get.reset()` in `tearDown`. `codemagic.yaml` runs `flutter analyze` and `flutter test` before building.

**Golden tests** guard the UI against visual regressions ([#35](https://github.com/Teixeira49/bcv_tracker_app/issues/35)): `AppStateView` (error/empty), the variation indicator, the Home cards and the converter body, each in light and dark. They use **Alchemist** (`*_golden_test.dart`), configured in `test/flutter_test_config.dart` to emit **only CI goldens** — text is obscured as blocks so the references render identically on the Linux CI and on a local Mac (icons, SVGs, palette and layout still render for real). Regenerate with `flutter test --update-goldens` **only** on an intended UI change, and review the `*.png` diff. Full procedure in [`docs/golden-tests.md`](docs/golden-tests.md).

## Versioning

`pubspec.yaml` is the **only** file where the version is edited; Android, iOS and `codemagic.yaml` derive it. Never set the version in Xcode or Gradle. See `.agents/rules/version-sources.md`.

**The Flutter SDK version is a different thing, and it is pinned.** The project builds on **Flutter 3.38.3**, declared in four places that must move together: `.github/workflows/pr-validation.yml` and the three workflows of `codemagic.yaml` — plus the development machine. They used to say `stable`, which installs whatever is stable that day, so CI ran ahead of the machines the code was written on: ten tests green locally failed the PR check against a `ListTile` assertion 3.38.3 does not carry ([#40](https://github.com/Teixeira49/bcv_tracker_app/issues/40)). The defect was real, but it surfaced late and for the wrong reason. Bumping the SDK is now a deliberate change with its own PR, touching all four at once.

## Known debt

Verified against the code. Fix on contact where the rule says so; do not treat as invisible:

- **GetX workers are never disposed** — `HomeController` and `ConverterController` register `ever()` without `onClose()`. `get` 4.7.3 has no automatic disposal, and `CurrencyRepository` is `permanent`, so listeners accumulate on every `fenix` recreation. Tracked in [#45](https://github.com/Teixeira49/bcv_tracker_app/issues/45). Because the `ever → update()` pattern was kept over `Obx`-granular ([#60](https://github.com/Teixeira49/bcv_tracker_app/issues/60)), this is a **permanent convention requirement**, not a one-time fix: every controller with a worker owns its `onClose()`, always.
- ~~**`SettingsController` is registered twice**~~ — fixed in [#59](https://github.com/Teixeira49/bcv_tracker_app/issues/59). One entry point now: `InitialBinding.initServices()`.
- **`WidthValues` is barely used** — the 8pt grid is declared and, since [#38](https://github.com/Teixeira49/bcv_tracker_app/issues/38), consumed by `features/currency_detail/`; the rest of the app's `EdgeInsets` still carry bare numbers. New UI uses the scale; migrate the older widgets on contact.
- **Placeholder bundle identifiers** — `com.example.*` on both platforms blocks store publishing. Tracked in [#22](https://github.com/Teixeira49/bcv_tracker_app/issues/22).
- ~~**Invalid locale codes**~~ — fixed in [#98](https://github.com/Teixeira49/bcv_tracker_app/issues/98). `languageOptions` now uses `en_US` and `ja_JP`, matching the keys `AppTranslations` registers exactly, and `_legacyLanguageCodes` migrates an install that stored `en_EN`/`ja_JA` **to the equivalent language** rather than dropping it to Spanish. The correction was not cosmetic: #98 needs "does the device's locale match a language we publish?" to be answerable by comparison, which an invalid code made impossible.
