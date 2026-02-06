class DollarEndpoints {

  static const String _apiEndpoints = '/api/venezuela';

  static const String _currentDollarParams = '?bcv=true&yadio=false&binance=false&fill_missing=true&enforce_bcv_dollar=true&enforce_yadio_dollar=false';

  static const String currentDollar = '$_apiEndpoints/saved-currencies$_currentDollarParams';

  static const String currentBCVDollar = '$_apiEndpoints/bcv/with-memory';
}
