/// The country dressing that a currency code alone cannot supply.
///
/// A rate arrives from the backend as a code and a number; a card has to show a
/// flag, a symbol and a translated name. This carries that, and it is built by
/// `CurrencyHelpers.castCurrencyCountry` from the code — a lookup, not data the
/// backend sends.
///
/// It lives under `features/home/` because the BCV card is what needs it: the
/// average tab identifies rates by market instead, so it reads
/// `CurrencyHelpers.castCurrencyDisplayName` and never touches this.
class CurrencyCountry {
  /// Country the currency belongs to, for context beside the code.
  ///
  /// **Hardcoded in Spanish** in `castCurrencyCountry` and not run through
  /// `AppMessages`, which is a gap rather than a decision: it is the one string
  /// here that does not follow `.agents/rules/i18n-convention.md`.
  final String countryName;

  /// ISO code the lookup was made with, or `-` when the code is unknown.
  final String currencyCode;

  /// Translated name of the currency, from `AppMessages`. This is what the card
  /// titles itself with.
  final String currencyCountryName;

  /// Asset path of the currency's symbol glyph, from `AppIcons`.
  final String currencySymbol;

  /// Asset path of the country's flag, from `AppIcons`.
  final String countryFlag;

  /// Groups the dressing for one currency code.
  CurrencyCountry({
    required this.countryName,
    required this.currencyCode,
    required this.currencyCountryName,
    required this.currencySymbol,
    required this.countryFlag,
  });
}
