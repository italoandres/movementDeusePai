import 'package:flutter/material.dart';

/// Theme constants for the Sales Landing Page
///
/// Defines colors, typography, and spacing values following the
/// contemplative minimalist design philosophy.
class SalesTheme {
  // Color Constants
  /// Background color - Pure black for contemplative atmosphere
  static const Color backgroundColor = Color(0xFF000000);

  /// Primary text color - Pure white for maximum contrast
  static const Color textColor = Color(0xFFFFFFFF);

  /// Accent color - Gold for highlights and CTAs
  static const Color accentColor = Color(0xFFD4AF37);

  // Typography Sizes - Desktop
  /// Hero section main text size on desktop
  static const double heroFontSizeDesktop = 48.0;

  /// Hero section subtext size on desktop
  static const double heroSubtextSizeDesktop = 20.0;

  /// Standard body text size on desktop
  static const double bodyFontSizeDesktop = 24.0;

  /// Revelação section text size on desktop
  static const double revelacaoFontSizeDesktop = 32.0;

  /// Silêncio section text size (same for desktop and mobile)
  static const double silencioFontSize = 16.0;

  // Typography Sizes - Mobile
  /// Hero section main text size on mobile
  static const double heroFontSizeMobile = 32.0;

  /// Hero section subtext size on mobile
  static const double heroSubtextSizeMobile = 16.0;

  /// Standard body text size on mobile
  static const double bodyFontSizeMobile = 18.0;

  /// Revelação section text size on mobile
  static const double revelacaoFontSizeMobile = 24.0;

  // Typography Weights
  /// Light font weight for body text
  static const FontWeight bodyFontWeight = FontWeight.w300;

  /// Regular font weight for emphasis text
  static const FontWeight emphasisFontWeight = FontWeight.w400;

  // Typography Line Height
  /// Line height for all body text
  static const double bodyLineHeight = 1.6;

  // Spacing Values - Desktop
  /// Vertical spacing between sections on desktop
  static const double sectionSpacingDesktop = 96.0;

  /// Spacing between hero main text and subtext
  static const double heroTextSpacing = 24.0;

  /// Spacing between hero subtext and CTA button
  static const double heroCtaSpacing = 48.0;

  /// Spacing between questions in Dor section
  static const double dorQuestionSpacing = 48.0;

  /// Spacing after Momento Guiado text
  static const double momentoGuiadoSpacing = 96.0;

  // Spacing Values - Mobile
  /// Vertical spacing between sections on mobile
  static const double sectionSpacingMobile = 64.0;

  // Layout Constants
  /// Maximum content width on desktop
  static const double desktopMaxWidth = 800.0;

  /// Horizontal padding on mobile
  static const double mobilePadding = 24.0;

  // Button Constants
  /// Border radius for CTA buttons
  static const double buttonBorderRadius = 8.0;

  /// Minimum touch target size for buttons
  static const double minTouchTargetSize = 48.0;

  /// Button hover opacity
  static const double buttonHoverOpacity = 0.9;

  /// Button tap scale
  static const double buttonTapScale = 0.98;

  // Animation Constants
  /// Duration for fade-in animations (increased for more contemplative feel)
  static const Duration fadeAnimationDuration = Duration(milliseconds: 800);

  /// Duration for button hover transitions
  static const Duration buttonHoverDuration = Duration(milliseconds: 200);

  /// Duration for button tap transitions
  static const Duration buttonTapDuration = Duration(milliseconds: 100);

  /// Duration for smooth scroll animations
  static const Duration scrollAnimationDuration = Duration(milliseconds: 600);

  /// Sequential delay between text animations (increased for emotional impact)
  static const Duration textAnimationDelay = Duration(milliseconds: 600);

  // Momento Guiado Border
  /// Border width for Momento Guiado section
  static const double momentoGuiadoBorderWidth = 1.0;

  // Silêncio Text Opacity
  /// Opacity for Silêncio section text
  static const double silencioTextOpacity = 0.7;
}
