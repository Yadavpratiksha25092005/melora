class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;

  ApiException({required this.code, required this.message, this.statusCode});

  @override
  String toString() => "ApiException($code): $message";
}
