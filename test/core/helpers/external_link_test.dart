import 'package:bcv_tracker_app/core/helpers/external_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Records what the app asked the platform to open, and lets a test say no.
class _FakeLauncher extends UrlLauncherPlatform {
  _FakeLauncher({this.accepts = true});

  /// What the platform answers. `false` is the real case of a device with no
  /// browser, or an Android 11+ manifest missing its `<queries>` entry.
  final bool accepts;

  final List<String> launched = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => accepts;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return accepts;
  }
}

/// Throws where the platform channel would when nothing can handle the intent.
class _ThrowingLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) =>
      Future<bool>.error(StateError('no activity found'));
}

/// The one door out of the app (#42). Its job is not "call `launchUrl`" — it is
/// to refuse what should not be opened and to answer honestly when the platform
/// declines, because the caller is a list row with a message to show and no
/// place to catch an exception.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UrlLauncherPlatform original;

  setUp(() => original = UrlLauncherPlatform.instance);
  tearDown(() => UrlLauncherPlatform.instance = original);

  test('opens an https address and reports success', () async {
    final _FakeLauncher launcher = _FakeLauncher();
    UrlLauncherPlatform.instance = launcher;

    expect(await ExternalLink.open('https://www.bcv.org.ve'), isTrue);
    expect(launcher.launched, <String>['https://www.bcv.org.ve']);
  });

  test(
    'refuses every scheme that is not https, without asking the platform',
    () async {
      final _FakeLauncher launcher = _FakeLauncher();
      UrlLauncherPlatform.instance = launcher;

      // `http` included on purpose: a downgrade is still a downgrade, and every
      // address this screen owns is https.
      for (final String url in <String>[
        'http://www.bcv.org.ve',
        'tel:+58000',
        'mailto:someone@example.com',
        'intent://scan/#Intent;scheme=zxing;end',
        'javascript:alert(1)',
        'file:///etc/passwd',
        '',
        'not a url at all',
      ]) {
        expect(
          await ExternalLink.open(url),
          isFalse,
          reason: '"$url" should not have been opened.',
        );
      }

      // The point of the check: it never reached the platform.
      expect(launcher.launched, isEmpty);
    },
  );

  test('a platform that declines is reported, not swallowed', () async {
    UrlLauncherPlatform.instance = _FakeLauncher(accepts: false);

    // What Android 11+ returns when the manifest never declared the intent.
    expect(await ExternalLink.open('https://github.com'), isFalse);
  });

  test('a platform that throws degrades to false instead of crashing', () async {
    UrlLauncherPlatform.instance = _ThrowingLauncher();

    // `launchUrl` raises a `PlatformException` when no activity can handle the
    // intent. From a settings row that is the same answer as `false`, and it
    // must not surface as a crash on a screen the user opened to read.
    expect(await ExternalLink.open('https://github.com'), isFalse);
  });
}
