import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/core/network/api_exception.dart';
import 'package:bcv_tracker_app/features/home/presentation/controller/home_controller.dart';
import 'package:bcv_tracker_app/features/home/presentation/page/home_page.dart';
import 'package:bcv_tracker_app/shared/data/repositories/currency_repository.dart';
import 'package:bcv_tracker_app/shared/domain/entities/bcv_currencies.dart';
import 'package:bcv_tracker_app/shared/domain/entities/currency.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/dollar_repositories.dart';
import 'package:bcv_tracker_app/shared/presentation/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Either returns empty rates or fails, no network. When [errorMessage] is set,
/// both calls throw, which drives `CurrencyRepository.refreshData` down its
/// error path and lands the home error state.
class _FakeDollarRepository implements IDollarRepository {
  _FakeDollarRepository({this.errorMessage});

  final String? errorMessage;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async {
    if (errorMessage != null) throw ApiException.network(errorMessage!);
    return BcvCurrencies(date: null, currencies: const []);
  }

  @override
  Future<List<Currency>> getCurrentDollar() async {
    if (errorMessage != null) throw ApiException.network(errorMessage!);
    return const [];
  }
}

/// Brings up HomePage over a fake repository. The repository's `onReady` fires
/// the refresh that produces the state under test, so nothing has to be poked
/// after the fact.
Future<void> _pumpHome(WidgetTester tester, {String? error}) async {
  Get.testMode = true;
  Get.put<IDollarRepository>(_FakeDollarRepository(errorMessage: error));
  final repo = Get.put(CurrencyRepository());
  Get.put(SettingsController());
  Get.put(HomeController());

  // Drop the skeleton placeholders before the first frame: they carry a
  // `placehold.co` image URL, and a real network fetch fails (and should) in a
  // test. Empty lists render no image-bearing cards.
  repo.averageCurrencies.clear();
  repo.bcvCurrencies.clear();

  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      // In the app HomePage is a tab inside DashboardPage's Scaffold; that
      // Scaffold gives the inner TabBar its Material ancestor and the
      // TabBarView its bounded height. Reproduce it.
      home: const Scaffold(body: HomePage()),
    ),
  );

  // Let onReady's refresh settle. Explicit pumps, not pumpAndSettle, which
  // would hang on the skeleton's shimmer animation.
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  tearDown(() => Get.reset());

  testWidgets('renders the error card with the mapped message', (tester) async {
    // A network failure: the repository maps it to a user message (#18), not
    // the backend's raw text. The card shows the "could not load" headline and
    // the "no connection" detail. In the error state showCurrencies is false,
    // so no rate cards (and no network images) are built.
    await _pumpHome(tester, error: 'Connection refused');

    expect(find.text(AppMessages.loadingError), findsWidgets);
    expect(find.text(AppMessages.errorNoConnection), findsWidgets);
    // The developer-oriented backend text never reaches the screen.
    expect(find.textContaining('Connection refused'), findsNothing);
  });

  testWidgets('shows no error card on a successful refresh', (tester) async {
    await _pumpHome(tester);

    expect(find.text(AppMessages.loadingError), findsNothing);
  });

  testWidgets('the home frame renders (title + scaffold)', (tester) async {
    await _pumpHome(tester, error: 'x');

    expect(find.text(AppMessages.homeView), findsWidgets);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
