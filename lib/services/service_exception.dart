class ServiceException implements Exception {
  static const String errorCodeUnauthorized = 'unauthorized';
  static const String errorCodeInvalidSession = 'invalid session';
  static const String errorCodeUnknown = 'unknown';

  ServiceException({
    this.message,
    required this.code,
    this.reference,
  });

  final String? message;
  final String code;
  final String? reference;

  @override
  String toString() {
    return '$code > ${message ?? ""} ${reference ?? ""}';
  }
}
