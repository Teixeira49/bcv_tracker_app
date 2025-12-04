
import '../entities/entities.dart';

abstract class IDollarRepository {

  Future<List<Currency>> getCurrentBCVDollar();

  Future<List<Currency>> getCurrentDollar();
}