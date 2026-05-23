import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/book_content.dart';
import '../providers/progress_providers.dart';
import 'fade_in_widget.dart';

/// Call-to-action button for starting or continuing reading
class CTAButton extends ConsumerWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  const CTAButton({
    super.key,
    required this.isMobile,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapter = ref.watch(currentChapterProvider);
    final hasStarted = currentChapter > 1;
    
    final buttonText = hasStarted
        ? BookContent.continueReadingButton
        : BookContent.startReadingButton;

    final semanticLabel = hasStarted
        ? 'Continuar leitura do capítulo $currentChapter'
        : 'Começar leitura do capítulo 1';

    return FadeInWidget(
      delay: const Duration(milliseconds: 800),
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: SizedBox(
          width: isMobile ? double.infinity : null,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37), // Gold
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 32 : 48,
                vertical: isMobile ? 16 : 20,
              ),
              textStyle: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(buttonText),
          ),
        ),
      ),
    );
  }
}
