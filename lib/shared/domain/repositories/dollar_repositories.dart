import '../entities/entities.dart';

/// What the app needs from a source of exchange rates.
///
/// The boundary between the domain and the network: everything above this
/// depends on the interface, and `DollarRepository` is registered against it in
/// `initial_bindings.dart` — which is what lets tests inject a fake with
/// `Get.put<IDollarRepository>(...)` and never touch the network.
///
/// **Two methods and not one** because the two sides of the app are two
/// requests: the official rates arrive with a shared effective date
/// ([BcvCurrencies]) and the parallel ones do not. Merging them here would mean
/// inventing a date for the markets that publish none.
///
/// Implementations return **entities and throw `ApiException`**. A `DioException`
/// must never cross this line: the layers above have no business knowing which
/// HTTP client fetched the data.
abstract class IDollarRepository {
  /// The official rates and the day they are effective on.
  ///
  /// Throws `ApiException` on a non-2xx, a timeout or an unparseable body.
  Future<BcvCurrencies> getCurrentBCVDollar();

  /// The parallel market rates, one per market and currency.
  ///
  /// Already normalised by `CurrencyNormalizer`, so duplicates are merged and
  /// markets the app does not list are dropped. Throws `ApiException` on failure.
  Future<List<Currency>> getCurrentDollar();
}
