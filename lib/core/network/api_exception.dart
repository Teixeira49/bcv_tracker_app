import 'dart:convert';

/// What kind of failure an [ApiException] represents, independent of the HTTP
/// code. Lets the UI tell "you have no connection" apart from "the service
/// answered with an error" — see `apiErrorMessage` in `api_error_messages.dart`.
enum ApiExceptionKind {
  /// The request never produced a response (no connectivity, DNS, timeout, TLS).
  network,

  /// A response arrived but its shape is not the expected contract.
  malformed,

  /// The backend answered with an error status and (usually) a message.
  response,
}

/// Failure while talking to the currency backend.
///
/// The backend answers every error with the same envelope
/// (`{"status": "Error", "message": "..."}`) and a meaningful status code —
/// 404 wrong route, 408 source timeout, 502 source unavailable, 500 internal.
/// This exception keeps both — plus a [kind] — so the UI can tell the user what
/// happened instead of failing silently.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.kind = ApiExceptionKind.response,
  });

  /// Builds the exception from an error response, reusing the `message` of the
  /// backend envelope when the body carries one.
  factory ApiException.fromResponse({int? statusCode, Object? body}) {
    return ApiException(
      message: _messageFromBody(body) ?? 'HTTP $statusCode',
      statusCode: statusCode,
      kind: ApiExceptionKind.response,
    );
  }

  /// The request never produced a response (no connectivity, DNS, timeout).
  const ApiException.network(this.message)
    : statusCode = null,
      kind = ApiExceptionKind.network;

  /// A response arrived but its shape is not the expected contract.
  const ApiException.malformed(this.message)
    : statusCode = null,
      kind = ApiExceptionKind.malformed;

  final String message;

  /// HTTP status code, or `null` when the request never reached the backend.
  final int? statusCode;

  /// The category of failure, used to pick a user-facing message.
  final ApiExceptionKind kind;

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
  String toString() => 'ApiException(${statusCode ?? 'no response'}): $message';
}
