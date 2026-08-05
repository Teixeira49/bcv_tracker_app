import 'package:bcv_tracker_app/config/theme/colors/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every palette exposed by [AppColors], by the name it carries in the class.
const Map<String, MaterialColor> _palettes = <String, MaterialColor>{
  'primary': AppColors.primary,
  'secondary': AppColors.secondary,
  'midnight': AppColors.midnight,
  'accent': AppColors.accent,
  'grey': AppColors.grey,
  'success': AppColors.success,
  'error': AppColors.error,
  'warning': AppColors.warning,
  'info': AppColors.info,
};

const List<int> _shades = <int>[
  50,
  100,
  200,
  300,
  400,
  500,
  600,
  700,
  800,
  900,
];

void main() {
  // A colour literal is written `0xAARRGGBB`. Drop a digit and the result is
  // still a valid int, so nothing fails to compile — Dart just reads the
  // shifted value and the missing digit lands in the alpha channel. That is how
  // `_warningValue` shipped as `0xFFFF980` (alpha 0x0F, ~6 % opacity) and went
  // unnoticed until someone looked at the dark theme. These tests are the guard
  // the compiler cannot be.
  group('AppColors opacity', () {
    test('every palette base colour is fully opaque', () {
      _palettes.forEach((name, palette) {
        expect(
          palette.a,
          1.0,
          reason:
              'AppColors.$name is not fully opaque: its literal is likely '
              'missing a digit (it must be 8, as 0xAARRGGBB).',
        );
      });
    });

    test('every shade of every palette is fully opaque', () {
      _palettes.forEach((name, palette) {
        for (final shade in _shades) {
          expect(
            palette[shade]!.a,
            1.0,
            reason:
                'AppColors.$name.shade$shade is not fully opaque: its literal '
                'is likely missing a digit (it must be 8, as 0xAARRGGBB).',
          );
        }
      });
    });

    test('warning holds the orange of its own ramp', () {
      // The ramp itself pins the value down: 400 is 0xFFFFA726 and 600 is
      // 0xFFF57C00, so 500 could only ever have been 0xFFFF9800.
      // Compared as packed ARGB: `AppColors.warning` is a MaterialColor, which
      // never equals a plain Color even when it paints the same pixels.
      expect(AppColors.warning.toARGB32(), 0xFFFF9800);
      expect(AppColors.warning.shade500.toARGB32(), 0xFFFF9800);
    });
  });
}
