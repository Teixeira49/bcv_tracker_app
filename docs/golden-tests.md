# Golden tests

Golden tests compare a widget's rendered pixels against a versioned reference
image (`*.png`) and fail on any visual difference — a colour, a padding, a
widget swapped. They are the app's regression net for the UI: logic tests never
notice that the error card lost its icon or that a card reads white-on-white in
dark mode. Introduced in issue #35.

## What is covered

Light **and** dark theme, for each:

| Widget | Test file |
|---|---|
| `AppStateView` (error + empty) | `test/shared/presentation/widgets/app_state_view_golden_test.dart` |
| `PerformanceIndicatorWidget` (positive / negative / zero) | `test/shared/presentation/widgets/performance_indicator_widget_golden_test.dart` |
| Home cards — average tab (`_CurrencyDollarAverageCard`, `_DollarCurrencyCard`) | `test/features/home/home_page_golden_test.dart` |
| Home cards — BCV tab (`_BCVAdvisorCard`, `_BCVDollarCard`) | `test/features/home/home_page_golden_test.dart` |
| Converter body (`_ConverterBody`, the VES↔USD inputs) | `test/features/converter/converter_page_golden_test.dart` |

The Home cards and the converter body are private (`part of` their page), so
they are rendered through their page with fixed **offline** fixtures — never
live data — and only the tab/body under test.

## Why the text is rendered as blocks

CI runs on Linux (`ubuntu-latest`); development happens on macOS. The two render
fonts differently, so a reference generated on a Mac would fail byte-comparison
on the Linux runner. We use [Alchemist](https://pub.dev/packages/alchemist),
configured in [`test/flutter_test_config.dart`](../test/flutter_test_config.dart)
to emit **only CI goldens**: text is obscured as solid blocks, which renders
identically on every OS. Icons, SVG flags, the palette and the layout still
render for real, so those regressions are caught; the exact glyphs of the text
are not (that is the trade-off for a reference that passes both locally and on
CI).

A side effect: obscured text is **wider** than real glyphs, so the page goldens
use a canvas wider than a real phone to avoid overflowing the dense rate rows.
Proportions differ from the device; the visual regression signal does not.

### The 1% tolerance

Obscuring the text removes the biggest cross-platform difference, but icons and
SVGs (the variation arrows, the flags, the currency symbols) still rasterize for
real, and their anti-aliasing differs slightly between the macOS Skia used
locally and the Linux Skia on CI. Measured in a Linux container (Flutter 3.44,
newer than the reference-generating Mac) the deltas are tiny — the converter and
Home goldens differ by ≤0.01%, and the worst, the variation indicator, by
0.16%. `CiGoldensConfig(diffThreshold: 0.01)` in `flutter_test_config.dart`
tolerates up to 1% — a ~6× margin over the worst case, while any real regression
(a colour change, a moved widget, a missing element) moves whole percent points.
The references in this repo were generated on macOS and confirmed to pass on
Linux within that tolerance.

## Running them

```bash
flutter test                          # whole suite, goldens included
flutter test --tags golden            # only the goldens
flutter test --exclude-tags golden    # skip them (logic tests only)
```

CI (`.github/workflows/pr-validation.yml`) runs the whole suite, so a golden
mismatch fails the PR check.

## Regenerating the references

Do this **only** when a UI change is intended, and review the resulting `*.png`
diff as carefully as code — an accidental regression looks exactly like a
deliberate one to `--update-goldens`.

```bash
# All goldens
flutter test --update-goldens

# Just one file after touching a specific widget
flutter test --update-goldens test/features/home/home_page_golden_test.dart
```

Then check the changed images (`git diff --stat`, and open them) before
committing. Because the goldens are platform-independent, regenerating on macOS
produces the same bytes CI will verify on Linux.

When a golden fails, Alchemist writes the expected/actual/diff images next to the
reference under a `failures/` folder — it is git-ignored, inspect it to see what
moved.

## Adding a new golden

1. Put the test next to the code it mirrors, named `*_golden_test.dart`.
2. For a self-contained widget, use `lightDarkGoldenTest` from
   [`test/shared/presentation/widgets/golden_utils.dart`](../test/shared/presentation/widgets/golden_utils.dart).
3. For a widget that needs GetX/pages, follow the harness in
   `home_page_golden_test.dart` (fakes via `Get.put`, a phone-sized
   `MediaQuery`, explicit pumps instead of `pumpAndSettle`).
4. Generate the reference with `--update-goldens` and commit the `*.png`.
