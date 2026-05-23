import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/quiz_questions.dart';

/// Quiz state notifier
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier() : super(const QuizState());

  void answerQuestion(int questionId, String answer) {
    final newAnswers = Map<int, String>.from(state.answers);
    newAnswers[questionId] = answer;
    state = state.copyWith(answers: newAnswers);
  }

  void nextQuestion() {
    if (state.currentIndex < consciousnessQuizQuestions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  bool get isLastQuestion =>
      state.currentIndex >= consciousnessQuizQuestions.length - 1;

  void reset() {
    state = const QuizState();
  }
}

/// Quiz state
class QuizState {
  final int currentIndex;
  final Map<int, String> answers;

  const QuizState({
    this.currentIndex = 0,
    this.answers = const {},
  });

  QuizState copyWith({
    int? currentIndex,
    Map<int, String>? answers,
  }) {
    return QuizState(
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
    );
  }
}

/// Provider
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
