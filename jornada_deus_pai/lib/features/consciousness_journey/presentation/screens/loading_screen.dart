import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contemplative loading screen - slow, breathing, with golden warmth
class JourneyLoadingScreen extends StatefulWidget {
  const JourneyLoadingScreen({super.key});

  @override
  State<JourneyLoadingScreen> createState() => _JourneyLoadingScreenState();
}

class _JourneyLoadingScreenState extends State<JourneyLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeFirst;
  late Animation<double> _fadeSecond;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    // First phrase fades in slowly (0-25%)
    _fadeFirst = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Second phrase fades in after pause (40-65%)
    _fadeSecond = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.65, curve: Curves.easeIn),
      ),
    );

    // Everything fades out gently at the end (85-100%)
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after full contemplative pause (9 seconds total)
    Future.delayed(const Duration(milliseconds: 9000), () {
      if (mounted) {
        context.pushReplacement('/journey/result');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.3),
              const Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: FadeTransition(
                opacity: _fadeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeFirst,
                      child: const Text(
                        'revisitando sua caminhada…',
                        style: TextStyle(
                          color: Color(0xFFC6A15B),
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 48),
                    FadeTransition(
                      opacity: _fadeSecond,
                      child: const Text(
                        'algumas dores espirituais\nnão nasceram em você.',
                        style: TextStyle(
                          color: Color(0xFFF5F1E8),
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.3,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
