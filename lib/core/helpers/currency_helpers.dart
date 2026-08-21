import 'dart:math';

import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/helpers/backend_date.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../config/theme/icons/icons_constants.dart';
import '../../features/home/domain/entities/currency_country.dart';
import '../../shared/domain/entities/currency.dart';

/// Turns rate data into the strings and dressing the UI shows.
///
/// The seam between what the backend sends and what a screen can render: a
/// translated name for a currency code, a flag, a symbol, an amount formatted for
/// display, a date kept in the right timezone. Pure functions, so their tests need
/// neither fakes nor GetX.
///
/// **Formatting happens here and only here.** The controllers keep full precision
/// and this rounds at the point of display — the order that fixed the converter's
/// original rounding bug, and one that must not be inverted. See [castAmount].
class CurrencyHelpers {
  static CurrencyCountry castCurrencyCountry({required String currencyCode}) {
    switch (currencyCode) {
      case 'USD':
        return CurrencyCountry(
          countryName: 'Estados Unidos',
          currencyCode: 'USD',
          currencyCountryName: AppMessages.eeuuDollar,
          currencySymbol: AppIcons.usdCurrencyIcon,
          countryFlag: AppIcons.flagEEUUIcon,
        );
      case 'EUR':
        return CurrencyCountry(
          countryName: 'Europa',
          currencyCode: 'EUR',
          currencyCountryName: AppMessages.europeanEuro,
          currencySymbol: AppIcons.eurCurrencyIcon,
          countryFlag: AppIcons.flagEuropeIcon,
        );
      case 'TRY':
        return CurrencyCountry(
          countryName: 'Turkia',
          currencyCode: 'TRY',
          currencyCountryName: AppMessages.turkishLira,
          currencySymbol: AppIcons.tryCurrencyIcon,
          countryFlag: AppIcons.flagTurkeyIcon,
        );
      case 'CNY':
        return CurrencyCountry(
          countryName: 'China',
          currencyCode: 'CNY',
          currencyCountryName: AppMessages.chineseYuan,
          currencySymbol: AppIcons.cnyCurrencyIcon,
          countryFlag: AppIcons.flagChinaIcon,
        );
      case 'RUB':
        return CurrencyCountry(
          countryName: 'Rusia',
          currencyCode: 'RUB',
          currencyCountryName: AppMessages.russianRuble,
          currencySymbol: AppIcons.rubCurrencyIcon,
          countryFlag: AppIcons.flagRussiaIcon,
        );
      default:
        return CurrencyCountry(
          countryName: 'Desconocido',
          currencyCode: '-',
          currencyCountryName: '-',
          currencySymbol: AppIcons.usdCurrencyIcon,
          countryFlag: AppIcons.flagEEUUIcon,
        );
    }
  }

  /// Code to show for a rate.
  ///
  /// Exchange Monitor identifies its rates with its own codes (`em`, `average`,
  /// `md`) instead of a currency one, but all of them quote the dollar.
  static String castCurrencyDisplayCode(String currencyCode) {
    switch (currencyCode) {
      case Markets.emOwnCode:
      case Markets.emAverageCode:
      case Markets.emMonitorCode:
        return 'USD';
      default:
        return currencyCode;
    }
  }

  /// Translated name of a rate, falling back to the name given by the backend.
  ///
  /// The backend names rates in Spanish ("Dolar", "Promedio", "Rublo"), so
  /// rendering them raw left the average tab untranslated in the other nine
  /// languages.
  ///
  /// The lira, the yuan and the rouble were added with the detail sheet (#38):
  /// the BCV card never called this — it reads the country name from
  /// [castCurrencyCountry], which was already translated — so the gap only
  /// surfaced when the sheet started naming those same rates.
  static String castCurrencyDisplayName(Currency currency) {
    switch (currency.keyName) {
      case 'USD':
        return AppMessages.eeuuDollar;
      case 'EUR':
        return AppMessages.europeanEuro;
      case 'TRY':
        return AppMessages.turkishLira;
      case 'CNY':
        return AppMessages.chineseYuan;
      case 'RUB':
        return AppMessages.russianRuble;
      case 'USDT':
        return 'Tether';
      case 'USDC':
        return 'USD Coin';
      case 'BTC':
        return 'Bitcoin';
      case Markets.emAverageCode:
      case Markets.emMonitorCode:
        return AppMessages.marketAverage;
      case Markets.emOwnCode:
        return Markets.exchangeMonitor;
      default:
        return currency.name;
    }
  }

  static String completeCurrencyExchange(String currencyCode) {
    return '${castCurrencyDisplayCode(currencyCode)}/VES';
  }

  /// The locale every number on screen is formatted for.
  ///
  /// **`Get.locale`, not the device's.** The user can pick a language in
  /// settings that differs from the phone's, and the separator has to follow
  /// what they are reading, not what Android thinks they read. Falls back to
  /// `intl`'s current locale only before `GetMaterialApp` has assigned one,
  /// which in practice is tests.
  static String get displayLocale =>
      Get.locale?.toString() ?? Intl.getCurrentLocale();

  /// **The** number formatter of the app. Every figure the user reads goes
  /// through here.
  ///
  /// `toStringAsFixed` always writes a `.`, whatever the language — and six of
  /// the ten this app ships use a comma ([#63](https://github.com/Teixeira49/bcv_tracker_app/issues/63)).
  /// A rate punctuated with the wrong mark is not a style slip in a financial
  /// app: it is a figure the reader has to stop and re-read to be sure of.
  ///
  /// [minDecimals] and [maxDecimals] give the floor-and-ceiling behaviour
  /// directly — `NumberFormat` pads up to the minimum and trims trailing zeros
  /// down to it, which is what [castAmount] used to do by hand with string
  /// surgery.
  ///
  /// **[grouping] is off wherever the figure travels back into a text field.**
  /// The thousands separator makes a rate far easier to read, but the
  /// converter's amount is carried across by `CurrencyDetailController.
  /// toggleDirection` and re-parsed: `1.234,57` reaches
  /// `CurrencyConversion.parseAmount`, which normalises the comma and hands
  /// `1.234.57` to `double.tryParse` — `0.0`, and the user's figure is gone.
  /// `AmountInputFormatter` would reject the next keystroke on top. Display-only
  /// figures group; round-tripping ones do not.
  static String formatNumber(
    double value, {
    required int minDecimals,
    required int maxDecimals,
    bool grouping = true,
  }) {
    final NumberFormat format = _formatFor(displayLocale)
      ..minimumFractionDigits = minDecimals
      ..maximumFractionDigits = maxDecimals;
    if (!grouping) {
      format.turnOffGrouping();
    }
    // Non-finite never reaches the screen, for the same reason
    // `CurrencyConversion.sanitize` exists: `NumberFormat` renders `Infinity`
    // and `NaN` verbatim.
    return format.format(value.isFinite ? value : 0.0);
  }

  /// A formatter for [locale], or for the fallback when `intl` does not know it.
  ///
  /// **`NumberFormat` does not fail quietly, and it does not fall back either.**
  /// A code it has never heard of raises `ArgumentError` — measured on intl
  /// 0.18.1 — from inside the `build` of every card that shows a figure. Today
  /// the only source is `Get.locale`, always one of the ten this build ships,
  /// but [displayLocale] is public and the next caller may not be.
  ///
  /// What **is** silent is the descent to the language subtag, and it happens
  /// to six of the ten: `fr_FR→fr`, `de_DE→de`, `it_IT→it`, `ja_JP→ja`,
  /// `ko_KR→ko`, `ru_RU→ru`. Harmless here, because those regional variants
  /// punctuate alike — but not a rule to lean on: `pt_PT` and `pt_BR` genuinely
  /// differ, and only the first is in the list.
  static NumberFormat _formatFor(String locale) {
    try {
      return NumberFormat.decimalPattern(locale);
    } on ArgumentError {
      return NumberFormat.decimalPattern('en_US');
    }
  }

  /// The amount as it appears **inside an editable field**.
  ///
  /// A third shape, and the reason is the caret. [castAmount] rounds to the
  /// user's ceiling, which is right for a result and wrong for a field being
  /// typed into: rounding `12,345` to `12,35` while the user is still writing
  /// rewrites the text under their finger. So this one **does not round** —
  /// `minDecimals: 0`, a high ceiling — and only replaces the separator.
  ///
  /// Introduced by #63's review. The input side used to print
  /// `convertedValue.toString()`, so after a swap the largest figure on the
  /// converter read `0.006565988181221273` — eighteen decimals **and a dot**,
  /// while the result right above it had a comma. The long tail was already
  /// there; the mismatched separator was this issue's doing.
  static String castEditableAmount(double value) => formatNumber(
    value,
    minDecimals: 0,
    maxDecimals: Constants.converterMaxDecimals,
    grouping: false,
  );

  /// A rate in bolívares, as the cards show it.
  ///
  /// Grouped: this figure is read, never typed back. `Bs.S` stays untranslated
  /// and unformatted — it is a currency symbol, which `i18n-convention.md`
  /// exempts explicitly.
  static String castCurrency({required double value}) {
    return 'Bs.S ${formatNumber(value, minDecimals: 2, maxDecimals: 2)}';
  }

  /// Significant digits kept when [Constants.converterAmountDecimals] alone
  /// would render a real amount as zero.
  ///
  /// Four rather than two because this figure is not only read: the detail
  /// sheet's converter carries the displayed value across when the direction is
  /// reversed, so every digit dropped here is precision lost from the next
  /// conversion. Two cost about 1% on a round trip; four keep it under 0.01%.
  static const int _significantDigitsWhenTiny = 4;

  /// Ceiling on the expansion, so a denormal cannot produce an absurd string.
  static const int _maxDecimals = 12;

  /// A converted amount, as the converter shows it.
  ///
  /// The pivot conversion divides doubles, so a clean input comes out as
  /// `864.0962999999999`; printed raw it wrapped onto a second line and read as
  /// noise rather than an answer. Rounding happens **here, at the point of
  /// display** — `ConverterController` keeps the full value, which is the rule
  /// the converter has followed since its rounding bug.
  ///
  /// The precision **adapts**, between a floor and a ceiling.
  ///
  /// [Constants.converterAmountDecimals] is the floor and is never crossed:
  /// `100` reads `100.00`, because a price with no decimals still has two.
  /// [maxDecimals] is the ceiling the user sets (#37's increment): a figure
  /// with more decimals than the floor shows them, up to the ceiling, and is
  /// rounded there. Digits that only exist to pad — the zeros of
  /// `152.3068000000` — are dropped back to the floor, so raising the setting
  /// never adds noise to a figure that does not have it.
  ///
  /// **The floor wins over the ceiling in one case**, and it is the reason this
  /// method exists at all: a few bolívares are thousandths of a dollar, and
  /// `0.00` for a real amount is not a rounding, it is the figure erased. When
  /// the ceiling would erase a non-zero value, the result expands past it to
  /// [_significantDigitsWhenTiny] significant digits. That expansion is
  /// measured against the **floor**, not against the ceiling: measured against
  /// the ceiling, raising the setting from 2 to 5 would take `0.001314` down to
  /// `0.00131`, and a setting called "more decimals" would have shown fewer.
  ///
  /// A non-finite value degrades to zero for the same reason
  /// `CurrencyConversion.sanitize` exists: `Infinity` and `NaN` format verbatim
  /// and must never reach the screen.
  static String castAmount({
    required double value,
    int maxDecimals = Constants.converterMinDecimals,
  }) {
    const int floor = Constants.converterAmountDecimals;
    final double safe = value.isFinite ? value : 0.0;
    final int ceiling = maxDecimals.clamp(
      floor,
      Constants.converterMaxDecimals,
    );

    // "The floor would have rounded this to zero", stated as arithmetic. It
    // used to be `double.parse(safe.toStringAsFixed(floor)) == 0`, which said
    // the same thing by rendering — replaced because #63 removes the
    // `toStringAsFixed` calls that could be mistaken for output, and because a
    // half-ulp comparison is what the rounding actually does.
    final bool erasedAtFloor = safe != 0 && safe.abs() < 0.5 * pow(10, -floor);

    int decimals = ceiling;
    if (erasedAtFloor) {
      final int firstSignificant = -(log(safe.abs()) / ln10).floor();
      final int expanded = (firstSignificant + _significantDigitsWhenTiny - 1)
          .clamp(floor, _maxDecimals);
      // `max`, not the expansion alone: a user who asked for ten decimals on a
      // tiny figure gets ten, not the four significant digits the rescue needs.
      decimals = expanded > ceiling ? expanded : ceiling;
    }

    // Ungrouped, and that is load-bearing: this is the figure the detail
    // sheet carries back into the amount field. See [formatNumber].
    //
    // The trailing zeros the old `_trimToFloor` stripped by hand are now
    // `NumberFormat`'s job — it pads to `minimumFractionDigits` and trims to it,
    // which is the same rule expressed once instead of twice.
    return formatNumber(
      safe,
      minDecimals: floor,
      maxDecimals: decimals,
      grouping: false,
    );
  }

  static String castCurrencySymbolText({required String currencyCode}) {
    switch (castCurrencyDisplayCode(currencyCode)) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'TRY':
        return '₺';
      case 'CNY':
        return '¥';
      case 'RUB':
        return '₽';
      case 'BTC':
        return '₿';
      case 'USDT':
        return '₮';
      case 'USDC':
        return '¢';
      case 'VES':
        return 'Bs.S';
      default:
        return '';
    }
  }

  static String castCurrencySymbolIcon({required String currencyCode}) {
    switch (castCurrencyDisplayCode(currencyCode)) {
      case 'VES':
        return AppIcons.flagVenezuelaIcon;
      case 'USD':
        return AppIcons.flagEEUUIcon;
      case 'EUR':
        return AppIcons.flagEuropeIcon;
      case 'TRY':
        return AppIcons.flagTurkeyIcon;
      case 'CNY':
        return AppIcons.flagChinaIcon;
      case 'RUB':
        return AppIcons.flagRussiaIcon;
      case 'BTC':
        return AppIcons.cryptoBTCIcon;
      case 'USDT':
        return AppIcons.cryptoUSDTIcon;
      case 'USDC':
        return AppIcons.cryptoUSDCIcon;
      default:
        return '';
    }
  }

  /// Average of the parallel market, in VES per dollar.
  ///
  /// Every dollar-equivalent quote counts (see
  /// [Markets.dollarEquivalentCodes]): the crypto markets quote USDT/USDC and
  /// Exchange Monitor uses its own codes, so matching `USD` alone left the
  /// average resting on the few markets that use that exact code. The BCV is
  /// excluded on purpose: it is the official rate, not a parallel one, and
  /// averaging it in dragged the figure away from the market.
  static double getAverageValue({
    required List<Currency> currencies,
    Set<String>? currencyCodes,
    String excludedPlatform = Markets.bcv,
  }) {
    final codes = currencyCodes ?? Markets.dollarEquivalentCodes;
    final values = currencies
        .where(
          (currency) =>
              currency.platform != excludedPlatform &&
              codes.contains(currency.keyName),
        )
        .map((currency) => currency.value);

    if (values.isEmpty) {
      return 0.0;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Shown instead of a value the backend did not send.
  ///
  /// Several fields of `CurrencySchema` are optional (`createDate`,
  /// `updateDate`, `change`), and their absence is not an error: it means "the
  /// source did not report it". Rendering a `0` there would read as data.
  static const String emptyValuePlaceholder = '--';

  /// Shown instead of a date when there is none to format.
  static const String emptyDatePlaceholder = emptyValuePlaceholder;

  /// Whether the rate comes from the official market.
  ///
  /// The BCV is the only official source the app consumes; everything else the
  /// backend serves (crypto P2P, Yadio, Exchange Monitor) quotes the parallel
  /// market. Matched by [Markets.bcv] — the exact `platform` string the backend
  /// reports — so a market renamed upstream stops being labelled official
  /// instead of silently mislabelling a parallel rate.
  static bool isOfficialRate(Currency currency) =>
      currency.platform == Markets.bcv;

  /// Signed percentage change of a rate, for the detail view.
  ///
  /// `change` is optional in the contract, so a rate can arrive without it —
  /// which is why `null` degrades to [emptyValuePlaceholder] instead of `0%`,
  /// a figure the user would read as "the rate did not move".
  ///
  /// **Two to four decimals, decided in #63.** It used to be a flat four —
  /// `+1.2400%` on every card, which is more precision than a daily change
  /// carries and four characters the eye skips past to reach what matters. A
  /// floor of two reads as a percentage; a ceiling of four keeps a move of
  /// `0,0012 %` from collapsing into `0,00 %`, which would claim the rate held
  /// when it did not. The zeros in between are trimmed, so the common case is
  /// short and the rare case is still true.
  ///
  /// Ungrouped: a change never reaches four digits before the decimal mark.
  static String castTendency({double? value}) {
    if (value == null) {
      return emptyValuePlaceholder;
    }
    final String sign = value > 0 ? '+' : '';
    final String number = formatNumber(
      value,
      minDecimals: 2,
      maxDecimals: 4,
      grouping: false,
    );
    return '$sign$number%';
  }

  /// Formats an optional rate timestamp, degrading to [emptyValuePlaceholder].
  ///
  /// The card can afford to hide a missing date; the detail view states it
  /// explicitly, so the absence has to be renderable.
  static String castOptionalDate({
    DateTime? date,
    String format = Constants.defaultFormatDate,
  }) {
    if (date == null) {
      return emptyValuePlaceholder;
    }
    return formatDate(date: date, format: format);
  }

  /// Formats a date **published** by a source, keeping its wall clock.
  ///
  /// Meant for the BCV effective date, which names a day for Venezuela rather
  /// than an instant: converting it to the device zone would move it to the
  /// previous day for anyone west of Caracas. Returns [emptyDatePlaceholder]
  /// when the string is empty or unparseable — the date is optional in the
  /// contract and is also empty while the first refresh is in flight.
  static String parseDate({
    required String date,
    String format = Constants.bcvFormatDate,
    bool addDayName = true,
  }) {
    final dateTime = BackendDate.asPublished(date);
    if (dateTime == null) {
      return emptyDatePlaceholder;
    }
    return formatDate(date: dateTime, format: format, addDayName: addDayName);
  }

  /// Formats an instant in the device's local zone.
  ///
  /// Rate timestamps reach here already local ([BackendDate.toLocal] converts
  /// them while parsing); the `toLocal()` is a guard for any other source.
  static String formatDate({
    required DateTime date,
    String format = Constants.defaultFormatDate,
    bool addDayName = false,
  }) {
    final local = date.isUtc ? date.toLocal() : date;
    final formattedDate = DateFormat(format).format(local);

    if (addDayName) {
      String dayName = getDayName(dayNumber: local.weekday);
      return '$dayName, $formattedDate';
    }
    return formattedDate;
  }

  static String getDayName({required int dayNumber}) {
    switch (dayNumber) {
      case 1:
        return AppMessages.mondayDay;
      case 2:
        return AppMessages.tuesdayDay;
      case 3:
        return AppMessages.wednesdayDay;
      case 4:
        return AppMessages.thursdayDay;
      case 5:
        return AppMessages.fridayDay;
      case 6:
        return AppMessages.saturdayDay;
      case 7:
        return AppMessages.sundayDay;
      default:
        return '';
    }
  }
}
