---
metadata:
  last_modified: "2026-08-03 12:00:00 (GMT+8)"
---

# Reactivity — `Obx`, `GetBuilder` and workers

## What each one actually listens to

GetX has two independent update systems. Mixing them up is the usual cause of "it doesn't rebuild".

| Mechanism | Listens to | Rebuilds when |
|---|---|---|
| `Obx(() => ...)` | Any `.value` **read inside the closure** during build | That observable changes |
| `GetBuilder<T>(builder: ...)` | Nothing automatically | The controller calls `update()` |
| `ever` / `debounce` / `interval` | An observable you name explicitly | Runs your callback — it does not rebuild anything by itself |

The trap in `Obx` is that the dependency is registered by **reading** the value while the closure runs. An observable read outside the closure, or behind a condition that was false on the first build, is not tracked — and the widget silently stops updating.

## What this app uses

`GetBuilder` is the default: 17 uses against 4 `Obx`. That is a consequence of the architecture, not a style preference — feature controllers expose plain unwrapped getters (`bool get isLoading => _repository.isLoading.value`), so there is no observable for `Obx` to track inside the view. The controller bridges the service's `Rx` with `ever(...) => update()`.

```dart
// home_body.dart — the house pattern
Widget build(BuildContext context) => GetBuilder<HomeController>(
  builder: (controller) {
    final String? error = controller.errorMessage;
    final bool showCurrencies = controller.hasAverageData || error == null;
    ...
  },
);
```

`Obx` is reserved for the four cases where a widget reads an `.obs` that lives **on the controller it is bound to**, with no service in between:

- `custom_bottom_navigator_bar.dart` and `dashboard_page.dart` → `NavigationController.selectedIndex`, an `RxInt` owned by that controller.
- `settings_widgets.dart` (×2) → `SettingsController` observables, inside a `GetBuilder` that supplies the controller.

## Which one to use

Use **`GetBuilder`** when the data comes from `CurrencyRepository` through a feature controller. It matches the surrounding code and keeps the service's `Rx` types out of the widget.

Use **`Obx`** when the widget reads an `.obs` declared on its own controller and you want the rebuild scoped to just that subtree — a toggle, a selected index, a form field. Keep the closure tight: everything inside it rebuilds.

Do **not** wrap a whole page in `Obx` to avoid thinking about dependencies. Rebuilding a `Scaffold` because a counter changed is exactly the jank this system exists to prevent.

## Workers

`ever`, `debounce`, `interval` and `once` react to an observable **outside** the widget tree. They belong in `onInit` of a controller, or in `initial_bindings.dart` when they wire two services together.

```dart
// initial_bindings.dart — cross-service wiring lives in the binding,
// so the app's plumbing reads in one place
ever(settings.selectedMarketKeys, (_) => currencies.refreshData());
```

`debounce` is the right tool for a search field or an amount input: it waits for the user to stop typing instead of recomputing on every keystroke. The converter does not use it today, but a text input that triggers a conversion on every character is a candidate.

**Every worker you create must be disposed.** See `lifecycle-and-di.md` — GetX 4.7.3 does not do it for you.

## Diagnosing

**The screen does not update.**
1. Is the state in a service and did you forget the `ever(...) => update()` in the controller? Most likely cause.
2. `GetBuilder` without a matching `update()` call after mutating state.
3. `Obx` whose closure never reads the observable — check it is read on the *first* build, not behind a condition.
4. A controller instantiated inside the widget instead of `Get.find()` — you are watching a different object than the one being updated.

**The screen rebuilds too much.**
1. `Obx` wrapping more subtree than it needs.
2. `update()` with no arguments when only one section changed — `update(['average'])` plus `GetBuilder(id: 'average')` narrows it.
3. Duplicate workers from a `fenix` controller recreated without disposing the previous ones.

**Assigning to an `RxList` does nothing.** `list.value = [...]` on an `RxList` replaces the internal reference without notifying in every case; use `assignAll()`, which is what `CurrencyRepository` does:

```dart
averageCurrencies.assignAll(CurrencyNormalizer.forAverageTab(result));
```

Same idea for mutation in place: `list.add(x)` notifies, `list.toList().add(x)` does not touch the observable at all.
