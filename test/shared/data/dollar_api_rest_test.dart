import 'package:bcv_tracker_app/core/constants/market_constants.dart';
import 'package:bcv_tracker_app/core/network/api_exception.dart';
import 'package:bcv_tracker_app/core/network/http_manager.dart';
import 'package:bcv_tracker_app/core/network/http_operation.dart';
import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar_api_rest.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Returns a canned response (or failure) instead of hitting the network, and
/// records the request so the tests can pin the contract that was sent.
class _FakeHttpManager extends HttpManager {
  _FakeHttpManager({this.statusCode = 200, this.responseBody, this.failure});

  final int statusCode;
  final Object? responseBody;
  final DioException? failure;

  String? sentEndpoint;
  HttpOperation? sentMethod;
  Map<String, dynamic>? sentBody;

  @override
  Future<Response> request({
    required String endpoint,
    HttpOperation method = HttpOperation.get,
    Map<String, dynamic>? body,
    Map<String, dynamic>? customHeader,
    String? clientCode,
  }) async {
    sentEndpoint = endpoint;
    sentMethod = method;
    sentBody = body;
    if (failure != null) throw failure!;
    return Response(
      requestOptions: RequestOptions(path: endpoint),
      statusCode: statusCode,
      data: responseBody,
    );
  }
}

DollarApiRest _api({
  int statusCode = 200,
  Object? body,
  DioException? failure,
}) => DollarApiRest(
  apiUrl: 'https://backend.test',
  client: _FakeHttpManager(
    statusCode: statusCode,
    responseBody: body,
    failure: failure,
  ),
);

void main() {
  group('the request the backend receives', () {
    test('is a POST carrying the per-market Body', () async {
      final client = _FakeHttpManager(
        responseBody: '{"status":"Success","message":"ok","data":[]}',
      );
      await DollarApiRest(
        apiUrl: 'https://backend.test',
        client: client,
      ).getCurrentDollar(
        Markets.selectionOf({Markets.bcvKey, Markets.binanceKey}),
      );

      expect(client.sentMethod, HttpOperation.post);
      expect(client.sentEndpoint, endsWith('/saved-currencies'));
      // A market absent from the Body is `off`: the request asks for exactly
      // the two markets selected, in the modes the catalogue declares.
      expect(client.sentBody, {
        'markets': {
          Markets.bcvKey: Markets.modeDbDollar,
          Markets.binanceKey: Markets.modeAverage,
        },
      });
    });

    test('targets the versioned path of the country controller', () async {
      final client = _FakeHttpManager(
        responseBody:
            '{"status":"Success","message":"ok","data":{"date":null,"currencies":[]}}',
      );
      await DollarApiRest(
        apiUrl: 'https://backend.test',
        client: client,
      ).getCurrentBCVDollar();

      expect(
        client.sentEndpoint,
        'https://backend.test/api/v1/venezuela/bcv/with-memory',
      );
      expect(client.sentMethod, HttpOperation.get);
      expect(client.sentBody, isNull);
    });
  });

  group('getCurrentDollar()', () {
    test('maps the data list of the envelope', () async {
      final result = await _api(
        body:
            '{"status":"Success","message":"ok","data":['
            '{"code":"USD","name":"Dolar","platform":"Banco Central de Venezuela",'
            '"value":737.8816,"change":33.08,"createDate":"2026-01-29T18:38:47.617316",'
            '"updateDate":"2026-07-23T03:46:17.336191","platform_img":"https://logo.test/bcv.png"}]}',
      ).getCurrentDollar(Markets.defaultSelection);

      expect(result, hasLength(1));
      expect(result.first.keyName, 'USD');
      expect(result.first.value, 737.8816);
      expect(result.first.tendency, 33.08);
      expect(result.first.imgUrl, 'https://logo.test/bcv.png');
      // Stored timestamps arrive with no offset and mean UTC; the model hands
      // them over already converted to the device zone.
      expect(
        result.first.updateDate!.toUtc(),
        DateTime.utc(2026, 7, 23, 3, 46, 17, 336, 191),
      );
      expect(result.first.updateDate!.isUtc, isFalse);
    });

    test('honours the offset of a live rate', () async {
      final result = await _api(
        body:
            '{"status":"Success","message":"ok","data":['
            '{"code":"USDT","name":"Tether-buy","platform":"Binance","value":860.6,'
            '"change":0.1,"createDate":"2026-07-26T21:18:42.522524-04:00",'
            '"updateDate":"2026-07-26T21:18:42.522529-04:00","platform_img":""}]}',
      ).getCurrentDollar(Markets.defaultSelection);

      expect(
        result.first.updateDate!.toUtc(),
        DateTime.utc(2026, 7, 27, 1, 18, 42, 522, 529),
      );
    });

    test('keeps the backend message on an error status', () async {
      await expectLater(
        _api(
          statusCode: 502,
          body:
              '{"status":"Error","message":"El portal del BCV no está disponible"}',
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 502)
              .having(
                (e) => e.message,
                'message',
                'El portal del BCV no está disponible',
              ),
        ),
      );
    });

    test(
      'falls back to the status code when the body is not the envelope',
      () async {
        // What a wrong route actually returns through the edge: an HTML page.
        await expectLater(
          _api(
            statusCode: 404,
            body: '<html>404</html>',
          ).getCurrentDollar(Markets.defaultSelection),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.message, 'message', 'HTTP 404'),
          ),
        );
      },
    );

    test('reads the validation detail of FastAPI on a 422', () async {
      // A mode a market does not allow: this response is built by FastAPI, so
      // it never goes through the error envelope of the backend.
      await expectLater(
        _api(
          statusCode: 422,
          body:
              '{"detail":[{"type":"value_error","loc":["body","markets"],'
              '"msg":"Value error, El modo \'solo-dolar\' no es válido para el '
              'mercado \'binance\'."}]}',
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 422)
              .having((e) => e.message, 'message', contains('no es válido')),
        ),
      );
    });

    test('reads a detail that comes as a plain string', () async {
      await expectLater(
        _api(
          statusCode: 405,
          body: '{"detail":"Method Not Allowed"}',
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Method Not Allowed',
          ),
        ),
      );
    });

    test('reports a malformed body instead of crashing', () async {
      await expectLater(
        _api(body: 'not json').getCurrentDollar(Markets.defaultSelection),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        _api(
          body: '{"status":"Success","message":"ok"}',
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(isA<ApiException>()),
      );
      await expectLater(
        _api(body: '').getCurrentDollar(Markets.defaultSelection),
        throwsA(isA<ApiException>()),
      );
      // `data` present but not a list.
      await expectLater(
        _api(
          body: '{"status":"Success","message":"ok","data":{}}',
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(isA<ApiException>()),
      );
    });

    test('translates a transport failure into ApiException.network', () async {
      await expectLater(
        _api(
          failure: DioException(
            requestOptions: RequestOptions(path: '/x'),
            message: 'Connection refused',
            type: DioExceptionType.connectionError,
          ),
        ).getCurrentDollar(Markets.defaultSelection),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', isNull)
              .having((e) => e.message, 'message', 'Connection refused'),
        ),
      );
    });

    test('skips optional fields without throwing', () async {
      final result = await _api(
        body:
            '{"status":"Success","message":"ok","data":['
            '{"code":"em","name":"Exchange monitor","platform":"Exchange Monitor",'
            '"value":803.58,"change":0,"createDate":null,"updateDate":null,"platform_img":""}]}',
      ).getCurrentDollar(Markets.defaultSelection);

      expect(result.first.keyName, 'em');
      expect(result.first.createDate, isNull);
      expect(result.first.updateDate, isNull);
      expect(result.first.tendency, 0.0);
      // An empty logo must become null so the UI falls back to the initials.
      expect(result.first.imgUrl, isNull);
    });
  });

  group('getCurrentBCVDollar()', () {
    test('maps date and currencies', () async {
      final result = await _api(
        body:
            '{"status":"Success","message":"ok","data":{"date":"2026-07-23T00:00:00-04:00",'
            '"currencies":[{"code":"USD","name":"Dolar","platform":"Banco Central de Venezuela",'
            '"value":737.88,"change":33.08,"createDate":"2026-01-29T18:38:47.617316",'
            '"updateDate":"2026-07-23T03:46:17.336191","platform_img":"https://logo.test/bcv.png"}]}}',
      ).getCurrentBCVDollar();

      expect(result.date, '2026-07-23T00:00:00-04:00');
      expect(result.currencies, hasLength(1));
    });

    test('accepts a null date and missing currencies', () async {
      final result = await _api(
        body: '{"status":"Success","message":"ok","data":{"date":null}}',
      ).getCurrentBCVDollar();

      expect(result.date, isNull);
      expect(result.currencies, isEmpty);
    });
  });
}
