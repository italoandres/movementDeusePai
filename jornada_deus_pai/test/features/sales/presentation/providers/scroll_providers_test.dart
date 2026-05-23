import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornada_deus_pai/features/sales/presentation/providers/scroll_providers.dart';

void main() {
  group('salesScrollControllerProvider', () {
    test('should create a ScrollController instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(salesScrollControllerProvider);

      expect(controller, isA<ScrollController>());
    });

    test('should dispose ScrollController when container is disposed', () {
      final container = ProviderContainer();
      final controller = container.read(salesScrollControllerProvider);

      // Verify controller is not disposed initially
      expect(() => controller.position, throwsAssertionError);

      // Dispose container
      container.dispose();

      // Verify controller is disposed
      expect(() => controller.position, throwsAssertionError);
    });

    test('should return the same controller instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller1 = container.read(salesScrollControllerProvider);
      final controller2 = container.read(salesScrollControllerProvider);

      expect(controller1, same(controller2));
    });
  });

  group('scrollPositionProvider', () {
    test('should initialize with 0.0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final position = container.read(scrollPositionProvider);

      expect(position, 0.0);
    });

    test('should update scroll position', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(scrollPositionProvider.notifier).state = 100.0;

      expect(container.read(scrollPositionProvider), 100.0);
    });

    test('should allow multiple position updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(scrollPositionProvider.notifier);

      notifier.state = 50.0;
      expect(container.read(scrollPositionProvider), 50.0);

      notifier.state = 150.0;
      expect(container.read(scrollPositionProvider), 150.0);

      notifier.state = 300.0;
      expect(container.read(scrollPositionProvider), 300.0);
    });
  });

  group('SectionVisibilityNotifier', () {
    test('should initialize with empty map', () {
      final notifier = SectionVisibilityNotifier();

      expect(notifier.state, isEmpty);
    });

    test('should update visibility for a single section', () {
      final notifier = SectionVisibilityNotifier();

      notifier.updateVisibility(0, true);

      expect(notifier.state, {0: true});
    });

    test('should update visibility for multiple sections', () {
      final notifier = SectionVisibilityNotifier();

      notifier.updateVisibility(0, true);
      notifier.updateVisibility(1, false);
      notifier.updateVisibility(2, true);

      expect(notifier.state, {
        0: true,
        1: false,
        2: true,
      });
    });

    test('should overwrite existing section visibility', () {
      final notifier = SectionVisibilityNotifier();

      notifier.updateVisibility(0, true);
      expect(notifier.state[0], true);

      notifier.updateVisibility(0, false);
      expect(notifier.state[0], false);
    });

    test('should preserve other sections when updating one section', () {
      final notifier = SectionVisibilityNotifier();

      notifier.updateVisibility(0, true);
      notifier.updateVisibility(1, true);
      notifier.updateVisibility(2, true);

      notifier.updateVisibility(1, false);

      expect(notifier.state, {
        0: true,
        1: false,
        2: true,
      });
    });
  });

  group('sectionVisibilityProvider', () {
    test('should initialize with empty map', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final visibility = container.read(sectionVisibilityProvider);

      expect(visibility, isEmpty);
    });

    test('should update section visibility through provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(sectionVisibilityProvider.notifier)
          .updateVisibility(0, true);

      expect(container.read(sectionVisibilityProvider), {0: true});
    });

    test('should handle multiple section updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(sectionVisibilityProvider.notifier);

      notifier.updateVisibility(0, true);
      notifier.updateVisibility(1, false);
      notifier.updateVisibility(2, true);

      expect(container.read(sectionVisibilityProvider), {
        0: true,
        1: false,
        2: true,
      });
    });

    test('should notify listeners when visibility changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var notificationCount = 0;
      container.listen<Map<int, bool>>(
        sectionVisibilityProvider,
        (previous, next) {
          notificationCount++;
        },
      );

      container
          .read(sectionVisibilityProvider.notifier)
          .updateVisibility(0, true);

      expect(notificationCount, 1);

      container
          .read(sectionVisibilityProvider.notifier)
          .updateVisibility(1, true);

      expect(notificationCount, 2);
    });
  });

  group('Integration tests', () {
    test('should work together for scroll tracking scenario', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Simulate scroll position update
      container.read(scrollPositionProvider.notifier).state = 100.0;

      // Simulate section visibility updates based on scroll
      final visibilityNotifier =
          container.read(sectionVisibilityProvider.notifier);
      visibilityNotifier.updateVisibility(0, true);
      visibilityNotifier.updateVisibility(1, false);

      // Verify state
      expect(container.read(scrollPositionProvider), 100.0);
      expect(container.read(sectionVisibilityProvider), {
        0: true,
        1: false,
      });

      // Simulate further scrolling
      container.read(scrollPositionProvider.notifier).state = 500.0;
      visibilityNotifier.updateVisibility(1, true);
      visibilityNotifier.updateVisibility(2, true);

      // Verify updated state
      expect(container.read(scrollPositionProvider), 500.0);
      expect(container.read(sectionVisibilityProvider), {
        0: true,
        1: true,
        2: true,
      });
    });
  });
}
