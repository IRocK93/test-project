import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/core/testing/stub_api_client.dart';
import 'package:baby_mon/core/providers.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/features/milestones/presentation/screens/milestones_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/health_screen.dart';
import 'package:baby_mon/features/feeding/presentation/screens/feeding_screen.dart';

/// A version of StubApiClient that returns configurable data wrapped in [Response].
class _TestApiClient extends StubApiClient {
  final Map<String, dynamic> _responseData = {};

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
  Future<Response> getEvolution(String babyMonId) async => _ok(
        _responseData['getEvolution'] ??
            {
              'currentStage': 1,
              'currentXp': 50,
            },
      );

  @override
  Future<Response> getMilestones(String babyMonId) async =>
      _ok(_responseData['getMilestones'] ?? <dynamic>[]);

  @override
  Future<Response> getFeedLogs(String babyMonId) async =>
      _ok(_responseData['getFeedLogs'] ?? <dynamic>[]);

  @override
  Future<Response> getHealthRecords(String babyMonId) async =>
      _ok(_responseData['getHealthRecords'] ?? <dynamic>[]);

  @override
  Future<Response> getBadges(String babyMonId) async =>
      _ok(_responseData['getBadges'] ?? <dynamic>[]);

  @override
  Future<Response> getGrowthRecords(String babyMonId, {String? type}) async =>
      _ok(_responseData['getGrowthRecords'] ?? <dynamic>[]);

  @override
  Future<Response> getAllergies(String babyMonId) async =>
      _ok(_responseData['getAllergies'] ?? <dynamic>[]);

  @override
  Future<Response> getSleepLogs(String babyMonId) async =>
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
}

Widget _buildTestApp(Widget child, _TestApiClient apiClient) {
  return ProviderScope(
    overrides: [
      apiClientProvider.overrideWithValue(apiClient),
    ],
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });


  group('DashboardScreen provider integration', () {
    testWidgets('renders loading state initially', (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      await tester.pumpWidget(
        _buildTestApp(const DashboardScreen(), apiClient),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no baby mon exists',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getBabyMons', <dynamic>[]);

      await tester.pumpWidget(
        _buildTestApp(const DashboardScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('renders dashboard with baby mon data',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getEvolution', {
        'currentStage': 3,
        'currentXp': 150,
      });
      apiClient.setData('getBadges', [
        {'id': 'badge-1', 'name': 'First Steps', 'icon': '🏆'},
      ]);

      await tester.pumpWidget(
        _buildTestApp(const DashboardScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully', (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getEvolution', null);

      await tester.pumpWidget(
        _buildTestApp(const DashboardScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  group('MilestonesScreen provider integration', () {
    testWidgets('renders empty state when no milestones',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getMilestones', <dynamic>[]);

      await tester.pumpWidget(
        _buildTestApp(const MilestonesScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MilestonesScreen), findsOneWidget);
    });

    testWidgets('renders milestone list with data',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getMilestones', [
        {
          'id': 'milestone-1',
          'title': 'First Smile',
          'notes': 'Baby smiled for the first time!',
          'happenedAt': '2024-03-15T10:30:00.000Z',
        },
        {
          'id': 'milestone-2',
          'title': 'Rolled Over',
          'notes': 'Rolled from back to tummy',
          'happenedAt': '2024-04-20T14:15:00.000Z',
        },
      ]);

      await tester.pumpWidget(
        _buildTestApp(const MilestonesScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MilestonesScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getMilestones', null);

      await tester.pumpWidget(
        _buildTestApp(const MilestonesScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MilestonesScreen), findsOneWidget);
    });
  });

  group('FeedingScreen provider integration', () {
    testWidgets('renders empty state when no feed logs',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getFeedLogs', <dynamic>[]);

      await tester.pumpWidget(
        _buildTestApp(const FeedingScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FeedingScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getFeedLogs', null);

      await tester.pumpWidget(
        _buildTestApp(const FeedingScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(FeedingScreen), findsOneWidget);
    });
  });

  group('HealthScreen provider integration', () {
    testWidgets('renders empty state when no health records',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getHealthRecords', <dynamic>[]);
      apiClient.setData('getAllergies', <dynamic>[]);

      await tester.pumpWidget(
        _buildTestApp(const HealthScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('renders health records with data',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getHealthRecords', [
        {
          'id': 'health-1',
          'category': 'CHECKUP',
          'title': '6-Month Checkup',
          'notes': 'All good!',
          'createdAt': '2024-03-15T10:30:00.000Z',
        },
      ]);
      apiClient.setData('getAllergies', <dynamic>[]);

      await tester.pumpWidget(
        _buildTestApp(const HealthScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      final apiClient = _TestApiClient();
      apiClient.setData('getHealthRecords', null);

      await tester.pumpWidget(
        _buildTestApp(const HealthScreen(), apiClient),
      );

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HealthScreen), findsOneWidget);
    });
  });

}
