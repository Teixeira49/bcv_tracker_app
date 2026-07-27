import '../../../domain/entities/market.dart';
import '../../model/model.dart';

abstract class IDollarApi {
  Future<BcvCurrenciesModel> getCurrentBCVDollar();

  /// Rates of the markets in [selection], each one in the mode it declares.
  Future<List<CurrencyModel>> getCurrentDollar(MarketSelection selection);
}
