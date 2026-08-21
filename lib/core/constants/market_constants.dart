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
  /// These are exactly the markets requested in the `saved-currencies` POST Body
  /// (`DollarEndpoints.currentDollarBody`); a market absent from that Body is
  /// `off` on the backend and never arrives. The order here is the display
  /// order, since the backend orders its rows by database id.
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

  /// Every market the app can show, with what kind of reference it publishes
  /// and where that reference comes from.
  ///
  /// Introduced by [#42](https://github.com/Teixeira49/bcv_tracker_app/issues/42)
  /// for the About screen, and placed **here rather than in that screen** on
  /// purpose: "what kind of thing is Binance's number, and whose is it" is a
  /// fact about the market, of the same order as its name, not a piece of copy.
  /// [#12](https://github.com/Teixeira49/bcv_tracker_app/issues/12) is the issue
  /// that wants this classification for the rate cards; when it lands it reads
  /// this list instead of writing a second one.
  ///
  /// Ordered as the About screen lists them: the official rate first, then the
  /// rest alphabetically. It is **not** [averageTab]'s order, which is the
  /// backend's display order for a different question.
  ///
  /// **Every URL is the market's own site, and none is a deep link.** The first
  /// draft mixed the two — `p2p.binance.com` for Binance's order book and the
  /// corporate home for the other three exchanges — which is worse than either
  /// rule applied consistently: a user comparing two rows would have been sent
  /// to two different kinds of place. Deep links to each P2P book would be more
  /// precise and are the better answer once someone has opened all four and
  /// confirmed the paths; guessing them from memory is how a row ends up
  /// pointing at a 404. `dolarapi.com` for the same reason: `ve.dolarapi.com`
  /// is the API host and would have answered a curious tap with raw JSON.
  static const List<MarketSource> sources = <MarketSource>[
    MarketSource(
      name: bcv,
      kind: MarketKind.official,
      url: 'https://www.bcv.org.ve',
    ),
    MarketSource(
      name: airtm,
      kind: MarketKind.peerToPeer,
      url: 'https://www.airtm.com',
    ),
    MarketSource(
      name: binance,
      kind: MarketKind.peerToPeer,
      url: 'https://www.binance.com',
    ),
    MarketSource(
      name: bitget,
      kind: MarketKind.peerToPeer,
      url: 'https://www.bitget.com',
    ),
    MarketSource(
      name: bybit,
      kind: MarketKind.peerToPeer,
      url: 'https://www.bybit.com',
    ),
    MarketSource(
      name: dolarApi,
      kind: MarketKind.aggregator,
      url: 'https://dolarapi.com',
    ),
    MarketSource(
      name: exchangeMonitor,
      kind: MarketKind.aggregator,
      url: 'https://exchangemonitor.net',
    ),
    MarketSource(
      name: okx,
      kind: MarketKind.peerToPeer,
      url: 'https://www.okx.com',
    ),
    MarketSource(
      name: yadio,
      kind: MarketKind.aggregator,
      url: 'https://yadio.io',
    ),
  ];
}

/// What kind of reference a market publishes.
///
/// Three kinds and not the "oficial / P2P cripto / agregador" of #42's wording,
/// for one reason: **Airtm is peer-to-peer but not crypto**, so filing it under
/// a "crypto P2P" label would state something untrue about where its number
/// comes from. [peerToPeer] covers both and claims less.
///
/// The distinction is not decorative. A rate the central bank *sets*, one that
/// emerges from people trading, and one that another service *averaged before
/// we saw it* answer "how much is the dollar" in three different senses, and
/// the user deciding what to charge is entitled to know which one they are
/// reading.
enum MarketKind {
  /// Published by the issuing institution. Only the BCV.
  official,

  /// Emerges from people trading with each other — the crypto exchanges' P2P
  /// books, and Airtm's digital-dollar marketplace.
  peerToPeer,

  /// Derives its number from other people's — by republishing, indexing or
  /// averaging. Exchange Monitor, Yadio and DolarAPI.
  ///
  /// Worth saying out loud on the About screen: when the app averages these it
  /// is averaging averages, and a user comparing two aggregators may be
  /// comparing two views of the same underlying trades.
  aggregator,
}

/// One market as the About screen presents it: who publishes it, what kind of
/// number it is, and where to go and check.
///
/// A plain value object in `core/constants/` rather than an entity, because it
/// carries no backend data — it is the app's own description of a market, fixed
/// at compile time. The rates themselves arrive as `Currency` and are matched
/// to this by [name].
class MarketSource {
  const MarketSource({
    required this.name,
    required this.kind,
    required this.url,
  });

  /// Exactly as the backend reports it in `platform`, so a row here and a rate
  /// on the Home can be matched without a second mapping. **Not translated**:
  /// these are institutions and brands.
  final String name;

  /// What kind of reference this market publishes.
  final MarketKind kind;

  /// Where the number comes from, for the user who wants to check it. `https`
  /// in every case — the About screen only opens that scheme.
  final String url;
}
