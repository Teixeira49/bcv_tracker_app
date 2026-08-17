/// The pivot conversion, with no state attached.
///
/// Every rate the app holds is quoted against the bolívar, so converting is
/// always `amount × fromRate ÷ toRate` with VES as the pivot. That arithmetic
/// used to live inside `ConverterController`, tangled with the selection it
/// operates on. #39 needs the same maths in the currency detail's embedded
/// converter, and the issue is explicit that it must not be copied: a second
/// copy is a second place for a rounding rule to drift.
///
/// So it moved here, and the full converter calls it too. That is what makes
/// "the embedded converter produces exactly the same result" a fact rather than
/// a promise — the two run the same lines.
///
/// Pure on purpose: no `Currency`, no controller, no formatting. It takes the
/// numbers and returns a number; who owns them and how they are displayed is
/// the caller's business.
class CurrencyConversion {
  const CurrencyConversion._();

  /// A rate can only take part in a conversion when it is finite and not zero.
  ///
  /// Zero reaches the app through ordinary paths — `Currency.empty` declares
  /// `value: 0.00`, and the backend answers with markets that have no data yet
  /// — and dividing doubles by zero does not throw in Dart: it yields
  /// `Infinity`, or `NaN` when the dividend is zero too (#15).
  static bool isUsableRate(double rate) => rate.isFinite && rate != 0.0;

  /// Whether a pair can produce a conversion at all.
  static bool canConvert({required double fromRate, required double toRate}) =>
      isUsableRate(fromRate) && isUsableRate(toRate);

  /// Last line of defence before a value reaches the UI: `Infinity` and `NaN`
  /// are formatted verbatim by `toString()`, so they never leave this class.
  static double sanitize(double value) => value.isFinite ? value : 0.0;

  /// [amount] of the currency quoted at [fromRate], expressed in the one quoted
  /// at [toRate].
  ///
  /// Returns zero when the pair cannot convert, which is the honest placeholder:
  /// a caller that wants to *say* so asks [canConvert] and renders a message,
  /// as both converters do.
  static double convert({
    required double amount,
    required double fromRate,
    required double toRate,
  }) {
    if (!canConvert(fromRate: fromRate, toRate: toRate)) {
      return 0.0;
    }
    return sanitize((amount * fromRate) / toRate);
  }

  /// Reads an amount the way a user typed it.
  ///
  /// The comma is a decimal mark in most of the languages the app ships, so it
  /// is accepted and normalised — `AmountInputFormatter` lets both through for
  /// this reason. A lone separator is the state of a field mid-keystroke and
  /// reads as zero rather than as a parse failure; anything else unparseable
  /// degrades to zero too, because a converter that throws while being typed
  /// into is worse than one that shows nothing yet.
  static double parseAmount(String value) {
    if (value.isEmpty) {
      return 0.0;
    }
    final String normalised = value.replaceAll(',', '.');
    if (normalised == '.') {
      return 0.0;
    }
    return double.tryParse(normalised) ?? 0.0;
  }
}
