import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// What version of the app is actually installed.
///
/// **Read from the package at runtime, never from a constant.** `pubspec.yaml`
/// is not readable at runtime, and a constant written by hand desynchronises on
/// the first release someone forgets to bump — which is precisely the failure
/// [#43](https://github.com/Teixeira49/bcv_tracker_app/issues/43) exists to
/// prevent. A version label that lies is worse than none: a tester reports a
/// bug against a build that never shipped.
///
/// **One service, so the menu and «Acerca de» cannot disagree.** #43 asks for
/// the figure in two places and requires them to be the same figure. Two
/// independent `PackageInfo.fromPlatform()` calls would satisfy that today and
/// stop satisfying it the day one of them gains a format.
///
/// **Registered through `InitialBinding.initServices()`, which `main` awaits.**
/// The first frame does not read it — settings are a tap away — but
/// `dependencies()` is *not* awaited by `GetMaterialApp`
/// (`dependency-injection.md`), so a `putAsync` there resolves whenever it
/// resolves and a `Get.find` that arrives first throws. "In practice it will
/// have finished" is exactly the reasoning that rule warns against. The cost is
/// one platform-channel round trip before `runApp`.
class AppInfoService extends GetxService {
  /// Semantic version of the installed package — `1.1.0`.
  ///
  /// Matches the part of `pubspec.yaml`'s `version:` before the `+`, which is
  /// what Codemagic passes as `--build-name`.
  late final String version;

  /// Build number of the installed package — `3`.
  ///
  /// **Will not match the `+N` in `pubspec.yaml` on a release build**, and that
  /// is correct rather than a defect: `codemagic.yaml` passes
  /// `--build-number ${CM_BUILD_NUMBER}`, so the number in the repository is
  /// only what a local `flutter build` would stamp. What matters for a bug
  /// report is the build the tester actually has, which is this one.
  late final String buildNumber;

  /// Version and build as one string — `1.1.0 (3)`.
  ///
  /// The shape a bug report needs: the semantic version says what the code is,
  /// the build number says which artefact of it. Formatted here so the menu,
  /// «Acerca de» and the clipboard all carry the same text.
  String get versionLabel => '$version ($buildNumber)';

  /// What is shown when the platform will not say.
  ///
  /// The same placeholder `CurrencyHelpers` uses for a missing figure, so an
  /// unknown version reads like every other absent value in the app.
  static const String unknown = '--';

  /// Ceiling on how long startup will wait for the plugin.
  ///
  /// `main` awaits this before `runApp`, so a channel that never answers would
  /// hold the app on a blank screen forever. Two seconds is far beyond what a
  /// package read takes and far below what a user would tolerate — and it
  /// stopped being hypothetical the moment the test suite hung on exactly that.
  static const Duration _readTimeout = Duration(seconds: 2);

  /// Reads the package and returns itself, for `Get.putAsync`.
  ///
  /// [info] is a parameter so a test can hand over a known package without a
  /// platform channel; production leaves it out and the plugin answers.
  ///
  /// **Never throws and never blocks past [_readTimeout].** A version label is
  /// the least important thing on the screen and this call sits in front of the
  /// first frame: failing to read it must degrade to `--`, not delay or crash
  /// the launch. The same reasoning as `Environment.load` — a configuration
  /// problem is something to report, not a reason to die before drawing.
  Future<AppInfoService> init({PackageInfo? info}) async {
    PackageInfo? resolved = info;
    if (resolved == null) {
      try {
        resolved = await PackageInfo.fromPlatform().timeout(_readTimeout);
      } on Object {
        resolved = null;
      }
    }

    version = resolved?.version ?? unknown;
    buildNumber = resolved?.buildNumber ?? unknown;
    return this;
  }
}
