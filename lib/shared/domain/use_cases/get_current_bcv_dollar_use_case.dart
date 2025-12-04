import 'package:bcv_tracker_app/shared/domain/repositories/repositories.dart';

import '../entities/currency.dart';

class GetCurrentBCVDollarUseCase {
  GetCurrentBCVDollarUseCase({required IDollarRepository dollarRepository})
    : _dollarRepository = dollarRepository;

  final IDollarRepository _dollarRepository;

  Future<List<Currency>> execute() async {
    try {
      final data = await _dollarRepository.getCurrentBCVDollar();

      return data;
    } catch (e, s) {
      rethrow;
    }
  }
}
