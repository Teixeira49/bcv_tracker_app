import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  /// Base URL of the currency backend, without trailing slashes.
  ///
  /// Endpoint paths are absolute (`/api/v1/...`), so a trailing slash in the
  /// `.env` value would build `//api/v1/...`, which the backend answers with a
  /// 308 redirect instead of serving the resource.
  static String get currency => normalizeBaseUrl(dotenv.env['CURRENCY_BACK']);

  static String normalizeBaseUrl(String? value) =>
      (value ?? '').trim().replaceAll(RegExp(r'/+$'), '');
}
