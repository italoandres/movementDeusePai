import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornada_deus_pai/features/sales/data/constants/sales_theme.dart';
import 'package:jornada_deus_pai/features/sales/presentation/widgets/sales_text_section.dart';

void main() {
  group('SalesTextSection', () {
    testWidgets('renders text content correctly', (tester) async {
      const testText = 'Test content text';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: testText,
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('applies fade-in animation when isVisible changes',
        (tester) async {
      const testText = 'Animated text';

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: testText,
                isVisible: false,
              ),
            ),
          ),
        ),
      );

      // Find the AnimatedOpacity widget
      final animatedOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));

      // Verify initial opacity is 0
      expect(animatedOpacity.opacity, 0.0);

      // Update to visible
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: testText,
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Verify opacity is now 1
      final updatedAnimatedOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(updatedAnimatedOpacity.opacity, 1.0);
    });

    testWidgets('uses 700ms duration for animation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Test',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final animatedOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));

      expect(animatedOpacity.duration, SalesTheme.fadeAnimationDuration);
      expect(animatedOpacity.duration.inMilliseconds, 700);
    });

    testWidgets('uses ease-out curve for animation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Test',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final animatedOpacity =
          tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));

      expect(animatedOpacity.curve, Curves.easeOut);
    });

    testWidgets('centers text horizontally', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Centered text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the Text widget
      final textWidget = tester.widget<Text>(find.text('Centered text'));

      // Verify text alignment is center
      expect(textWidget.textAlign, TextAlign.center);

      // Verify there's a Center widget in the tree
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('applies custom text style when provided', (tester) async {
      const customStyle = TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Custom styled text',
                textStyle: customStyle,
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Custom styled text'));

      expect(textWidget.style?.fontSize, 30.0);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('applies custom text color when provided', (tester) async {
      const customColor = Colors.blue;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Custom colored text',
                textColor: customColor,
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Custom colored text'));

      expect(textWidget.style?.color, customColor);
    });

    testWidgets('applies custom vertical spacing', (tester) async {
      const customSpacing = 120.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Spaced text',
                verticalSpacing: customSpacing,
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the Container widget
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      expect(container.margin, EdgeInsets.only(bottom: customSpacing));
    });

    testWidgets('uses default vertical spacing of 96px', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Default spacing',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      expect(container.margin, const EdgeInsets.only(bottom: 96.0));
    });

    testWidgets('applies 800px max width on desktop', (tester) async {
      // Set desktop viewport size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Desktop text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.maxWidth, SalesTheme.desktopMaxWidth);
      expect(container.constraints?.maxWidth, 800.0);
    });

    testWidgets('applies 24px padding on mobile', (tester) async {
      // Set mobile viewport size
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Mobile text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: SalesTheme.mobilePadding),
      );
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 24.0),
      );
    });

    testWidgets('applies no horizontal padding on desktop', (tester) async {
      // Set desktop viewport size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Desktop text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(Center),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 0.0),
      );
    });

    testWidgets('uses default white text color from theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Default color text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Default color text'));

      expect(textWidget.style?.color, SalesTheme.textColor);
    });

    testWidgets('uses responsive font sizes', (tester) async {
      // Test desktop font size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Responsive text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final desktopTextWidget =
          tester.widget<Text>(find.text('Responsive text'));
      expect(
          desktopTextWidget.style?.fontSize, SalesTheme.bodyFontSizeDesktop);

      // Test mobile font size
      tester.view.physicalSize = const Size(375, 667);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesTextSection(
                text: 'Responsive text',
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final mobileTextWidget =
          tester.widget<Text>(find.text('Responsive text'));
      expect(mobileTextWidget.style?.fontSize, SalesTheme.bodyFontSizeMobile);
    });
  });
}
