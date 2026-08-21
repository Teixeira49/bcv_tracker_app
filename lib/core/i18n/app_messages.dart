import 'package:get/get.dart';

/// Every string the user can read, as typed getters.
///
/// The **only** file in the app that calls `.tr`. Widgets go through these getters
/// instead, which buys autocompletion, a central inventory, and a compile error
/// when a key is removed — where a raw `'homeView'.tr` in a widget would just
/// render the key on screen.
///
/// A new key goes into **all ten** language files in the same commit. Miss one and
/// GetX shows the raw key for that language; nothing throws, and it surfaces only
/// by switching language by hand. `.agents/rules/i18n-convention.md` has the
/// parity script.
///
/// The getters below are deliberately left without individual docstrings: the key
/// name and the getter name are the same word, and a comment restating it is what
/// `.agents/rules/documentation-convention.md` calls out as noise. The few that
/// *are* documented are the ones with a reason — see [officialRate] and
/// [noSearchResultsMessage].
class AppMessages {
  static String get homeView => 'homeView'.tr;

  static String get converterView => 'converterView'.tr;

  static String get settingsView => 'settingsView'.tr;

  static String get averageSection => 'averageSection'.tr;

  static String get officialSection => 'officialSection'.tr;

  static String get averageValue => 'averageValue'.tr;

  static String get currencyValue => 'currencyValue'.tr;

  static String get lastUpdate => 'lastUpdate'.tr;

  static String get moneyValue => 'moneyValue'.tr;

  static String get currencyDate => 'currencyDate'.tr;

  static String get selectCurrency => 'selectCurrency'.tr;

  static String get originalCurrency => 'originalCurrency'.tr;

  static String get mainMarkets => 'mainMarkets'.tr;

  static String get otherCurrencies => 'otherCurrencies'.tr;

  static String get defaultMarket => 'defaultMarket'.tr;

  static String get officialDollar => 'officialDollar'.tr;

  static String get parallelDollar => 'parallelDollar'.tr;

  static String get eeuuDollar => 'eeuuDollar'.tr;

  static String get europeanEuro => 'europeanEuro'.tr;

  static String get turkishLira => 'turkishLira'.tr;

  static String get chineseYuan => 'chineseYuan'.tr;

  static String get russianRuble => 'russianRuble'.tr;

  static String get theme => 'theme'.tr;

  static String get language => 'language'.tr;

  static String get lightTheme => 'lightTheme'.tr;

  static String get darkTheme => 'darkTheme'.tr;

  static String get systemTheme => 'systemTheme'.tr;

  static String get defaultLanguage => 'defaultLanguage'.tr;

  static String get spanishLanguage => 'spanishLanguage'.tr;

  static String get englishLanguage => 'englishLanguage'.tr;

  static String get portugueseLanguage => 'portugueseLanguage'.tr;

  static String get germanLanguage => 'germanLanguage'.tr;

  static String get frenchLanguage => 'frenchLanguage'.tr;

  static String get italianLanguage => 'italianLanguage'.tr;

  static String get japaneseLanguage => 'japaneseLanguage'.tr;

  static String get koreanLanguage => 'koreanLanguage'.tr;

  static String get chineseLanguage => 'chineseLanguage'.tr;

  static String get russianLanguage => 'russianLanguage'.tr;

  static String get mondayDay => 'mondayDay'.tr;

  static String get tuesdayDay => 'tuesdayDay'.tr;

  static String get wednesdayDay => 'wednesdayDay'.tr;

  static String get thursdayDay => 'thursdayDay'.tr;

  static String get fridayDay => 'fridayDay'.tr;

  static String get saturdayDay => 'saturdayDay'.tr;

  static String get sundayDay => 'sundayDay'.tr;

  static String get marketAverage => 'marketAverage'.tr;

  static String get loadingError => 'loadingError'.tr;

  static String get retryAction => 'retryAction'.tr;

  static String get conversionUnavailable => 'conversionUnavailable'.tr;

  static String get configErrorTitle => 'configErrorTitle'.tr;

  static String get configErrorBody => 'configErrorBody'.tr;

  static String get errorNoConnection => 'errorNoConnection'.tr;

  static String get errorTimeout => 'errorTimeout'.tr;

  static String get errorServiceUnavailable => 'errorServiceUnavailable'.tr;

  static String get errorInvalidRequest => 'errorInvalidRequest'.tr;

  static String get errorServerInternal => 'errorServerInternal'.tr;

  static String get errorUnexpectedResponse => 'errorUnexpectedResponse'.tr;

  static String get errorGeneric => 'errorGeneric'.tr;

  static String get emptyStateTitle => 'emptyStateTitle'.tr;

  static String get emptyStateMessage => 'emptyStateMessage'.tr;

  // --- Currency detail sheet (#38) ---

  static String get currencyDetailTitle => 'currencyDetailTitle'.tr;

  static String get currencyDetailsSection => 'currencyDetailsSection'.tr;

  static String get marketLabel => 'marketLabel'.tr;

  static String get currencyPairLabel => 'currencyPairLabel'.tr;

  static String get rateTypeLabel => 'rateTypeLabel'.tr;

  static String get currencyCodeLabel => 'currencyCodeLabel'.tr;

  static String get registeredSince => 'registeredSince'.tr;

  static String get variationLabel => 'variationLabel'.tr;

  /// Kind of market a rate comes from. Deliberately not `officialDollar` /
  /// `parallelDollar`: the BCV also publishes the euro, the yuan and the rouble,
  /// and calling those "official dollar" is wrong in every language.
  static String get officialRate => 'officialRate'.tr;

  static String get parallelRate => 'parallelRate'.tr;

  static String get closeAction => 'closeAction'.tr;

  // --- Converter embedded in the currency detail (#39) ---

  static String get quickConverterSection => 'quickConverterSection'.tr;

  /// Hands the detailed rate over to the full converter (#103), carrying the
  /// amount and the direction with it.
  static String get openInConverterAction => 'openInConverterAction'.tr;

  static String get amountLabel => 'amountLabel'.tr;

  static String get invertConversionAction => 'invertConversionAction'.tr;
  // --- Currency selector search (#41) ---

  static String get searchCurrencyHint => 'searchCurrencyHint'.tr;

  static String get noSearchResultsTitle => 'noSearchResultsTitle'.tr;

  /// What the user typed, quoted back at them.
  ///
  /// A method rather than a getter because the query is interpolated by GetX
  /// (`@query`), not concatenated here: the word order around the quotes
  /// differs between the ten languages, and gluing strings would fix it to the
  /// Spanish one (see `i18n-convention.md`, rule 7).
  static String noSearchResultsMessage(String query) =>
      'noSearchResultsMessage'.trParams(<String, String>{'query': query});

  static String get clearSearchAction => 'clearSearchAction'.tr;

  // --- Settings screen (#37) ---

  /// Heading of the group that changes how the app behaves — the market it
  /// opens on, the language it speaks. Kept apart from [appearanceSection]
  /// because "what the app does" and "what the app looks like" are the two
  /// questions a settings menu has to answer, and the settings still to come
  /// (notifications #13, accessibility #33, analytics consent #34) each belong
  /// clearly to one of them.
  static String get preferencesSection => 'preferencesSection'.tr;

  static String get appearanceSection => 'appearanceSection'.tr;

  /// One line under each menu entry saying what the setting decides.
  ///
  /// The dialog this screen replaces had none: three selectors in a row with no
  /// statement of what they affected. They are deliberately short — the entry
  /// also shows its current value, and the two together have to fit a row in
  /// German and Russian.
  static String get defaultMarketDescription => 'defaultMarketDescription'.tr;

  static String get languageDescription => 'languageDescription'.tr;

  static String get themeDescription => 'themeDescription'.tr;

  /// Tooltip of the strip's back button. Not decoration: it is the only label
  /// a screen reader has for an icon-only control.
  static String get backAction => 'backAction'.tr;

  /// The sentence that opens each choice sub-screen, above the options.
  ///
  /// A different job from the `…Description` keys above, which label the
  /// setting on the menu in three or four words. These are addressed to
  /// someone who has already tapped through and is looking at a list: they say
  /// what picking one will do, in a full sentence and in the second person, so
  /// the screen reads as an invitation rather than a bare set of radio rows.
  ///
  /// Written as complete sentences **with a full stop**, unlike every other
  /// key here — they are prose, not labels, and the ten translations have to
  /// agree on that or the screens read differently per language.
  static String get defaultMarketIntro => 'defaultMarketIntro'.tr;

  static String get languageIntro => 'languageIntro'.tr;

  static String get themeIntro => 'themeIntro'.tr;

  // --- Converter decimals (#37, incremental) ---

  static String get converterDecimals => 'converterDecimals'.tr;

  static String get converterDecimalsDescription =>
      'converterDecimalsDescription'.tr;

  static String get converterDecimalsIntro => 'converterDecimalsIntro'.tr;

  /// Labels the worked figure under the counter — the same amount rendered at
  /// the chosen ceiling, so "seven decimals" is something the user can see
  /// rather than imagine.
  static String get decimalsExample => 'decimalsExample'.tr;

  /// Tooltips of the counter's two buttons. Icon-only controls, so these are
  /// the only names a screen reader has for them.
  static String get decreaseAction => 'decreaseAction'.tr;

  static String get increaseAction => 'increaseAction'.tr;

  // --- About screen (#42) ---

  /// Heading of the menu group that holds «About» — and, from #43, the app's
  /// version. Kept apart from `aboutView`: in Italian both words are
  /// «Informazioni», so the entry is «Info sull'app» to keep the group and its
  /// row from reading as the same label twice.
  static String get informationSection => 'informationSection'.tr;

  static String get aboutView => 'aboutView'.tr;

  static String get aboutDescription => 'aboutDescription'.tr;

  static String get aboutIntro => 'aboutIntro'.tr;

  /// One sentence saying what the app does, under its name.
  static String get appTagline => 'appTagline'.tr;

  static String get dataSourcesSection => 'dataSourcesSection'.tr;

  static String get dataSourcesNote => 'dataSourcesNote'.tr;

  static String get projectSection => 'projectSection'.tr;

  static String get creditsSection => 'creditsSection'.tr;

  /// What kind of reference a market publishes — the labels of `MarketKind`.
  ///
  /// The market **names** are not translated (they are institutions and
  /// brands); what a market *is* has to be, because that is the part the user
  /// reads to judge the number.
  static String get marketKindOfficial => 'marketKindOfficial'.tr;

  static String get marketKindPeerToPeer => 'marketKindPeerToPeer'.tr;

  static String get marketKindAggregator => 'marketKindAggregator'.tr;

  static String get licenseLabel => 'licenseLabel'.tr;

  static String get appRepositoryLabel => 'appRepositoryLabel'.tr;

  static String get backendRepositoryLabel => 'backendRepositoryLabel'.tr;

  static String get apiDocsLabel => 'apiDocsLabel'.tr;

  static String get developedByLabel => 'developedByLabel'.tr;

  static String get reportIssueLabel => 'reportIssueLabel'.tr;

  /// Shown when a link cannot be opened — no browser, or the platform refused.
  /// A silent tap is indistinguishable from a broken screen.
  static String get openLinkError => 'openLinkError'.tr;

  // --- App version (#43) ---

  static String get appVersion => 'appVersion'.tr;

  static String get appVersionDescription => 'appVersionDescription'.tr;

  /// Confirms the copy. Without it the tap is silent, and a control that does
  /// nothing visible is one the user taps again wondering if it worked.
  static String get versionCopied => 'versionCopied'.tr;
}
