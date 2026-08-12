import 'package:get/get.dart';

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

  /// Clears the rate when the sheet closes, so a stale one never flashes on the
  /// next open.
  void dismiss() => _currency.value = null;
}
