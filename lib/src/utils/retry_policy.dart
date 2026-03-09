import 'dart:async';

/// Defines how failures should be retried automatically.
class RetryPolicy {
  /// The maximum number of retry attempts.
  final int maxRetries;

  /// The delay before the first retry. Subsequent retries use exponential backoff.
  final Duration initialDelay;

  /// Creates a [RetryPolicy] using exponential backoff.
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
  });

  /// Executes an [action], retrying it if [shouldRetry] returns true.
  Future<T> execute<T>(
    Future<T> Function() action,
    bool Function(Exception) shouldRetry,
  ) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } on Exception catch (e) {
        if (!shouldRetry(e) || attempt >= maxRetries) {
          rethrow;
        }
        final delay = initialDelay * (1 << attempt);
        await Future<void>.delayed(delay);
        attempt++;
      }
    }
  }
}
