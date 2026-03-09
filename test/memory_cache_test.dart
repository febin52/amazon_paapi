import 'package:flutter_test/flutter_test.dart';
import 'package:amazon_paapi5/amazon_paapi5.dart';

void main() {
  group('MemoryCache', () {
    test('sets and gets values', () {
      final cache = MemoryCache();
      cache.set('key1', 'value1');
      expect(cache.get<String>('key1'), equals('value1'));
    });

    test('returns null for missing keys', () {
      final cache = MemoryCache();
      expect(cache.get<String>('missing'), isNull);
    });

    test('expires values after TTL', () async {
      final cache = MemoryCache();
      cache.set('key1', 'value1', ttl: const Duration(milliseconds: 10));
      expect(cache.get<String>('key1'), equals('value1'));

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cache.get<String>('key1'), isNull);
    });

    test('disables caching when disabled', () {
      final cache = MemoryCache(enabled: false);
      cache.set('key1', 'value1');
      expect(cache.get<String>('key1'), isNull);
    });
  });
}
