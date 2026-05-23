import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/sales_content.dart';
import '../../data/constants/sales_theme.dart';
import '../../domain/models/responsive_breakpoints.dart';

/// Special section for guided spiritual moment with visual emphasis
///
/// Displays the "Momento Guiado" text with a subtle gold border,
/// creating a contemplative pause in the sales page flow.
///
/// Features:
/// - Displays text: "Fecha os olhos por um instante… e fala com Ele agora."
/// - Subtle gold border (1px solid #D4AF37)
/// - 96px vertical spacing after text for contemplative pause
/// - Fade-in animation when visible
/// - Centers content horizontally
/// - Responsive padding (800px max width desktop, 24px padding mobile)
///
/// Requirements: 9.1, 9.2, 9.3, 9.4, 20.6
class SalesMomentoGuiadoSection extends ConsumerWidget {
  /// Controls visibility and fade-in animation
  final bool isVisible;

  const SalesMomentoGuiadoSection({
    super.key,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine responsive padding
    final horizontalPadding = ResponsiveBreakpoints.isMobile(context)
        ? SalesTheme.mobilePadding
        : 0.0;

    // Determine max width constraint
    final maxWidth = ResponsiveBreakpoints.isDesktop(context)
        ? SalesTheme.desktopMaxWidth
        : double.infinity;

    // Build text style
    final textStyle = TextStyle(
      fontSize: ResponsiveBreakpoints.valueWhen(
        context,
        desktop: SalesTheme.bodyFontSizeDesktop,
        mobile: SalesTheme.bodyFontSizeMobile,
      ),
      fontWeight: SalesTheme.bodyFontWeight,
      color: SalesTheme.textColor,
      height: SalesTheme.bodyLineHeight,
    );

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: SalesTheme.fadeAnimationDuration,
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        margin: EdgeInsets.only(bottom: SalesTheme.momentoGuiadoSpacing),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: SalesTheme.accentColor,
                width: SalesTheme.momentoGuiadoBorderWidth,
              ),
            ),
            child: Text(
              SalesContent.momentoGuiadoText,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
