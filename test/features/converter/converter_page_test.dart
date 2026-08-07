import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/features/converter/presentation/controller/converter_controller.dart';
import 'package:bcv_tracker_app/features/converter/presentation/page/converter_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeDollarRepository implements IDollarRepository {
  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async =>
      BcvCurrencies(date: null, currencies: const []);

  @override
  Future<List<Currency>> getCurrentDollar() async => const [];
}

Future<void> _pumpConverter(WidgetTester tester) async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository());
  final repo = Get.put(CurrencyRepository());
  Get.put(ConverterController());

  // The default pivot/skeleton currencies fall back to initials for their icon,
  // so no network image loads; clearing the placeholder lists keeps it that way.
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: const Scaffold(body: ConverterPage()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  tearDown(() => Get.reset());

  testWidgets('renders the converter body with a title and an input', (
    tester,
  ) async {
    await _pumpConverter(tester);

    // The frame and the body are up: the title, and the amount input of the
    // "from" card.
    expect(find.text(AppMessages.converterView), findsWidgets);
    expect(find.byType(TextFormField), findsWidgets);
  });

  testWidgets('typing an amount does not throw', (tester) async {
    await _pumpConverter(tester);

    await tester.enterText(find.byType(TextFormField).first, '100');
    await tester.pump();

    // The controller ran calculator() without error; the field holds the input.
    expect(find.text('100'), findsWidgets);
  });
}
