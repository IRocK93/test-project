import 'dart:collection';
import 'package:dio/dio.dart';

/// Lightweight in-memory LRU cache for API GET responses.
///
/// Cached entries expire after [_ttl] (5 minutes by default). When the cache
/// exceeds [_maxEntries], the least-recently-used entry is evicted.
///
/// Mutations (POST/PATCH/DELETE/PUT) invalidate related GET caches via
/// path-segment matching rather than arbitrary substring matching.
class ResponseCache {
  static const _defaultTtl = Duration(minutes: 5);
  static const _defaultMaxEntries = 200;

  final Duration _ttl;
  final int _maxEntries;
  final LinkedHashMap<String, _CacheEntry> _cache = LinkedHashMap();

  ResponseCache({
    Duration ttl = _defaultTtl,
    int maxEntries = _defaultMaxEntries,
  })  : _ttl = ttl,
        _maxEntries = maxEntries;

  /// Number of entries currently in the cache.
  int get length => _cache.length;

  /// Returns a cached [Response] for [key] if one exists and hasn't expired.
  /// Accessing an entry marks it as recently used (LRU promotion).
  Response? get(String key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _ttl) {
      return null; // expired — don't reinsert
    }
    // Re-insert at end to mark as recently used
    _cache[key] = entry;
    return entry.response;
  }

  /// Stores [response] in the cache keyed by [key].
  /// Evicts the least-recently-used entry if at capacity.
  void set(String key, Response response) {
    // Remove if already present (re-insert to promote)
    _cache.remove(key);
    while (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = _CacheEntry(response: response, timestamp: DateTime.now());
  }

  /// Invalidates cache entries whose keys contain [path] as a URL path
  /// segment. This uses `/path` boundaries rather than arbitrary substring
  /// matching to avoid false positives.
  ///
  /// For example, invalidating `/baby-mons/abc123` will match:
  /// - `/baby-mons/abc123`
  /// - `/baby-mons/abc123/milestones`
  /// - `/baby-mons/abc123/dashboard`
  ///
  /// But will NOT match:
  /// - `/baby-mons/abc123456` (different UUID)
  void invalidatePath(String path) {
    final normalized = path.endsWith('/') ? path.substring(0, path.length - 1) : path;
    _cache.removeWhere((key, _) {
      return key == normalized ||
             key.startsWith('$normalized/') ||
             key.startsWith('$normalized|'); // locale-suffixed cache keys
    });
  }

  /// Removes all cache entries whose key contains [pattern] as a substring.
  /// Prefer [invalidatePath] for URL-based invalidation — this method is kept
  /// for backward compatibility with broader invalidation needs.
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
