import 'package:get/get.dart';

import '../../../../core/helpers/currency_helpers.dart';
import '../../../../shared/domain/conversion.dart';
import '../../../../shared/domain/entities/currency.dart';

/// Owns which rate the detail sheet is showing.
///
/// The sheet itself is a modal, not a route, so nothing else keeps track of
/// what it has open. This controller does: `showCurrencyDetailSheet` sets the
/// rate before opening and clears it when the sheet closes, which gives the
/// sections a single place to read from instead of each receiving its own copy.
///
/// **Why a controller at all, when #38 only renders a snapshot.** Because the
/// sections that come next do not: the chart (#5) has to fetch and cache a
/// series, the converter (#39) holds an amount and a direction, and both have
/// to survive the rebuilds the sheet performs continuously while it is being
/// dragged. State parked in a `StatefulWidget` inside the sheet would be at the
/// mercy of that. This is where it goes.
///
/// The rate is a **snapshot handed over by the card**, not a live value: the
/// Home list already holds the freshest copy the app has, and re-requesting it
/// would put a spinner over data the user is looking at. Re-syncing it with
/// `CurrencyRepository` while the sheet is open is a deliberate non-goal of
/// #38 — see [open] for where that would hook in.
class CurrencyDetailController extends GetxController {
  final Rxn<Currency> _currency = Rxn<Currency>();

  /// Worker bridging the observable to `update()`, kept so [onClose] can
  /// dispose it.
  ///
  /// `get` 4.7.3 does not dispose workers on its own, and this controller is
  /// registered with `fenix: true`, so it is recreated after every discard. A
  /// worker left behind on each cycle is the leak tracked in #45 — every
  /// controller in this app owns its `onClose`, permanently.
  Worker? _currencyWorker;

  /// The rate on display, or `null` while no sheet is open.
  Currency? get currency => _currency.value;

  /// Whether there is something to render. The sheet is built by a `GetBuilder`
  /// that can run one frame after [dismiss], so it has to be able to ask.
  bool get hasCurrency => _currency.value != null;

  @override
  void onInit() {
    super.onInit();
    // The views use GetBuilder, not Obx (see `getx-architecture`), so the
    // observable has to be bridged explicitly or the sheet never repaints.
    _currencyWorker = ever(_currency, (_) => update());
  }

  @override
  void onClose() {
    _currencyWorker?.dispose();
    _currencyWorker = null;
    super.onClose();
  }

  /// Points the sheet at [currency]. Called before the sheet is shown.
  ///
  /// A future issue that wants the open sheet to follow a background refresh
  /// would add the subscription here — `ever` on `CurrencyRepository`, matching
  /// on `keyName` + `platform`, which is the pair that identifies a rate across
  /// markets — and drop it in [dismiss].
  void open(Currency currency) => _currency.value = currency;

  /// Clears everything when the sheet closes, so nothing stale flashes on the
  /// next open — neither the previous rate nor the amount typed against it.
  void dismiss() {
    _currency.value = null;
    _amountInput = '';
    _isReversed = false;
  }

  // ---------------------------------------------------------------------------
  // Embedded converter (#39)
  // ---------------------------------------------------------------------------

  /// What the user typed, verbatim.
  ///
  /// Kept as the raw string rather than a parsed number so the field never
  /// fights the typing: `1.` and `1.0` are the same value but not the same
  /// text, and writing a parsed value back would move the caret.
  String _amountInput = '';

  bool _isReversed = false;

  String get amountInput => _amountInput;

  /// Whether the conversion runs from the bolívar into the detailed rate
  /// instead of the other way round.
  bool get isReversed => _isReversed;

  /// The side the amount is expressed in, for the [rate] being detailed.
  ///
  /// The rate is a **parameter, not read from [currency]**, even though the two
  /// are the same at runtime. The sheet renders the rate it was handed and the
  /// converter must convert that one: reading a second source here would mean a
  /// sheet that shows one rate and converts another the day they drift apart.
  ///
  /// Unreversed it answers "what is one of this worth in bolívares", which is
  /// the question someone opening a rate is asking. Reversed, the opposite.
  Currency fromCurrencyFor(Currency rate) =>
      _isReversed ? Currency.pivotCurrency : rate;

  /// The side the result is expressed in, for the [rate] being detailed.
  Currency toCurrencyFor(Currency rate) =>
      _isReversed ? rate : Currency.pivotCurrency;

  /// Whether the pair can produce a conversion at all — a market with no rate
  /// yet cannot, and the view says so instead of painting a zero.
  bool canConvertFor(Currency rate) => CurrencyConversion.canConvert(
    fromRate: fromCurrencyFor(rate).value,
    toRate: toCurrencyFor(rate).value,
  );

  /// The converted amount, from the **same** maths the full converter runs.
  ///
  /// #39 requires the result to match `ConverterController` exactly, so both go
  /// through [CurrencyConversion] rather than each keeping a copy of the
  /// formula. Recomputed on read instead of cached: the inputs are two doubles
  /// and a string, and a cache here would be one more thing to invalidate.
  double convertedValueFor(Currency rate) => CurrencyConversion.convert(
    amount: CurrencyConversion.parseAmount(_amountInput),
    fromRate: fromCurrencyFor(rate).value,
    toRate: toCurrencyFor(rate).value,
  );

  void setAmount(String value) {
    if (_amountInput == value) return;
    _amountInput = value;
    update();
  }

  /// Flips the conversion, **carrying the values across with their currencies**.
  ///
  /// This is how the full converter's swap behaves and it is the right model:
  /// the figure belongs to its currency, so `USD 2,5 | VES 1903,04` inverts to
  /// `VES 1903,04 | USD 2,50`, not to `VES 2,5`. Leaving the amount in place
  /// silently changed the question — it asked what two and a half *bolívares*
  /// are worth, and answered `0.00`, which read as a broken converter rather
  /// than as a correct answer to a question nobody asked.
  ///
  /// The result is carried **as it is displayed**, through the same formatting
  /// the view uses, so what moves is what the user was reading. That is also
  /// why [CurrencyHelpers.castAmount] has to keep small values legible: rounding
  /// the carried figure to `0.00` here would destroy it for good.
  void toggleDirection(Currency rate) {
    final String carried = CurrencyHelpers.castAmount(
      value: convertedValueFor(rate),
    );
    _isReversed = !_isReversed;
    _amountInput = carried;
    update();
  }
}
