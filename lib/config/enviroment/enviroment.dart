import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String currency = dotenv.env['CURRENCY_BACK'] ?? '';
}
