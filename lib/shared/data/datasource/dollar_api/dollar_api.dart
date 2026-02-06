
import '../../model/model.dart';

abstract class IDollarApi {

  Future<BcvCurrenciesModel> getCurrentBCVDollar();

  Future<List<CurrencyModel>> getCurrentDollar();
}