import 'package:bcv_tracker_app/core/logging/app_logger.dart';
import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar.dart';
import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/repositories.dart';

class DollarRepository implements IDollarRepository {
  DollarRepository({required IDollarApi dollarApi}) : _dollarApi = dollarApi;

  final IDollarApi _dollarApi;

  static const String _source = 'DollarRepository';

  @override
  Future<BcvCurrencies> getCurrentBCVDollar() async {
    try {
      final data = await _dollarApi.getCurrentBCVDollar();

      return data.toEntity();
    } catch (e, s) {
      // A trace point at the repository boundary: the datasource has already
      // logged the specific parse/transport cause, this records that the BCV
      // fetch is the one that failed before the error propagates to the service.
      AppLogger.warning(
        'getCurrentBCVDollar failed',
        name: _source,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<Currency>> getCurrentDollar() async {
    try {
      final data = await _dollarApi.getCurrentDollar();
      return data.map((e) => e.toEntity()).toList();
    } catch (e, s) {
      AppLogger.warning(
        'getCurrentDollar failed',
        name: _source,
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
