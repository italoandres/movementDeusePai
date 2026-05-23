import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/sales_theme.dart';
import '../../domain/models/responsive_breakpoints.dart';

/// Reusable text section widget for the Sales Landing Page
///
/// Displays text content with fade-in animation, responsive layout,
/// and configurable styling. Used for standard content sections
/// throughout the sales page.
///
/// Features:
/// - AnimatedOpacity with 700ms duration and ease-out curve
/// - Responsive padding (800px max width desktop, 24px padding mobile)
/// - Configurable vertical spacing between sections
/// - Custom text styling and color support
/// - Riverpod state management integration
class SalesTextSection extends ConsumerWidget {
  /// The text content to display
  final String text;

  /// Optional custom text style (overrides default)
  final TextStyle? textStyle;

  /// Optional custom text color (overrides default white)
  final Color? textColor;

  /// Vertical spacing after this section (default: 96px)
  final double verticalSpacing;

  /// Controls visibility and fade-in animation
  final bool isVisible;

  const SalesTextSection({
    super.key,
    required this.text,
    this.textStyle,
    this.textColor,
    this.verticalSpacing = 96.0,
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

    // Build default text style if not provided
    final effectiveTextStyle = textStyle ??
        TextStyle(
          fontSize: ResponsiveBreakpoints.valueWhen(
            context,
            desktop: SalesTheme.bodyFontSizeDesktop,
            mobile: SalesTheme.bodyFontSizeMobile,
          ),
          fontWeight: SalesTheme.bodyFontWeight,
          color: textColor ?? SalesTheme.textColor,
          height: SalesTheme.bodyLineHeight,
        );

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: SalesTheme.fadeAnimationDuration,
      curve: Curves.easeOut,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        margin: EdgeInsets.only(bottom: verticalSpacing),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: effectiveTextStyle.copyWith(
              color: textColor ?? effectiveTextStyle.color,
            ),
          ),
        ),
      ),
    );
  }
}
