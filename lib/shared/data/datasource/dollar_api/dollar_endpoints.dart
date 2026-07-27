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

  /// Rates of the selected markets. **POST since backend v3.0.0**: it takes a
  /// per-market Body (`MarketSelection`) instead of the old query flags, so the
  /// request carries no query string — see `MarketSelection.toJson()`.
  static const String currentDollar = '$_apiEndpoints/saved-currencies';

  static const String currentBCVDollar = '$_apiEndpoints/bcv/with-memory';
}
