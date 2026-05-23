import 'package:flutter/material.dart';

/// Widget that displays a single phrase with fade animation
class IntroTextWidget extends StatefulWidget {
  final String phrase;
  final VoidCallback? onAnimationComplete;

  const IntroTextWidget({
    super.key,
    required this.phrase,
    this.onAnimationComplete,
  });

  @override
  State<IntroTextWidget> createState() => _IntroTextWidgetState();
}

class _IntroTextWidgetState extends State<IntroTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void didUpdateWidget(IntroTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phrase != widget.phrase) {
      // Restart animation when phrase changes
      _controller.reset();
      _controller.forward().then((_) {
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return FadeTransition(
      opacity: _animation,
      child: Text(
        widget.phrase,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 24 : 32,
          fontWeight: FontWeight.w300,
          height: 1.6,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
