import '../../shared/domain/entities/market.dart';

/// Catalogue of the markets the app can request, and the modes it uses.
///
/// Mirrors `MarketName` / `MarketMode` of the backend
/// (`api/models/market_request.py`). Each market type accepts only some modes,
/// and asking for one it does not allow answers `422`:
///
/// - BCV, Yadio, Airtm, DolarAPI → `off`, `solo-dolar`, `todas`,
///   `bd-solo-dolar`, `bd-todas`
/// - Binance, Bybit, OKX, Bitget → `off`, `average`, `ambas`, `bd-todas`
/// - Exchange Monitor → `off`, `own`, `own+monitor`, `bd-todas`
class Markets {
  const Markets._();

  // --- Modes of the state machine -------------------------------------------
  static const String modeOff = 'off';
  static const String modeLiveDollar = 'solo-dolar';
  static const String modeLiveAll = 'todas';
  static const String modeDbDollar = 'bd-solo-dolar';
  static const String modeDbAll = 'bd-todas';

  /// Crypto only: one averaged rate per asset, `(buy + sell) / 2`.
  static const String modeAverage = 'average';

  /// Crypto only: both sides of every asset.
  static const String modeBoth = 'ambas';

  /// Exchange Monitor only: its own value.
  static const String modeEmOwn = 'own';

  /// Exchange Monitor only: its own value plus its estimated average.
  static const String modeEmOwnMonitor = 'own+monitor';

  // --- Platform names, as they travel in the `platform` field ---------------
  static const String bcv = 'Banco Central de Venezuela';
  static const String exchangeMonitor = 'Exchange Monitor';
  static const String yadio = 'Yadio.io';
  static const String binance = 'Binance';
  static const String bybit = 'Bybit';
  static const String okx = 'OKX';
  static const String bitget = 'Bitget';
  static const String airtm = 'Airtm';
  static const String dolarApi = 'DolarAPI';

  // --- Keys of the Body -----------------------------------------------------
  static const String bcvKey = 'bcv';
  static const String exchangeMonitorKey = 'exchange_monitor';
  static const String yadioKey = 'yadio';
  static const String binanceKey = 'binance';
  static const String bybitKey = 'bybit';
  static const String okxKey = 'okx';
  static const String bitgetKey = 'bitget';
  static const String airtmKey = 'airtm';
  static const String dolarApiKey = 'dolarapi';

  /// Every market the app can request, in display order.
  ///
  /// The mode of each one is the cheapest that still answers what the UI shows:
  /// the BCV from the database, since the backend cron refreshes it once a day
  /// at midnight Venezuela time, and the rest live so their rate and its ROC
  /// are current. Crypto markets use `average` because reading them from the
  /// database would collapse buy and sell — the backend keys its rows by
  /// `(code, platform)`, so only the last side written survives.
  static const List<Market> catalog = <Market>[
    Market(key: bcvKey, platform: bcv, mode: modeDbDollar),
    // No mode returns only the estimated average, so this brings its own value
    // too and [emAverageCode] keeps just "Monitor Dólar".
    Market(
      key: exchangeMonitorKey,
      platform: exchangeMonitor,
      mode: modeEmOwnMonitor,
    ),
    Market(key: yadioKey, platform: yadio, mode: modeLiveDollar),
    Market(key: binanceKey, platform: binance, mode: modeAverage),
    Market(key: bybitKey, platform: bybit, mode: modeAverage),
    Market(key: okxKey, platform: okx, mode: modeAverage),
    Market(key: bitgetKey, platform: bitget, mode: modeAverage),
    Market(key: airtmKey, platform: airtm, mode: modeLiveDollar),
    Market(key: dolarApiKey, platform: dolarApi, mode: modeLiveDollar),
  ];

  /// Markets selected out of the box: the reference rates of the parallel
  /// market plus the official one. The rest are opt-in from the settings.
  static const Set<String> defaultKeys = <String>{
    bcvKey,
    exchangeMonitorKey,
    yadioKey,
    binanceKey,
    bybitKey,
  };

  static MarketSelection get defaultSelection => selectionOf(defaultKeys);

  /// Selection with the catalogue markets whose key is in [keys], keeping the
  /// catalogue order. Unknown keys are ignored, so a preference saved by an
  /// older version cannot break the request.
  static MarketSelection selectionOf(Set<String> keys) => MarketSelection(
    catalog.where((market) => keys.contains(market.key)).toList(),
  );

  /// Exchange Monitor publishes its own value, an estimated average
  /// ("Monitor Dólar") and, live, one entry per bank.
  static const String emOwnCode = 'em';
  static const String emAverageCode = 'average';
  static const String emMonitorCode = 'md';

  /// Codes that quote a dollar-equivalent against VES.
  ///
  /// Used to average the parallel market: the crypto markets quote USDT/USDC
  /// and Exchange Monitor uses its own codes, so filtering by `USD` alone
  /// silently dropped most of them.
  static const Set<String> dollarEquivalentCodes = <String>{
    'USD',
    'USDT',
    'USDC',
    emOwnCode,
    emAverageCode,
    emMonitorCode,
  };
}
