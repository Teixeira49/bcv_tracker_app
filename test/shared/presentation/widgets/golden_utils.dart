import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/config/theme/theme.dart';
import 'package:flutter/material.dart';

/// Registers a golden test for [buildGroup] in **both** the light and the dark
/// app theme, writing a separate reference file per mode
/// (`<fileBase>_light` / `<fileBase>_dark`).
///
/// The theme is supplied through the `pumpWidget` `MaterialApp` so that
/// Alchemist resolves it as the inherited theme — that is what lets it obscure
/// the text for cross-platform CI goldens while `ColorValues` still reads the
/// correct `Brightness` from it. See `test/flutter_test_config.dart` for why
/// only the (platform-independent) CI goldens are versioned.
void lightDarkGoldenTest(
  String description,
  String fileBase,
  Widget Function() buildGroup,
) {
  const modes = <(String, bool)>[('light', false), ('dark', true)];
  for (final (mode, isDark) in modes) {
    final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    goldenTest(
      '$description — $mode',
      fileName: '${fileBase}_$mode',
      pumpWidget: (tester, widget) => tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: widget,
        ),
      ),
      builder: buildGroup,
    );
  }
}

/// Paints [child] on the active theme's surface with a little breathing room,
/// so the light and dark references differ by their real background and each
/// scenario has bounded width.
Widget goldenScenarioSurface(Widget child, {double width = 360}) => Builder(
  builder: (context) => Container(
    width: width,
    color: Theme.of(context).scaffoldBackgroundColor,
    padding: const EdgeInsets.all(16),
    child: Material(type: MaterialType.transparency, child: child),
  ),
);
