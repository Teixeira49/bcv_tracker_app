import 'package:flutter/services.dart';

/// Keeps an amount field to what the converter can actually parse.
///
/// `keyboardType: TextInputType.numberWithOptions(decimal: true)` only *asks*
/// the on-screen keyboard for a numeric layout — it is a hint, not a
/// constraint. A hardware keyboard, a paste, an IME suggestion or a voice
/// dictation all reach the field unfiltered, and `ConverterController.calculator`
/// then falls back to `0.0` on anything it cannot parse: the amount silently
/// becomes zero and the conversion reads as a legitimate result.
///
/// Rejecting the edit as a whole, rather than stripping the offending
/// characters, is deliberate: stripping turns a pasted `1.2.3` into `1.23`,
/// which is a number the user never wrote. Refusing leaves the field exactly as
/// it was, and nothing is invented.
class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  /// Digits, at most one separator, digits.
  ///
  /// Both `.` and `,` are accepted because `calculator` normalises the comma
  /// before parsing, and the two are the decimal mark in different locales the
  /// app ships. The empty string matches on purpose — the field has to be
  /// clearable — and so do the partial forms a user types through: `1`, `1.`,
  /// `.5`.
  static final RegExp _amount = RegExp(r'^\d*[.,]?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => _amount.hasMatch(newValue.text) ? newValue : oldValue;
}
