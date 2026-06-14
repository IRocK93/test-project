import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baby_mon/core/providers.dart';

void main() {
  group('appRefreshProvider', () {
    test('starts at 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appRefreshProvider), 0);
    });

    test('can be incremented', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(appRefreshProvider), 0);
      container.read(appRefreshProvider.notifier).state++;
      expect(container.read(appRefreshProvider), 1);
    });

    test('can be incremented multiple times', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(appRefreshProvider.notifier).state++;
      container.read(appRefreshProvider.notifier).state++;
      container.read(appRefreshProvider.notifier).state++;
      expect(container.read(appRefreshProvider), 3);
    });

    test('can be set to arbitrary values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(appRefreshProvider.notifier).state = 42;
      expect(container.read(appRefreshProvider), 42);
    });
  });

  group('tabRefreshProvider', () {
    test('each tab starts at 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (int i = 0; i < 5; i++) {
        expect(container.read(tabRefreshProvider(i)), 0);
      }
    });

    test('incrementing one tab does not affect others', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(tabRefreshProvider(0).notifier).state++;
      expect(container.read(tabRefreshProvider(0)), 1);
      expect(container.read(tabRefreshProvider(1)), 0);
      expect(container.read(tabRefreshProvider(2)), 0);
    });

    test('different tabs have independent state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(tabRefreshProvider(0).notifier).state = 5;
      container.read(tabRefreshProvider(1).notifier).state = 10;
      container.read(tabRefreshProvider(2).notifier).state = 15;

      expect(container.read(tabRefreshProvider(0)), 5);
      expect(container.read(tabRefreshProvider(1)), 10);
      expect(container.read(tabRefreshProvider(2)), 15);
    });

    test('tab index is used as family key', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Same index returns same provider
      expect(
        container.read(tabRefreshProvider(0)),
        container.read(tabRefreshProvider(0)),
      );

      // Different indices return different providers
      container.read(tabRefreshProvider(0).notifier).state = 99;
      expect(container.read(tabRefreshProvider(0)), 99);
      expect(container.read(tabRefreshProvider(1)), 0);
    });
  });

  group('pendingAddActionProvider', () {
    test('starts at null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(pendingAddActionProvider), isNull);
    });

    test('can be set to feeding action', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(pendingAddActionProvider.notifier).state =
          AddAction.feeding;
      expect(container.read(pendingAddActionProvider), AddAction.feeding);
    });

    test('can be set to milestone action', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(pendingAddActionProvider.notifier).state =
          AddAction.milestone;
      expect(container.read(pendingAddActionProvider), AddAction.milestone);
    });

    test('can be set to healthMeasurement action', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(pendingAddActionProvider.notifier).state =
          AddAction.healthMeasurement;
      expect(
          container.read(pendingAddActionProvider), AddAction.healthMeasurement);
    });

    test('can be cleared back to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(pendingAddActionProvider.notifier).state =
          AddAction.feeding;
      expect(container.read(pendingAddActionProvider), AddAction.feeding);

      container.read(pendingAddActionProvider.notifier).state = null;
      expect(container.read(pendingAddActionProvider), isNull);
    });

    test('AddAction enum has exactly 3 values', () {
      expect(AddAction.values.length, 3);
      expect(AddAction.values, contains(AddAction.feeding));
      expect(AddAction.values, contains(AddAction.milestone));
      expect(AddAction.values, contains(AddAction.healthMeasurement));
    });
  });
}
