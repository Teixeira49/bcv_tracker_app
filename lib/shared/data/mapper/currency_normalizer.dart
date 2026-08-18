import '../../../core/constants/market_constants.dart';
import '../../domain/entities/currency.dart';

/// Turns the raw `saved-currencies` payload into the list the UI can render.
///
/// The endpoint returns every market it knows (nine today) with one row per
/// P2P side, and its database keeps rates keyed by `(code, platform)` — which
/// makes repeated rows for the same pair possible. This collapses all of that:
///
/// 1. keeps only the markets in [Markets.averageTab];
/// 2. drops repeated `(platform, code, name)` rows, keeping the first one —
///    the backend orders by descending id, so that is the most recent;
/// 3. merges the `-buy` / `-sell` sides of a pair into a single averaged rate;
/// 4. sorts by market, so the order does not depend on database ids.
class CurrencyNormalizer {
  const CurrencyNormalizer._();

  static const String _buySuffix = '-buy';
  static const String _sellSuffix = '-sell';

  /// The rows the average tab should show, from what the backend actually sent.
  ///
  /// Three problems in one pass, all of them real rather than defensive: markets
  /// the app does not list are dropped, the `-buy`/`-sell` pair each P2P market
  /// publishes is merged into one row, and duplicates the database occasionally
  /// repeats are removed. Without this the tab shows Binance three times and the
  /// average is dragged by whichever side repeated.
  static List<Currency> forAverageTab(List<Currency> currencies) {
    final allowed = currencies.where(
      (currency) => Markets.averageTab.contains(currency.platform),
    );
    final merged = _mergeSides(_dedupe(allowed));
    merged.sort(_byMarketThenCode);
    return merged;
  }

  /// Removes exact repeats of `(platform, code, name)`, keeping the first.
  static List<Currency> _dedupe(Iterable<Currency> currencies) {
    final seen = <String>{};
    return currencies
        .where(
          (currency) => seen.add(
            '${currency.platform}|${currency.keyName}|${currency.name}',
          ),
        )
        .toList();
  }

  /// Averages the buy and sell sides of the same asset into one rate.
  static List<Currency> _mergeSides(List<Currency> currencies) {
    final groups = <String, List<Currency>>{};
    for (final currency in currencies) {
      final key =
          '${currency.platform}|${currency.keyName}|${_baseName(currency.name)}';
      groups.putIfAbsent(key, () => <Currency>[]).add(currency);
    }
    return groups.values.map(_merge).toList();
  }

  static Currency _merge(List<Currency> group) {
    final first = group.first;
    if (group.length == 1) {
      return first.copyWith(name: _baseName(first.name));
    }

    final tendencies = group
        .map((currency) => currency.tendency)
        .whereType<double>()
        .toList();

    return Currency(
      name: _baseName(first.name),
      keyName: first.keyName,
      platform: first.platform,
      value: _mean(group.map((currency) => currency.value)),
      imgUrl: group
          .map((currency) => currency.imgUrl)
          .firstWhere((url) => url != null, orElse: () => null),
      createDate: _earliest(group.map((currency) => currency.createDate)),
      updateDate: _latest(group.map((currency) => currency.updateDate)),
      tendency: tendencies.isEmpty ? null : _mean(tendencies),
    );
  }

  /// `Tether-buy` / `Tether-sell` → `Tether`.
  static String _baseName(String name) {
    final lower = name.toLowerCase();
    for (final suffix in const [_buySuffix, _sellSuffix]) {
      if (lower.endsWith(suffix)) {
        return name.substring(0, name.length - suffix.length);
      }
    }
    return name;
  }

  static double _mean(Iterable<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  static DateTime? _earliest(Iterable<DateTime?> dates) => dates
      .whereType<DateTime>()
      .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);

  static DateTime? _latest(Iterable<DateTime?> dates) => dates
      .whereType<DateTime>()
      .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

  static int _byMarketThenCode(Currency a, Currency b) {
    final byMarket = Markets.averageTab
        .indexOf(a.platform)
        .compareTo(Markets.averageTab.indexOf(b.platform));
    if (byMarket != 0) return byMarket;
    final byCode = a.keyName.compareTo(b.keyName);
    return byCode != 0 ? byCode : a.name.compareTo(b.name);
  }
}
