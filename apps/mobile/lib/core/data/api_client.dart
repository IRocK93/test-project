import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:baby_mon/core/utils/json_utils.dart';
import '../../core/constants/api_constants.dart';
import 'response_cache.dart';
import 'retry_interceptor.dart';

class ApiClient {
  late final Dio _dio;
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
	          final resource = url.replaceAll(RegExp(r'/api/v1'), '').replaceAll(RegExp(r'/[a-f0-9-]{36}'), '');
	          _cache.invalidatePattern(resource);
	        }
	        return handler.next(response);
	      },
	    ));

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
    return _dio.post('/api/v1${ApiConstants.register}', data: {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Response> login(String email, String password) async {
    return _dio.post('/api/v1${ApiConstants.login}', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getProfile() async {
    return _dio.get('/api/v1/users/me');
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>('/api/v1${ApiConstants.logout}');
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
    return _dio.get('/api/v1${ApiConstants.babyMons}');
  }

  Future<Response> getBabyMon(String id) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$id');
  }

  Future<Response> createBabyMon(Map<String, dynamic> data) async {
    // Explicitly add auth token header (bypasses any interceptor issues)
    final token = await _storage.read(key: StorageKeys.accessToken);
    final options = token != null
        ? Options(headers: {'Authorization': 'Bearer $token'})
        : null;
    return _dio.post('/api/v1${ApiConstants.babyMons}', data: data, options: options);
  }

  Future<Response> updateBabyMon(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1${ApiConstants.babyMons}/$id', data: data);
  }

  Future<Response> deleteBabyMon(String id) async {
    return _dio.delete('/api/v1${ApiConstants.babyMons}/$id');
  }

  Future<Response> getBabyMonStage(String id) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$id/stage');
  }

  // Milestones
  Future<Response> getMilestones(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/milestones',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createMilestone(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/milestones', data: data);
  }

  Future<Response> updateMilestone(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1/milestones/$id', data: data);
  }

  Future<Response> deleteMilestone(String id) async {
    return _dio.delete('/api/v1/milestones/$id');
  }

  // Feed Logs
  Future<Response> getFeedLogs(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/feed-logs',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createFeedLog(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/feed-logs', data: data);
  }

  Future<Response> updateFeedLog(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1/feed-logs/$id', data: data);
  }

  Future<Response> deleteFeedLog(String id) async {
    return _dio.delete('/api/v1/feed-logs/$id');
  }

  // Health Records
  Future<Response> getHealthRecords(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/health-records',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  Future<Response> createHealthRecord(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/health-records', data: data);
  }

  Future<Response> updateHealthRecord(String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1/health-records/$id', data: data);
  }

  Future<Response> deleteHealthRecord(String id) async {
    return _dio.delete('/api/v1/health-records/$id');
  }

  // Badges
  Future<Response> getBadges(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/badges');
  }

  Future<Response> getBadgeDefinitions() async {
    return _dio.get('/api/v1/badges/definitions');
  }

  // Allergies (event-based tracking)
  Future<Response> getAllergies(String babyMonId) async => _dio.get('/api/v1/baby-mons/$babyMonId/allergies');
  Future<Response> createAllergy(String babyMonId, Map<String, dynamic> data) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies', data: data);
  Future<Response> addAllergyEvent(String babyMonId, String allergyId, Map<String, dynamic> data) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies/$allergyId/events', data: data);
  Future<Response> deleteAllergyEvent(String babyMonId, String eventId) async => _dio.delete('/api/v1/baby-mons/$babyMonId/allergies/events/$eventId');
  Future<Response> cureAllergy(String babyMonId, String allergyId) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies/$allergyId/cure');
  Future<Response> reactivateAllergy(String babyMonId, String allergyId) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies/$allergyId/reactivate');
  Future<Response> clearAllAllergies(String babyMonId) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies/clear-all');
  Future<Response> clearAllAllergyEvents(String babyMonId) async => _dio.post('/api/v1/baby-mons/$babyMonId/allergies/events/clear-all');
  Future<Response> deleteAllergy(String babyMonId, String allergyId) async => _dio.delete('/api/v1/baby-mons/$babyMonId/allergies/$allergyId');

  // Medical Team (dedicated table)
  Future<Response> getMedicalTeam(String babyMonId) async => _dio.get('/api/v1/baby-mons/$babyMonId/medical-team');
  Future<Response> createMedicalTeamMember(String babyMonId, Map<String, dynamic> data) async => _dio.post('/api/v1/baby-mons/$babyMonId/medical-team', data: data);
  Future<Response> deleteMedicalTeamMember(String babyMonId, String memberId) async => _dio.delete('/api/v1/baby-mons/$babyMonId/medical-team/$memberId');

  // Evolution
  Future<Response> getEvolution(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/evolution');
  }

  // Journal
  Future<Response> getJournal(String babyMonId, {String? type}) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/journal', queryParameters: type != null ? {'type': type} : null);
  }

  Future<Response> getProposals(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/journal/proposals');
  }

  Future<Response> respondToProposal(String babyMonId, String proposalId, bool accept, String? reason) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/journal/proposals/$proposalId/respond', data: {
      'accept': accept,
      'reason': reason,
    });
  }

  // Export
  Future<Response> exportBabyMon(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/export');
  }

  // Subscription
  Future<Response> getSubscription() async {
    return _dio.get('/api/v1${ApiConstants.subscription}');
  }

  Future<Response> devOverrideTrial(int days) async {
    return _dio.post('/api/v1${ApiConstants.devOverride}', data: {'days': days});
  }

  // Growth Records
  /// Fetches all growth records for a BabyMon, optionally filtered by metric type
  Future<Response> getGrowthRecords(String babyMonId, {String? type, bool forceRefresh = false}) async {
    return _dio.get(
      '/api/v1${ApiConstants.babyMons}/$babyMonId/growth',
      queryParameters: type != null ? {'type': type} : null,
      options: Options(extra: {'forceRefresh': forceRefresh}),
    );
  }

  /// Creates a new growth measurement record
  Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/growth', data: data);
  }

  /// Updates an existing growth measurement record
  Future<Response> updateGrowthRecord(String babyMonId, String recordId, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1${ApiConstants.babyMons}/$babyMonId/growth/$recordId', data: data);
  }

  /// Deletes a growth measurement record by ID
  Future<Response> deleteGrowthRecord(String babyMonId, String recordId) async {
    return _dio.delete('/api/v1${ApiConstants.babyMons}/$babyMonId/growth/$recordId');
  }

  // Partners
  /// Invites a user by email to become a partner/co-parent for a BabyMon
  Future<Response> invitePartner(String babyMonId, String email, String role) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/partners/invite', data: {'email': email, 'role': role});
  }

  /// Lists all partners for a BabyMon with their status and user details
  Future<Response> getPartners(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/partners');
  }

  /// Respond to a partner invitation (ACCEPTED or DECLINED)
  Future<Response> respondToInvitation(String partnerId, String status) async {
    return _dio.patch('/api/v1${ApiConstants.babyMons}/$partnerId/respond', data: {'status': status});
  }

  /// Removes a partner (or cancels an invitation) from a BabyMon
  Future<Response> removePartner(String babyMonId, String partnerId) async {
    return _dio.delete('/api/v1${ApiConstants.babyMons}/$babyMonId/partners/$partnerId');
  }

  // Photos
  /// Uploads a photo (base64) for a BabyMon via Cloudinary
  Future<Response> uploadPhoto(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/photos', data: data);
  }

  /// Lists all photos for a BabyMon ordered by date
  Future<Response> getPhotos(String babyMonId) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/photos');
  }

  /// Deletes a photo by ID (also removes from Cloudinary)
  Future<Response> deletePhoto(String id) async {
    return _dio.delete('/api/v1${ApiConstants.babyMons}/photos/$id');
  }

  // Sleep Logs
  /// Fetches all sleep logs for a BabyMon, ordered by startTime descending
  Future<Response> getSleepLogs(String babyMonId, {bool forceRefresh = false}) async {
    return _dio.get('/api/v1${ApiConstants.babyMons}/$babyMonId/sleep-logs',
      options: Options(extra: {'forceRefresh': forceRefresh}));
  }

  /// Creates a new sleep log entry
  Future<Response> createSleepLog(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api/v1${ApiConstants.babyMons}/$babyMonId/sleep-logs', data: data);
  }

  /// Updates an existing sleep log entry
  Future<Response> updateSleepLog(String babyMonId, String id, Map<String, dynamic> data) async {
    return _dio.patch('/api/v1/sleep-logs/$id', data: data);
  }

  /// Deletes a sleep log entry by ID
  Future<Response> deleteSleepLog(String babyMonId, String id) async {
    return _dio.delete('/api/v1/sleep-logs/$id');
  }

  // Stage Content
  Future<Response> getStageContent(String stageKey) async {
    return _dio.get('/api/v1/stage-content/$stageKey');
  }

  // Storage
  Future<void> saveTokens(String accessToken, String refreshToken, String userId) async {
    await _storage.write(key: StorageKeys.accessToken, value: accessToken);
    await _storage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await _storage.write(key: StorageKeys.userId, value: userId);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: StorageKeys.accessToken);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: StorageKeys.userId);
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
    if (path.startsWith('/api/v1/')) return path;
    if (path.startsWith('/api/')) return path.replaceFirst('/api/', '/api/v1/');
    if (path.startsWith('/')) return '/api/v1$path';
    return '/api/v1/$path';
  }
}
