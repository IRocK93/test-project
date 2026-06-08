import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isRefreshing = false;
  final List<Function(String)> _pendingRetries = [];

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: StorageKeys.accessToken);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Don't try to refresh token for auth endpoints
          final path = error.requestOptions.path;
          if (path.contains('/auth/login') || path.contains('/auth/register') || path.contains('/auth/refresh')) {
            return handler.next(error);
          }
          // Queue this request to retry after token refresh
          _pendingRetries.add((newToken) async {
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
          });
          // Only trigger refresh once
          if (!_isRefreshing) {
            _isRefreshing = true;
            final success = await _refreshToken();
            final newToken = await _storage.read(key: StorageKeys.accessToken);
            // Retry all queued requests with the new token
            final retries = List<Function(String)>.from(_pendingRetries);
            _pendingRetries.clear();
            for (final retry in retries) {
              if (success && newToken != null) {
                retry(newToken);
              }
            }
            _isRefreshing = false;
          }
          return;
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}/api${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(key: StorageKeys.accessToken, value: response.data['accessToken']);
        await _storage.write(key: StorageKeys.refreshToken, value: response.data['refreshToken']);
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
    return _dio.get('/api${ApiConstants.profile}');
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api${ApiConstants.logout}');
    } catch (_) {}
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
  Future<Response> getMilestones(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/milestones');
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
  Future<Response> getFeedLogs(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/feed-logs');
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
  Future<Response> getHealthRecords(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/health-records');
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
  Future<Response> getEvolution(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/evolution');
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

  // Growth Records
  /// Fetches all growth records for a BabyMon, optionally filtered by metric type
  Future<Response> getGrowthRecords(String babyMonId, {String? type}) async {
    return _dio.get(
      '/api${ApiConstants.babyMons}/$babyMonId/growth',
      queryParameters: type != null ? {'type': type} : null,
    );
  }

  /// Creates a new growth measurement record
  Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) async {
    return _dio.post('/api${ApiConstants.babyMons}/$babyMonId/growth', data: data);
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

  /// Removes a partner from a BabyMon
  Future<Response> removePartner(String partnerId) async {
    return _dio.delete('/api${ApiConstants.babyMons}/$partnerId');
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
  Future<Response> getSleepLogs(String babyMonId) async {
    return _dio.get('/api${ApiConstants.babyMons}/$babyMonId/sleep-logs');
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
  }) async {
    // Always prepend /api for paths that start with / (backend global prefix)
    final fullPath = path.startsWith('/api/') ? path : (path.startsWith('/') ? '/api$path' : '/api/$path');
    return _dio.post(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = path.startsWith('/api/') ? path : (path.startsWith('/') ? '/api$path' : '/api/$path');
    return _dio.get(
      fullPath,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = path.startsWith('/api/') ? path : (path.startsWith('/') ? '/api$path' : '/api/$path');
    return _dio.patch(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = path.startsWith('/api/') ? path : (path.startsWith('/') ? '/api$path' : '/api/$path');
    return _dio.put(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = path.startsWith('/api/') ? path : (path.startsWith('/') ? '/api$path' : '/api/$path');
    return _dio.delete(
      fullPath,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
