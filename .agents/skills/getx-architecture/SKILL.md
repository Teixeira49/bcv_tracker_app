---
name: "building-with-getx-architecture"
description: "State management and layered architecture for the BCV Tracker Flutter app, built on GetX (get v4.7.3). Use this skill whenever working on anything reactive or structural in this codebase: adding or editing a GetxController or GetxService, deciding between Obx and GetBuilder, wiring ever/debounce/interval workers, registering dependencies in initial_bindings.dart, choosing which layer a piece of logic belongs to, deciding where new state should live, testing a controller, or diagnosing why a screen does not rebuild, rebuilds too often, or leaks listeners. Also use it when a generic Flutter guide suggests BLoC, Riverpod, Provider or GoRouter — this project uses GetX and the migration is not on the table."
metadata:
  last_modified: "2026-08-03 12:00:00 (GMT+8)"
---

# GetX Architecture — BCV Tracker App

## Goal

Keep every reactive and structural change in this app consistent with the architecture already in the codebase, instead of with generic GetX tutorials. GetX offers three or four ways to do everything; this project has already chosen one of each, and the value of documenting them is that a screen written today behaves like the screens written last month.

The rules in `.agents/rules/` say **what is mandatory**. This skill says **how it is done here** and, more importantly, **why** — so you can extend the pattern to cases the rules do not name.

## The one thing to understand first

Reactive state lives in a **service**, not in the feature controllers.

```
DollarApiRest (datasource, Dio)
  → DollarRepository            implements IDollarRepository
  → CurrencyRepository          GetxService, permanent — owns the Rx state
  → HomeController /            GetxController — bridges Rx to update()
    ConverterController           and exposes plain, unwrapped getters
  → GetBuilder<T>               the views
```

`CurrencyRepository` is the only place holding `RxList<Currency>`, `RxBool`, `RxnString`. A feature controller does **not** re-expose those `Rx` objects. It exposes plain values:

```dart
// HomeController
bool get isLoading => _repository.isLoading.value;   // ← unwrapped, not RxBool
String? get errorMessage => _repository.errorMessage.value;
```

and republishes changes with a worker plus `update()`:

```dart
@override
void onInit() {
  super.onInit();
  ever(_repository.averageCurrencies, (_) => update());
  ever(_repository.isLoading, (_) => update());
}
```

**Why this shape rather than exposing the `Rx` straight to `Obx`?** It is the same boundary argument as `entities-vs-models.md`: the widget layer should not reach through a controller into another layer's internals. If a view did `Obx(() => Text('${Get.find<CurrencyRepository>().isLoading.value}'))`, the service's observable type would become part of the widget's contract, and swapping `RxBool` for something else would break screens. With plain getters, the controller owns the contract and the service stays replaceable.

The cost is that rebuilds are explicit: **if you add reactive state to a service and forget the `ever(...) => update()`, the screen silently stops refreshing.** That is the single most common bug in this architecture.

## Process

1. **Decide the layer before writing code.** Read `references/layers.md`. Data shaping belongs in the mapper, shared state in the service, view logic in the controller, and nothing but rendering in the widget.
2. **Pick the rebuild mechanism.** `GetBuilder` is the default here (17 uses vs 4 `Obx`). Read `references/reactivity.md` for the decision and for what each one actually listens to.
3. **Register the dependency in `initial_bindings.dart`** — never anywhere else. Read `references/lifecycle-and-di.md` for `fenix` vs `permanent` vs `GetxService` and for the lifecycle hooks.
4. **Dispose your workers.** GetX 4.7.3 does not do it for you. See the Constraints below.
5. **Write the test with a fake and `Get.reset()`.** Read `references/testing-controllers.md`.

## Reference Documentation

| File | Read it when |
|---|---|
| `references/reactivity.md` | Choosing `Obx` vs `GetBuilder` vs a worker; a screen does not rebuild or rebuilds too much |
| `references/lifecycle-and-di.md` | Registering a dependency; choosing `onInit`/`onReady`/`onClose`; `fenix` vs `permanent`; disposing workers |
| `references/layers.md` | Deciding where new code belongs; adding a market, an endpoint or a screen |
| `references/testing-controllers.md` | Testing a controller or a service without touching the network |

## Constraints

* **Workers are never disposed automatically.** In `get` 4.7.3, `Worker.dispose()` is manual and `GetxController.onClose()` is an empty no-op — there is no registry that cleans them up. Since `CurrencyRepository` is `permanent: true` it outlives every controller, so a worker registered in `onInit` keeps listening after its controller dies. With `fenix: true` the controller is recreated and registers a *second* set of workers, each calling `update()` on a disposed controller. Keep the handles and cancel them:

  ```dart
  final _workers = <Worker>[];

  @override
  void onInit() {
    super.onInit();
    _workers.add(ever(_repository.isLoading, (_) => update()));
  }

  @override
  void onClose() {
    for (final w in _workers) { w.dispose(); }
    super.onClose();
  }
  ```

  `HomeController` and `ConverterController` currently register workers without disposing them. Fix it when you touch either file.

* **Dependencies are registered only in `initial_bindings.dart`.** `main.dart` currently also does `Get.put(SettingsController())`, duplicating the `Get.lazyPut<SettingsController>` in the binding. Do not copy that pattern; see `.agents/rules/dependency-injection.md`.

* **Never instantiate a controller in a widget.** `HomeController()` inside a `build` creates an instance nobody else can see, listening to the same service but wired to nothing. The symptom is always "the screen does not update", far from the cause.

* **Widgets stay passive.** They render what the controller hands them and call its methods. No `Dio`, no `SharedPreferences`, no `.fromJson` and no business calculations in a widget.

* **Entities only, above the data layer.** Controllers and views handle `Currency`, never `CurrencyModel` — see `.agents/rules/entities-vs-models.md`.

* **Navigate with named routes.** `Get.toNamed` / `Get.offAllNamed`, never `Navigator` and never by passing a widget — see `.agents/rules/navigation-convention.md`.

* **GetX is a settled decision, not an open comparison.** Generic Flutter material — including `flutter-expert` in this same directory — will suggest BLoC or Riverpod, and rate GetX as fit for "rapid prototyping". Do not propose a migration as part of an unrelated task. If you think the stack should change, that is its own issue with its own discussion.
