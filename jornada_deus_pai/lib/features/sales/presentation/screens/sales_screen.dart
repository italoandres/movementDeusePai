import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/sales_content.dart';
import '../../data/constants/sales_theme.dart';
import '../../domain/models/responsive_breakpoints.dart';
import '../providers/sales_navigation_provider.dart';
import '../widgets/sales_cta_button.dart';

/// Main screen for the Sales Landing Page
///
/// This screen creates an emotional journey that leads visitors to recognize
/// their deep need for a Father and guides them toward action. The design is
/// minimalist and contemplative, with sequential fade-in animations that create
/// a powerful emotional impact.
///
/// Features:
/// - Sequential text animations with emotional pacing
/// - Black background with white text and gold accents
/// - Generous spacing for contemplative reading
/// - Single powerful CTA button
/// - Optional support text
///
/// **Validates: Emotional sales page requirements**
class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  /// Tracks which texts are currently visible
  final List<bool> _textVisibility = List.generate(
    SalesContent.heroTexts.length + 2, // texts + button + support
    (_) => false,
  );

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  /// Starts the sequential fade-in animation for all texts
  void _startAnimationSequence() {
    // Animate each text with a delay
    for (int i = 0; i < _textVisibility.length; i++) {
      Future.delayed(SalesTheme.textAnimationDelay * i, () {
        if (mounted) {
          setState(() {
            _textVisibility[i] = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigation = ref.read(salesNavigationProvider);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Scaffold(
      backgroundColor: SalesTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 0 : SalesTheme.mobilePadding,
            vertical: 80.0,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? SalesTheme.desktopMaxWidth : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero texts - emotional journey
                  ...List.generate(
                    SalesContent.heroTexts.length,
                    (index) => _buildAnimatedText(
                      SalesContent.heroTexts[index],
                      _textVisibility[index],
                      isDesktop,
                    ),
                  ),

                  // Extra spacing before button
                  const SizedBox(height: 80),

                  // CTA Button
                  AnimatedOpacity(
                    opacity: _textVisibility[SalesContent.heroTexts.length] ? 1.0 : 0.0,
                    duration: SalesTheme.fadeAnimationDuration,
                    curve: Curves.easeOut,
                    child: SalesCtaButton(
                      text: SalesContent.ctaButtonText,
                      onPressed: () => navigation.navigateToCheckout(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48.0,
                        vertical: 20.0,
                      ),
                    ),
                  ),

                  // Extra spacing before support text
                  const SizedBox(height: 80),

                  // Support text
                  AnimatedOpacity(
                    opacity: _textVisibility[SalesContent.heroTexts.length + 1] ? 1.0 : 0.0,
                    duration: SalesTheme.fadeAnimationDuration,
                    curve: Curves.easeOut,
                    child: Text(
                      SalesContent.supportText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 16.0 : 14.0,
                        fontWeight: FontWeight.w300,
                        color: SalesTheme.textColor.withOpacity(0.6),
                        height: 1.8,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an animated text widget with fade-in effect
  Widget _buildAnimatedText(String text, bool isVisible, bool isDesktop) {
    // Determine font size based on text length and emphasis
    double fontSize;
    FontWeight fontWeight;

    if (text.length < 30) {
      // Short, impactful phrases
      fontSize = isDesktop ? 32.0 : 24.0;
      fontWeight = FontWeight.w400;
    } else if (text.length < 60) {
      // Medium phrases
      fontSize = isDesktop ? 28.0 : 22.0;
      fontWeight = FontWeight.w300;
    } else {
      // Longer, descriptive phrases
      fontSize = isDesktop ? 24.0 : 20.0;
      fontWeight = FontWeight.w300;
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: SalesTheme.fadeAnimationDuration,
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 48.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: SalesTheme.textColor,
            height: 1.8,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
