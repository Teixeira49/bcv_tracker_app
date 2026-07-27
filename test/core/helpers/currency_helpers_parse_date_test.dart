import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDate()', () {
    test('empty string returns the placeholder instead of throwing', () {
      // The BCV date is empty until the first refresh lands, and stays empty if
      // the backend has no stored platform date.
      expect(
        CurrencyHelpers.parseDate(date: ''),
        CurrencyHelpers.emptyDatePlaceholder,
      );
    });

    test('unparseable string returns the placeholder', () {
      expect(
        CurrencyHelpers.parseDate(date: 'no-es-una-fecha'),
        CurrencyHelpers.emptyDatePlaceholder,
      );
    });

    test('formats a valid ISO-8601 date', () {
      final formatted = CurrencyHelpers.parseDate(
        date: '2026-07-23T00:00:00-04:00',
        addDayName: false,
      );
      expect(formatted, isNot(CurrencyHelpers.emptyDatePlaceholder));
      expect(formatted, contains('2026'));
    });
  });
}
