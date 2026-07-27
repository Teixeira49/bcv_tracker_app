import '../../../core/constants/market_constants.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/market.dart';

/// Turns the raw `saved-currencies` payload into the list the UI can render.
///
/// The Body already asks for the requested markets only, so this closes the
/// gaps the contract leaves open:
///
/// 1. keeps only the platforms of [MarketSelection], as a guard against a
///    market answering with a platform that was not requested;
/// 2. keeps a single Exchange Monitor rate — the one filter the Body cannot
///    express, see [_withoutRedundantExchangeMonitor];
/// 3. drops repeated `(platform, code, name)` rows, keeping the first one —
///    reads from the database come ordered by descending id, so that is the
///    most recent;
/// 4. merges the `-buy` / `-sell` sides of a pair into a single averaged rate,
///    which is what Airtm returns and what any market in `ambas` would;
/// 5. sorts by the order of the selection, so it does not depend on the order
///    the backend concatenates database reads and live fetches in.
///
/// Steps 3 and 4 are guards for most markets: with the modes the catalogue
/// uses, the backend already returns the latest row per `(code, platform)` and
/// crypto arrives averaged. They still do real work for Airtm, and they cover
/// any market switched to `ambas` or `bd-todas`.
class CurrencyNormalizer {
  const CurrencyNormalizer._();

  static const String _buySuffix = '-buy';
  static const String _sellSuffix = '-sell';

  static List<Currency> forAverageTab(
    List<Currency> currencies,
    MarketSelection selection,
  ) {
    final platforms = selection.platforms;
    final order = [for (final market in selection.markets) market.platform];

    final allowed = currencies.where(
      (currency) => platforms.contains(currency.platform),
    );
    final merged = _mergeSides(
      _dedupe(_withoutRedundantExchangeMonitor(allowed)),
    );
    merged.sort((a, b) => _byMarketThenCode(a, b, order));
    return merged;
  }

  /// Keeps only the estimated average of Exchange Monitor, when it is there.
  ///
  /// No mode returns just that rate: `own+monitor` and `bd-todas` bring its own
  /// value (`em`) alongside the average (`average`), and the old contract
  /// trimmed it server side with `enforce_em_average`. The other rows are only
  /// dropped if the average is present, so a market asked in `own` still shows.
  static Iterable<Currency> _withoutRedundantExchangeMonitor(
    Iterable<Currency> currencies,
  ) {
    final hasAverage = currencies.any(
      (currency) =>
          currency.platform == Markets.exchangeMonitor &&
          currency.keyName == Markets.emAverageCode,
    );
    if (!hasAverage) return currencies;

    return currencies.where(
      (currency) =>
          currency.platform != Markets.exchangeMonitor ||
          currency.keyName == Markets.emAverageCode,
    );
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

  static int _byMarketThenCode(Currency a, Currency b, List<String> order) {
    final byMarket = order
        .indexOf(a.platform)
        .compareTo(order.indexOf(b.platform));
    if (byMarket != 0) return byMarket;
    final byCode = a.keyName.compareTo(b.keyName);
    return byCode != 0 ? byCode : a.name.compareTo(b.name);
  }
}
