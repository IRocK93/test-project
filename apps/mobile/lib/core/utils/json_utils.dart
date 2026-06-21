// Safe JSON parsing helpers to replace bare `as Map<String, dynamic>` /
// `as List` casts on API response data throughout the codebase.
//
// Every function checks the runtime type first so that non-conforming
// data (null, wrong type, unexpected shape) produces a graceful fallback
// instead of a TypeError.
//
// Example:
//   // Before (unsafe)
//   final data = response.data as Map<String, dynamic>;
//
//   // After (safe)
//   final data = parseJsonMap(response.data);
//   if (data == null) return;

/// Safely interpret [value] as a JSON object (`Map<String, dynamic>`).
///
/// Returns `null` (not an empty map) because a caller that expects a full
/// object should know when the API returned something unexpected.  Use the
/// `??` operator if a default is needed:
/// ```dart
/// final data = parseJsonMap(raw) ?? <String, dynamic>{};
/// ```
Map<String, dynamic>? parseJsonMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

/// Safely interpret [value] as a JSON array of objects
/// (`List<Map<String, dynamic>>`).
///
/// Returns an empty list when [value] is not a `List`, so callers can
/// iterate safely without a null check:
/// ```dart
/// for (final item in parseJsonList(raw)) { … }
/// ```
///
/// Each element in the source list is converted through
/// [Map<String, dynamic>.from], so non-Map elements will still throw at
/// iteration time.  If element-level safety is needed, wrap the call in
/// `try/catch` or use [parseList] + [safeCast].
List<Map<String, dynamic>> parseJsonList(dynamic value) =>
    value is List
        ? List<Map<String, dynamic>>.from(value)
        : <Map<String, dynamic>>[];

/// Safely interpret [value] as a plain list (`List<dynamic>`).
///
/// Returns an empty list when [value] is not a `List`.  Unlike
/// [parseJsonList], this does not attempt to convert elements — the
/// caller retains full control over how each element is consumed.
List<dynamic> parseList(dynamic value) =>
    value is List ? value : <dynamic>[];

/// Safely cast [value] to type `T`, returning `null` if the cast fails.
///
/// Useful for extracting nullable-typed fields from maps without an
/// unsafe `as` cast:
/// ```dart
/// final name = safeCast<String>(data['name']) ?? 'unknown';
/// ```
T? safeCast<T>(dynamic value) => value is T ? value : null;

/// Safely extract a list of items from an API response that may return
/// either a bare array or a paginated envelope `{ items: [...] }`.
///
/// This is the most common pattern in the codebase and replaces:
/// ```dart
/// // Before
/// final items = (response.data is List)
///     ? response.data
///     : ((response.data as Map)['items'] as List?) ?? [];
///
/// // After
/// final items = parseItems(response.data);
/// ```
List<dynamic> parseItems(dynamic value) {
  if (value is List) return value;
  final map = parseJsonMap(value);
  return parseList(map?['items']);
}

/// Safely extract a non-null `String` from a dynamic [value].
///
/// Returns `null` when [value] is not a `String`, making it a safe
/// replacement for `value as String?`:
/// ```dart
/// final name = parseString(data['name']) ?? 'Unknown';
/// ```
String? parseString(dynamic value) => value is String ? value : null;

/// Safely extract a non-null `int` from a dynamic [value].
///
/// Returns `null` when [value] is not an `int`, making it a safe
/// replacement for `value as int?`:
/// ```dart
/// final xp = parseInt(data['xpValue']) ?? 10;
/// ```
int? parseInt(dynamic value) => value is int ? value : null;

/// Safely extract a non-null `double` from a dynamic [value].
///
/// Also accepts `int` values (widening conversion via [num.toDouble]).
/// Returns `null` when [value] is not a `num` at all:
/// ```dart
/// final ratio = parseDouble(data['value']) ?? 0.0;
/// ```
double? parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Safely extract a non-null `bool` from a dynamic [value].
///
/// Returns `null` when [value] is not a `bool`, making it a safe
/// replacement for `value as bool?`:
/// ```dart
/// final enabled = parseBool(data['isActive']) ?? false;
/// ```
bool? parseBool(dynamic value) => value is bool ? value : null;

/// Like [parseItems] but returns `List<Map<String, dynamic>>` with each
/// element typed-converted through [Map.from].
///
/// ```dart
/// final items = parseItemsTyped<Map<String, dynamic>>(response.data);
/// ```
///
/// Non-Map elements will throw at iteration time (same as [parseJsonList]).
List<Map<String, dynamic>> parseItemsTyped(dynamic value) {
  if (value is List) return parseJsonList(value);
  final map = parseJsonMap(value);
  return parseJsonList(map?['items']);
}
