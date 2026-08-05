import 'dart:convert';
import 'dart:io';

import 'package:bcv_tracker_app/shared/data/datasource/datasource.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/http_manager.dart';
import '../../model/model.dart';

class DollarApiRest implements IDollarApi {
  DollarApiRest({
    required String apiUrl,
    HttpManager? client,
  }) : _apiUrl = apiUrl,
       _client = client ?? HttpManager();

  final String _apiUrl;
  final HttpManager _client;

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
    } catch (e) {
      throw ApiException.malformed(
        'No se pudo interpretar la respuesta de bcv/with-memory: $e',
      );
    }
  }

  @override
  Future<List<CurrencyModel>> getCurrentDollar() async {
    final data = await _getData(DollarEndpoints.currentDollar);

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
    } catch (e) {
      throw ApiException.malformed(
        'No se pudo interpretar la respuesta de saved-currencies: $e',
      );
    }
  }

  /// Performs the request and returns the `data` field of the backend envelope
  /// (`{status, message, data}`), translating every failure into an
  /// [ApiException] that carries the backend message.
  Future<Object?> _getData(String endpoint) async {
    final Response response;
    try {
      response = await _client.request(endpoint: _apiUrl + endpoint);
    } on DioException catch (e) {
      // HttpManager accepts every status code, so Dio only throws when there is
      // no response at all (connectivity, DNS, timeout, TLS).
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

    final body = response.data;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException.fromResponse(
        statusCode: response.statusCode,
        body: body,
      );
    }

    if (body is! String || body.isEmpty) {
      throw const ApiException.malformed('El backend respondió con un cuerpo vacío.');
    }

    final Object? envelope;
    try {
      envelope = json.decode(body);
    } catch (e) {
      throw ApiException.malformed('El backend respondió con un cuerpo no JSON: $e');
    }

    if (envelope is! Map<String, dynamic> || !envelope.containsKey('data')) {
      throw const ApiException.malformed(
        'El backend respondió sin el campo "data" del envelope.',
      );
    }

    return envelope['data'];
  }
}
