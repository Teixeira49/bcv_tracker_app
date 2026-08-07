import 'package:bcv_tracker_app/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The threshold is global mutable state; restore it so one test cannot bleed
  // into the next.
  final LogLevel original = AppLogger.minLevel;
  tearDown(() => AppLogger.minLevel = original);

  group('shouldLog', () {
    test('emits a record at or above the threshold', () {
      AppLogger.minLevel = LogLevel.warning;

      expect(AppLogger.shouldLog(LogLevel.warning), isTrue);
      expect(AppLogger.shouldLog(LogLevel.error), isTrue);
    });

    test('drops a record below the threshold', () {
      AppLogger.minLevel = LogLevel.warning;

      expect(AppLogger.shouldLog(LogLevel.debug), isFalse);
      expect(AppLogger.shouldLog(LogLevel.info), isFalse);
    });

    test('a debug threshold lets everything through', () {
      AppLogger.minLevel = LogLevel.debug;

      for (final level in LogLevel.values) {
        expect(AppLogger.shouldLog(level), isTrue, reason: '$level');
      }
    });

    test('an error threshold keeps only errors', () {
      AppLogger.minLevel = LogLevel.error;

      expect(AppLogger.shouldLog(LogLevel.error), isTrue);
      expect(AppLogger.shouldLog(LogLevel.warning), isFalse);
    });

    test('level values are ordered by severity', () {
      expect(LogLevel.debug.value, lessThan(LogLevel.info.value));
      expect(LogLevel.info.value, lessThan(LogLevel.warning.value));
      expect(LogLevel.warning.value, lessThan(LogLevel.error.value));
    });
  });

  group('redactUri', () {
    test('drops the query string, where a token would sit', () {
      expect(
        AppLogger.redactUri('https://api.example.com/v1/rates?token=secret'),
        'https://api.example.com/v1/rates?…',
      );
    });

    test('drops the user:pass userinfo', () {
      expect(
        AppLogger.redactUri('https://user:pass@api.example.com/v1/rates'),
        'https://api.example.com/v1/rates',
      );
    });

    test('keeps scheme, host, port and path intact', () {
      expect(
        AppLogger.redactUri('http://10.0.2.2:8000/api/v1/bcv'),
        'http://10.0.2.2:8000/api/v1/bcv',
      );
    });

    test('leaves a non-URL string untouched instead of throwing', () {
      expect(AppLogger.redactUri('/api/v1/bcv'), '/api/v1/bcv');
      expect(AppLogger.redactUri(''), '');
    });

    test('never leaks a query value it was given', () {
      final redacted = AppLogger.redactUri(
        'https://api.example.com/rates?apikey=DEADBEEF&user=me',
      );
      expect(redacted, isNot(contains('DEADBEEF')));
      expect(redacted, isNot(contains('apikey')));
    });
  });
}
