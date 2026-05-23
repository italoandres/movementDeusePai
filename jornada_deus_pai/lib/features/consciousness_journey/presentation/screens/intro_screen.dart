import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Intro screen - contemplative entry with golden warmth
class JourneyIntroScreen extends StatefulWidget {
  const JourneyIntroScreen({super.key});

  @override
  State<JourneyIntroScreen> createState() => _JourneyIntroScreenState();
}

class _JourneyIntroScreenState extends State<JourneyIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeText;
  late Animation<double> _fadeSubtext;
  late Animation<double> _fadeButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _fadeSubtext = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeIn),
      ),
    );

    _fadeButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
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
            radius: 1.4,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.25),
              const Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fadeText,
                    child: const Text(
                      'Antes de continuar…\nprecisamos te fazer algumas perguntas.',
                      style: TextStyle(
                        color: Color(0xFFF5F1E8),
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeSubtext,
                    child: const Text(
                      'Não é um teste.\nÉ só um espelho.',
                      style: TextStyle(
                        color: Color(0xB3F5F1E8), // 70% opacity
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _fadeButton,
                    child: GestureDetector(
                      onTap: () => context.push('/journey/quiz'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFC6A15B).withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'começar',
                          style: TextStyle(
                            color: Color(0xFFC6A15B),
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
