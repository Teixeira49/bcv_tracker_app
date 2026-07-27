import '../entities/entities.dart';

abstract class IDollarRepository {
  Future<BcvCurrencies> getCurrentBCVDollar();

  /// Rates of the markets in [selection], each one in the mode it declares.
  Future<List<Currency>> getCurrentDollar(MarketSelection selection);
}
