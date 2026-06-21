import 'package:dio/dio.dart';

/// Lightweight in-memory cache for API GET responses.
/// Cached entries expire after [_ttl] (5 minutes by default).
/// Mutations (POST/PATCH/DELETE) invalidate related GET caches.
class ResponseCache {
  static const _defaultTtl = Duration(minutes: 5);

  final Duration _ttl;
  final _cache = <String, _CacheEntry>{};

  ResponseCache({Duration ttl = _defaultTtl}) : _ttl = ttl;

  /// Returns a cached [Response] for [url] if one exists and hasn't expired.
  Response? get(String url) {
    final entry = _cache[url];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _ttl) {
      _cache.remove(url);
      return null;
    }
    return entry.response;
  }

  /// Stores [response] in the cache keyed by [url].
  void set(String url, Response response) {
    _cache[url] = _CacheEntry(response: response, timestamp: DateTime.now());
  }

  /// Removes all cache entries whose key contains [pattern].
  /// Use after mutations to invalidate related GET endpoints.
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  /// Removes all cached entries.
  void clear() {
    _cache.clear();
  }
}

class _CacheEntry {
  final Response response;
  final DateTime timestamp;

  const _CacheEntry({required this.response, required this.timestamp});
}
