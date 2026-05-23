import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Access Created screen - "a silent door opening"
/// Between /receber-carta and /carta
class AccessCreatedScreen extends StatefulWidget {
  const AccessCreatedScreen({super.key});

  @override
  State<AccessCreatedScreen> createState() => _AccessCreatedScreenState();
}

class _AccessCreatedScreenState extends State<AccessCreatedScreen>
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
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),

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

                  // Body
                  FadeTransition(
                    opacity: _fadeText,
                    child: const Text(
                      'Não como alguém que chegou perfeito.\nMas como alguém que decidiu começar.\n\nA partir daqui, essa caminhada\ntambém pode ser sua.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w300,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                    const SizedBox(height: 60),

                    // Button
                    FadeTransition(
                    opacity: _fadeButton,
                    child: GestureDetector(
                      onTap: () => context.go('/home'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _goldPrimary.withOpacity(0.08),
                          border: Border.all(
                            color: _goldPrimary.withOpacity(0.35),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'receber a carta',
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

                    const SizedBox(height: 80),
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
