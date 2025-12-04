import 'package:bcv_tracker_app/shared/data/datasource/datasource.dart';
import 'package:bcv_tracker_app/shared/data/model/currency_model.dart';
import 'package:html/parser.dart' show parse;

import '../../../../core/network/http_manager.dart';
import '../../model/model.dart';

class DollarApiRest implements IDollarApi {
  DollarApiRest({
    required String apiUrl,
    required String secondApiUrl,
    HttpManager? client,
  }) : _apiUrl = apiUrl,
       _secondApiUrl = secondApiUrl,
       _client = client ?? HttpManager();

  final String _apiUrl;
  final String _secondApiUrl;
  final HttpManager _client;

  @override
  Future<List<CurrencyModel>> getCurrentBCVDollar() async {
    try {
      final response = await _client.request(
        endpoint: _apiUrl + DollarEndpoints.currentDollar,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final document = parse(response.data);
        final data = document.getElementsByClassName("col-sm-12 col-xs-12");
        List<CurrencyModel> currencies = [];
        for (var element in data) {
          final subElement = element.getElementsByClassName("row recuadrotsmc");
          if (subElement.isNotEmpty) {
            final image = subElement.first
                .querySelector('img.icono_bss_blanco1')
                ?.attributes['src'];
            currencies.add(
              CurrencyModel(
                name: element.id,
                keyName: subElement.first
                    .getElementsByTagName('span')
                    .first
                    .text,
                value: subElement.first
                    .getElementsByTagName('strong')
                    .last
                    .text,
                imgUrl: image != null ? _apiUrl + image : null,
              ),
            );
          }
        }
        return currencies;
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
        endpoint: _secondApiUrl + DollarEndpoints.currentDollar,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final document = parse(response.data);
        final dataDollar = document.getElementById("mesa-cambio-bcv-dolar");
        final dataEuro = document.getElementById("mesa-cambio-bcv-euro");
        print(document.getElementsByClassName('elementor-icon-box-description').first.getElementsByTagName('span')
            .first
            .text);
        List<CurrencyModel> currencies = [
          if (dataEuro != null)
            CurrencyModel(name: 'Euro', keyName: 'EUR', value: dataEuro.text),
          if (dataDollar != null)
            CurrencyModel(
              name: 'Dolar',
              keyName: 'USD',
              value: dataDollar.text,
            ),
        ];
        return currencies;
      }

      throw Exception(response.statusCode);
    } catch (e) {
      rethrow;
    }
  }
}
