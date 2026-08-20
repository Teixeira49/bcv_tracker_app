import 'package:get/get.dart';
import '../../../../shared/data/repositories/currency_repository.dart';
import '../../../../shared/domain/conversion.dart';
import '../../../../shared/domain/entities/currency.dart';
import '../../../../shared/presentation/controller/settings_controller.dart';
import '../../domain/entities/convertible_currency.dart';

/// Drives the full converter: which pair, how much, and the result.
///
/// **The pivot rule is the thing to understand here.** Every rate the backend
/// publishes is quoted in bolívares, so there is no cross-rate for `USD → EUR`;
/// the converter therefore keeps [Currency.pivotCurrency] on **one side at all
/// times** and reads `USD → EUR` as `USD → VES → EUR`. [selectCurrency] enforces
/// that invariant rather than trusting callers, which is why picking a second
/// non-VES currency moves the other side to VES instead of refusing.
///
/// Unlike `HomeController` this holds state of its own — the pair and the amount
/// — and that state **survives between visits to the tab**, deliberately: a user
/// coming back to a calculation finds it where they left it. Which is also why
/// [preloadFromDetail] is the only thing allowed to overwrite it, and only on an
/// explicit tap.
///
/// The arithmetic is **not** here: `CurrencyConversion` in `shared/domain/` owns
/// it, and the detail sheet's quick converter calls the same functions. That is
/// what makes "both converters agree" a test rather than a hope.
class ConverterController extends GetxController {
  final CurrencyRepository _repository = Get.find<CurrencyRepository>();
  final SettingsController _settings = Get.find<SettingsController>();

  /// Workers bridging the two services to `update()`, kept so [onClose] can
  /// dispose them.
  ///
  /// `get` 4.7.3 disposes no worker on its own, and both services are
  /// `permanent`: without this every `fenix` recreation of this controller left
  /// its listeners attached to objects that outlive it
  /// ([#45](https://github.com/Teixeira49/bcv_tracker_app/issues/45)). Because
  /// the app keeps the `ever → update()` bridge over granular `Obx` (#60),
  /// owning the disposal is a permanent requirement, not a one-off fix.
  final List<Worker> _workers = <Worker>[];

  /// Most decimals a result may show, as the user set it (#37's increment).
  ///
  /// A plain `int`, not the `Rx`: the view never names the service's reactive
  /// types — that boundary is the reason the bridge below exists at all.
  int get amountDecimals => _settings.favDecimals.value;

  /// Whether a refresh is in flight — the same one Home shows, so the two
  /// screens never disagree about whether the app is busy.
  bool get isLoading => _repository.isLoading.value;

  /// Detail of the last failed refresh, or `null` when the last one succeeded —
  /// the same failure the Home shows, so the converter states stay consistent.
  String? get errorMessage => _repository.errorMessage.value;

  /// Every rate the user can pick from, official and parallel in one list.
  ///
  /// Consolidated because the converter asks "which rate", not "which tab": the
  /// selector shows them together. Deduplicated on `keyName + platform + name` by
  /// [_updateCurrenciesAndInit], since the BCV dollar and a parallel dollar are
  /// different rates that share a code.
  ///
  /// Starts as skeleton placeholders, like the service's own lists.
  final RxList<Currency> currencies = List.generate(
    5,
    (e) => Currency.emptySkeletonizer,
  ).obs;

  /// Refetches the rates. Bound to the converter's pull-to-refresh and to retry.
  Future<void> refreshConverterData() async {
    await _repository.refreshData();
  }

  /// The bolívar, held as a field so the pivot rule reads as a comparison rather
  /// than a literal. See [Currency.pivotCurrency].
  Currency pivotCurrency = Currency.pivotCurrency;

  final Rx<ConvertibleCurrency> _fromCurrency = ConvertibleCurrency(
    currency: Currency.emptySkeletonizer,
    convertedValue: 0.0,
  ).obs;

  /// The side the user types into, with the amount they typed.
  ConvertibleCurrency get fromCurrency => _fromCurrency.value;

  /// Replaces the input side. Setting it does **not** recalculate — call
  /// [calculator] after, which is what every path here does.
  set fromCurrency(ConvertibleCurrency value) => _fromCurrency.value = value;

  final Rx<ConvertibleCurrency> _toCurrency = ConvertibleCurrency(
    currency: Currency.emptySkeletonizer,
    convertedValue: 0.0,
  ).obs;

  /// The side the result is expressed in, with that result.
  ConvertibleCurrency get toCurrency => _toCurrency.value;

  /// Replaces the output side. Like [fromCurrency], does not recalculate on its
  /// own.
  set toCurrency(ConvertibleCurrency value) => _toCurrency.value = value;

  @override
  void onInit() {
    super.onInit();

    // Listen to repository changes to initialize
    _workers.add(
      ever(_repository.averageCurrencies, (_) => _updateCurrenciesAndInit()),
    );
    _workers.add(
      ever(_repository.bcvCurrencies, (_) => _updateCurrenciesAndInit()),
    );

    _updateCurrenciesAndInit();

    _workers.add(ever(_repository.isLoading, (_) => update()));
    _workers.add(ever(_repository.errorMessage, (_) => update()));
    // The decimals ceiling is set on another screen, stacked over this one, so
    // nothing rebuilds the converter when the user comes back. Without this
    // bridge the new precision would only appear at the next keystroke.
    _workers.add(ever(_settings.favDecimals, (_) => update()));
  }

  @override
  void onClose() {
    for (final Worker worker in _workers) {
      worker.dispose();
    }
    _workers.clear();
    super.onClose();
  }

  void _updateCurrenciesAndInit() {
    // Use a composite key for uniqueness based on keyName, platform, and name.
    final Set<String> addedKeys = {};
    final List<Currency> mergedList = [];

    // Helper to create a unique composite key for each currency.
    String compositeKey(Currency c) => '${c.keyName}-${c.platform}-${c.name}';

    // 1. Add Average Currencies
    for (var c in _repository.averageCurrencies) {
      if (addedKeys.add(compositeKey(c))) {
        mergedList.add(c);
      }
    }

    // 2. Add BCV Currencies (excluding duplicates)
    for (var c in _repository.bcvCurrencies) {
      if (addedKeys.add(compositeKey(c))) {
        mergedList.add(c);
      }
    }

    currencies.assignAll(mergedList);
    _initializeSelection();
  }

  void _initializeSelection() {
    // If already initialized, don't overwrite unless empty
    if (fromCurrency.currency.keyName.isNotEmpty &&
        fromCurrency.currency != Currency.emptySkeletonizer) {
      return;
    }

    if (currencies.isNotEmpty) {
      // Default: VES as from, First from list (usually USD) as to.
      // Assuming first item in currencies is the main average USD.

      // Select first available currency that is NOT VES for 'to'

      final initialTo = currencies.firstWhere(
        (c) => c.keyName != 'VES',
        orElse: () => currencies.last,
      );

      fromCurrency = ConvertibleCurrency(
        currency: pivotCurrency,
        convertedValue: initialTo.value,
      );

      toCurrency = ConvertibleCurrency(
        currency: pivotCurrency,
        convertedValue: initialTo.value,
      );

      // Format/Calculate
      calculator(fromCurrency.convertedValue.toString());
    }
  }

  /// The rate line under each card — `1.0 ≈ 826.84`, in the pair's own units.
  String getRoundedCurrency() =>
      '${fromCurrency.originalValue} ≈ ${toCurrency.originalValue}';

  /// Whether the pair currently selected cannot produce a conversion.
  ///
  /// A rate of `0.0` reaches the app through ordinary paths — [Currency.empty]
  /// declares `value: 0.00`, and the backend answers with a market that has no
  /// data yet — and dividing doubles by zero does not throw in Dart: it yields
  /// `Infinity`, or `NaN` when the dividend is zero too. The views read this
  /// getter to say so instead of painting a meaningless number.
  bool get isConversionUnavailable => !CurrencyConversion.canConvert(
    fromRate: fromCurrency.currency.value,
    toRate: toCurrency.currency.value,
  );

  /// Picks [selected] for the input side when [isInput], the output side
  /// otherwise, keeping the pivot rule.
  ///
  /// Returns `null` when nothing changed (the same rate was already there),
  /// `true` when the pair moved. The four branches in the body are the rule made
  /// explicit: same rate, the other side's rate (so swap), a new rate, and the
  /// case where neither side would be VES — which moves the *other* side to the
  /// pivot rather than rejecting the choice the user just made.
  bool? selectCurrency(Currency selected, {required bool isInput}) {
    final Currency current = isInput
        ? fromCurrency.currency
        : toCurrency.currency;
    final Currency other = isInput
        ? toCurrency.currency
        : fromCurrency.currency;

    // 1. Same currency selected? Do nothing.
    if (current.keyName == selected.keyName &&
        current.platform == selected.platform) {
      return null;
    }

    // 2. Selected the other side's currency? Swap.
    if (other.keyName == selected.keyName) {
      swapCurrencies();
      return true;
    }

    // 3. Define new configuration
    Currency newFrom = isInput ? selected : fromCurrency.currency;
    Currency newTo = !isInput ? selected : toCurrency.currency;

    // 4. Pivot Rule: One must be Pivot (VES).
    if (newFrom.keyName != pivotCurrency.keyName &&
        newTo.keyName != pivotCurrency.keyName) {
      if (isInput) {
        newTo = pivotCurrency;
      } else {
        newFrom = pivotCurrency;
      }
    }

    // 5. Update state with specific logic
    if (!isInput) {
      // Logic: Set "To" to 1, calculate "From"
      toCurrency = ConvertibleCurrency(currency: newTo, convertedValue: 1.0);
      fromCurrency = fromCurrency.copyWith(currency: newFrom);

      // Reverse calculation: From = (ToAmount * ToRate) / FromRate. Same
      // shared maths as [calculator], read the other way round, so the guard
      // against a market with no rate comes for free.
      final double fromAmount = CurrencyConversion.convert(
        amount: 1.0,
        fromRate: newTo.value,
        toRate: newFrom.value,
      );
      fromCurrency = fromCurrency.copyWith(convertedValue: fromAmount);
    } else {
      // Logic: Reset "From" to 1 (standard behavior), calculate "To"
      fromCurrency = ConvertibleCurrency(
        currency: newFrom,
        convertedValue: 1.0,
      );
      toCurrency = toCurrency.copyWith(currency: newTo);

      calculator(fromCurrency.convertedValue.toString());
    }

    update();
    return true;
  }

  /// Loads the pair, the amount and the direction a caller hands over, and
  /// converts (#103).
  ///
  /// **The decision this method is, written down.** #39 left open whether
  /// arriving from the rate detail should preload the full converter, and #103
  /// chose the strongest of the three options on the table: preload the
  /// currency **and carry the amount and the direction across**. The user story
  /// is about continuing a calculation already in progress ("seguir donde
  /// iba"), and a preload that dropped the number would make them type it again
  /// — which is the thing the button exists to avoid.
  ///
  /// **Why overwriting the user's pair is acceptable here, and only here.** The
  /// pair in this controller survives between visits to the tab, and it may
  /// well have been chosen on purpose. This does not fire when the tab is
  /// entered: it fires when the user taps a button that says it will open the
  /// rate in the converter. Consent is the tap. Switching tabs without that tap
  /// must leave the selection alone — there is a test for it, because it is the
  /// half that a future change breaks silently.
  ///
  /// [reversed] mirrors the detail sheet's own flip: unreversed means "this rate
  /// into bolívares", so the rate is the input side. The pivot rule the rest of
  /// this controller enforces holds either way, since one side is always VES.
  ///
  /// The amount arrives as the **raw string** the user typed, not a parsed
  /// number, for the same reason the detail keeps it that way: `1.` and `1.0`
  /// are the same value and not the same text, and it is [calculator]'s job to
  /// parse it — the one place that already handles an empty field and a comma.
  void preloadFromDetail({
    required Currency rate,
    String amount = '',
    bool reversed = false,
  }) {
    final Currency input = reversed ? pivotCurrency : rate;
    final Currency output = reversed ? rate : pivotCurrency;

    fromCurrency = ConvertibleCurrency(currency: input, convertedValue: 0.0);
    toCurrency = ConvertibleCurrency(currency: output, convertedValue: 0.0);

    // Through `calculator` rather than assigning a result, so the empty field,
    // the decimal comma and the market with no rate all behave exactly as they
    // do when the user types — no second implementation to keep in step.
    calculator(amount);
  }

  /// Flips the pair, **carrying each figure with its currency**.
  ///
  /// The figure belongs to its currency, so `USD 2 | VES 1653` inverts to
  /// `VES 1653 | USD 2`, not to `VES 2`. Leaving the amount behind would silently
  /// change the question — it would ask what two bolívares are worth and answer
  /// `0.00`, which reads as a broken converter rather than a correct answer to a
  /// question nobody asked. The detail sheet's quick converter follows the same
  /// model.
  void swapCurrencies() {
    final ConvertibleCurrency temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    calculator(fromCurrency.convertedValue.toString());
  }

  /// Parses what the user typed and publishes the converted result.
  ///
  /// Takes the **raw string**, not a number: `1.` and `1.0` are the same value
  /// and not the same text, and writing a parsed value back would move the caret.
  /// It is also the single place that decides what a string means — empty field,
  /// lone separator, decimal comma — which is why [preloadFromDetail] routes
  /// through here instead of parsing the handed-over amount itself.
  ///
  /// The full precision is kept in state; rounding happens only at display, in
  /// `CurrencyHelpers.castAmount`. That order is the fix for the converter's
  /// original rounding bug and must not be inverted.
  void calculator(String value) {
    if (value.isEmpty) {
      fromCurrency = fromCurrency.copyWith(convertedValue: 0.0);
      toCurrency = toCurrency.copyWith(convertedValue: 0.0);
      update();
      return;
    }

    final double amount = CurrencyConversion.parseAmount(value);

    fromCurrency = fromCurrency.copyWith(convertedValue: amount);

    // Zero when the pair cannot convert, which is the honest placeholder;
    // [isConversionUnavailable] is what tells the user why.
    final double result = CurrencyConversion.convert(
      amount: amount,
      fromRate: fromCurrency.currency.value,
      toRate: toCurrency.currency.value,
    );

    toCurrency = toCurrency.copyWith(convertedValue: result);
    update();
  }
}
