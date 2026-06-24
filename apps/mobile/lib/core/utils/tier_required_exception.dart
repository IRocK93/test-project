/// Thrown when a feature requires a PREMIUM subscription.
///
/// The API returns HTTP 402 with code UPGRADE_REQUIRED. Catch this
/// exception in UI screens to show an upgrade prompt instead of an
/// error state.
class TierRequiredException implements Exception {
  final String message;

  const TierRequiredException([this.message = 'Premium tier required']);

  @override
  String toString() => 'TierRequiredException: $message';
}
