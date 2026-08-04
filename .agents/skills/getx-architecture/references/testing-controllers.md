---
metadata:
  last_modified: "2026-08-03 12:00:00 (GMT+8)"
---

# Testing controllers and services

A GetX controller is testable without a widget tree: it is a plain object that reads its dependencies from a container. The whole technique is to fill that container with fakes before constructing it, and to empty it afterwards.

## The pattern in this repo

From `test/features/converter/converter_controller_calculator_test.dart`:

```dart
setUp(() {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  Get.put<CurrencyRepository>(CurrencyRepository(), permanent: true);
  controller = Get.put(ConverterController());
});

tearDown(() => Get.reset());
```

Four things are doing work here:

- **`Get.testMode = true`** stops GetX from touching navigation. Without it, any code path that calls `Get.toNamed` or `Get.snackbar` tries to reach a `GetMaterialApp` that does not exist and throws inside the test.
- **Registering in dependency order.** `CurrencyRepository` resolves `Get.find<IDollarRepository>()` in its field initialiser, so the fake repository must already be in the container when it is constructed. Get the order wrong and the failure is a confusing "not found" pointing at the service, not at the test.
- **`Get.put`, not `lazyPut`.** The test wants the instance to exist now, deterministically.
- **`Get.reset()` in `tearDown`.** The container is global. Skip this and the next test inherits the previous test's instances — the classic symptom is a suite that passes one test at a time and fails when run together.

## Writing the fake

Implement the interface, return canned data, no network:

```dart
class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: '2024-01-01', currencies: []);

  @override
  Future<List<Currency>> getCurrentDollar(MarketSelection selection) async => [];
}
```

`implements` rather than `extends` is deliberate: it forces the compiler to flag the fake when the interface gains a method, instead of letting it silently inherit a real implementation that hits the network.

For the datasource layer the equivalent is a fake `HttpManager` that records what was requested and returns a canned `Response` — see `test/shared/data/dollar_api_rest_test.dart`.

## What to assert

Assert on **state**, not on widgets:

```dart
controller.calculator('1,5');
expect(controller.fromCurrency.convertedValue, 1.5);
```

For observables, read `.value`. If the controller exposes plain getters (the pattern in `HomeController`), read the getter — that is the contract the views consume, so it is the contract worth pinning.

Cover the edges of any calculation: empty string, `'.'`, comma as decimal separator, zero, a missing rate, an unavailable currency, and long decimals. Those are where a converter actually breaks, and none of them throw — they just produce a wrong number.

## Testing a worker

A worker fires asynchronously. Mutate the observable, let the microtask queue drain, then assert:

```dart
repository.isLoading.value = true;
await Future<void>.delayed(Duration.zero);
expect(controller.someDerivedState, isTrue);
```

If you are testing that a rebuild happened rather than that state changed, that is a widget test — use `tester.pump()` after the mutation.

## Testing a service

Same idea one layer down: register the fake datasource, construct the service, drive it and assert on its observables.

```dart
Get.put<IDollarRepository>(_FakeDollarRepository());
final repo = Get.put(CurrencyRepository());
await repo.refreshData();
expect(repo.hasAverageData.value, isTrue);
expect(repo.errorMessage.value, isNull);
```

Cover the failure path too: a fake that throws `ApiException` should leave `errorMessage` populated and `isLoading` back to `false`. `refreshData` uses `Future.wait` without `eagerError`, so a partial failure must still land the data that succeeded — worth a test of its own, because it is easy to break by "simplifying" the error handling.

## Widget tests

When the widget itself holds logic, pump it inside a `GetMaterialApp` so `GetBuilder`/`Obx` can resolve their controller:

```dart
await tester.pumpWidget(GetMaterialApp(home: HomeBody()));
```

Register the controller in `setUp` as above. If the widget only renders what the controller hands it, test the controller instead — it is faster and it is where the bugs are.
