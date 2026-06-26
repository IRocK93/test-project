import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import '../../core/constants/api_constants.dart';
import 'response_cache.dart';
import 'retry_interceptor.dart';
import 'backoff_interceptor.dart';
import 'locale_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  /// Exposed for services that need Dio directly (e.g. streaming downloads).
  Dio get dio => _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ResponseCache _cache = ResponseCache();

  /// Optional [HttpClientAdapter] for testing — allows injecting a mock adapter.
  /// When null, Dio uses the platform default (IOHttpClientAdapter).
  ApiClient({HttpClientAdapter? adapter}) {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
    }
    _dio = dio;

    // ── API versioning: transparently upgrade /api/ → /api/v1/ ──
    const v1 = '/api/v1';
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final path = options.path;
        if (path.startsWith('/api/') && !path.startsWith('$v1/')) {
          options.path = path.replaceFirst('/api/', '$v1/');
        }
        return handler.next(options);
      },
    ));

		    _dio.interceptors.add(InterceptorsWrapper(
	      onRequest: (options, handler) async {
	        final token = await _storage.read(key: StorageKeys.accessToken);
	        if (token != null) {
	          options.headers['Authorization'] = 'Bearer $token';
	        }
	        // Serve from cache for GET requests (skip if forceRefresh is set)
	        if (options.method.toUpperCase() == 'GET') {
	          final forceRefresh = options.extra['forceRefresh'] == true;
	          if (!forceRefresh) {
	            final cacheKey = _buildCacheKey(options.path, options.queryParameters);
	            final cached = _cache.get(cacheKey);
	            if (cached != null) {
	              return handler.resolve(cached);
	            }
	          }
	        }
	        return handler.next(options);
	      },
	      onResponse: (response, handler) {
	        final method = response.requestOptions.method.toUpperCase();
	        // Cache successful GET responses
	        if (method == 'GET') {
	          final cacheKey = _buildCacheKey(response.requestOptions.path, response.requestOptions.queryParameters);
	          _cache.set(cacheKey, response);
	        }
	        // Invalidate related GET caches on successful mutations
	        if (method == 'POST' || method == 'PATCH' || method == 'DELETE' || method == 'PUT') {
	          final url = response.requestOptions.path;
	          // Strip /api prefix and action suffixes (with preceding UUID), keep resource UUIDs intact
	          // so the pattern matches GET cache keys. Normalize trailing slashes.
          final resource = url
              .replaceAll(RegExp(r'^/api(/v1)?'), '')
              .replaceAll(RegExp(r'/[a-f0-9-]{36}/(achieve|complete|cure|reactivate|clear-all|respond|bookmark|rate|invite|sync)$'), '')
              .replaceAll(RegExp(r'/routine/[^/]+/complete$'), '/routine')
              .replaceAll(RegExp(r'/(achieve|complete|cure|reactivate|clear-all|respond|bookmark|rate|invite|sync)$'), '')
              .replaceAll(RegExp(r'/[a-f0-9-]{36}$'), '')   // strip trailing UUID for single-resource mutations
              .replaceAll(RegExp(r'/+$'), '');
          _cache.invalidatePattern(resource);
          // Also invalidate the parent baby-mon dashboard — mutations on any
          // sub-resource (milestones, feed-logs, etc.) should refresh counts.
          final parentMatch = RegExp(r'^(/baby-mons/[a-f0-9-]+)').firstMatch(resource);
          if (parentMatch != null) {
            _cache.invalidatePattern(parentMatch.group(1)!);
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // Mutations that return errors (e.g., 409 badge conflict) still changed
        // server state — invalidate cache so subsequent GETs see fresh data.
        final method = error.requestOptions.method.toUpperCase();
        if (method == 'POST' || method == 'PATCH' || method == 'DELETE' || method == 'PUT') {
          final url = error.requestOptions.path;
          final resource = url
              .replaceAll(RegExp(r'^/api(/v1)?'), '')
              .replaceAll(RegExp(r'/[a-f0-9-]{36}/(achieve|complete|cure|reactivate|clear-all|respond|bookmark|rate|invite|sync)$'), '')
              .replaceAll(RegExp(r'/routine/[^/]+/complete$'), '/routine')
              .replaceAll(RegExp(r'/(achieve|complete|cure|reactivate|clear-all|respond|bookmark|rate|invite|sync)$'), '')
              .replaceAll(RegExp(r'/[a-f0-9-]{36}$'), '')
              .replaceAll(RegExp(r'/+$'), '');
          _cache.invalidatePattern(resource);
          final parentMatch = RegExp(r'^(/baby-mons/[a-f0-9-]+)').firstMatch(resource);
          if (parentMatch != null) {
            _cache.invalidatePattern(parentMatch.group(1)!);
          }
        }
        return handler.next(error);
      },
    ));

    _dio.interceptors.add(LocaleInterceptor());
    _dio.interceptors.add(BackoffInterceptor());
    _dio.interceptors.add(RetryInterceptor(
      storage: _storage,
      dio: _dio,
      refreshToken: _refreshToken,
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return false;

	      final refreshDio = Dio();
	      refreshDio.httpClientAdapter = _dio.httpClientAdapter;
	      final response = await refreshDio.post<dynamic>(
	        '${ApiConstants.baseUrl}/api/v1${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: StorageKeys.accessToken, value: parseString(response.data['accessToken']));
        await _storage.write(key: StorageKeys.refreshToken, value: parseString(response.data['refreshToken']));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Auth
  Future<Response> register(String email, String password, String? name) async {
    return _dio.post('/api${ApiConstants.register}', data: {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Response> login(String email, String password) async {
    return _dio.post('/api${ApiConstants.login}', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getProfile() async {
    return _dio.get('/api/users/me');
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/api${ApiConstants.logout}');
    } catch (e) { 
      // ignore: avoid_print
      print('Logout API call failed (non-critical): $e'); 
    }
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.selectedBabyMonId);
  }

  // BabyMons
  Future<Response> getBabyMons() async {
    return _dio.get('/api${ApiConstants.babyMons}');
  }

  Future<Response> getBabyMon(String id) async {
    return _dio.get('/api${ApiConstants.babyMons}/$id');
  }

  Future<Response> createBabyMon(Map<String, dynamic> data) async {
    // Explicitly add auth token header (bypasses any interceptor issues)
    final token = await _storage.read(key: StorageKeys.accessToken);
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;
    return _dio.post('/api${ApiConstants.babyMons}', data: data, options: options);
  }

  Future<Response> updateBabyMon(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api${ApiConstants.babyMons}/$id', data: data);
  }

  Future<Response> deleteBabyMon(String id) async {
    return _dio.delete('/api${ApiConstants.babyMons}/$id');
  }

  Future<Response> getBabyMonStage(String id) async {
    return _dio.get('/api${ApiConstants.babyMons}/$id/stage');
  }

  // Milestones
  Future<Response> getMilestones(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/milestones',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createMilestone(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/milestones', data: data);
  }

  Future<Response> updateMilestone(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/milestones/$id', data: data);
  }

  Future<Response> deleteMilestone(String id) async {
    return _dio.delete('/api/milestones/$id');
  }

  // Feed Logs
  Future<Response> getFeedLogs(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/feed-logs',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createFeedLog(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/feed-logs', data: data);
  }

  Future<Response> updateFeedLog(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/feed-logs/$id', data: data);
  }

  Future<Response> deleteFeedLog(String id) async {
    return _dio.delete('/api/feed-logs/$id');
  }

  // Health Records
  Future<Response> getHealthRecords(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/health-records',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createHealthRecord(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/health-records', data: data);
  }

  Future<Response> updateHealthRecord(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/health-records/$id', data: data);
  }

  Future<Response> deleteHealthRecord(String id) async {
    return _dio.delete('/api/health-records/$id');
  }

  // Badges
  Future<Response> getBadges(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/badges');
  }

  Future<Response> getBadgeDefinitions() async {
    return _dio.get('/api/badges/definitions');
  }

  // Allergies (event-based tracking)
  Future<Response> getAllergies(String babyMonId) async => _dio.get('/api/baby-mons/$babyMonId/allergies');
  Future<Response> createAllergy(String babyMonId, Map<String, dynamic> data) async => _dio.post('/api/baby-mons/$babyMonId/allergies', data: data);
  Future<Response> addAllergyEvent(String babyMonId, String allergyId, Map<String, dynamic> data) async => _dio.post('/api/baby-mons/$babyMonId/allergies/$allergyId/events', data: data);
  Future<Response> deleteAllergyEvent(String babyMonId, String eventId) async => _dio.delete('/api/baby-mons/$babyMonId/allergies/events/$eventId');
  Future<Response> cureAllergy(String babyMonId, String allergyId) async => _dio.post('/api/baby-mons/$babyMonId/allergies/$allergyId/cure');
  Future<Response> reactivateAllergy(String babyMonId, String allergyId) async => _dio.post('/api/baby-mons/$babyMonId/allergies/$allergyId/reactivate');
  Future<Response> clearAllAllergies(String babyMonId) async => _dio.post('/api/baby-mons/$babyMonId/allergies/clear-all');
  Future<Response> clearAllAllergyEvents(String babyMonId) async => _dio.post('/api/baby-mons/$babyMonId/allergies/events/clear-all');
  Future<Response> deleteAllergy(String babyMonId, String allergyId) async => _dio.delete('/api/baby-mons/$babyMonId/allergies/$allergyId');

  // Medical Team (dedicated table)
  Future<Response> getMedicalTeam(String babyMonId) async => _dio.get('/api/baby-mons/$babyMonId/medical-team');
  Future<Response> createMedicalTeamMember(String babyMonId, Map<String, dynamic> data) async => _dio.post('/api/baby-mons/$babyMonId/medical-team', data: data);
  Future<Response> deleteMedicalTeamMember(String babyMonId, String memberId) async => _dio.delete('/api/baby-mons/$babyMonId/medical-team/$memberId');

  // Evolution
  Future<Response> getEvolution(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/evolution',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  // ── Dashboard Aggregation (collapses 8+ requests into 1) ──
  Future<Response> getDashboard(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/dashboard',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  // Journal
  Future<Response> getJournal(String babyMonId, {String? type}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/journal', queryParameters: type != null ? {'type': type} : null);
  }

  Future<Response> getProposals(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/journal/proposals');
  }

  Future<Response> respondToProposal(String babyMonId, String proposalId, bool accept, String? reason) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/journal/proposals/$proposalId/respond', data: {
      'accept': accept,
      'reason': reason,
    });
  }

  // Export
  Future<Response> exportBabyMon(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/export');
  }

  // Subscription
  Future<Response> getSubscription() async {
    return _dio.get('/api${ApiConstants.subscription}');
  }

  Future<Response> devOverrideTrial(int days) async {
    return _dio.post('/api${ApiConstants.devOverride}', data: {'days': days});
  }

  Future<Response> validatePromoCode(String code) async {
    return _dio.post('/api${ApiConstants.validatePromo}', data: {'code': code});
  }

  Future<Response> redeemPromoCode(String code) async {
    return _dio.post('/api${ApiConstants.redeemPromo}', data: {'code': code});
  }

  // Growth Records
  /// Fetches all growth records for a BabyMon, optionally filtered by metric type
  Future<Response> getGrowthRecords(String babyMonId, {String? type, bool forceRefresh = false}) async {
    return _dio.get(
      '/api${ApiConstants.babyMons}/$babyMonId/growth',
      queryParameters: type != null ? {'type': type} : null,
      options: Options(extra: {'forceRefresh': forceRefresh}),
    );
  }

  /// Creates a new growth measurement record
  Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/growth', data: data);
  }

  /// Updates an existing growth measurement record
  Future<Response> updateGrowthRecord(String babyMonId, String recordId, Map<String, dynamic> data) async {
    return _dio.patch('/api${ApiConstants.babyMons}/$babyMonId/growth/$recordId', data: data);
  }

  /// Deletes a growth measurement record by ID
  Future<Response> deleteGrowthRecord(String babyMonId, String recordId) async {
    return _dio.delete('/api${ApiConstants.babyMons}/$babyMonId/growth/$recordId');
  }

  // Partners
  /// Invites a user by email to become a partner/co-parent for a BabyMon
  Future<Response> invitePartner(String babyMonId, String email, String role) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/partners/invite', data: {'email': email, 'role': role});
  }

  /// Lists all partners for a BabyMon with their status and user details
  Future<Response> getPartners(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/partners');
  }

  /// Respond to a partner invitation (ACCEPTED or DECLINED)
  Future<Response> respondToInvitation(String partnerId, String status) async {
    return _dio.patch('/api${ApiConstants.babyMons}/$partnerId/respond', data: {'status': status});
  }

  /// Removes a partner (or cancels an invitation) from a BabyMon
  Future<Response> removePartner(String babyMonId, String partnerId) async {
    return _dio.delete('/api${ApiConstants.babyMons}/$babyMonId/partners/$partnerId');
  }

  // Photos
  /// Uploads a photo (base64) for a BabyMon via Cloudinary
  Future<Response> uploadPhoto(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/photos', data: data);
  }

  /// Lists all photos for a BabyMon ordered by date
  Future<Response> getPhotos(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/photos');
  }

  /// Deletes a photo by ID (also removes from Cloudinary)
  Future<Response> deletePhoto(String id) async {
    return _dio.delete('/api${ApiConstants.babyMons}/photos/$id');
  }

  // Sleep Logs
  /// Fetches all sleep logs for a BabyMon, ordered by startTime descending
  Future<Response> getSleepLogs(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/sleep-logs',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  /// Creates a new sleep log entry
  Future<Response> createSleepLog(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/sleep-logs', data: data);
  }

  /// Updates an existing sleep log entry
  Future<Response> updateSleepLog(String babyMonId, String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/sleep-logs/$id', data: data);
  }

  /// Deletes a sleep log entry by ID
  Future<Response> deleteSleepLog(String babyMonId, String id) async {
    return _dio.delete('/api/sleep-logs/$id');
  }

  // Stage Content
  Future<Response> getStageContent(String stageKey) async {
    return _dio.get('/api/stage-content/$stageKey');
  }

  Future<Response> getStageContentForBabyMon(String babyMonId) async {
    return _dio.get('/api/stage-content/baby-mon/$babyMonId');
  }

  // Storage
  Future<void> saveTokens(String accessToken, String refreshToken, String userId, {String? userEmail}) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _storage.write(key: StorageKeys.userId, value: userId);
    if (userEmail != null) {
      await _storage.write(key: StorageKeys.userEmail, value: userEmail);
    }
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: StorageKeys.userId);
  }

  Future<String?> getUserEmail() async {
    return _storage.read(key: StorageKeys.userEmail);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);
    await _storage.delete(key: StorageKeys.userId);
    await _storage.delete(key: StorageKeys.userEmail);
  }

  Future<void> setSelectedBabyMonId(String? id) async {
    if (id == null || id.isEmpty) {
      await _storage.delete(key: StorageKeys.selectedBabyMonId);
    } else {
      await _storage.write(key: StorageKeys.selectedBabyMonId, value: id);
    }
  }

  Future<String?> getSelectedBabyMonId() async {
    final id = await _storage.read(key: StorageKeys.selectedBabyMonId);
    // Treat empty string as null (legacy bug where '' was stored instead of deleting the key)
    if (id == null || id.isEmpty) return null;
    return id;
  }

  // Trial override for testing
  Future<void> setTrialOverride(int days) async {
    await _storage.write(key: StorageKeys.trialOverride, value: days.toString());
  }

  Future<int?> getTrialOverride() async {
    final value = await _storage.read(key: StorageKeys.trialOverride);
    return value != null ? int.tryParse(value) : null;
  }

  // Generic HTTP methods for flexibility
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final fullPath = _resolvePath(path);
    return _dio.post(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    final fullPath = _resolvePath(path);
    // Build cache key including query params
    final cacheKey = queryParameters != null && queryParameters.isNotEmpty
        ? '$fullPath?${queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : fullPath;
    if (!forceRefresh) {
      final cached = _cache.get(cacheKey);
      if (cached != null) return cached;
    }
    final response = await _dio.get(
      fullPath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    _cache.set(cacheKey, response);
    return response;
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final fullPath = _resolvePath(path);
    return _dio.patch(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final fullPath = _resolvePath(path);
    return _dio.put(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final fullPath = _resolvePath(path);
    return _dio.delete(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  String _buildCacheKey(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return path;
    final params = queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return '$path?$params';
  }

  String _resolvePath(String path) {
    // Ensure the path has /api prefix — versioning interceptor handles /v1
    if (path.startsWith('/api/')) return path;
    if (path.startsWith('/')) return '/api$path';
    return '/api/$path';
  }
}
