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

  /// `saved-currencies` is a **POST** since the backend replaced its query-param
  /// flags (`fill_missing`, `enforce_*`, one boolean per market) with a
  /// structured Body — a state machine per market (`MarketSelection`, backend
  /// issue #71). GET-with-body is not reliable across clients, hence POST.
  static const String currentDollar = '$_apiEndpoints/saved-currencies';

  /// Body sent to `saved-currencies`: the state (`mode`) requested per market.
  ///
  /// A market **absent** from the map is treated as `off` by the backend, so
  /// this map alone decides which markets arrive — it lists exactly the ones the
  /// average tab shows ([Markets.averageTab]); `okx`, `bitget`, `airtm` and
  /// `dolarapi` are left out on purpose.
  ///
  /// The modes reproduce what the old flags produced:
  /// - `bcv: bd-solo-dolar` — from the database (cheap, cron-refreshed), only
  ///   the official dollar (was `bcv=true` + `enforce_bcv_dollar`).
  /// - `yadio: solo-dolar` — live, only the dollar; Yadio also quotes euro and
  ///   bitcoin (was `yadio=false` + `enforce_yadio_dollar`).
  /// - `binance`/`bybit: average` — the crypto average per asset, `(buy+sell)/2`
  ///   computed by the backend (was live, both sides merged on the client).
  /// - `exchange_monitor: own+monitor` — its own value plus the estimated
  ///   average ("Monitor Dólar"). The old `enforce_em_average` returned only the
  ///   average; the new contract has no "average-only" mode, so this is the
  ///   closest (backend issue #89 flags it for review).
  ///
  /// Every live source is a failure point — the backend gathers them without
  /// `return_exceptions`, so one answering 502 fails the whole request — which
  /// is why only the markets shown are requested and BCV stays on the database.
  static const Map<String, dynamic> currentDollarBody = {
    'markets': {
      'bcv': 'bd-solo-dolar',
      'yadio': 'solo-dolar',
      'binance': 'average',
      'bybit': 'average',
      'exchange_monitor': 'own+monitor',
    },
  };

  /// Official BCV rates plus the effective date the institution reported.
  ///
  /// `with-memory` is the variant that answers from the backend's stored copy when
  /// the BCV's own page is unreachable — which it regularly is, since that side
  /// scrapes HTML. It is why the app can open on official rates during an outage.
  static const String currentBCVDollar = '$_apiEndpoints/bcv/with-memory';
}
