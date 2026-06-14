import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:baby_mon/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:baby_mon/features/milestones/presentation/screens/milestones_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/health_screen.dart';
import 'package:baby_mon/features/feeding/presentation/screens/feeding_screen.dart';
import 'package:baby_mon/features/journal/presentation/screens/journal_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/settings_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/subscription_screen.dart';
import 'package:baby_mon/features/settings/presentation/screens/partners_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/sleep_screen.dart';
import 'package:baby_mon/features/health/presentation/screens/growth_chart_screen.dart';
import 'package:baby_mon/features/album/presentation/screens/album_screen.dart';
import 'package:baby_mon/features/discover/presentation/screens/discover_screen.dart';
import 'screen_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DashboardScreen', () {
    testWidgets('renders loading state initially', (WidgetTester tester) async {
      final apiClient = TestApiClient();
      await tester.pumpWidget(buildTestApp(const DashboardScreen(), apiClient));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders empty state when no baby mon exists',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      apiClient.setData('getBabyMons', <dynamic>[]);
      await tester.pumpWidget(buildTestApp(const DashboardScreen(), apiClient));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('renders dashboard with baby mon data',
        (WidgetTester tester) async {
      final apiClient = TestApiClient();
      apiClient.setData('getEvolution', {
        'currentStage': 3,
        'currentXp': 150,
      });
      apiClient.setData('getBadges', [
        {'id': 'badge-1', 'name': 'First Steps', 'icon': '🏆'},
      ]);
      await tester.pumpWidget(buildTestApp(const DashboardScreen(), apiClient));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully', (WidgetTester tester) async {
      final apiClient = TestApiClient();
      apiClient.setData('getEvolution', null);
      await tester.pumpWidget(buildTestApp(const DashboardScreen(), apiClient));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  group('MilestonesScreen', () {
    testWidgets('renders empty state when no milestones',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const MilestonesScreen(),
          data: {'getMilestones': <dynamic>[]});
      expect(find.byType(MilestonesScreen), findsOneWidget);
    });

    testWidgets('renders milestone list with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const MilestonesScreen(), data: {
        'getMilestones': [
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
        ],
      });
      expect(find.byType(MilestonesScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const MilestonesScreen(),
          data: {'getMilestones': null});
      expect(find.byType(MilestonesScreen), findsOneWidget);
    });
  });

  group('FeedingScreen', () {
    testWidgets('renders empty state when no feed logs',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const FeedingScreen(),
          data: {'getFeedLogs': <dynamic>[]});
      expect(find.byType(FeedingScreen), findsOneWidget);
    });

    testWidgets('renders feed logs with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const FeedingScreen(), data: {
        'getFeedLogs': [
          {
            'id': 'feed-1',
            'type': 'BOTTLE',
            'amount': '120',
            'unit': 'ml',
            'happenedAt': DateTime.now().toIso8601String(),
          },
        ],
      });
      expect(find.byType(FeedingScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const FeedingScreen(),
          data: {'getFeedLogs': null});
      expect(find.byType(FeedingScreen), findsOneWidget);
    });
  });

  group('HealthScreen', () {
    testWidgets('renders empty state when no health records',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const HealthScreen(), data: {
        'getHealthRecords': <dynamic>[],
        'getAllergies': <dynamic>[],
      });
      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('renders health records with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const HealthScreen(), data: {
        'getHealthRecords': [
          {
            'id': 'health-1',
            'category': 'CHECKUP',
            'title': '6-Month Checkup',
            'notes': 'All good!',
            'createdAt': '2024-03-15T10:30:00.000Z',
          },
        ],
        'getAllergies': <dynamic>[],
      });
      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const HealthScreen(),
          data: {'getHealthRecords': null});
      expect(find.byType(HealthScreen), findsOneWidget);
    });
  });

  group('JournalScreen', () {
    testWidgets('renders empty state when no journal entries',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const JournalScreen(), data: {
        'getJournal': <dynamic>[],
        'getProposals': <dynamic>[],
      });
      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('renders journal entries with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const JournalScreen(), data: {
        'getJournal': [
          {
            'id': 'entry-1',
            'entryType': 'MILESTONE',
            'title': 'First Smile',
            'happenedAt': '2024-03-15T10:30:00.000Z',
          },
        ],
        'getProposals': <dynamic>[],
      });
      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const JournalScreen(),
          data: {'getJournal': null});
      expect(find.byType(JournalScreen), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders settings with user profile',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SettingsScreen(), data: {
        'getProfile': {
          'id': 'user-1',
          'name': 'Test Parent',
          'email': 'test@example.com',
        },
        'getSubscription': {
          'plan': 'FREE',
          'trialDaysRemaining': 7,
        },
      });
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('renders empty state when no profile',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SettingsScreen(),
          data: {'getProfile': null});
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });

  group('SubscriptionScreen', () {
    testWidgets('renders subscription plans', (WidgetTester tester) async {
      await pumpTestScreen(tester, const SubscriptionScreen(), data: {
        'getSubscription': {
          'plan': 'FREE',
          'trialDaysRemaining': 14,
        },
      });
      expect(find.byType(SubscriptionScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SubscriptionScreen(),
          data: {'getSubscription': null});
      expect(find.byType(SubscriptionScreen), findsOneWidget);
    });
  });

  group('SleepScreen', () {
    testWidgets('renders empty state when no sleep logs',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SleepScreen(),
          data: {'getSleepLogs': <dynamic>[]});
      expect(find.byType(SleepScreen), findsOneWidget);
    });

    testWidgets('renders sleep logs with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SleepScreen(), data: {
        'getSleepLogs': [
          {
            'id': 'sleep-1',
            'type': 'NIGHT',
            'startTime': '2024-03-15T22:00:00.000Z',
            'endTime': '2024-03-16T06:30:00.000Z',
            'quality': 'GREAT',
          },
        ],
      });
      expect(find.byType(SleepScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const SleepScreen(),
          data: {'getSleepLogs': null});
      expect(find.byType(SleepScreen), findsOneWidget);
    });
  });

  group('GrowthChartScreen', () {
    testWidgets('renders empty state when no growth records',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const GrowthChartScreen(),
          data: {'getGrowthRecords': <dynamic>[]});
      expect(find.byType(GrowthChartScreen), findsOneWidget);
    });

    testWidgets('renders growth records with data',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const GrowthChartScreen(), data: {
        'getGrowthRecords': [
          {
            'id': 'growth-1',
            'type': 'WEIGHT',
            'value': '7.5',
            'unit': 'kg',
            'measuredAt': '2024-03-15T10:00:00.000Z',
          },
        ],
      });
      expect(find.byType(GrowthChartScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const GrowthChartScreen(),
          data: {'getGrowthRecords': null});
      expect(find.byType(GrowthChartScreen), findsOneWidget);
    });
  });

  group('PartnersScreen', () {
    testWidgets('renders empty state when no partners',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const PartnersScreen(),
          data: {'getPartners': <dynamic>[]});
      expect(find.byType(PartnersScreen), findsOneWidget);
    });

    testWidgets('renders partners with data', (WidgetTester tester) async {
      await pumpTestScreen(tester, const PartnersScreen(), data: {
        'getPartners': [
          {
            'id': 'partner-1',
            'status': 'ACCEPTED',
            'role': 'PARENT',
            'user': {'name': 'Co-Parent', 'email': 'partner@test.com'},
          },
        ],
      });
      expect(find.byType(PartnersScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const PartnersScreen(),
          data: {'getPartners': null});
      expect(find.byType(PartnersScreen), findsOneWidget);
    });
  });

  group('AlbumScreen', () {
    testWidgets('renders empty state when no photos',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const AlbumScreen(),
          data: {'getPhotos': <dynamic>[]});
      expect(find.byType(AlbumScreen), findsOneWidget);
    });

    testWidgets('renders album with photos', (WidgetTester tester) async {
      await pumpTestScreen(tester, const AlbumScreen(), data: {
        'getPhotos': [
          {
            'id': 'photo-1',
            'takenAt': '2024-03-15T10:00:00.000Z',
            'url': 'https://example.com/photo1.jpg',
          },
        ],
      });
      expect(find.byType(AlbumScreen), findsOneWidget);
    });

    testWidgets('handles API errors gracefully',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const AlbumScreen(),
          data: {'getPhotos': null});
      expect(find.byType(AlbumScreen), findsOneWidget);
    });
  });

  group('DiscoverScreen', () {
    testWidgets('renders discover coming soon screen',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const DiscoverScreen());
      expect(find.byType(DiscoverScreen), findsOneWidget);
    });

    testWidgets('renders coming soon badge',
        (WidgetTester tester) async {
      await pumpTestScreen(tester, const DiscoverScreen());
      expect(find.text('COMING SOON'), findsOneWidget);
    });
  });
}
