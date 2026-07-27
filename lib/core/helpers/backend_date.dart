/// Reads the timestamps as the backend writes them.
///
/// Two shapes travel in the same fields:
///
/// - rates read from the database arrive **without** an offset
///   (`2026-07-27T00:00:53.287063`). Their column is a `DateTime` with no
///   timezone, so the database normalized the Caracas instant the backend
///   stamped to its session zone — UTC — and dropped the offset.
/// - rates fetched live are serialized straight from the backend object and
///   keep their explicit Caracas offset (`2026-07-26T21:18:42.391560-04:00`).
///
/// `DateTime.parse` reads the first shape as **device local time**, so every
/// stored rate was shown hours off for anyone outside UTC.
class BackendDate {
  const BackendDate._();

  /// Trailing `Z`, `+HH:MM`, `-HHMM`… of an ISO-8601 timestamp.
  static final RegExp _offsetSuffix = RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$');

  /// Instant of a backend timestamp, expressed in the device's local zone.
  ///
  /// A timestamp with no offset is read as UTC, which is what the database
  /// stores; one with an offset is honoured as given. Returns `null` for
  /// anything unparseable, since every date is optional in the contract.
  static DateTime? toLocal(Object? raw) {
    if (raw is! String) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    final absolute = _offsetSuffix.hasMatch(value) ? value : '${value}Z';
    return DateTime.tryParse(absolute)?.toLocal();
  }

  /// The same wall clock the backend published, with no zone conversion.
  ///
  /// For a date that names a day instead of an instant — the BCV publishes its
  /// effective date for Venezuela — converting to the device zone would move
  /// the day for anyone west of Caracas.
  static DateTime? asPublished(Object? raw) {
    if (raw is! String) return null;
    final value = raw.trim();
    if (value.isEmpty) return null;

    return DateTime.tryParse(value.replaceFirst(_offsetSuffix, ''));
  }
}
