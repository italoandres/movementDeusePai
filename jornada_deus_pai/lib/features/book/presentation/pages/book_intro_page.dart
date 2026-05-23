import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/constants/intro_content.dart';
import '../state/intro_text_controller.dart';
import '../widgets/intro_text_widget.dart';
import '../widgets/tap_detector_widget.dart';

/// Introduction reading page - displays phrases one at a time
class BookIntroPage extends ConsumerWidget {
  const BookIntroPage({super.key});

  void _handleTap(BuildContext context, WidgetRef ref) {
    final controller = ref.read(introTextControllerProvider.notifier);
    final state = ref.read(introTextControllerProvider);

    if (state.isComplete) {
      // Navigate back to book home
      context.pop();
    } else {
      controller.nextPhrase();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(introTextControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: TapDetectorWidget(
        onTap: () => _handleTap(context, ref),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content - centered text
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 48,
                  ),
                  child: IntroTextWidget(
                    key: ValueKey(state.currentIndex),
                    phrase: state.currentPhrase,
                  ),
                ),
              ),

              // Bottom hint - tap to continue
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    state.isComplete
                        ? "toque para voltar"
                        : IntroContent.tapHint,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              // Progress indicator (top)
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(
                    value: (state.currentIndex + 1) / IntroContent.phrases.length,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD4AF37), // Gold
                    ),
                    minHeight: 2,
                  ),
                ),
              ),

              // Back button (top left)
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                  tooltip: 'Voltar',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
