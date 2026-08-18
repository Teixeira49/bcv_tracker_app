// ignore_for_file: public_member_api_docs, sort_constructors_first
// Flutter imports:
// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import 'http_operation.dart';

// Project imports:

/// Placeholder discriminator kept for the transport's own error path.
///
/// A single-value enum, which is as much as it needs to be: callers never see it,
/// because failures leave this layer as `ApiException`.
enum HttpManagerUtilError {
  /// The transport failed. The cause travels in the exception, not here.
  error,
}

/// The app's HTTP client — Dio, configured once.
///
/// Every request goes through here so the timeout, the headers and the logging
/// are one decision rather than a per-datasource habit. `DollarApiRest` takes an
/// instance, which is what lets a test hand it a fake and assert **the outgoing
/// contract** (the path and the method actually sent) without a network.
///
/// It **maps transport failures to `ApiException`**. A `DioException` must not
/// escape this file: the layers above have no business knowing which client
/// fetched the data, and `.agents/rules/test-coverage.md` requires a test for each
/// of non-2xx, timeout and empty body.
class HttpManager {
  BaseOptions _dioOptions(
    String endpoint,
    Map<String, dynamic>? customHeader,
    String? clientCode,
  ) {
    final repositoryHeader = customHeader ?? <String, dynamic>{};
    const timeout = Duration(seconds: 30);

    final options = BaseOptions(
      responseType: ResponseType.plain,
      headers: repositoryHeader,
      contentType: 'application/json',
      validateStatus: (status) => true,
      connectTimeout: timeout,
      receiveTimeout: timeout,
    );

    return options;
  }

  static const _source = 'HttpManagerUtil';

  /// Creates and executes an HTTP request.
  ///
  /// The `endpoint` and `operation` type is the type of operation to be performed.
  ///
  ///
  Future<Response> request({
    required String endpoint,
    HttpOperation method = HttpOperation.get,
    Map<String, dynamic>? body,
    Map<String, dynamic>? customHeader,
    String? clientCode,
  }) async {
    final setDioOptions = _dioOptions(endpoint, customHeader, clientCode);

    // The adapter is left untouched on purpose. Dio validates the certificate
    // chain against the system trust store by default, and the backend is
    // served over HTTPS with a valid certificate, so it needs no help.
    //
    // ⚠️ Never override `httpClientAdapter` to accept every certificate
    // (`badCertificateCallback => true`): it defeats iOS ATS and Android's
    // network security config, and lets anyone on the same network serve
    // forged exchange rates. See issue #50.
    final dio = Dio(setDioOptions);

    Response? response;

    final data = json.encode(body ?? {});

    // Endpoint redacted: the request is logged for tracing, but a query string
    // never reaches the log (see AppLogger.redactUri).
    AppLogger.debug(
      '→ ${method.name.toUpperCase()} ${AppLogger.redactUri(endpoint)}',
      name: _source,
    );

    try {
      switch (method) {
        case HttpOperation.get:
          response = await dio.get(endpoint);
          break;
        case HttpOperation.post:
          response = await dio.post(endpoint, data: data);
          break;
        case HttpOperation.put:
          if (body != null) {
            response = await dio.put(endpoint, data: data);
          } else {
            response = await dio.put(endpoint);
          }
          break;
        case HttpOperation.delete:
          if (body != null) {
            response = await dio.delete(endpoint, data: data);
          } else {
            response = await dio.delete(endpoint);
          }
          break;
        case HttpOperation.patch:
          response = await dio.patch(endpoint, data: data);
          break;
        case HttpOperation.options:
          response = await dio.request(
            endpoint,
            options: Options(method: 'OPTIONS'),
          );
          break;
        case HttpOperation.head:
          response = await dio.request(
            endpoint,
            options: Options(method: 'HEAD'),
          );
          break;
      }

      dio.close();

      return response;
    } catch (e, s) {
      AppLogger.error(
        '❌ HTTP request failed for ${AppLogger.redactUri(endpoint)}',
        name: '$_source.request',
        error: e,
        stackTrace: s,
      );

      rethrow;
    }
  }
}
