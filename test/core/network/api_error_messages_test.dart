import 'package:bcv_tracker_app/core/i18n/app_messages.dart';
import 'package:bcv_tracker_app/core/network/api_error_messages.dart';
import 'package:bcv_tracker_app/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The mapper returns AppMessages getters. Without GetX translations loaded,
  // `.tr` returns the raw key, so both the actual and the expected evaluate to
  // the same key — the assertions test the *mapping*, not the translation.
  group('apiErrorMessage by kind', () {
    test('a network failure is "no connection", not a server error', () {
      expect(
        apiErrorMessage(const ApiException.network('Connection refused')),
        AppMessages.errorNoConnection,
      );
    });

    test('a malformed response maps to "unexpected response"', () {
      expect(
        apiErrorMessage(const ApiException.malformed('bad contract')),
        AppMessages.errorUnexpectedResponse,
      );
    });
  });

  group('apiErrorMessage by status code', () {
    final cases = <int, String>{
      408: AppMessages.errorTimeout,
      422: AppMessages.errorInvalidRequest,
      502: AppMessages.errorServiceUnavailable,
      500: AppMessages.errorServerInternal,
    };

    cases.forEach((code, expected) {
      test('$code maps to its own message', () {
        expect(
          apiErrorMessage(ApiException.fromResponse(statusCode: code)),
          expected,
        );
      });
    });

    test('any other code falls to the controlled generic message', () {
      for (final code in [404, 401, 400, 503, 418]) {
        expect(
          apiErrorMessage(ApiException.fromResponse(statusCode: code)),
          AppMessages.errorGeneric,
          reason: 'code $code',
        );
      }
    });
  });

  test('connectivity is distinguished from a server failure', () {
    final network = apiErrorMessage(const ApiException.network('x'));
    final server = apiErrorMessage(ApiException.fromResponse(statusCode: 502));
    expect(network, isNot(server));
  });

  test('the backend developer message never becomes the user message', () {
    // fromResponse keeps the backend text in `.message`; the user sees the
    // mapped app message instead.
    final e = ApiException.fromResponse(
      statusCode: 500,
      body:
          '{"status":"Error","message":"Traceback: NoneType has no attribute"}',
    );
    expect(apiErrorMessage(e), AppMessages.errorServerInternal);
    expect(apiErrorMessage(e), isNot(contains('Traceback')));
  });
}
