import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar.dart';
import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/repositories.dart';

class DollarRepository implements IDollarRepository {
  DollarRepository({required IDollarApi dollarApi}) : _dollarApi = dollarApi;

  final IDollarApi _dollarApi;

  @override
  Future<List<Currency>> getCurrentBCVDollar() async {
    try {
      final data = await _dollarApi.getCurrentBCVDollar();

      return data.map((e) => e.toEntity()).toList();
    } catch (e, s) {
      rethrow;
    }
  }

  @override
  Future<List<Currency>> getCurrentDollar() async {
    try {
      final data = await _dollarApi.getCurrentDollar();

      return data.map((e) => e.toEntity()).toList();
    } catch (e, s) {
      rethrow;
    }
  }
}
