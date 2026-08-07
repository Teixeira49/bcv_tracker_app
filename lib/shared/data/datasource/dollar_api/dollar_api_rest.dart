import 'dart:convert';
import 'dart:io';

import 'package:bcv_tracker_app/shared/data/datasource/datasource.dart';
import 'package:dio/dio.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/http_manager.dart';
import '../../../../core/network/http_operation.dart';
import '../../model/model.dart';

class DollarApiRest implements IDollarApi {
  DollarApiRest({required String apiUrl, HttpManager? client})
    : _apiUrl = apiUrl,
      _client = client ?? HttpManager();

  final String _apiUrl;
  final HttpManager _client;

  static const String _source = 'DollarApiRest';

  @override
  Future<BcvCurrenciesModel> getCurrentBCVDollar() async {
    final data = await _getData(DollarEndpoints.currentBCVDollar);

    if (data is! Map<String, dynamic>) {
      throw const ApiException.malformed(
        'La respuesta de bcv/with-memory no trae un objeto en "data".',
      );
    }

    try {
      return BcvCurrenciesModel.fromJson(data);
    } catch (e, s) {
      AppLogger.warning(
        'Contract parse failed for bcv/with-memory',
        name: _source,
        error: e,
        stackTrace: s,
      );
      throw ApiException.malformed(
        'No se pudo interpretar la respuesta de bcv/with-memory: $e',
      );
    }
  }

  @override
  Future<List<CurrencyModel>> getCurrentDollar() async {
    // saved-currencies is a POST carrying the per-market Body (see
    // DollarEndpoints.currentDollarBody); the response envelope is unchanged.
    final data = await _getData(
      DollarEndpoints.currentDollar,
      method: HttpOperation.post,
      body: DollarEndpoints.currentDollarBody,
    );

    if (data is! List) {
      throw const ApiException.malformed(
        'La respuesta de saved-currencies no trae una lista en "data".',
      );
    }

    try {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CurrencyModel.fromJson)
          .toList();
    } catch (e, s) {
      AppLogger.warning(
        'Contract parse failed for saved-currencies',
        name: _source,
        error: e,
        stackTrace: s,
      );
      throw ApiException.malformed(
        'No se pudo interpretar la respuesta de saved-currencies: $e',
      );
    }
  }

  /// Performs the request and returns the `data` field of the backend envelope
  /// (`{status, message, data}`), translating every failure into an
  /// [ApiException] that carries the backend message.
  ///
  /// [method] and [body] let a caller POST a structured Body (as
  /// `saved-currencies` needs); they default to a plain GET.
  Future<Object?> _getData(
    String endpoint, {
    HttpOperation method = HttpOperation.get,
    Map<String, dynamic>? body,
  }) async {
    final Response<dynamic> response;
    try {
      response = await _client.request(
        endpoint: _apiUrl + endpoint,
        method: method,
        body: body,
      );
    } on DioException catch (e, s) {
      // HttpManager accepts every status code, so Dio only throws when there is
      // no response at all (connectivity, DNS, timeout, TLS).
      AppLogger.warning(
        'Transport failure calling ${AppLogger.redactUri(_apiUrl + endpoint)}',
        name: _source,
        error: e,
        stackTrace: s,
      );
      final cause = e.error;
      if (cause is HandshakeException || cause is CertificateException) {
        // Raised when the certificate does not validate against the system
        // trust store: an interception proxy, a captive portal or a network
        // serving a forged certificate. Dio's own message is the raw OS error
        // (`CERTIFICATE_VERIFY_FAILED`), useless to the user.
        throw const ApiException.network(
          'No se pudo verificar la identidad del servidor. '
          'La conexión podría estar siendo interceptada; '
          'prueba con otra red.',
        );
      }
      throw ApiException.network(e.message ?? e.type.name);
    }

    final rawBody = response.data;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException.fromResponse(
        statusCode: response.statusCode,
        body: rawBody,
      );
    }

    if (rawBody is! String || rawBody.isEmpty) {
      throw const ApiException.malformed(
        'El backend respondió con un cuerpo vacío.',
      );
    }

    final Object? envelope;
    try {
      envelope = json.decode(rawBody);
    } catch (e, s) {
      AppLogger.warning(
        'Backend responded with a non-JSON body',
        name: _source,
        error: e,
        stackTrace: s,
      );
      throw ApiException.malformed(
        'El backend respondió con un cuerpo no JSON: $e',
      );
    }

    if (envelope is! Map<String, dynamic> || !envelope.containsKey('data')) {
      throw const ApiException.malformed(
        'El backend respondió sin el campo "data" del envelope.',
      );
    }

    return envelope['data'];
  }
}
