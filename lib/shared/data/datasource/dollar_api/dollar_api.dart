
import '../../model/model.dart';

abstract class IDollarApi {

  Future<List<CurrencyModel>> getCurrentBCVDollar();

  Future<List<CurrencyModel>> getCurrentDollar();
}