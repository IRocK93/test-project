import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_client.dart';
import '../core/constants/api_constants.dart';

/// Global API Client provider — the SINGLE source of truth for ApiClient across the app
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Refresh counter — bump this to force all tab screens to reload their data.
/// Incremented after BabyMon creation, deletion, or any state-changing operation.
final appRefreshProvider = StateProvider<int>((ref) => 0);