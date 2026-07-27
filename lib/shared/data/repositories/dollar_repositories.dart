import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar.dart';
import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/repositories.dart';

class DollarRepository implements IDollarRepository {
  DollarRepository({required IDollarApi dollarApi}) : _dollarApi = dollarApi;

  final IDollarApi _dollarApi;

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async {
    try {
      final data = await _dollarApi.getCurrentBCVDollar();

      return data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Currency>> getCurrentDollar(MarketSelection selection) async {
    try {
      final data = await _dollarApi.getCurrentDollar(selection);
      return data.map((e) => e.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }
}
