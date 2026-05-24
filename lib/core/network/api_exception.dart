class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  final String message;
  final int? statusCode;
  final Object? responseBody;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$status: $message';
  }
}
