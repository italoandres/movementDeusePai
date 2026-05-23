import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Thank You / Obrigado screen - after payment approved
/// Contemplative, minimal, golden warmth
///
/// Headline: "Seu acesso foi preparado."
/// Button: "Criar meu acesso" → leads to account creation
class ThankYouScreen extends ConsumerStatefulWidget {
  const ThankYouScreen({super.key});

  @override
  ConsumerState<ThankYouScreen> createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends ConsumerState<ThankYouScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeHeadline;
  late Animation<double> _fadeText;
  late Animation<double> _fadeButton;

  // Design tokens
  static const _bgColor = Color(0xFF0D0D0D);
  static const _goldPrimary = Color(0xFFC6A15B);
  static const _textPrimary = Color(0xFFF5F1E8);
  static const _textSecondary = Color(0xB3F5F1E8);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _fadeHeadline = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
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
      backgroundColor: _bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.25),
              _bgColor,
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

                  // Headline
                  FadeTransition(
                    opacity: _fadeHeadline,
                    child: const Text(
                      'Seu acesso foi preparado.',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Divider
                  FadeTransition(
                    opacity: _fadeText,
                    child: Container(
                      width: 30,
                      height: 1,
                      color: _goldPrimary.withOpacity(0.2),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Body text
                  FadeTransition(
                    opacity: _fadeText,
                    child: const Text(
                      'Leia sem pressa.\nEscute em silêncio.\n\nE permita que o Pai reconstrua\naquilo que a religião cansou em você.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CTA Button
                  FadeTransition(
                    opacity: _fadeButton,
                    child: GestureDetector(
                      onTap: () => context.push('/criar-acesso'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _goldPrimary.withOpacity(0.08),
                          border: Border.all(
                            color: _goldPrimary.withOpacity(0.35),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'criar meu acesso',
                          style: TextStyle(
                            color: _goldPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
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
