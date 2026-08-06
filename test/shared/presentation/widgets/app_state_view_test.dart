import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/app_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Wraps [child] in the minimum GetX + Material frame the view needs: the
/// translations (so `AppMessages` resolves instead of showing raw keys) and a
/// `Theme` (so `ColorValues` can read the active brightness).
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  Get.testMode = true;
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(brightness: brightness),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pump();
}

void main() {
  tearDown(() => Get.reset());

  testWidgets('error state shows the loadingError headline and the message', (
    tester,
  ) async {
    await _pump(
      tester,
      const AppStateView.error(message: 'Sin conexión a internet'),
    );

    expect(find.text(AppMessages.loadingError), findsOneWidget);
    expect(find.text('Sin conexión a internet'), findsOneWidget);
    // The error illustration, not the empty one.
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('error state renders a retry button that calls onRetry', (
    tester,
  ) async {
    var retries = 0;
    await _pump(
      tester,
      AppStateView.error(message: 'Falló', onRetry: () => retries++),
    );

    // `FilledButton.icon` builds a private subclass, so the label is the stable
    // handle on the retry action.
    final retry = find.text(AppMessages.retryAction);
    expect(retry, findsOneWidget);

    await tester.tap(retry);
    await tester.pump();
    expect(retries, 1);
  });

  testWidgets('error state disables the retry button while busy', (
    tester,
  ) async {
    var retries = 0;
    await _pump(
      tester,
      AppStateView.error(
        message: 'Falló',
        onRetry: () => retries++,
        isBusy: true,
      ),
    );

    await tester.tap(find.text(AppMessages.retryAction));
    await tester.pump();
    // A disabled button swallows the tap, so a second refresh never fires.
    expect(retries, 0);
  });

  testWidgets('error state without onRetry shows no retry button', (
    tester,
  ) async {
    await _pump(tester, const AppStateView.error(message: 'Falló'));

    expect(find.text(AppMessages.retryAction), findsNothing);
  });

  testWidgets('empty state shows its own title and message', (tester) async {
    await _pump(tester, const AppStateView.empty());

    expect(find.text(AppMessages.emptyStateTitle), findsOneWidget);
    expect(find.text(AppMessages.emptyStateMessage), findsOneWidget);
    // The empty state must not reuse the error headline.
    expect(find.text(AppMessages.loadingError), findsNothing);
    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });

  testWidgets('empty state accepts a custom message', (tester) async {
    await _pump(
      tester,
      const AppStateView.empty(message: 'Todavía no sigues ningún mercado'),
    );

    expect(find.text('Todavía no sigues ningún mercado'), findsOneWidget);
    expect(find.text(AppMessages.emptyStateMessage), findsNothing);
  });

  testWidgets('renders in dark mode without throwing', (tester) async {
    await _pump(
      tester,
      const AppStateView.error(message: 'Falló'),
      brightness: Brightness.dark,
    );

    expect(find.text(AppMessages.loadingError), findsOneWidget);
  });
}
