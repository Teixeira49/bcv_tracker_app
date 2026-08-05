import 'dart:convert';
import 'dart:typed_data';

import 'package:bcv_tracker_app/config/enviroment/enviroment.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The `.env` exists but is empty — a bare `touch .env`, or an `echo` that
/// failed in CI and left the file at zero bytes.
///
/// Kept in its own file because it mocks the asset bundle for every key, which
/// would interfere with the rest of the `Environment` tests.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      ByteData? message,
    ) async {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode('')));
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });

  test('an empty .env is reported, not thrown', () async {
    // `flutter_dotenv` raises `EmptyEnvFileError` here, and that one is a plain
    // `Error` rather than a `FlutterError`, so `load(isOptional: true)` never
    // caught it: the exception escaped `main()` and killed the app before the
    // first frame, with no message for the user and no log for the developer.
    await expectLater(Environment.load(), completes);

    expect(Environment.isEnvFileAvailable, isFalse);
    expect(Environment.validate()?.issue, EnvironmentIssue.envFileUnavailable);
  });

  test('the app can still read currency afterwards', () async {
    // A failed load leaves dotenv uninitialised, and `dotenv.env` throws in
    // that state — which would turn the reported problem back into a crash on
    // the way to the configuration error screen.
    await Environment.load();

    expect(() => Environment.currency, returnsNormally);
    expect(Environment.currency, '');
  });
}
