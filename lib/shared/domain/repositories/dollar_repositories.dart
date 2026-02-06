
import '../entities/entities.dart';

abstract class IDollarRepository {

  Future<BcvCurrencies> getCurrentBCVDollar();

  Future<List<Currency>> getCurrentDollar();
}