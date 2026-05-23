import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Emotional result screen - gives language to the pain, golden warmth
class EmotionalResultScreen extends StatefulWidget {
  const EmotionalResultScreen({super.key});

  @override
  State<EmotionalResultScreen> createState() => _EmotionalResultScreenState();
}

class _EmotionalResultScreenState extends State<EmotionalResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeHeadline;
  late Animation<double> _fadeBody1;
  late Animation<double> _fadeBody2;
  late Animation<double> _fadeBody3;
  late Animation<double> _fadeButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );

    _fadeHeadline = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    _fadeBody1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.35, curve: Curves.easeIn),
      ),
    );

    _fadeBody2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.55, curve: Curves.easeIn),
      ),
    );

    _fadeBody3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.75, curve: Curves.easeIn),
      ),
    );

    _fadeButton = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.82, 1.0, curve: Curves.easeIn),
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
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.2),
              const Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Headline
                    FadeTransition(
                      opacity: _fadeHeadline,
                      child: const Text(
                        'Você não se afastou de Deus.\n\nVocê apenas aprendeu a se relacionar com Ele como alguém distante.',
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

                    const SizedBox(height: 56),

                    // Subtle golden divider
                    FadeTransition(
                      opacity: _fadeBody1,
                      child: Container(
                        width: 40,
                        height: 1,
                        color: const Color(0xFFC6A15B).withOpacity(0.3),
                      ),
                    ),

                    const SizedBox(height: 56),

                    // Body 1
                    FadeTransition(
                      opacity: _fadeBody1,
                      child: const Text(
                        'Durante muito tempo, você pode ter aprendido sobre obrigação, medo, culpa, performance espiritual.\n\nMas Jesus não veio apenas ensinar pessoas a obedecer.\nEle veio revelar acesso ao Pai.',
                        style: TextStyle(
                          color: Color(0xB3F5F1E8), // 70%
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Body 2
                    FadeTransition(
                      opacity: _fadeBody2,
                      child: const Text(
                        'Talvez o vazio que você sente não seja falta de esforço.\n\nTalvez seja falta de relacionamento.',
                        style: TextStyle(
                          color: Color(0xB3F5F1E8),
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Body 3
                    FadeTransition(
                      opacity: _fadeBody3,
                      child: const Text(
                        'Existe uma diferença entre:\n\nservir um Deus distante\n\nou\n\nviver como filho diante do Pai.',
                        style: TextStyle(
                          color: Color(0xFFF5F1E8),
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          height: 1.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 72),

                    // Button
                    FadeTransition(
                      opacity: _fadeButton,
                      child: GestureDetector(
                        onTap: () => context.push('/journey/sales'),
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
                            'continuar',
                            style: TextStyle(
                              color: Color(0xFFC6A15B),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
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
