/// Paths of the currency backend (see `bcv_tracker_backend`).
///
/// The backend owns the API version in a router (`api/router/v1.py`) mounted by
/// `main.py` under `Constants.API_V1_STR`, and each country controller
/// contributes its own segment (`/venezuela`). The resulting contract is
/// `/api/{version}/{country}/...`, so both pieces are kept apart here instead of
/// being baked into every path.
class DollarEndpoints {
  static const String _apiVersion = 'v1';

  static const String _country = 'venezuela';

  static const String _apiEndpoints = '/api/$_apiVersion/$_country';

  /// Sources and filters for `saved-currencies`.
  ///
  /// `fill_missing` fetches live every market left at `false`, and there is no
  /// way to leave a market out: one at `true` is read from the database and one
  /// at `false` is scraped live, but both come back. So this map does not pick
  /// *which* markets arrive — [Markets.averageTab] does that on the client —
  /// it picks **where each one comes from**:
  ///
  /// - live (`false`) only the three the app shows as fresh rates. Each live
  ///   source adds latency and is a failure point: the backend gathers them
  ///   without `return_exceptions`, so one source answering 502 fails the whole
  ///   request.
  /// - from the database (`true`) the rest, which is cheap, plus BCV and
  ///   Exchange Monitor, refreshed by the backend cron six times a day.
  ///
  /// Once the per-market Body (#71) is deployed this whole dance is replaced by
  /// `off` for the markets we do not want and `average` for the crypto ones.
  static const Map<String, String> _currentDollarParams = {
    // Live.
    'yadio': 'false',
    'binance': 'false',
    'bybit': 'false',
    // From the database.
    'bcv': 'true',
    'exchange_monitor': 'true',
    'okx': 'true',
    'bitget': 'true',
    'airtm': 'true',
    'dolarapi': 'true',
    'fill_missing': 'true',
    // Only the official dollar out of the BCV, only the dollar out of Yadio
    // (it also publishes euro and bitcoin) and only the estimated average of
    // Exchange Monitor ("Monitor Dólar").
    'enforce_bcv_dollar': 'true',
    'enforce_yadio_dollar': 'true',
    'enforce_em_average': 'true',
  };

  static final String currentDollar = Uri(
    path: '$_apiEndpoints/saved-currencies',
    queryParameters: _currentDollarParams,
  ).toString();

  static const String currentBCVDollar = '$_apiEndpoints/bcv/with-memory';
}
