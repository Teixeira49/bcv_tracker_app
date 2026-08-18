import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/app_state_view.dart';

import 'golden_utils.dart';

/// Golden references for the shared error/empty state view (issue #35), in the
/// light and dark app themes. Text renders as blocks in the CI goldens (see
/// `flutter_test_config.dart`); the icon, the logo and the palette are what
/// these references guard against regressions.
void main() {
  lightDarkGoldenTest(
    'AppStateView',
    'app_state_view',
    () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'error with retry',
          child: goldenScenarioSurface(
            AppStateView.error(
              message: 'No hay conexión a internet',
              onRetry: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'empty',
          child: goldenScenarioSurface(AppStateView.empty(onRetry: () {})),
        ),
        // #41. Must not look like `empty`: there the app has nothing, here the
        // user's own filter excluded everything — hence the struck-through
        // magnifier instead of the logo, and no retry button.
        GoldenTestScenario(
          name: 'no results',
          child: goldenScenarioSurface(
            const AppStateView.noResults(
              message: 'Ninguna moneda coincide con «bitcoin».',
            ),
          ),
        ),
      ],
    ),
  );
}
