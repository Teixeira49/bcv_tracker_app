import 'package:bcv_tracker_app/core/helpers/amount_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs the formatter the way a field does: an old value, an attempted new one.
String _type({required String from, required String to}) =>
    const AmountInputFormatter()
        .formatEditUpdate(
          TextEditingValue(text: from),
          TextEditingValue(text: to),
        )
        .text;

void main() {
  group('accepts what the converter can parse', () {
    test('digits', () {
      expect(_type(from: '', to: '100'), '100');
      expect(_type(from: '1', to: '12'), '12');
    });

    test('one separator, either mark', () {
      // `calculator` normalises the comma before parsing, and the two are the
      // decimal mark in different locales the app ships.
      expect(_type(from: '1', to: '1.5'), '1.5');
      expect(_type(from: '1', to: '1,5'), '1,5');
    });

    test('the partial forms typed on the way to a number', () {
      expect(_type(from: '1', to: '1.'), '1.');
      expect(_type(from: '', to: '.'), '.');
      expect(_type(from: '.', to: '.5'), '.5');
    });

    test('an empty field, so it can be cleared', () {
      expect(_type(from: '100', to: ''), '');
    });
  });

  group('refuses what would silently become zero', () {
    test('letters, from a hardware keyboard or a dictation', () {
      // `TextInputType.numberWithOptions` only asks the on-screen keyboard for
      // a numeric layout; nothing stops these from reaching the field.
      expect(_type(from: '10', to: '10a'), '10');
      expect(_type(from: '', to: 'abc'), '');
    });

    test('symbols and separators of thousands', () {
      for (final String attempt in <String>['10\$', '1 000', '1-0', '1e5']) {
        expect(
          _type(from: '10', to: attempt),
          '10',
          reason: attempt,
        );
      }
    });

    test('a second separator', () {
      expect(_type(from: '1.5', to: '1.5.'), '1.5');
      expect(_type(from: '1.5', to: '1.5,2'), '1.5');
    });

    test('a paste is refused whole, never repaired', () {
      // Stripping would turn this into `1.23`, a number the user never wrote.
      expect(_type(from: '', to: '1.2.3'), '');
      expect(_type(from: '7', to: 'Bs.S 100'), '7');
    });
  });
}
