import '../../model/model.dart';

/// The HTTP calls the app makes for exchange rates.
///
/// One step below `IDollarRepository` and the mirror of it in the data layer:
/// this one traffics in **models**, that one in entities, and `DollarRepository`
/// is the seam where `.toEntity()` runs. Splitting them is what lets a test fake
/// the transport (`DollarApiRest` with a fake `HttpManager`) separately from
/// faking the data (`IDollarRepository`).
///
/// Implementations throw `ApiException`, never a `DioException`: mapping the
/// transport's own failures is the datasource's job, and
/// `.agents/rules/test-coverage.md` requires a test for each of non-2xx,
/// timeout and empty body.
abstract class IDollarApi {
  /// `GET`s the official rates and their effective date, unparsed into entities.
  Future<BcvCurrenciesModel> getCurrentBCVDollar();

  /// `GET`s the parallel market rates, unparsed into entities.
  Future<List<CurrencyModel>> getCurrentDollar();
}
