/// One exchange rate, as the app reasons about it.
///
/// The unit of the whole domain: Home lists these, the converter converts
/// between two of them, and the detail sheet renders one. A rate is identified
/// by **[keyName] + [platform]**, never by [keyName] alone — several markets
/// quote the same currency at different prices, and matching on the code would
/// silently pick whichever came first.
///
/// Built from `CurrencyModel.toEntity()`. Nothing in `features/` or in a
/// controller should ever hold the model: see
/// `.agents/rules/entities-vs-models.md` for the four places a new field has to
/// touch, and why the compiler cannot catch that leak on its own.
class Currency {
  /// Human-readable name **as the source spells it**, in Spanish.
  ///
  /// Not for display on its own: the backend names rates in Spanish ("Dolar",
  /// "Promedio"), so rendering this raw left the average tab untranslated in the
  /// other nine languages. Go through `CurrencyHelpers.castCurrencyDisplayName`,
  /// which falls back to this only for codes it does not know.
  final String name;

  /// Code the source identifies the rate by — usually ISO 4217 (`USD`, `EUR`),
  /// sometimes not.
  ///
  /// Exchange Monitor uses its own codes (`em`, `average`, `md`) even though all
  /// of them quote the dollar, and the crypto markets quote `USDT`/`USDC`. Use
  /// `CurrencyHelpers.castCurrencyDisplayCode` to show it, and
  /// `Markets.dollarEquivalentCodes` to decide whether it counts as a dollar.
  final String keyName;

  /// Market the rate comes from, verbatim from the backend
  /// (`Banco Central de Venezuela`, `Binance`, `Yadio.io`…).
  ///
  /// Half of the identity of a rate, and what `CurrencyHelpers.isOfficialRate`
  /// matches on. Compared against the constants in `Markets` rather than typed
  /// literals, so a market renamed upstream fails visibly instead of quietly
  /// changing category.
  final String platform;

  /// Price in bolívares for one unit of this currency.
  ///
  /// **Can legitimately be `0.0`**: [empty] declares it, and the backend answers
  /// with markets that have no data yet. Dividing by it does not throw in Dart —
  /// it yields `Infinity`, or `NaN` when the dividend is zero too — so every
  /// conversion goes through `CurrencyConversion`, which guards it.
  final double value;

  /// Logo of the market, or `null` when the source publishes none.
  ///
  /// Optional in the contract, so it cannot be dereferenced. Also carries the
  /// `placehold.co` placeholder while the first refresh is in flight, which is
  /// why widget tests clear the skeleton lists instead of letting them resolve a
  /// network image.
  final String? imgUrl;

  /// When the source first published this rate, or `null` if it does not say.
  ///
  /// Absent from `bcv/with-memory`, so the detail sheet drops the row rather
  /// than dashing it out.
  final DateTime? createDate;

  /// When the rate was last refreshed, or `null` if the source does not say.
  final DateTime? updateDate;

  /// Signed percentage change the source reports, or `null` when it reports none.
  ///
  /// `null` is **not** zero, and the difference matters on screen: `0%` reads as
  /// "the rate held", while the absence means "nobody said". That is why
  /// `CurrencyHelpers.castTendency` degrades to a placeholder instead.
  final double? tendency;

  /// Creates a rate. `const` so [empty] and the fixtures can be compile-time
  /// constants.
  const Currency({
    required this.name,
    required this.keyName,
    required this.platform,
    required this.value,
    this.imgUrl,
    this.createDate,
    this.updateDate,
    this.tendency,
  });

  /// A copy with the given fields replaced.
  ///
  /// Used by the converter to move an amount onto a rate without rebuilding the
  /// rate itself. Note it cannot **clear** an optional field — passing `null` keeps
  /// the current value — which is the usual `copyWith` trade-off and has not been
  /// a problem because nothing here needs to un-set a date or a tendency.
  Currency copyWith({
    String? name,
    String? keyName,
    String? platform,
    double? value,
    String? imgUrl,
    DateTime? createDate,
    DateTime? updateDate,
    double? tendency,
  }) {
    return Currency(
      name: name ?? this.name,
      keyName: keyName ?? this.keyName,
      platform: platform ?? this.platform,
      value: value ?? this.value,
      imgUrl: imgUrl ?? this.imgUrl,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      tendency: tendency ?? this.tendency,
    );
  }

  /// A rate with nothing in it, for a slot that has no data and is not loading.
  ///
  /// Distinct from [emptySkeletonizer] on purpose: this one is **blank**, and
  /// its `value: 0.00` is what makes `CurrencyConversion`'s guard reachable
  /// through an ordinary path rather than only in tests.
  static const empty = Currency(
    name: '',
    platform: '',
    keyName: '',
    value: 0.00,
    imgUrl: 'https://placehold.co/600x400/png',
    tendency: 0.00,
  );

  /// A rate with plausible-looking content, to be covered by the shimmer while
  /// the first request is in flight.
  ///
  /// Every field is filled — including the dates — because the skeleton draws
  /// the **shape** of a loaded card, and a null date would collapse the row it
  /// is meant to be standing in for. Not `const`: `DateTime.now()` is not.
  static final emptySkeletonizer = Currency(
    name: 'name',
    keyName: 'keyName',
    platform: 'platform',
    value: 1.0,
    imgUrl: 'https://placehold.co/600x400/png',
    createDate: DateTime.now(),
    updateDate: DateTime.now(),
    tendency: 1.0,
  );

  /// The bolívar, and the axis every conversion turns on.
  ///
  /// The app converts through a pivot rather than between arbitrary pairs: every
  /// rate the backend publishes is quoted **in bolívares**, so `USD → EUR` is
  /// `USD → VES → EUR` and there is no cross-rate to invent. Its `value: 1.0` is
  /// what makes the pivot disappear from the arithmetic. `ConverterController`
  /// enforces that one side of the pair is always this.
  static final pivotCurrency = Currency(
    keyName: 'VES',
    name: 'Bolivares',
    value: 1.0,
    platform: 'Banco Central de Venezuela',
  );
}
