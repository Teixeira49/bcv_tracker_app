import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/controller/currency_detail_controller.dart';
import 'package:bcv_tracker_app/features/currency_detail/presentation/page/currency_detail_sheet.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Golden references for the currency detail sheet (#38), in light and dark.
///
/// Two scenarios, because the sheet renders differently depending on what the
/// source reported: a parallel rate with a full payload (logo fallback,
/// variation badge, both timestamps) and an official BCV rate with no `change`
/// and no `createDate`, which is what the `with-memory` endpoint actually
/// sends. The second is the one that guards the placeholder rows and the absent
/// badge.
///
/// The fixtures use `imgUrl: null` on purpose: a `NetworkImage` cannot resolve
/// in a test, and the fallback chain (country flag → initials) is what the app
/// shows for most markets anyway.
void main() {
  final DateTime updated = DateTime(2026, 8, 1, 10, 30);
  final DateTime created = DateTime(2026, 3, 12, 8, 0);

  final Currency parallel = Currency(
    name: 'Dólar estadounidense',
    keyName: 'USD',
    platform: Markets.binance,
    value: 152.3068,
    tendency: 1.24,
    createDate: created,
    updateDate: updated,
  );

  final Currency official = Currency(
    name: 'Euro',
    keyName: 'EUR',
    platform: Markets.bcv,
    value: 163.4500,
    updateDate: updated,
  );

  _detailGolden(
    'Currency detail sheet',
    'currency_detail_sheet',
    <(String, Currency)>[
      ('parallel rate', parallel),
      ('official rate', official),
    ],
  );
}

/// Registers the light and dark goldens for [scenarios].
///
/// `GetMaterialApp` with the real translations, not a bare `MaterialApp`: the CI
/// goldens obscure text as solid blocks whose **width follows the string**, so
/// an untranslated `marketLabel` would be measurably wider than `Mercado` and
/// the reference would not describe the app.
void _detailGolden(
  String description,
  String fileBase,
  List<(String, Currency)> scenarios,
) {
  const modes = <(String, bool)>[('light', false), ('dark', true)];
  for (final (mode, isDark) in modes) {
    final ThemeData theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      '$description — $mode',
      fileName: '${fileBase}_$mode',
      pumpWidget: (tester, widget) {
        Get.testMode = true;
        // #37's increment made the decimals ceiling a setting, so both converters
        // now resolve `SettingsController`. Registered first, as
        // `test-coverage.md` asks: fakes in dependency order.
        Get.put(SettingsController());
        Get.put(CurrencyDetailController());
        return tester.pumpWidget(
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: const Locale('es', 'ES'),
            fallbackLocale: const Locale('en', 'US'),
            theme: theme,
            home: widget,
          ),
        );
      },
      builder: () => GoldenTestGroup(
        columns: scenarios.length,
        children: <Widget>[
          for (final (name, currency) in scenarios)
            GoldenTestScenario(
              name: name,
              // The sheet sizes itself as a fraction of the available height,
              // so the scenario has to bound it. Wider and taller than a phone
              // for the same reason as the Home goldens: obscured text is wider
              // than the glyphs it replaces, so the rows wrap and the sheet
              // needs the extra room to be captured whole.
              child: SizedBox(
                width: 420,
                height: 1400,
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  child: CurrencyDetailSheet(currency: currency),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
