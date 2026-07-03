import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
export 'fake_auth_helpers.dart' show StubAuthRepo, FakeAuthNotifier;

/// Extended test API client with configurable method responses.
class TestApiClient extends StubApiClient {
  final Map<String, dynamic> _responseData = {};

  /// Captured POST calls: list of (path, data) pairs.
  final List<MapEntry<String, dynamic>> capturedPosts = [];

  /// Captured setSelectedBabyMonId calls.
  final List<String?> capturedBabyMonIds = [];

  Response<dynamic> _ok(dynamic data) => Response<dynamic>(
        data: data,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/test'),
      );

  void setData(String method, dynamic data) {
    _responseData[method] = data;
  }

  @override
  Future<String?> getSelectedBabyMonId() async => 'test-baby-mon-id';

  @override
  Future<Response> getBabyMons() async => _ok(
        _responseData['getBabyMons'] ??
            [
              {'id': 'test-baby-mon-id', 'name': 'Test Baby'},
            ],
      );

  @override
  Future<Response> getEvolution(String babyMonId, {bool forceRefresh = false}) async => _ok(
        _responseData['getEvolution'] ??
            {
              'currentStage': 1,
              'currentXp': 50,
            },
      );

  @override
  Future<Response> getMilestones(String babyMonId, {bool forceRefresh = false}) async =>
      _ok(_responseData['getMilestones'] ?? <dynamic>[]);

  @override
  Future<Response> getFeedLogs(String babyMonId, {bool forceRefresh = false}) async =>
      _ok(_responseData['getFeedLogs'] ?? <dynamic>[]);

  @override
  Future<Response> getHealthRecords(String babyMonId, {bool forceRefresh = false}) async =>
      _ok(_responseData['getHealthRecords'] ?? <dynamic>[]);

  @override
  Future<Response> getBadges(String babyMonId) async =>
      _ok(_responseData['getBadges'] ?? <dynamic>[]);

  @override
  Future<Response> getGrowthRecords(String babyMonId, {String? type, bool forceRefresh = false}) async =>
      _ok(_responseData['getGrowthRecords'] ?? <dynamic>[]);

  @override
  Future<Response> getAllergies(String babyMonId) async =>
      _ok(_responseData['getAllergies'] ?? <dynamic>[]);

  @override
  Future<Response> getSleepLogs(String babyMonId, {bool forceRefresh = false}) async =>
      _ok(_responseData['getSleepLogs'] ?? <dynamic>[]);

  @override
  Future<Response> getProfile() async => _ok(
        _responseData['getProfile'] ??
            {
              'id': 'user-1',
              'email': 'test@example.com',
            },
      );

  @override
  Future<Response> getJournal(String babyMonId, {String? type}) async =>
      _ok(_responseData['getJournal'] ?? <dynamic>[]);

  @override
  Future<Response> getProposals(String babyMonId) async =>
      _ok(_responseData['getProposals'] ?? <dynamic>[]);

  @override
  Future<Response> getStageContent(String stageKey) async => _ok(
        _responseData['getStageContent'] ??
            {
              'summary': 'Test stage content',
              'nurturing': 'Test nurturing tips',
              'encouragement': 'You are doing great!',
            },
      );

  @override
  Future<Response> getPartners(String babyMonId) async =>
      _ok(_responseData['getPartners'] ?? <dynamic>[]);

  @override
  Future<Response> getPhotos(String babyMonId) async =>
      _ok(_responseData['getPhotos'] ?? <dynamic>[]);

  /// Optional callback to override post() behavior (e.g., to throw errors).
  Future<Response> Function(String path, {dynamic data})? postCallback;

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    capturedPosts.add(MapEntry(path, data));
    if (postCallback != null) return postCallback!(path, data: data);
    // Return a response with 'id' so screens that read response.data['id'] work.
    return _ok({'id': 'new-record-id'});
  }

  @override
  Future<void> setSelectedBabyMonId(String? id) async {
    capturedBabyMonIds.add(id);
  }
}

/// Wrap a widget in [ProviderScope] + [MaterialApp] with mock API client.
Widget buildTestApp(Widget child, TestApiClient apiClient) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Scaffold(body: child),
      ),
    ),
  );
}

/// Pump a test screen with optional mock data, then settle.
///
/// Returns the [TestApiClient] for further customization if needed.
Future<TestApiClient> pumpTestScreen(
  WidgetTester tester,
  Widget screen, {
  Map<String, dynamic> data = const {},
}) async {
  final apiClient = TestApiClient();
  data.forEach(apiClient.setData);
  await tester.pumpWidget(buildTestApp(screen, apiClient));
  await tester.pump(const Duration(milliseconds: 500));
  return apiClient;
}

// StubAuthRepo and FakeAuthNotifier are re-exported from fake_auth_helpers.dart above.
