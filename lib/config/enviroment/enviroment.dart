import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Why the configuration the app was built with cannot be used.
enum EnvironmentIssue {
  /// The `.env` itself could not be read: absent, empty, or not bundled.
  ///
  /// Reported apart from [missing] because the fix is different — you copy the
  /// template, you do not edit it.
  envFileUnavailable,

  /// The file loaded, but the variable is absent from it or holds only
  /// whitespace.
  missing,

  /// The variable is there but is not an absolute `http`/`https` URL, so Dio
  /// would build a relative request and fail much later, as a network error.
  notAbsoluteUrl,
}

/// A configuration problem detected at startup, before anything tries to use it.
///
/// Carries the name of the offending variable and what is wrong with it — never
/// its value. Printing the configured URL on screen would leak a private
/// deployment address into a screenshot or a bug report.
class EnvironmentError {
  const EnvironmentError({required this.variable, required this.issue});

  /// Name of the environment variable, as written in `.env.example`.
  final String variable;

  final EnvironmentIssue issue;

  /// Developer-facing diagnostic. Never shown in a release build: it names the
  /// project's own files, which means nothing to a user.
  String get developerMessage => switch (issue) {
    EnvironmentIssue.envFileUnavailable =>
      'No se pudo leer el archivo .env.\n\n'
          'Falta, está vacío, o no se empaquetó como asset.\n\n'
          'Crea uno a partir de la plantilla:\n'
          '    cp .env.example .env\n\n'
          'y define $variable dentro.',
    EnvironmentIssue.missing =>
      'Falta la variable $variable.\n\n'
          'Copia la plantilla y completa el valor:\n'
          '    cp .env.example .env\n\n'
          'Debe ser la URL base del backend, sin barra final.',
    EnvironmentIssue.notAbsoluteUrl =>
      '$variable no es una URL absoluta.\n\n'
          'Tiene que empezar por http:// o https:// e incluir el host, '
          'sin barra final.\n\n'
          'Revisa el valor en tu .env (formato en .env.example).',
  };

  @override
  String toString() => 'EnvironmentError($variable, ${issue.name})';
}

class Environment {
  /// Key of the backend URL in `.env`. Kept as a constant because both the
  /// getter and the validation name it, and a typo in either would be silent.
  static const String currencyBackKey = 'CURRENCY_BACK';

  /// Base URL of the currency backend, without trailing slashes.
  ///
  /// Endpoint paths are absolute (`/api/v1/...`), so a trailing slash in the
  /// `.env` value would build `//api/v1/...`, which the backend answers with a
  /// 308 redirect instead of serving the resource.
  static String get currency => normalizeBaseUrl(_read(currencyBackKey));

  /// Reads a variable without assuming the file loaded.
  ///
  /// After a failed [load] `dotenv.env` throws `NotInitializedError`, which
  /// would turn a reported configuration problem back into a crash.
  static String? _read(String key) =>
      dotenv.isInitialized ? dotenv.env[key] : null;

  static String normalizeBaseUrl(String? value) =>
      (value ?? '').trim().replaceAll(RegExp(r'/+$'), '');

  static bool _envFileAvailable = false;

  /// Whether the `.env` could be read on the last [load].
  static bool get isEnvFileAvailable => _envFileAvailable;

  /// Loads the `.env`, and **never throws**: an unreadable file is a
  /// configuration problem for [validate] to report, not a reason to die
  /// before the first frame.
  ///
  /// `dotenv.load(isOptional: true)` is not enough on its own. It only swallows
  /// `FileNotFoundError`, and `flutter_dotenv` raises `EmptyEnvFileError` — a
  /// plain `Error`, not a `FlutterError` — when the file is there but empty,
  /// which a failed `echo` in CI or a bare `touch .env` produces easily. That
  /// one used to escape and crash the app on startup.
  static Future<void> load({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
      _envFileAvailable = true;
    } catch (_) {
      // FileNotFoundError, EmptyEnvFileError, or anything else the asset bundle
      // raises. All of them mean the same thing to the app: no configuration.
      _envFileAvailable = false;
    }
  }

  /// Lets a test place the app in the "env file unreadable" state, which is
  /// otherwise only reachable through the asset bundle.
  @visibleForTesting
  static void debugSetEnvFileAvailable(bool value) => _envFileAvailable = value;

  /// Checks the configuration the app cannot run without, and returns the first
  /// problem found — or `null` when everything is in place.
  ///
  /// This runs at startup, right after `dotenv.load`, because the alternative is
  /// failing **late**: with no `CURRENCY_BACK`, [currency] is the empty string,
  /// Dio builds a request against a relative URL and the user gets a generic
  /// network error that never mentions that a variable is missing.
  static EnvironmentError? validate() {
    if (!_envFileAvailable) {
      return const EnvironmentError(
        variable: currencyBackKey,
        issue: EnvironmentIssue.envFileUnavailable,
      );
    }

    final raw = normalizeBaseUrl(_read(currencyBackKey));

    if (raw.isEmpty) {
      return const EnvironmentError(
        variable: currencyBackKey,
        issue: EnvironmentIssue.missing,
      );
    }

    if (!_isAbsoluteHttpUrl(raw)) {
      return const EnvironmentError(
        variable: currencyBackKey,
        issue: EnvironmentIssue.notAbsoluteUrl,
      );
    }

    return null;
  }

  /// A base URL is only usable when it carries the scheme and the host: without
  /// them `Uri.parse` still succeeds, and the value silently becomes a path.
  static bool _isAbsoluteHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
