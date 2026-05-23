import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// "Ver resultado" screen - micro silence with golden warmth
class ResultRevealScreen extends StatefulWidget {
  const ResultRevealScreen({super.key});

  @override
  State<ResultRevealScreen> createState() => _ResultRevealScreenState();
}

class _ResultRevealScreenState extends State<ResultRevealScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeText;
  late Animation<double> _fadeButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _fadeText = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _fadeButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _fadeText,
                    child: const Text(
                      'Existe uma razão\npara você sentir isso.',
                      style: TextStyle(
                        color: Color(0xFFF5F1E8),
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.3,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 2),
                  FadeTransition(
                    opacity: _fadeButton,
                    child: GestureDetector(
                      onTap: () => context.push('/journey/loading'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFC6A15B).withOpacity(0.35),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'ver resultado',
                          style: TextStyle(
                            color: Color(0xFFC6A15B),
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.8,
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
