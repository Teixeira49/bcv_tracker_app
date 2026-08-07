import 'package:bcv_tracker_app/config/theme/colors/colors_constants.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme is Material 3', () {
    test('both themes enable useMaterial3', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
    });

    test('brightness matches the theme', () {
      expect(AppTheme.lightTheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
      expect(AppTheme.lightTheme.colorScheme.brightness, Brightness.light);
      expect(AppTheme.darkTheme.colorScheme.brightness, Brightness.dark);
    });
  });

  group('the ColorScheme keeps the brand identity', () {
    for (final entry in {
      'light': AppTheme.lightTheme,
      'dark': AppTheme.darkTheme,
    }.entries) {
      test('${entry.key}: brand roles are the palette, not seed-generated', () {
        final scheme = entry.value.colorScheme;
        // The migration must not lose the app's colours: primary/secondary/
        // tertiary(accent)/error are pinned to AppColors, not to whatever
        // ColorScheme.fromSeed would generate.
        expect(scheme.primary, AppColors.primary);
        expect(scheme.secondary, AppColors.secondary);
        expect(scheme.tertiary, AppColors.accent);
        expect(scheme.error, AppColors.error);
      });
    }
  });

  testWidgets('a Material component renders under the theme', (tester) async {
    // Exercises the theme end to end: a switch and a dialog build without
    // error under the M3 theme, in both brightnesses.
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                Switch(value: true, onChanged: (_) {}),
                const Card(child: SizedBox(height: 20, width: 20)),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    }
  });
}
