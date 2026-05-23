import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/sales_content.dart';
import '../../data/constants/sales_theme.dart';
import 'sales_cta_button.dart';

/// Hero section widget for the sales landing page.
///
/// This widget displays the main message of the landing page with a primary
/// call-to-action button. It implements a fade-in animation on mount and
/// responsive typography that adapts to desktop and mobile viewports.
///
/// Features:
/// - Main text: "Você não precisa orar… você pode falar com o Pai"
///   - 48px on desktop, 32px on mobile
/// - Subtext: "Talvez ninguém nunca tenha te ensinado isso."
///   - 20px on desktop, 16px on mobile
/// - Primary CTA button: "Começar agora"
/// - 24px spacing between main text and subtext
/// - 48px spacing between subtext and button
/// - Fade-in animation on mount (700ms duration)
/// - Centered content vertically and horizontally
///
/// **Validates: Requirements 3.1, 3.2, 3.3, 14.1-14.4, 20.3, 20.4**
class SalesHeroSection extends ConsumerStatefulWidget {
  /// Callback function when the CTA button is pressed
  final VoidCallback onCtaPressed;

  const SalesHeroSection({
    super.key,
    required this.onCtaPressed,
  });

  @override
  ConsumerState<SalesHeroSection> createState() => _SalesHeroSectionState();
}

class _SalesHeroSectionState extends ConsumerState<SalesHeroSection>
    with SingleTickerProviderStateMixin {
  /// Animation controller for fade-in effect
  late AnimationController _animationController;

  /// Animation for opacity fade-in
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: SalesTheme.fadeAnimationDuration,
      vsync: this,
    );

    // Create fade animation from 0.0 to 1.0
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Start animation on mount
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on desktop (for responsive typography)
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    // Calculate responsive font sizes
    final mainTextSize = isDesktop
        ? SalesTheme.heroFontSizeDesktop
        : SalesTheme.heroFontSizeMobile;
    final subtextSize = isDesktop
        ? SalesTheme.heroSubtextSizeDesktop
        : SalesTheme.heroSubtextSizeMobile;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        // Full viewport height for hero section
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        // Center content vertically and horizontally
        child: Center(
          child: Container(
            // Apply responsive max width and padding
            constraints: BoxConstraints(
              maxWidth: isDesktop
                  ? SalesTheme.desktopMaxWidth
                  : double.infinity,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 0 : SalesTheme.mobilePadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main text
                Text(
                  SalesContent.heroMainText,
                  style: TextStyle(
                    fontSize: mainTextSize,
                    fontWeight: SalesTheme.bodyFontWeight,
                    color: SalesTheme.textColor,
                    height: SalesTheme.bodyLineHeight,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Spacing between main text and subtext (24px)
                const SizedBox(height: SalesTheme.heroTextSpacing),

                // Subtext
                Text(
                  SalesContent.heroSubtext,
                  style: TextStyle(
                    fontSize: subtextSize,
                    fontWeight: SalesTheme.bodyFontWeight,
                    color: SalesTheme.textColor,
                    height: SalesTheme.bodyLineHeight,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Spacing between subtext and button (48px)
                const SizedBox(height: SalesTheme.heroCtaSpacing),

                // CTA Button
                SalesCtaButton(
                  text: SalesContent.heroCtaText,
                  onPressed: widget.onCtaPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
