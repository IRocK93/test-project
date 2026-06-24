import 'package:dio/dio.dart';
import 'package:baby_mon/core/data/api_client.dart';

/// A hand-written [ApiClient] mock for use in widget and unit tests.
///
/// Override individual stub fields to control behavior, or leave
/// defaults (all return empty data).
///
/// Usage:
/// ```dart
/// final mock = MockApiClient();
/// mock.stub.getMilestones = (id) async =>
///     successResponse([{'id': '1', 'title': 'First smile'}]);
/// ```
class MockApiClient implements ApiClient {
  final _stub = StubController();

  StubController get stub => _stub;

  // ── Auth ──
  @override Future<Response> register(String email, String password, String? name) =>
      _stub.register(email, password, name);
  @override Future<Response> login(String email, String password) =>
      _stub.login(email, password);
  @override Future<Response> getProfile() => _stub.getProfile();
  @override Future<void> logout() => _stub.logout();

  // ── BabyMons ──
  @override Future<Response> getBabyMons() => _stub.getBabyMons();
  @override Future<Response> getBabyMon(String id) => _stub.getBabyMon(id);
  @override Future<Response> createBabyMon(Map<String, dynamic> data) => _stub.createBabyMon(data);
  @override Future<Response> updateBabyMon(String id, Map<String, dynamic> data) =>
      _stub.updateBabyMon(id, data);
  @override Future<Response> deleteBabyMon(String id) => _stub.deleteBabyMon(id);
  @override Future<Response> getBabyMonStage(String id) => _stub.getBabyMonStage(id);

  // ── Milestones ──
  @override Future<Response> getMilestones(String babyMonId) => _stub.getMilestones(babyMonId);
  @override Future<Response> createMilestone(String babyMonId, Map<String, dynamic> data) =>
      _stub.createMilestone(babyMonId, data);
  @override Future<Response> updateMilestone(String id, Map<String, dynamic> data) =>
      _stub.updateMilestone(id, data);
  @override Future<Response> deleteMilestone(String id) => _stub.deleteMilestone(id);

  // ── Feed Logs ──
  @override Future<Response> getFeedLogs(String babyMonId) => _stub.getFeedLogs(babyMonId);
  @override Future<Response> createFeedLog(String babyMonId, Map<String, dynamic> data) =>
      _stub.createFeedLog(babyMonId, data);
  @override Future<Response> updateFeedLog(String id, Map<String, dynamic> data) =>
      _stub.updateFeedLog(id, data);
  @override Future<Response> deleteFeedLog(String id) => _stub.deleteFeedLog(id);

  // ── Health Records ──
  @override Future<Response> getHealthRecords(String babyMonId) => _stub.getHealthRecords(babyMonId);
  @override Future<Response> createHealthRecord(String babyMonId, Map<String, dynamic> data) =>
      _stub.createHealthRecord(babyMonId, data);
  @override Future<Response> updateHealthRecord(String id, Map<String, dynamic> data) =>
      _stub.updateHealthRecord(id, data);
  @override Future<Response> deleteHealthRecord(String id) => _stub.deleteHealthRecord(id);

  // ── Badges ──
  @override Future<Response> getBadges(String babyMonId) => _stub.getBadges(babyMonId);
  @override Future<Response> getBadgeDefinitions() => _stub.getBadgeDefinitions();

  // ── Allergies ──
  @override Future<Response> getAllergies(String babyMonId) => _stub.getAllergies(babyMonId);
  @override Future<Response> createAllergy(String babyMonId, Map<String, dynamic> data) =>
      _stub.createAllergy(babyMonId, data);
  @override Future<Response> addAllergyEvent(String babyMonId, String allergyId, Map<String, dynamic> data) =>
      _stub.addAllergyEvent(babyMonId, allergyId, data);
  @override Future<Response> deleteAllergyEvent(String babyMonId, String eventId) =>
      _stub.deleteAllergyEvent(babyMonId, eventId);
  @override Future<Response> cureAllergy(String babyMonId, String allergyId) =>
      _stub.cureAllergy(babyMonId, allergyId);
  @override Future<Response> reactivateAllergy(String babyMonId, String allergyId) =>
      _stub.reactivateAllergy(babyMonId, allergyId);
  @override Future<Response> clearAllAllergies(String babyMonId) =>
      _stub.clearAllAllergies(babyMonId);
  @override Future<Response> clearAllAllergyEvents(String babyMonId) =>
      _stub.clearAllAllergyEvents(babyMonId);
  @override Future<Response> deleteAllergy(String babyMonId, String allergyId) =>
      _stub.deleteAllergy(babyMonId, allergyId);

  // ── Medical Team ──
  @override Future<Response> getMedicalTeam(String babyMonId) => _stub.getMedicalTeam(babyMonId);
  @override Future<Response> createMedicalTeamMember(String babyMonId, Map<String, dynamic> data) =>
      _stub.createMedicalTeamMember(babyMonId, data);
  @override Future<Response> deleteMedicalTeamMember(String babyMonId, String memberId) =>
      _stub.deleteMedicalTeamMember(babyMonId, memberId);

  // ── Evolution ──
  @override Future<Response> getEvolution(String babyMonId) => _stub.getEvolution(babyMonId);

  // ── Journal ──
  @override Future<Response> getJournal(String babyMonId, {String? type}) =>
      _stub.getJournal(babyMonId, type: type);
  @override Future<Response> getProposals(String babyMonId) => _stub.getProposals(babyMonId);
  @override Future<Response> respondToProposal(String babyMonId, String proposalId, bool accept, String? reason) =>
      _stub.respondToProposal(babyMonId, proposalId, accept, reason);

  // ── Export ──
  @override Future<Response> exportBabyMon(String babyMonId) => _stub.exportBabyMon(babyMonId);

  // ── Subscription ──
  @override Future<Response> getSubscription() => _stub.getSubscription();
  @override Future<Response> devOverrideTrial(int days) => _stub.devOverrideTrial(days);

  // ── Growth ──
  @override Future<Response> getGrowthRecords(String babyMonId, {String? type}) =>
      _stub.getGrowthRecords(babyMonId, type: type);
  @override Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) =>
      _stub.createGrowthRecord(babyMonId, data);
  @override Future<Response> updateGrowthRecord(String babyMonId, String recordId, Map<String, dynamic> data) =>
      _stub.updateGrowthRecord(babyMonId, recordId, data);
  @override Future<Response> deleteGrowthRecord(String babyMonId, String recordId) =>
      _stub.deleteGrowthRecord(babyMonId, recordId);

  // ── Partners ──
  @override Future<Response> invitePartner(String babyMonId, String email, String role) =>
      _stub.invitePartner(babyMonId, email, role);
  @override Future<Response> getPartners(String babyMonId) => _stub.getPartners(babyMonId);
  @override Future<Response> respondToInvitation(String partnerId, String status) =>
      _stub.respondToInvitation(partnerId, status);
  @override Future<Response> removePartner(String babyMonId, String partnerId) => _stub.removePartner(babyMonId, partnerId);

  // ── Photos ──
  @override Future<Response> uploadPhoto(String babyMonId, Map<String, dynamic> data) =>
      _stub.uploadPhoto(babyMonId, data);
  @override Future<Response> getPhotos(String babyMonId) => _stub.getPhotos(babyMonId);
  @override Future<Response> deletePhoto(String id) => _stub.deletePhoto(id);

  // ── Sleep Logs ──
  @override Future<Response> getSleepLogs(String babyMonId) => _stub.getSleepLogs(babyMonId);
  @override Future<Response> createSleepLog(String babyMonId, Map<String, dynamic> data) =>
      _stub.createSleepLog(babyMonId, data);
  @override Future<Response> updateSleepLog(String babyMonId, String id, Map<String, dynamic> data) =>
      _stub.updateSleepLog(babyMonId, id, data);
  @override Future<Response> deleteSleepLog(String babyMonId, String id) =>
      _stub.deleteSleepLog(babyMonId, id);

  // ── Stage Content ──
  @override Future<Response> getStageContent(String stageKey) => _stub.getStageContent(stageKey);

  // ── Storage ──
  @override Future<void> saveTokens(String accessToken, String refreshToken, String userId) =>
      _stub.saveTokens(accessToken, refreshToken, userId);
  @override Future<String?> getAccessToken() => _stub.getAccessToken();
  @override Future<String?> getUserId() => _stub.getUserId();
  @override Future<void> setSelectedBabyMonId(String? id) => _stub.setSelectedBabyMonId(id);
  @override Future<String?> getSelectedBabyMonId() => _stub.getSelectedBabyMonId();
  @override Future<void> setTrialOverride(int days) => _stub.setTrialOverride(days);
  @override Future<int?> getTrialOverride() => _stub.getTrialOverride();

  // ── Generic HTTP ──
  @override Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _stub.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  @override Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, bool forceRefresh = false}) =>
      _stub.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  @override Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _stub.patch(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  @override Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _stub.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  @override Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _stub.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
}

/// Default stub implementations for [MockApiClient].
///
/// All methods return an empty successful response by default.
/// Override any method to return custom data or throw errors.
class StubController {
  // ── Auth ──
  Future<Response> register(String email, String password, String? name) => _ok();
  Future<Response> login(String email, String password) => _ok();
  Future<Response> getProfile() => _ok();
  Future<void> logout() async {}

  // ── BabyMons ──
  Future<Response> getBabyMons() => _ok();
  Future<Response> getBabyMon(String id) => _ok();
  Future<Response> createBabyMon(Map<String, dynamic> data) => _ok();
  Future<Response> updateBabyMon(String id, Map<String, dynamic> data) => _ok();
  Future<Response> deleteBabyMon(String id) => _ok();
  Future<Response> getBabyMonStage(String id) => _ok();

  // ── Milestones ──
  Future<Response> getMilestones(String babyMonId) => _ok();
  Future<Response> createMilestone(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> updateMilestone(String id, Map<String, dynamic> data) => _ok();
  Future<Response> deleteMilestone(String id) => _ok();

  // ── Feed Logs ──
  Future<Response> getFeedLogs(String babyMonId) => _ok();
  Future<Response> createFeedLog(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> updateFeedLog(String id, Map<String, dynamic> data) => _ok();
  Future<Response> deleteFeedLog(String id) => _ok();

  // ── Health Records ──
  Future<Response> getHealthRecords(String babyMonId) => _ok();
  Future<Response> createHealthRecord(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> updateHealthRecord(String id, Map<String, dynamic> data) => _ok();
  Future<Response> deleteHealthRecord(String id) => _ok();

  // ── Badges ──
  Future<Response> getBadges(String babyMonId) => _ok();
  Future<Response> getBadgeDefinitions() => _ok();

  // ── Allergies ──
  Future<Response> getAllergies(String babyMonId) => _ok();
  Future<Response> createAllergy(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> addAllergyEvent(String babyMonId, String allergyId, Map<String, dynamic> data) => _ok();
  Future<Response> deleteAllergyEvent(String babyMonId, String eventId) => _ok();
  Future<Response> cureAllergy(String babyMonId, String allergyId) => _ok();
  Future<Response> reactivateAllergy(String babyMonId, String allergyId) => _ok();
  Future<Response> clearAllAllergies(String babyMonId) => _ok();
  Future<Response> clearAllAllergyEvents(String babyMonId) => _ok();
  Future<Response> deleteAllergy(String babyMonId, String allergyId) => _ok();

  // ── Medical Team ──
  Future<Response> getMedicalTeam(String babyMonId) => _ok();
  Future<Response> createMedicalTeamMember(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> deleteMedicalTeamMember(String babyMonId, String memberId) => _ok();

  // ── Evolution ──
  Future<Response> getEvolution(String babyMonId) => _ok();

  // ── Journal ──
  Future<Response> getJournal(String babyMonId, {String? type}) => _ok();
  Future<Response> getProposals(String babyMonId) => _ok();
  Future<Response> respondToProposal(String babyMonId, String proposalId, bool accept, String? reason) => _ok();

  // ── Export ──
  Future<Response> exportBabyMon(String babyMonId) => _ok();

  // ── Subscription ──
  Future<Response> getSubscription() => _ok();
  Future<Response> devOverrideTrial(int days) => _ok();

  // ── Growth ──
  Future<Response> getGrowthRecords(String babyMonId, {String? type}) => _ok();
  Future<Response> createGrowthRecord(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> updateGrowthRecord(String babyMonId, String recordId, Map<String, dynamic> data) => _ok();
  Future<Response> deleteGrowthRecord(String babyMonId, String recordId) => _ok();

  // ── Partners ──
  Future<Response> invitePartner(String babyMonId, String email, String role) => _ok();
  Future<Response> getPartners(String babyMonId) => _ok();
  Future<Response> respondToInvitation(String partnerId, String status) => _ok();
  Future<Response> removePartner(String babyMonId, String partnerId) => _ok();

  // ── Photos ──
  Future<Response> uploadPhoto(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> getPhotos(String babyMonId) => _ok();
  Future<Response> deletePhoto(String id) => _ok();

  // ── Sleep Logs ──
  Future<Response> getSleepLogs(String babyMonId) => _ok();
  Future<Response> createSleepLog(String babyMonId, Map<String, dynamic> data) => _ok();
  Future<Response> updateSleepLog(String babyMonId, String id, Map<String, dynamic> data) => _ok();
  Future<Response> deleteSleepLog(String babyMonId, String id) => _ok();

  // ── Stage Content ──
  Future<Response> getStageContent(String stageKey) => _ok();

  // ── Storage ──
  Future<void> saveTokens(String accessToken, String refreshToken, String userId) async {}
  Future<String?> getAccessToken() async => null;
  Future<String?> getUserId() async => null;
  Future<void> setSelectedBabyMonId(String? id) async {}
  Future<String?> getSelectedBabyMonId() async => null;
  Future<void> setTrialOverride(int days) async {}
  Future<int?> getTrialOverride() async => null;

  // ── Generic HTTP ──
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) => _ok();
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, bool forceRefresh = false}) => _ok();
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) => _ok();
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) => _ok();
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) => _ok();

  static Future<Response<dynamic>> _ok() async => Response<dynamic>(data: <String, dynamic>{}, statusCode: 200, requestOptions: RequestOptions(path: '/test'));
}

/// Creates a successful Dio [Response] with the given [data].
Response<T> successResponse<T>(T data, {int statusCode = 200}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/test'),
  );
}

/// Creates an error Dio [Response] with the given [message] and [statusCode].
Response<dynamic> errorResponse(String message, {int statusCode = 400}) {
  return Response<dynamic>(
    data: <String, String>{'message': message},
    statusCode: statusCode,
    requestOptions: RequestOptions(path: '/test'),
  );
}
