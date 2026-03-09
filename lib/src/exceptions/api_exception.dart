/// Represents an Exception thrown by the PAAPI 5 Client.
class PaapiException implements Exception {
  /// The HTTP status code returned by the API (e.g. 429, 400).
  final int statusCode;

  /// The error code string returned by the PAAPI (e.g. 'InvalidParameterValue').
  final String errorCode;

  /// A descriptive message for the error.
  final String message;

  /// The AWS request ID associated with the error.
  final String? requestId;

  /// Creates a [PaapiException].
  const PaapiException({
    required this.statusCode,
    required this.errorCode,
    required this.message,
    this.requestId,
  });

  @override
  String toString() {
    return 'PaapiException(statusCode: $statusCode, errorCode: $errorCode, message: $message, requestId: $requestId)';
  }
}
