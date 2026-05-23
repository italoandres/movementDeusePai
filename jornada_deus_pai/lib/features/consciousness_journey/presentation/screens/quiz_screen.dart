import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/constants/quiz_questions.dart';
import '../state/quiz_state.dart';

/// Quiz screen - one question at a time, contemplative golden warmth
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectOption(String option) async {
    if (_isTransitioning) return;

    final quizNotifier = ref.read(quizProvider.notifier);
    final currentState = ref.read(quizProvider);
    final question = consciousnessQuizQuestions[currentState.currentIndex];

    // Save answer
    quizNotifier.answerQuestion(question.id, option);

    // Fade out
    setState(() => _isTransitioning = true);
    await _fadeController.reverse();

    // Contemplative pause between questions
    await Future.delayed(const Duration(milliseconds: 400));

    // Check if last question
    if (quizNotifier.isLastQuestion) {
      if (mounted) {
        context.push('/journey/reveal');
      }
      return;
    }

    // Next question
    quizNotifier.nextQuestion();

    setState(() => _isTransitioning = false);
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final question = consciousnessQuizQuestions[state.currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              const Color(0xFF1A121C).withOpacity(0.2),
              const Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Question text
                  Text(
                    question.text,
                    style: const TextStyle(
                      color: Color(0xFFF5F1E8),
                      fontSize: 21,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.2,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Options
                  ...question.options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => _selectOption(option),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFC6A15B).withOpacity(0.15),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Color(0xB3F5F1E8), // 70% opacity warm
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }),

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
