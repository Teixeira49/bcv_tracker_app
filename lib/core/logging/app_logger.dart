import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity of a log record. The numeric value follows the `dart:developer`
/// convention (higher is more severe), so it maps straight onto `log(level:)`
/// and onto the IDE's log filtering.
enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.value);

  /// The `dart:developer` level int this severity emits at.
  final int value;
}

/// The project's single logging entry point.
///
/// The app used to log almost nothing: the `catch` blocks at the system
/// boundaries absorbed the exception and turned it into UI state, so the real
/// cause — the `message` and `statusCode` an `ApiException` carries — vanished
/// the moment it became an error string on screen. This routes those causes to
/// one place, with levels, before the translation happens.
///
/// **This is the standard.** No `print`/`debugPrint` (the `avoid_print` lint
/// enforces the first); every boundary `catch` logs its cause here. See
/// `.agents/rules/logging-convention.md`.
///
/// **Release stays quiet and clean.** [minLevel] defaults to `warning` in
/// release, so the verbose `debug`/`info` records — the ones most likely to
/// carry a URL or a payload — never reach a shipped build. And a URL is logged
/// through [redactUri], never raw, so no credentials in a query or userinfo
/// component leak into a device log.
class AppLogger {
  AppLogger._();

  /// Records below this level are dropped. `debug` and up in a debug build,
  /// `warning` and up in release. Settable so a test can pin it and so a build
  /// can raise or lower verbosity without touching call sites — the log level
  /// is configuration, not something each caller decides.
  static LogLevel minLevel = kReleaseMode ? LogLevel.warning : LogLevel.debug;

  /// Whether a record at [level] would be emitted under the current [minLevel].
  /// Exposed so the threshold is unit-testable without capturing developer log
  /// output.
  static bool shouldLog(LogLevel level) => level.value >= minLevel.value;

  static void debug(String message, {String? name}) =>
      _log(LogLevel.debug, message, name: name);

  static void info(String message, {String? name}) =>
      _log(LogLevel.info, message, name: name);

  static void warning(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.warning,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );

  static void error(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) => _log(
    LogLevel.error,
    message,
    name: name,
    error: error,
    stackTrace: stackTrace,
  );

  /// Strips the parts of a URL that must never reach a log: the `user:pass@`
  /// userinfo and the query string, where a token or key would sit. Returns
  /// `scheme://host[:port]/path`, or the input unchanged if it is not a URL
  /// (better a harmless string than a thrown logger).
  static String redactUri(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return url;
    final buffer = StringBuffer('${uri.scheme}://${uri.host}');
    if (uri.hasPort) buffer.write(':${uri.port}');
    buffer.write(uri.path);
    if (uri.hasQuery) buffer.write('?…');
    return buffer.toString();
  }

  static void _log(
    LogLevel level,
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!shouldLog(level)) return;
    developer.log(
      message,
      level: level.value,
      name: name ?? 'bcv_tracker',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
