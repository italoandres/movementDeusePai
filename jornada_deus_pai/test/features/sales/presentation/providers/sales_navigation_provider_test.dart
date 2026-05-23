import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:jornada_deus_pai/features/sales/presentation/providers/sales_navigation_provider.dart';
import 'package:jornada_deus_pai/shared/core/app_routes.dart';

void main() {
  group('SalesNavigation', () {
    group('navigateToAuth', () {
      testWidgets('should navigate to login route', (tester) async {
        String? navigatedRoute;

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(
                body: Text('Home'),
              ),
            ),
            GoRoute(
              path: AppRoutes.login,
              builder: (context, state) {
                navigatedRoute = AppRoutes.login;
                return const Scaffold(
                  body: Text('Login'),
                );
              },
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );

        final context = tester.element(find.text('Home'));
        final navigation = SalesNavigation();

        navigation.navigateToAuth(context);
        await tester.pumpAndSettle();

        expect(navigatedRoute, AppRoutes.login);
      });

      testWidgets('should show error snackbar on navigation failure',
          (tester) async {
        // Create a widget with a context but no router
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      final navigation = SalesNavigation();
                      navigation.navigateToAuth(context);
                    },
                    child: const Text('Navigate'),
                  ),
                );
              },
            ),
          ),
        );

        // Tap the button to trigger navigation (which will fail)
        await tester.tap(find.text('Navigate'));
        await tester.pump();

        // Verify error snackbar is shown
        expect(
          find.text('Não foi possível navegar. Tente novamente.'),
          findsOneWidget,
        );
      });
    });

    group('scrollToSection', () {
      testWidgets('should scroll to target section with animation',
          (tester) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        // Create a scrollable widget
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    10,
                    (index) => Container(
                      height: 800,
                      color: index.isEven ? Colors.blue : Colors.red,
                      child: Center(child: Text('Section $index')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final navigation = SalesNavigation();

        // Scroll to section 2
        navigation.scrollToSection(scrollController, 2);
        await tester.pumpAndSettle();

        // Verify scroll position (approximately 1600 pixels for section 2)
        expect(scrollController.offset, greaterThan(1500));
        expect(scrollController.offset, lessThan(1700));
      });

      testWidgets('should not exceed max scroll extent', (tester) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        // Create a scrollable widget with limited content
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: List.generate(
                    3,
                    (index) => Container(
                      height: 800,
                      color: index.isEven ? Colors.blue : Colors.red,
                      child: Center(child: Text('Section $index')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final navigation = SalesNavigation();
        final maxExtent = scrollController.position.maxScrollExtent;

        // Try to scroll to a section beyond the content
        navigation.scrollToSection(scrollController, 10);
        await tester.pumpAndSettle();

        // Verify scroll position does not exceed max extent
        expect(scrollController.offset, lessThanOrEqualTo(maxExtent));
      });

      testWidgets('should use 600ms duration for scroll animation',
          (tester) async {
        final scrollController = ScrollController();
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scrollController,
                child: SizedBox(
                  height: 10000, // Large height to ensure scrollability
                  child: Column(
                    children: List.generate(
                      10,
                      (index) => Container(
                        height: 800,
                        color: index.isEven ? Colors.blue : Colors.red,
                        child: Center(child: Text('Section $index')),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final navigation = SalesNavigation();

        // Verify initial position is 0
        expect(scrollController.offset, 0.0);

        // Start scroll animation
        navigation.scrollToSection(scrollController, 2);

        // Pump a single frame to start animation
        await tester.pump();

        // Pump for 300ms (half of animation duration)
        await tester.pump(const Duration(milliseconds: 300));

        // Verify scroll is in progress (not at start or end)
        expect(scrollController.offset, greaterThan(0));
        expect(scrollController.offset, lessThan(1600));

        // Complete animation
        await tester.pumpAndSettle();

        // Verify scroll completed
        expect(scrollController.offset, greaterThan(1500));
      });

      test('should handle scroll errors gracefully', () {
        // Create a disposed controller to trigger error
        final scrollController = ScrollController();
        scrollController.dispose();

        final navigation = SalesNavigation();

        // Should not throw exception
        expect(
          () => navigation.scrollToSection(scrollController, 2),
          returnsNormally,
        );
      });
    });
  });

  group('salesNavigationProvider', () {
    test('should provide SalesNavigation instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final navigation = container.read(salesNavigationProvider);

      expect(navigation, isA<SalesNavigation>());
    });

    test('should return the same instance on multiple reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final navigation1 = container.read(salesNavigationProvider);
      final navigation2 = container.read(salesNavigationProvider);

      expect(navigation1, same(navigation2));
    });
  });

  group('Integration tests', () {
    testWidgets('should navigate and scroll in sequence', (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      String? navigatedRoute;

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: List.generate(
                          5,
                          (index) => Container(
                            height: 800,
                            color: index.isEven ? Colors.blue : Colors.red,
                            child: Center(child: Text('Section $index')),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final navigation = SalesNavigation();
                      navigation.navigateToAuth(context);
                    },
                    child: const Text('Navigate to Auth'),
                  ),
                ],
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) {
              navigatedRoute = AppRoutes.login;
              return const Scaffold(
                body: Text('Login'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final navigation = SalesNavigation();

      // First, scroll to a section
      navigation.scrollToSection(scrollController, 3);
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(2000));

      // Then navigate to auth
      await tester.tap(find.text('Navigate to Auth'));
      await tester.pumpAndSettle();

      expect(navigatedRoute, AppRoutes.login);
    });
  });
}
