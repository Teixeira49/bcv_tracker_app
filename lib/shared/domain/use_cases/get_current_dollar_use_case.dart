import '../entities/currency.dart';
import '../repositories/dollar_repositories.dart';

class GetCurrentDollarUseCase {
  GetCurrentDollarUseCase({required IDollarRepository dollarRepository})
    : _dollarRepository = dollarRepository;

  final IDollarRepository _dollarRepository;

  Future<List<Currency>> execute() async {
    try {
      final data = await _dollarRepository.getCurrentDollar();

      return data;
    } catch (e, s) {
      rethrow;
    }
  }
}
