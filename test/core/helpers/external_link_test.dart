import 'package:bcv_tracker_app/core/helpers/external_link.dart';
import 'package:flutter/services.dart';
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

/// Lanza un error de programación, no una negativa de la plataforma.
class _ArgumentErrorLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) =>
      Future<bool>.error(ArgumentError('mode no soportado'));
}

/// Throws where the platform channel would when nothing can handle the intent.
class _ThrowingLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(
    String url,
    LaunchOptions options,
  ) => Future<bool>.error(
    // Lo que lanza el canal cuando ninguna actividad puede atender el intent.
    PlatformException(code: 'ACTIVITY_NOT_FOUND'),
  );
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
    'refuses anything that is not a web address, without asking the platform',
    () async {
      final _FakeLauncher launcher = _FakeLauncher();
      UrlLauncherPlatform.instance = launcher;

      for (final String url in <String>[
        'tel:+58000',
        'mailto:someone@example.com',
        'intent://scan/#Intent;scheme=zxing;end',
        'javascript:alert(1)',
        'file:///etc/passwd',
        '',
        'not a url at all',
        // Parsean como esquema `https` **sin host**: comprobar solo el esquema
        // dejaría pasar cadenas que no son direcciones.
        'https:',
        'https:/malformed',
        'https:javascript:alert(1)',
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

  test('http is allowed, because Environment accepts it too', () async {
    final _FakeLauncher launcher = _FakeLauncher();
    UrlLauncherPlatform.instance = launcher;

    // `CURRENCY_BACK=http://10.0.2.2:8000` es la forma documentada de alcanzar
    // un backend local desde el emulador de Android, y de ahí sale la fila de
    // la documentación de la API. Rechazarla aquí la dejaba muerta sin
    // explicación, con dos validadores discrepando sobre qué es una URL válida.
    expect(await ExternalLink.open('http://10.0.2.2:8000/docs'), isTrue);
    expect(launcher.launched, <String>['http://10.0.2.2:8000/docs']);
  });

  test(
    'the scheme comparison is case-insensitive, as Uri normalises it',
    () async {
      final _FakeLauncher launcher = _FakeLauncher();
      UrlLauncherPlatform.instance = launcher;

      // `Uri.parse` pasa el esquema a minúsculas. Documentado en un test para
      // que nadie «arregle» la comparación añadiendo un `toLowerCase()`.
      expect(await ExternalLink.open('HTTPS://example.com'), isTrue);
    },
  );

  test('a platform that declines is reported, not swallowed', () async {
    UrlLauncherPlatform.instance = _FakeLauncher(accepts: false);

    // What Android 11+ returns when the manifest never declared the intent.
    expect(await ExternalLink.open('https://github.com'), isFalse);
  });

  test('a PlatformException degrades to false instead of crashing', () async {
    UrlLauncherPlatform.instance = _ThrowingLauncher();

    // Desde una fila de ajustes es la misma respuesta que `false`, y no puede
    // llegar al usuario como un crash en una pantalla que abrió para leer.
    expect(await ExternalLink.open('https://github.com'), isFalse);
  });

  test('any other exception propagates, because it is a bug here', () async {
    UrlLauncherPlatform.instance = _ArgumentErrorLauncher();

    // `on Object` habría convertido un error de programación de este archivo
    // en una fila que deja de funcionar en silencio. Se deja escapar a
    // propósito: es lo único que hace que se arregle.
    expect(
      () => ExternalLink.open('https://github.com'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
