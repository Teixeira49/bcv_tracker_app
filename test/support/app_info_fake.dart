import 'package:bcv_tracker_app/shared/presentation/controller/app_info_service.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The version these tests treat as installed.
///
/// Deliberately **not** the one in `pubspec.yaml`: an assertion against the real
/// version would break on every release, which is the coupling #43 exists to
/// remove. If a screen ever read the `pubspec` instead of the package, the
/// mismatch is what makes the test fail.
const String kFakeVersion = '9.9.9';
const String kFakeBuild = '42';
const String kFakeVersionLabel = '$kFakeVersion ($kFakeBuild)';

/// Registers an [AppInfoService] already filled in with the fake package.
///
/// Shared rather than copied into each test file — the first version of #43 had
/// this helper duplicated verbatim in four of them, which the review of #121
/// flagged. Awaiting [AppInfoService.load] here makes the value deterministic
/// by the time the widget builds, so no test has to pump for it.
Future<AppInfoService> putFakeAppInfo({
  String version = kFakeVersion,
  String build = kFakeBuild,
}) async {
  final AppInfoService service = AppInfoService();
  await service.load(
    read: () async => PackageInfo(
      appName: 'BCV Tracker',
      packageName: 'com.example.bcv_tracker_app',
      version: version,
      buildNumber: build,
    ),
  );
  return Get.put<AppInfoService>(service, permanent: true);
}
