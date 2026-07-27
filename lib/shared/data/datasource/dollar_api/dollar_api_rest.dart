import 'dart:convert';

import 'package:bcv_tracker_app/shared/data/datasource/datasource.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/http_manager.dart';
import '../../../../core/network/http_operation.dart';
import '../../../domain/entities/market.dart';
import '../../model/model.dart';

class DollarApiRest implements IDollarApi {
  DollarApiRest({required String apiUrl, HttpManager? client})
    : _apiUrl = apiUrl,
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
  Future<List<CurrencyModel>> getCurrentDollar(
    MarketSelection selection,
  ) async {
    // POST since backend v3.0.0: the markets and their modes travel in the
    // Body. A market left out of it is `off`, so the request already asks for
    // exactly what the UI renders.
    final data = await _getData(
      DollarEndpoints.currentDollar,
      method: HttpOperation.post,
      body: selection.toJson(),
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
    } catch (e) {
      throw ApiException.malformed(
        'No se pudo interpretar la respuesta de saved-currencies: $e',
      );
    }
  }

  /// Performs the request and returns the `data` field of the backend envelope
  /// (`{status, message, data}`), translating every failure into an
  /// [ApiException] that carries the backend message.
  Future<Object?> _getData(
    String endpoint, {
    HttpOperation method = HttpOperation.get,
    Map<String, dynamic>? body,
  }) async {
    final Response response;
    try {
      response = await _client.request(
        endpoint: _apiUrl + endpoint,
        method: method,
        body: body,
      );
    } on DioException catch (e) {
      // HttpManager accepts every status code, so Dio only throws when there is
      // no response at all (connectivity, DNS, timeout).
      throw ApiException.network(e.message ?? e.type.name);
    }

    final payload = response.data;

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException.fromResponse(
        statusCode: response.statusCode,
        body: payload,
      );
    }

    if (payload is! String || payload.isEmpty) {
      throw const ApiException.malformed(
        'El backend respondió con un cuerpo vacío.',
      );
    }

    final Object? envelope;
    try {
      envelope = json.decode(payload);
    } catch (e) {
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
