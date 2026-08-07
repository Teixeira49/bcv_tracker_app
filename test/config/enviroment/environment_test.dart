import 'package:bcv_tracker_app/config/enviroment/enviroment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// Replaces the contents of the `.env` for the duration of a test, and marks
/// the file as readable — the state `Environment.load()` leaves behind when the
/// asset is there.
void loadEnv(String contents) {
  dotenv.testLoad(fileInput: contents);
  Environment.debugSetEnvFileAvailable(true);
}

void main() {
  tearDown(() => loadEnv(''));

  group('load()', () {
    // Exercises the real dotenv path rather than the test seam, so the
    // "never throws" contract is checked against an actual bundle failure.
    test('reports a file that is not there instead of throwing', () async {
      await expectLater(
        Environment.load(fileName: 'assets/no-such-file.env'),
        completes,
      );

      expect(Environment.isEnvFileAvailable, isFalse);
      expect(
        Environment.validate()?.issue,
        EnvironmentIssue.envFileUnavailable,
      );
    });

    test('leaves currency readable, not throwing NotInitializedError', () {
      // A failed load can leave dotenv uninitialised, and `dotenv.env` throws
      // in that state — which would turn the reported problem back into a
      // crash on the way to the error screen.
      Environment.debugSetEnvFileAvailable(false);

      expect(() => Environment.currency, returnsNormally);
    });
  });

  group('an unreadable .env', () {
    test('is reported instead of crashing the app', () {
      // `flutter_dotenv` raises `EmptyEnvFileError` for a file that exists but
      // is empty, and that one is a plain `Error`, not a `FlutterError`, so
      // `load(isOptional: true)` never swallowed it. It used to escape
      // `main()` and take the app down before the first frame.
      loadEnv('CURRENCY_BACK=https://backend.example.com');
      Environment.debugSetEnvFileAvailable(false);

      final error = Environment.validate();
      expect(error, isNotNull);
      expect(error!.issue, EnvironmentIssue.envFileUnavailable);
    });

    test('is told apart from a variable that is merely missing', () {
      Environment.debugSetEnvFileAvailable(false);
      final fileMessage = Environment.validate()!.developerMessage;

      loadEnv('');
      final variableMessage = Environment.validate()!.developerMessage;

      // The two are fixed differently: you copy the template, or you edit it.
      expect(fileMessage, isNot(variableMessage));
      expect(fileMessage, contains('No se pudo leer el archivo .env'));
      expect(variableMessage, contains('Falta la variable CURRENCY_BACK'));
    });

    test('still names the variable to define, and no value', () {
      loadEnv('CURRENCY_BACK=https://private-deploy.internal');
      Environment.debugSetEnvFileAvailable(false);

      final message = Environment.validate()!.developerMessage;

      expect(message, contains('CURRENCY_BACK'));
      expect(message, contains('cp .env.example .env'));
      expect(message, isNot(contains('private-deploy.internal')));
    });

    test('takes priority over the value left in memory', () {
      // A previous load may have populated dotenv. If the file is gone now,
      // that stale value must not make the app look configured.
      loadEnv('CURRENCY_BACK=https://backend.example.com');
      expect(Environment.validate(), isNull);

      Environment.debugSetEnvFileAvailable(false);
      expect(Environment.validate(), isNotNull);
    });
  });

  group('validate() rejects', () {
    test('a variable that is not defined at all', () {
      loadEnv('SOME_OTHER_KEY=whatever');

      final error = Environment.validate();
      expect(error, isNotNull);
      expect(error!.variable, 'CURRENCY_BACK');
      expect(error.issue, EnvironmentIssue.missing);
    });

    test('an empty value', () {
      loadEnv('CURRENCY_BACK=');

      expect(Environment.validate()?.issue, EnvironmentIssue.missing);
    });

    test('a value that is only whitespace', () {
      loadEnv('CURRENCY_BACK="   "');

      expect(Environment.validate()?.issue, EnvironmentIssue.missing);
    });

    test('a URL with no scheme', () {
      // The case that used to slip through: Dio builds a relative request and
      // the failure only shows up later, as a generic network error.
      loadEnv('CURRENCY_BACK=backend.example.com');

      expect(Environment.validate()?.issue, EnvironmentIssue.notAbsoluteUrl);
    });

    test('a scheme that is not http or https', () {
      loadEnv('CURRENCY_BACK=ftp://backend.example.com');

      expect(Environment.validate()?.issue, EnvironmentIssue.notAbsoluteUrl);
    });

    test('a URL with a scheme but no host', () {
      // `Uri.parse` accepts this happily, which is why the host is checked.
      loadEnv('CURRENCY_BACK=https://');

      expect(Environment.validate()?.issue, EnvironmentIssue.notAbsoluteUrl);
    });
  });

  group('validate() accepts', () {
    test('an absolute https URL', () {
      loadEnv('CURRENCY_BACK=https://backend.example.com');

      expect(Environment.validate(), isNull);
    });

    test('an absolute http URL, port included', () {
      // How the backend is reached from an emulator against a local machine.
      loadEnv('CURRENCY_BACK=http://10.0.2.2:8000');

      expect(Environment.validate(), isNull);
    });

    test('a URL with trailing slashes, which normalizeBaseUrl trims', () {
      loadEnv('CURRENCY_BACK=https://backend.example.com//');

      expect(Environment.validate(), isNull);
      expect(Environment.currency, 'https://backend.example.com');
    });
  });

  group('the reported error', () {
    test('names the variable and how to define it, never its value', () {
      loadEnv('CURRENCY_BACK=https://private-deploy.internal');
      // Force the malformed branch with a value that must not be echoed.
      loadEnv('CURRENCY_BACK=private-deploy.internal');

      final message = Environment.validate()!.developerMessage;

      expect(message, contains('CURRENCY_BACK'));
      expect(message, contains('.env'));
      // Printing the configured URL would leak a private deployment address
      // into any screenshot or bug report.
      expect(message, isNot(contains('private-deploy.internal')));
    });

    test('tells a missing variable apart from a malformed one', () {
      loadEnv('');
      final missing = Environment.validate()!.developerMessage;

      loadEnv('CURRENCY_BACK=nope');
      final malformed = Environment.validate()!.developerMessage;

      expect(missing, isNot(malformed));
      expect(missing, contains('cp .env.example .env'));
      expect(malformed, contains('https://'));
    });
  });

  group('normalizeBaseUrl()', () {
    test('trims whitespace and every trailing slash', () {
      expect(
        Environment.normalizeBaseUrl('  https://backend.example.com///  '),
        'https://backend.example.com',
      );
    });

    test('turns a null or empty value into the empty string', () {
      expect(Environment.normalizeBaseUrl(null), '');
      expect(Environment.normalizeBaseUrl('   '), '');
    });
  });
}
