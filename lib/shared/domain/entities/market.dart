/// A rate source of the backend and the mode the app asks it in.
///
/// Since v3.0.0 the backend selects sources with a per-market state machine
/// instead of query flags: every market declares a `mode` and the ones left out
/// of the request are `off`. See `api/models/market_request.py` in the backend.
class Market {
  const Market({
    required this.key,
    required this.platform,
    required this.mode,
    String? shortName,
  }) : _shortName = shortName;

  /// Key inside the `markets` Body — the backend's `MarketName`.
  final String key;

  /// Value the market puts in the `platform` field of the rates it returns.
  /// It is not the same string as [key], and it is also what the UI shows.
  final String platform;

  final String? _shortName;

  /// Name for tight spots, where [platform] does not fit. Not translated:
  /// every market is a brand or an institution.
  String get shortName => _shortName ?? platform;

  /// Mode requested for this market, out of the ones its type allows.
  final String mode;

  Market copyWith({String? mode}) => Market(
    key: key,
    platform: platform,
    mode: mode ?? this.mode,
    shortName: _shortName,
  );
}

/// The set of markets a request asks for, ready to travel as the Body.
class MarketSelection {
  const MarketSelection(this.markets);

  /// Markets to request, in the order the UI renders them.
  final List<Market> markets;

  bool get isEmpty => markets.isEmpty;

  /// Platforms the answer may contain, to keep anything else out of the UI.
  Set<String> get platforms => {for (final market in markets) market.platform};

  /// `{"markets": {"bcv": "bd-solo-dolar", …}}` — a market that is absent is
  /// `off` for the backend, which is exactly what "not selected" means here.
  Map<String, dynamic> toJson() => {
    'markets': {for (final market in markets) market.key: market.mode},
  };
}
