import 'dart:async';

/// A utility to throttle API requests based on rate limits.
///
/// Helps maintain compliance with the PAAPI 5 rate limits, which specify
/// max requests per second and max requests per minute based on account performance.
class RateLimiter {
  /// Maximum allowed requests per second.
  final int maxRequestsPerSecond;

  /// Maximum allowed requests per minute.
  final int maxRequestsPerMinute;

  final List<DateTime> _history = [];

  /// Creates a [RateLimiter].
  RateLimiter({
    this.maxRequestsPerSecond = 1,
    this.maxRequestsPerMinute = 60,
  });

  /// Asynchronously waits until a request is allowed to proceed.
  Future<void> acquire() async {
    while (true) {
      final now = DateTime.now();
      _cleanup(now);

      if (_history.length < maxRequestsPerMinute) {
        final recentCount =
            _history.where((t) => now.difference(t).inSeconds < 1).length;
        if (recentCount < maxRequestsPerSecond) {
          _history.add(now);
          return;
        } else {
          // Wait briefly before trying again to satisfy the per-second limit
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      } else {
        // Wait longer to satisfy the per-minute limit
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
  }

  void _cleanup(DateTime now) {
    _history.removeWhere((t) => now.difference(t).inSeconds >= 60);
  }
}
