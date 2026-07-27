import 'package:bcv_tracker_app/core/helpers/backend_date.dart';
import 'package:flutter_test/flutter_test.dart';

/// The assertions compare instants (`toUtc()`) instead of wall clocks, so they
/// hold on any machine. The suite is also run under a second `TZ` in CI-style
/// checks to prove the conversion is not a no-op in the author's zone.
void main() {
  group('toLocal()', () {
    test('reads a timestamp with no offset as UTC', () {
      // What a rate stored in the database looks like.
      final parsed = BackendDate.toLocal('2026-07-27T00:00:53.287063');

      expect(parsed, isNotNull);
      expect(parsed!.toUtc(), DateTime.utc(2026, 7, 27, 0, 0, 53, 287, 63));
      // Returned in the device zone so DateFormat prints local time.
      expect(parsed.isUtc, isFalse);
    });

    test('honours an explicit offset', () {
      // What a rate fetched live looks like: stamped in Caracas.
      final parsed = BackendDate.toLocal('2026-07-26T21:18:42.391560-04:00');

      expect(parsed!.toUtc(), DateTime.utc(2026, 7, 27, 1, 18, 42, 391, 560));
      expect(parsed.isUtc, isFalse);
    });

    test('both shapes of the same instant land on the same moment', () {
      final fromDatabase = BackendDate.toLocal('2026-07-27T01:18:42');
      final fromLive = BackendDate.toLocal('2026-07-26T21:18:42-04:00');

      expect(fromDatabase, fromLive);
    });

    test('accepts the Z suffix and an offset without a colon', () {
      expect(
        BackendDate.toLocal('2026-07-27T00:00:53Z')!.toUtc(),
        DateTime.utc(2026, 7, 27, 0, 0, 53),
      );
      expect(
        BackendDate.toLocal('2026-07-26T20:00:53-0400')!.toUtc(),
        DateTime.utc(2026, 7, 27, 0, 0, 53),
      );
    });

    test('returns null for anything it cannot read', () {
      expect(BackendDate.toLocal(null), isNull);
      expect(BackendDate.toLocal(''), isNull);
      expect(BackendDate.toLocal('   '), isNull);
      expect(BackendDate.toLocal('no es una fecha'), isNull);
      expect(BackendDate.toLocal(1753574453), isNull);
    });
  });

  group('asPublished()', () {
    test('keeps the wall clock of a date published with an offset', () {
      // The BCV effective date: it names a day for Venezuela, so it must read
      // 2026-07-23 no matter where the device is.
      final parsed = BackendDate.asPublished('2026-07-23T00:00:00-04:00');

      expect(parsed, DateTime(2026, 7, 23));
      expect(parsed!.isUtc, isFalse);
      expect(parsed.hour, 0);
    });

    test('leaves a plain date untouched', () {
      expect(BackendDate.asPublished('2026-07-23'), DateTime(2026, 7, 23));
    });

    test('returns null for anything it cannot read', () {
      expect(BackendDate.asPublished(null), isNull);
      expect(BackendDate.asPublished(''), isNull);
      expect(BackendDate.asPublished('no es una fecha'), isNull);
    });
  });
}
