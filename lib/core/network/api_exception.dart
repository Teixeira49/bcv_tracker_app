import 'dart:convert';

/// Failure while talking to the currency backend.
///
/// The backend answers every error with the same envelope
/// (`{"status": "Error", "message": "..."}`) and a meaningful status code —
/// 404 wrong route, 408 source timeout, 502 source unavailable, 500 internal.
/// This exception keeps both so the UI can tell the user what happened instead
/// of failing silently.
class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode});

  /// Builds the exception from an error response, reusing the `message` of the
  /// backend envelope when the body carries one.
  factory ApiException.fromResponse({int? statusCode, Object? body}) {
    return ApiException(
      message: _messageFromBody(body) ?? 'HTTP $statusCode',
      statusCode: statusCode,
    );
  }

  /// The request never produced a response (no connectivity, DNS, timeout).
  const ApiException.network(this.message) : statusCode = null;

  /// A response arrived but its shape is not the expected contract.
  const ApiException.malformed(this.message) : statusCode = null;

  final String message;

  /// HTTP status code, or `null` when the request never reached the backend.
  final int? statusCode;

  static String? _messageFromBody(Object? body) {
    if (body is! String || body.isEmpty) return null;
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['message'] is String) {
        final message = (decoded['message'] as String).trim();
        return message.isEmpty ? null : message;
      }
    } catch (_) {
      // Not JSON (e.g. an HTML error page from the edge): fall back to the code.
    }
    return null;
  }

  @override
  String toString() =>
      'ApiException(${statusCode ?? 'no response'}): $message';
}
