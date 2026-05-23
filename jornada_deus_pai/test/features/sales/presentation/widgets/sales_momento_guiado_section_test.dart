import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jornada_deus_pai/features/sales/data/constants/sales_content.dart';
import 'package:jornada_deus_pai/features/sales/data/constants/sales_theme.dart';
import 'package:jornada_deus_pai/features/sales/presentation/widgets/sales_momento_guiado_section.dart';

void main() {
  group('SalesMomentoGuiadoSection', () {
    testWidgets('renders momento guiado text correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text(SalesContent.momentoGuiadoText), findsOneWidget);
      expect(
        find.text('Fecha os olhos por um instante… e fala com Ele agora.'),
        findsOneWidget,
      );
    });

    testWidgets('applies fade-in animation when isVisible changes',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
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
              body: SalesMomentoGuiadoSection(
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
              body: SalesMomentoGuiadoSection(
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
              body: SalesMomentoGuiadoSection(
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

    testWidgets('applies gold border with 1px width', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the inner Container with border decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final borderedContainer = containers.firstWhere(
        (container) => container.decoration is BoxDecoration,
      );

      final decoration = borderedContainer.decoration as BoxDecoration;
      final border = decoration.border as Border;

      // Verify border color is gold
      expect(border.top.color, SalesTheme.accentColor);
      expect(border.top.color, const Color(0xFFD4AF37));

      // Verify border width is 1px
      expect(border.top.width, SalesTheme.momentoGuiadoBorderWidth);
      expect(border.top.width, 1.0);
    });

    testWidgets('applies 96px vertical spacing after text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the outer Container with margin
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outerContainer = containers.firstWhere(
        (container) =>
            container.margin == EdgeInsets.only(bottom: SalesTheme.momentoGuiadoSpacing),
      );

      expect(
        outerContainer.margin,
        const EdgeInsets.only(bottom: 96.0),
      );
    });

    testWidgets('centers text horizontally', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the Text widget
      final textWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));

      // Verify text alignment is center
      expect(textWidget.textAlign, TextAlign.center);

      // Verify there's a Center widget in the tree
      expect(find.byType(Center), findsOneWidget);
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
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the outer Container with constraints
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outerContainer = containers.firstWhere(
        (container) => container.constraints != null,
      );

      expect(outerContainer.constraints?.maxWidth, SalesTheme.desktopMaxWidth);
      expect(outerContainer.constraints?.maxWidth, 800.0);
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
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the outer Container with padding
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outerContainer = containers.firstWhere(
        (container) => container.padding != null && container.constraints != null,
      );

      expect(
        outerContainer.padding,
        const EdgeInsets.symmetric(horizontal: SalesTheme.mobilePadding),
      );
      expect(
        outerContainer.padding,
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
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the outer Container with padding
      final containers = tester.widgetList<Container>(find.byType(Container));
      final outerContainer = containers.firstWhere(
        (container) => container.padding != null && container.constraints != null,
      );

      expect(
        outerContainer.padding,
        const EdgeInsets.symmetric(horizontal: 0.0),
      );
    });

    testWidgets('uses white text color from theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));

      expect(textWidget.style?.color, SalesTheme.textColor);
      expect(textWidget.style?.color, const Color(0xFFFFFFFF));
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
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final desktopTextWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));
      expect(
        desktopTextWidget.style?.fontSize,
        SalesTheme.bodyFontSizeDesktop,
      );
      expect(desktopTextWidget.style?.fontSize, 24.0);

      // Test mobile font size
      tester.view.physicalSize = const Size(375, 667);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final mobileTextWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));
      expect(
        mobileTextWidget.style?.fontSize,
        SalesTheme.bodyFontSizeMobile,
      );
      expect(mobileTextWidget.style?.fontSize, 18.0);
    });

    testWidgets('applies 24px padding inside border container', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      // Find the inner Container with border decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      final borderedContainer = containers.firstWhere(
        (container) => container.decoration is BoxDecoration,
      );

      expect(borderedContainer.padding, const EdgeInsets.all(24.0));
    });

    testWidgets('uses light font weight', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));

      expect(textWidget.style?.fontWeight, SalesTheme.bodyFontWeight);
      expect(textWidget.style?.fontWeight, FontWeight.w300);
    });

    testWidgets('uses 1.6 line height', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SalesMomentoGuiadoSection(
                isVisible: true,
              ),
            ),
          ),
        ),
      );

      final textWidget =
          tester.widget<Text>(find.text(SalesContent.momentoGuiadoText));

      expect(textWidget.style?.height, SalesTheme.bodyLineHeight);
      expect(textWidget.style?.height, 1.6);
    });
  });
}
