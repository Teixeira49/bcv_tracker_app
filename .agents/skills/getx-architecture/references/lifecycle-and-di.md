---
metadata:
  last_modified: "2026-08-03 12:00:00 (GMT+8)"
---

# Lifecycle and dependency injection

## Where dependencies are registered

`lib/config/bindings/initial_bindings.dart`, and nowhere else. One file describes the whole object graph of the app: what exists, with what lifetime, and what depends on what. See `.agents/rules/dependency-injection.md` for the rule; this file covers the choices it leaves open.

## Choosing the registration

| Need | How | Why |
|---|---|---|
| Feature controller, disposable and recreatable | `Get.lazyPut<T>(() => T(), fenix: true)` | Built on first `Get.find()`; `fenix` lets it be rebuilt after disposal instead of throwing |
| Repository / datasource behind an interface | `Get.lazyPut<IFoo>(() => Foo(dep: Get.find()), fenix: true)` | Consumers depend on the abstraction, and the test can swap the implementation |
| Shared state that must survive all navigation | `Get.put<T>(T(), permanent: true)` | Created immediately, never disposed |
| Service with async initialisation | `extends GetxService` + `Get.putAsync` | `putAsync` awaits before the app uses it |

`GetxService` and `GetxController` behave the same at runtime; the difference is intent and disposal. GetX will not dispose a `GetxService` when routes change, which is why `CurrencyRepository` is one — the whole app reads its data and losing it on a tab switch would refetch the rates constantly.

Each `permanent: true` is memory that is never released. Justify it in the PR.

## Order inside the binding

`Get.lazyPut` defers construction, so a `Get.find()` inside the factory resolves on first use — order does not matter there. It does matter when you need the instance **during** the binding itself:

```dart
// SettingsController must exist now, because CurrencyRepository takes a
// callback into it and the ever() below needs its observable.
Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
final SettingsController settings = Get.find<SettingsController>();

final CurrencyRepository currencies = Get.put<CurrencyRepository>(
  CurrencyRepository(selection: () => settings.marketSelection),
  permanent: true,
);

ever(settings.selectedMarketKeys, (_) => currencies.refreshData());
```

Note the dependency is passed as a **callback** (`() => settings.marketSelection`), not as a value. The service reads the current selection at request time instead of capturing whatever it was at startup.

## Lifecycle hooks

| Hook | When it runs | Use it for |
|---|---|---|
| `onInit()` | Right after construction, **before** the first frame | Wiring workers, reading preferences, initialising local state |
| `onReady()` | One frame **after** the widget is on screen | The first network fetch, anything that shows a dialog or a snackbar |
| `onClose()` | Just before disposal | Disposing workers, controllers and subscriptions |

`CurrencyRepository` fetches in `onReady`, not `onInit`, and that is deliberate: firing the request after the first frame lets the skeleton render immediately instead of competing with the network call during the initial build.

Do not `await` inside `onInit` — it is not async. If initialisation needs I/O, either call an async method fire-and-forget (as `SettingsController._loadPreferences()` does) and let the observables update the UI when the data lands, or use `Get.putAsync` when nothing may run before it finishes. The fire-and-forget variant is only safe because every consumer reads observables that start with a sensible default.

## Disposing workers — mandatory

In `get` 4.7.3 there is no automatic cleanup: `Worker.dispose()` is manual and `GetxController.onClose()` is an empty method. Nothing tracks the workers you create.

This matters here because `CurrencyRepository` is `permanent: true` and outlives every controller. A worker registered in a controller's `onInit` keeps holding a reference to that controller after it is disposed, and with `fenix: true` the recreated controller registers another set. Each rebuild of the screen adds listeners that call `update()` on dead objects.

```dart
class HomeController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();
  final _workers = <Worker>[];

  @override
  void onInit() {
    super.onInit();
    _workers
      ..add(ever(_repository.averageCurrencies, (_) => update()))
      ..add(ever(_repository.bcvCurrencies, (_) => update()))
      ..add(ever(_repository.isLoading, (_) => update()))
      ..add(ever(_repository.errorMessage, (_) => update()));
  }

  @override
  void onClose() {
    for (final w in _workers) { w.dispose(); }
    _workers.clear();
    super.onClose();
  }
}
```

The same applies to `TextEditingController`, `ScrollController`, `AnimationController` and `StreamSubscription` held by a controller: dispose them in `onClose`.

## Known debt

`main.dart` runs `Get.put(SettingsController())` before `runApp`, while `initial_bindings.dart` also registers it with `Get.lazyPut<SettingsController>`. The instance from `main` wins and the lazy factory never runs, so the behaviour is correct by accident — but the graph is described in two places, which is exactly what the single-binding rule exists to prevent. If the eager registration is genuinely needed (it runs before `GetMaterialApp` builds), the fix is to keep it in one place and document why, not to have both.

`HomeController` and `ConverterController` register workers without disposing them. Fix on contact.
