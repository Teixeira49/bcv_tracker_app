---
metadata:
  last_modified: "2026-08-03 12:00:00 (GMT+8)"
---

# Layers — where each piece of code belongs

## The shape

Feature-first with layers. **Not** Clean Architecture: there is no UseCase layer, and adding one would be a structural change, not a refactor. Generic guides — including `flutter-expert/references/architecture.md` in this same directory — assume UseCases and BLoC; that is a different architecture from this one.

```
lib/
├── features/<feature>/          splash · home · converter · settings · dashboard
│   ├── domain/entities/         entities specific to the feature
│   └── presentation/
│       ├── controller/          GetxController — view logic, no widgets
│       ├── page/                the screen
│       └── widget(s)/           pieces of the screen
├── shared/
│   ├── domain/
│   │   ├── entities/            Currency, BcvCurrencies, Market, Language
│   │   └── repositories/        interfaces (IDollarRepository)
│   ├── data/
│   │   ├── datasource/          DollarApiRest (Dio) + DollarEndpoints
│   │   ├── model/               mirrors the backend JSON — never leaves this layer
│   │   ├── mapper/              CurrencyNormalizer — shaping and deduplication
│   │   └── repositories/        DollarRepository + CurrencyRepository (GetxService)
│   └── presentation/            SettingsController and cross-feature widgets
├── core/                        network · i18n · constants · helpers
├── config/                      routes · theme · enviroment · bindings
└── navigation/                  NavigationController (bottom tab index)
```

## Decision table

| What you are writing | Where it goes | Why not elsewhere |
|---|---|---|
| A new endpoint path | `data/datasource/dollar_api/dollar_endpoints.dart` | Keeps the API version and country segment in one place instead of baked into each call |
| Reading a JSON field | `data/model/*.fromJson` | The only layer allowed to know the backend's key names |
| Normalising, deduplicating, averaging the response | `data/mapper/currency_normalizer.dart` | Shaping is data-layer work; a controller doing it would duplicate it per feature |
| State two or more features read | `data/repositories/currency_repository.dart` (the `GetxService`) | A controller owning it would lose it on disposal and refetch |
| Logic for one screen | `features/<f>/presentation/controller/` | Feature-local, disposable with the screen |
| A user preference that must persist | `shared/presentation/controller/settings_controller.dart` | Single owner of `SharedPreferences`; scattering keys loses them silently |
| A visible string | `core/i18n/app_messages.dart` + the 10 language files | See `.agents/rules/i18n-convention.md` |
| A reusable literal | `core/constants/` or `config/theme/` | See `.agents/rules/constants-centralization.md` |
| Bottom tab index | `navigation/navigation_controller.dart` | Tabs are not route navigation; they are an index |

## The two boundaries that matter

**Models do not cross into the domain.** `CurrencyModel extends Currency`, so the compiler will happily let a model reach a widget. The datasource must call `.toEntity()`. See `.agents/rules/entities-vs-models.md`.

**`Rx` does not cross into the widget.** The service owns the observables; the controller exposes plain values. A widget that reads `Get.find<CurrencyRepository>().isLoading.value` has coupled itself to the service's internals. See `reactivity.md`.

Both are the same principle: each layer publishes a contract, not its internals.

## Adding a market end to end

The order matters — each step depends on the previous one:

1. `core/constants/market_constants.dart` — the market and the modes it accepts, matching the backend contract.
2. `data/datasource/` — the endpoint, if it is a new one; document which backend version introduced it.
3. `data/model/` — deserialisation with a fallback per optional field, then the field in `toEntity()`.
4. `data/mapper/currency_normalizer.dart` — how it joins the average or gets deduplicated.
5. `data/repositories/currency_repository.dart` — only if it needs its own observable.
6. `shared/presentation/controller/settings_controller.dart` — exposing it in the market selection.
7. `core/i18n/` — its name in the 10 languages.
8. Tests for mapping and selection, in the same PR (`.agents/rules/test-coverage.md`).

If step 5 adds an observable, remember the `ever(...) => update()` in every controller that must react to it — or the screen will not refresh.

## Adding a screen

1. Constant in `config/routes/routes.dart` and `GetPage` in `pages.dart`.
2. Controller in `features/<f>/presentation/controller/`, registered in `initial_bindings.dart`.
3. Page and widgets, consuming the controller with `GetBuilder` (or `Obx` for its own observables).
4. Copy via `AppMessages` in the 10 languages.
5. Navigate with `Get.toNamed(AppRoutes.x)` — see `.agents/rules/navigation-convention.md`.
