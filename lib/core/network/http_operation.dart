/// {@template http_method}
/// HTTP Method such as GET or PUT.
/// {@endtemplate}
enum HttpOperation {
  /// DELETE HTTP Method
  delete('DELETE'),

  /// GET HTTP Method
  get('GET'),

  /// HEAD HTTP Method
  head('HEAD'),

  /// OPTIONS HTTP Method
  options('OPTIONS'),

  /// PATCH HTTP Method
  patch('PATCH'),

  /// POST HTTP Method
  post('POST'),

  /// PUT HTTP Method
  put('PUT');

  /// {@macro http_method}
  const HttpOperation(this.value);

  /// The HTTP method value as a string.
  final String value;
}
