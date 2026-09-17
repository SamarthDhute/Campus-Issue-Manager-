class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, String>? validationErrors;

  AppException({
    required this.message,
    this.statusCode,
    this.validationErrors,
  });

  @override
  String toString() => message;
}
