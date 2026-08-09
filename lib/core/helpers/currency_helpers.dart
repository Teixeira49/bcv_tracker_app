import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/helpers/backend_date.dart';
import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:intl/intl.dart';

import '../../config/theme/icons/icons_constants.dart';
import '../../features/home/domain/entities/currency_country.dart';
import '../../shared/domain/entities/currency.dart';

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
  /// The backend names rates in Spanish ("Dolar", "Promedio"), so rendering
  /// them raw left the average tab untranslated in the other nine languages.
  static String castCurrencyDisplayName(Currency currency) {
    switch (currency.keyName) {
      case 'USD':
        return AppMessages.eeuuDollar;
      case 'EUR':
        return AppMessages.europeanEuro;
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

  static String castCurrency({required double value}) {
    return 'Bs.S ${value.toStringAsFixed(2)}';
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
  /// a figure the user would read as "the rate did not move". The four decimals
  /// match what `PerformanceIndicatorWidget` already shows in the cards.
  static String castTendency({double? value}) {
    if (value == null) {
      return emptyValuePlaceholder;
    }
    final String sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(4)}%';
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
