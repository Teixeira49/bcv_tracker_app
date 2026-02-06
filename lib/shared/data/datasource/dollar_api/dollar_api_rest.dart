import 'dart:convert';

import 'package:bcv_tracker_app/shared/data/datasource/datasource.dart';

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
    try {
      final response = await _client.request(
        endpoint: _apiUrl + DollarEndpoints.currentBCVDollar,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BcvCurrenciesModel.fromJson(
          json.decode(response.data)['data'] as Map<String, dynamic>,
        );
      }

      throw Exception(response.statusCode);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CurrencyModel>> getCurrentDollar() async {
    try {
      final response = await _client.request(
        endpoint: _apiUrl + DollarEndpoints.currentDollar,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.data)['data'] as List;
        return data.map((e) => CurrencyModel.fromJson(e)).toList();
      }

      throw Exception(response.statusCode);
    } catch (e) {
      rethrow;
    }
  }
}
