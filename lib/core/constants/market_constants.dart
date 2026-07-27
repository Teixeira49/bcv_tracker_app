/// Markets served by the backend, named exactly as it reports them.
///
/// The values mirror `Constants.*_NAME` of `bcv_tracker_backend`, which is what
/// travels in the `platform` field of every rate.
class Markets {
  const Markets._();

  static const String bcv = 'Banco Central de Venezuela';
  static const String yadio = 'Yadio.io';
  static const String binance = 'Binance';
  static const String bybit = 'Bybit';
  static const String okx = 'OKX';
  static const String bitget = 'Bitget';
  static const String airtm = 'Airtm';
  static const String dolarApi = 'DolarAPI';
  static const String exchangeMonitor = 'Exchange Monitor';

  /// Markets rendered in the average tab, in display order.
  ///
  /// `saved-currencies` answers with every market it knows once `fill_missing`
  /// is on (nine of them today), so this list is what decides which ones reach
  /// the UI — and in which order, since the backend orders by database id.
  static const List<String> averageTab = <String>[
    bcv,
    exchangeMonitor,
    yadio,
    binance,
    bybit,
  ];

  /// Exchange Monitor publishes its own value, an estimated average
  /// ("Monitor Dólar") and, live, one entry per bank.
  static const String emOwnCode = 'em';
  static const String emAverageCode = 'average';
  static const String emMonitorCode = 'md';

  /// Codes that quote a dollar-equivalent against VES.
  ///
  /// Used to average the parallel market: the crypto markets quote USDT/USDC
  /// and Exchange Monitor uses its own codes, so filtering by `USD` alone —
  /// as the average card used to do — silently dropped most of them.
  static const Set<String> dollarEquivalentCodes = <String>{
    'USD',
    'USDT',
    'USDC',
    emOwnCode,
    emAverageCode,
    emMonitorCode,
  };
}
