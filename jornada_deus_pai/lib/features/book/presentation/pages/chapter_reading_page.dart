import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/chapter_controller_providers.dart';
import '../widgets/chapter_text_renderer.dart';

/// Chapter Reading Page
/// Displays chapter content one phrase at a time with tap-to-advance
class ChapterReadingPage extends ConsumerStatefulWidget {
  final int chapterId;

  const ChapterReadingPage({
    super.key,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterReadingPage> createState() => _ChapterReadingPageState();
}

class _ChapterReadingPageState extends ConsumerState<ChapterReadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isAnimating) return;

    final controller = ref.read(chapterControllerProvider(widget.chapterId).notifier);
    final state = ref.read(chapterControllerProvider(widget.chapterId));

    if (state.isComplete) {
      // Navigate back to book home
      context.pop();
      return;
    }

    setState(() {
      _isAnimating = true;
    });

    // Fade out
    _animationController.reverse().then((_) {
      // Move to next and auto-save
      controller.next().then((_) {
        // Fade in
        _animationController.forward().then((_) {
          setState(() {
            _isAnimating = false;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chapterControllerProvider(widget.chapterId));
    final controller = ref.read(chapterControllerProvider(widget.chapterId).notifier);
    final currentItem = controller.currentItem;

    // Show loading while fetching saved progress
    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD4AF37), // Gold
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Main content
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: currentItem != null
                        ? ChapterTextRenderer(item: currentItem)
                        : const SizedBox.shrink(),
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
                    value: state.progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD4AF37), // Gold
                    ),
                    minHeight: 2,
                  ),
                ),
              ),

              // Tap indicator (bottom)
              if (!state.isComplete)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'toque para continuar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),

              // Completion message
              if (state.isComplete)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Capítulo concluído',
                          style: TextStyle(
                            color: const Color(0xFFD4AF37).withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'toque para voltar',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
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

