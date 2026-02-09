import 'package:bcv_tracker_app/core/constants/constants.dart';
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

  static String completeCurrencyExchange(String currencyCode) {
    return '$currencyCode/VES';
  }

  static String castCurrency({required double value}) {
    return 'Bs.S ${value.toStringAsFixed(2)}';
  }

  static String castCurrencySymbolText({required String currencyCode}) {
    switch (currencyCode) {
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
    switch (currencyCode) {
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

  static double getAverageValue({
    required List<Currency> currencies,
    String currencyCode = 'USD',
  }) {
    if (currencies.isEmpty) {
      return 0.0;
    }
    double sum = 0.0;
    double count = 0.0;
    for (var currency in currencies) {
      if (currency.keyName == currencyCode) {
        sum += currency.value;
        count++;
      }
    }
    return sum / count;
  }

  static String parseDate({
    required String date,
    String format = Constants.bcvFormatDate,
    bool addDayName = true,
  }) {
    final dateTime = DateTime.parse(date);
    final formattedDate = DateFormat(format).format(dateTime);

    if (addDayName) {
      String dayName = getDayName(dayNumber: dateTime.weekday);
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
