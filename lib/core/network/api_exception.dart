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
      if (decoded is Map) {
        return _text(decoded['message']) ?? _detail(decoded['detail']);
      }
    } catch (_) {
      // Not JSON (e.g. an HTML error page from the edge): fall back to the code.
    }
    return null;
  }

  /// Reads the `detail` FastAPI answers with when the Body fails validation.
  ///
  /// That response is built by FastAPI itself, so it never reaches the error
  /// envelope of the backend and carries no `message`. Since v3.0.0 it is how a
  /// mode that a market does not allow arrives, and without this the user only
  /// saw "HTTP 422".
  static String? _detail(Object? detail) {
    if (detail is String) return _text(detail);
    if (detail is List) {
      final messages = detail
          .whereType<Map>()
          .map((entry) => _text(entry['msg']))
          .whereType<String>();
      if (messages.isNotEmpty) return messages.join(' · ');
    }
    return null;
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  @override
  String toString() => 'ApiException(${statusCode ?? 'no response'}): $message';
}
