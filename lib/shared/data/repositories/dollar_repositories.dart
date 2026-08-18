import 'package:bcv_tracker_app/core/logging/app_logger.dart';
import 'package:bcv_tracker_app/shared/data/datasource/dollar_api/dollar.dart';
import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';
import 'package:bcv_tracker_app/shared/domain/repositories/repositories.dart';

/// [IDollarRepository] over the REST datasource.
///
/// Two jobs, and nothing else: **convert models to entities**, so no object of
/// the data layer escapes upwards (see `.agents/rules/entities-vs-models.md`),
/// and **log the boundary** before letting the failure through.
///
/// It deliberately does not catch. The datasource has already turned transport
/// problems into `ApiException`; swallowing one here would leave
/// `CurrencyRepository` unable to tell a genuine empty market from a failed
/// request, and the screen would show "no data" for what is really an outage.
class DollarRepository implements IDollarRepository {
  /// Takes the datasource it reads from. Resolved by the binding, never
  /// constructed here — that is what makes it substitutable in tests.
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
