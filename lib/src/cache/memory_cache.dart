/// A single entry in the memory cache.
class CacheEntry<T> {
  /// The cached value.
  final T value;

  /// The datetime when this entry should expire.
  final DateTime expiresAt;

  /// Creates a [CacheEntry].
  CacheEntry(this.value, this.expiresAt);

  /// Checks if the entry has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// A rudimentary in-memory cache supporting TTL and max size (LRU).
class MemoryCache {
  /// The maximum number of items to keep in cache.
  final int maxSize;

  /// The default time-to-live for a cached entry.
  final Duration defaultTtl;

  /// Determines if caching is currently enabled.
  final bool enabled;

  final Map<String, CacheEntry<dynamic>> _store = {};

  /// Creates a [MemoryCache].
  MemoryCache({
    this.maxSize = 100,
    this.defaultTtl = const Duration(minutes: 10),
    this.enabled = true,
  });

  /// Retrieves a value from the cache by [key].
  T? get<T>(String key) {
    if (!enabled) {
      return null;
    }
    final entry = _store[key];
    if (entry == null) {
      return null;
    }

    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }

    // Move to end (recently used)
    _store.remove(key);
    _store[key] = entry;

    return entry.value as T?;
  }

  /// Sets a [value] in the cache under [key].
  void set<T>(String key, T value, {Duration? ttl}) {
    if (!enabled) {
      return;
    }

    if (_store.length >= maxSize) {
      // Remove oldest (first item in LinkedHashMap)
      _store.remove(_store.keys.first);
    }

    _store[key] = CacheEntry(value, DateTime.now().add(ttl ?? defaultTtl));
  }
}
