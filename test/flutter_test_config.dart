import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Global golden-test configuration for the whole `test/` tree (Alchemist reads
/// it from this well-known file name).
///
/// **Why platform goldens are disabled.** Alchemist can emit two kinds of
/// golden: *platform* goldens (real fonts, one set per host OS) and *CI*
/// goldens (text obscured as solid blocks, identical on every OS). Our CI runs
/// on Linux (`ubuntu-latest`) while development happens on macOS, and the two
/// render fonts differently — a platform golden generated on a Mac would fail
/// byte-comparison on the Linux runner. Keeping only the CI goldens leaves a
/// single, platform-independent set of reference images that passes both
/// locally and on CI (issue #35). The trade-off, accepted for #35: the text in
/// the references is rendered as blocks, not readable glyphs; icons and colours
/// still render for real, so regressions in layout, palette and spacing are
/// caught all the same.
///
/// Regenerate the references with `flutter test --update-goldens`. See
/// `docs/golden-tests.md`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      // Only the platform-independent CI goldens are versioned; see above.
      platformGoldensConfig: PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
