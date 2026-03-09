import 'package:flutter_test/flutter_test.dart';
import 'package:paapi5_flutter/paapi5_flutter.dart';

void main() {
  group('RateLimiter', () {
    test('allows requests within limit instantly', () async {
      final limiter = RateLimiter(
        maxRequestsPerSecond: 10,
        maxRequestsPerMinute: 60,
      );

      final start = DateTime.now();
      await limiter.acquire();
      await limiter.acquire();
      final elapsed = DateTime.now().difference(start);

      expect(elapsed.inMilliseconds, lessThan(50));
    });

    test('throttles requests over second limit', () async {
      final limiter = RateLimiter(
        maxRequestsPerSecond: 1,
        maxRequestsPerMinute: 60,
      );

      final start = DateTime.now();
      await limiter.acquire();
      await limiter.acquire();
      final elapsed = DateTime.now().difference(start);

      // Should have waited at least ~100ms and max ~1 second
      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(50));
    });
  });
}
