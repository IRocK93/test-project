import 'package:dio/dio.dart';
import 'package:baby_mon/core/data/api_client.dart';

/// A minimal [ApiClient] stub for smoke / rendering tests.
///
/// All methods return an empty successful response by default.
/// Override individual methods as needed for specific test scenarios.
///
/// This lives in `lib/` (not `test/`) so it can be imported via
/// `package:baby_mon/core/testing/stub_api_client.dart` from any test file.
class StubApiClient implements ApiClient {
  Response<dynamic> _ok() => Response<dynamic>(
        data: <String, dynamic>{},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

  // ── Auth ──
  @override Future<Response> register(String e, String p, String? n) async => _ok();
  @override Future<Response> login(String e, String p) async => _ok();
  @override Future<Response> getProfile() async => _ok();
  @override Future<void> logout() async {}

  // ── BabyMons ──
  @override Future<Response> getBabyMons() async => _ok();
  @override Future<Response> getBabyMon(String id) async => _ok();
  @override Future<Response> createBabyMon(Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateBabyMon(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteBabyMon(String id) async => _ok();
  @override Future<Response> getBabyMonStage(String id) async => _ok();

  // ── Milestones ──
  @override Future<Response> getMilestones(String id, {bool forceRefresh = false}) async => _ok();
  @override Future<Response> createMilestone(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateMilestone(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteMilestone(String id) async => _ok();

  // ── Feed Logs ──
  @override Future<Response> getFeedLogs(String id, {bool forceRefresh = false}) async => _ok();
  @override Future<Response> createFeedLog(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateFeedLog(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteFeedLog(String id) async => _ok();

  // ── Health Records ──
  @override Future<Response> getHealthRecords(String id, {bool forceRefresh = false}) async => _ok();
  @override Future<Response> createHealthRecord(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateHealthRecord(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteHealthRecord(String id) async => _ok();

  // ── Badges ──
  @override Future<Response> getBadges(String id) async => _ok();
  @override Future<Response> getBadgeDefinitions() async => _ok();

  // ── Allergies ──
  @override Future<Response> getAllergies(String id) async => _ok();
  @override Future<Response> createAllergy(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> addAllergyEvent(String id, String a, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteAllergyEvent(String id, String e) async => _ok();
  @override Future<Response> cureAllergy(String id, String a) async => _ok();
  @override Future<Response> reactivateAllergy(String id, String a) async => _ok();
  @override Future<Response> clearAllAllergies(String id) async => _ok();
  @override Future<Response> clearAllAllergyEvents(String id) async => _ok();
  @override Future<Response> deleteAllergy(String id, String a) async => _ok();

  // ── Medical Team ──
  @override Future<Response> getMedicalTeam(String id) async => _ok();
  @override Future<Response> createMedicalTeamMember(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteMedicalTeamMember(String id, String m) async => _ok();

  // ── Evolution ──
  @override Future<Response> getEvolution(String id, {bool forceRefresh = false}) async => _ok();

  // ── Dashboard Aggregation ──
  @override Future<Response> getDashboard(String id) async => _ok();

  // ── Stage Content ──
  @override Future<Response> getStageContentForBabyMon(String id) async => _ok();

  // ── Journal ──
  @override Future<Response> getJournal(String id, {String? type}) async => _ok();
  @override Future<Response> getProposals(String id) async => _ok();
  @override Future<Response> respondToProposal(String id, String p, bool a, String? r) async => _ok();

  // ── Export ──
  @override Future<Response> exportBabyMon(String id) async => _ok();

  // ── Subscription ──
  @override Future<Response> getSubscription() async => _ok();
  @override Future<Response> devOverrideTrial(int d) async => _ok();

  // ── Growth ──
  @override Future<Response> getGrowthRecords(String id, {String? type, bool forceRefresh = false}) async => _ok();
  @override Future<Response> createGrowthRecord(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateGrowthRecord(String id, String r, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteGrowthRecord(String id, String r) async => _ok();

  // ── Partners ──
  @override Future<Response> invitePartner(String id, String e, String r) async => _ok();
  @override Future<Response> getPartners(String id) async => _ok();
  @override Future<Response> respondToInvitation(String id, String s) async => _ok();
  @override Future<Response> removePartner(String babyMonId, String partnerId) async => _ok();

  // ── Photos ──
  @override Future<Response> uploadPhoto(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> getPhotos(String id) async => _ok();
  @override Future<Response> deletePhoto(String id) async => _ok();

  // ── Sleep Logs ──
  @override Future<Response> getSleepLogs(String id, {bool forceRefresh = false}) async => _ok();
  @override Future<Response> createSleepLog(String id, Map<String, dynamic> d) async => _ok();
  @override Future<Response> updateSleepLog(String id, String s, Map<String, dynamic> d) async => _ok();
  @override Future<Response> deleteSleepLog(String id, String s) async => _ok();

  // ── Stage Content ──
  @override Future<Response> getStageContent(String s) async => _ok();

  // ── Storage ──
  @override Future<void> saveTokens(String a, String r, String u) async {}
  @override Future<String?> getAccessToken() async => null;
  @override Future<String?> getUserId() async => null;
  @override Future<void> setSelectedBabyMonId(String? id) async {}
  @override Future<String?> getSelectedBabyMonId() async => null;
  @override Future<void> setTrialOverride(int d) async {}
  @override Future<int?> getTrialOverride() async => null;

  // ── Generic HTTP ──
  @override Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async => _ok();
  @override Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, bool forceRefresh = false}) async => _ok();
  @override Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async => _ok();
  @override Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async => _ok();
  @override Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async => _ok();
}
