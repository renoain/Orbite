enum FailureKind {
  network,
  timeout,
  badRequest,
  unauthorized,
  notFound,
  server,
  unknown,
}

class AppFailure implements Exception {
  const AppFailure(
    this.message, {
    this.kind = FailureKind.unknown,
    this.statusCode,
  });

  final String message;
  final FailureKind kind;
  final int? statusCode;

  @override
  String toString() =>
      'AppFailure(${kind.name}, status: $statusCode): $message';
}
