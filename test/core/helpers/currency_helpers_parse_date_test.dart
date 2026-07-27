import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/core/helpers/currency_helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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

    test('keeps the day the BCV published, in any device zone', () {
      // Converting this to the device zone would show 2026-07-22 to anyone
      // west of Caracas: it names a day for Venezuela, not an instant.
      expect(
        CurrencyHelpers.parseDate(
          date: '2026-07-23T00:00:00-04:00',
          addDayName: false,
        ),
        '2026-07-23',
      );
    });
  });

  group('formatDate()', () {
    test('prints an instant in the device zone', () {
      final instant = DateTime.utc(2026, 7, 27, 0, 0, 53).toLocal();

      expect(
        CurrencyHelpers.formatDate(date: instant),
        DateFormat(Constants.defaultFormatDate).format(instant),
      );
    });

    test('converts a UTC instant instead of printing its UTC clock', () {
      final utc = DateTime.utc(2026, 7, 27, 0, 0, 53);

      expect(
        CurrencyHelpers.formatDate(date: utc),
        DateFormat(Constants.defaultFormatDate).format(utc.toLocal()),
      );
    });
  });
}
