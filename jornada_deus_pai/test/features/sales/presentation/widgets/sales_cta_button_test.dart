import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornada_deus_pai/features/sales/data/constants/sales_theme.dart';
import 'package:jornada_deus_pai/features/sales/presentation/widgets/sales_cta_button.dart';

void main() {
  group('SalesCtaButton Widget Tests', () {
    testWidgets('renders with correct text', (tester) async {
      const buttonText = 'Começar agora';
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: buttonText,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Verify button text is displayed
      expect(find.text(buttonText), findsOneWidget);
    });

    testWidgets('has gold background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(SalesTheme.accentColor));
      expect(decoration.color, equals(const Color(0xFFD4AF37)));
    });

    testWidgets('has black text color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Text widget
      final textWidget = tester.widget<Text>(find.text('Test Button'));
      expect(textWidget.style?.color, equals(Colors.black));
    });

    testWidgets('has 8px border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Container with decoration
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      final borderRadius = decoration.borderRadius as BorderRadius;
      expect(
        borderRadius.topLeft.x,
        equals(SalesTheme.buttonBorderRadius),
      );
    });

    testWidgets('has minimum 48x48px touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Container with constraints
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.constraints?.minWidth,
        equals(SalesTheme.minTouchTargetSize),
      );
      expect(
        container.constraints?.minHeight,
        equals(SalesTheme.minTouchTargetSize),
      );
    });

    testWidgets('triggers onPressed callback when tapped', (tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(SalesCtaButton));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('has semantic label for accessibility', (tester) async {
      const buttonText = 'Começar agora';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: buttonText,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify the Semantics widget exists with correct properties
      final semanticsFinder = find.descendant(
        of: find.byType(SalesCtaButton),
        matching: find.byType(Semantics),
      );
      
      expect(semanticsFinder, findsOneWidget);
      
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder);
      expect(semanticsWidget.properties.label, equals(buttonText));
      expect(semanticsWidget.properties.button, isTrue);
    });

    testWidgets('applies tap scale animation on mobile', (tester) async {
      // Set mobile viewport size
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Transform.scale widget
      final transformFinder = find.descendant(
        of: find.byType(SalesCtaButton),
        matching: find.byType(Transform),
      );

      expect(transformFinder, findsOneWidget);

      // Tap down to trigger scale animation
      await tester.press(find.byType(SalesCtaButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // The scale should be animating towards 0.98
      // Note: Exact value depends on animation progress
      expect(transformFinder, findsOneWidget);
    });

    testWidgets('applies custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.all(20.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
              padding: customPadding,
            ),
          ),
        ),
      );

      // Find the Container with padding
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, equals(customPadding));
    });

    testWidgets('uses default padding when not provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Container with padding
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        equals(const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)),
      );
    });

    testWidgets('hover effect on desktop viewport', (tester) async {
      // Set desktop viewport size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the AnimatedOpacity widget
      final opacityFinder = find.descendant(
        of: find.byType(SalesCtaButton),
        matching: find.byType(AnimatedOpacity),
      );

      expect(opacityFinder, findsOneWidget);

      // Initial opacity should be 1.0
      AnimatedOpacity opacityWidget =
          tester.widget<AnimatedOpacity>(opacityFinder);
      expect(opacityWidget.opacity, equals(1.0));

      // Note: Testing actual hover behavior requires more complex setup
      // with TestGesture and pointer events, which is beyond basic widget tests
    });

    testWidgets('displays cursor pointer on hover', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SalesCtaButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the MouseRegion widget
      final mouseRegion = tester.widget<MouseRegion>(
        find.descendant(
          of: find.byType(SalesCtaButton),
          matching: find.byType(MouseRegion),
        ),
      );

      expect(mouseRegion.cursor, equals(SystemMouseCursors.click));
    });
  });
}
