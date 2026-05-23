import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/intro_content.dart';

/// State for the introduction text reader
class IntroTextState {
  final int currentIndex;
  final bool isComplete;

  const IntroTextState({
    required this.currentIndex,
    required this.isComplete,
  });

  factory IntroTextState.initial() {
    return const IntroTextState(
      currentIndex: 0,
      isComplete: false,
    );
  }

  IntroTextState copyWith({
    int? currentIndex,
    bool? isComplete,
  }) {
    return IntroTextState(
      currentIndex: currentIndex ?? this.currentIndex,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  String get currentPhrase {
    if (currentIndex >= IntroContent.phrases.length) {
      return IntroContent.phrases.last;
    }
    return IntroContent.phrases[currentIndex];
  }

  bool get hasNext {
    return currentIndex < IntroContent.phrases.length - 1;
  }
}

/// Controller for managing introduction text navigation
class IntroTextController extends StateNotifier<IntroTextState> {
  IntroTextController() : super(IntroTextState.initial());

  /// Advances to the next phrase
  void nextPhrase() {
    if (state.hasNext) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
      );
    } else {
      // Mark as complete when reaching the end
      state = state.copyWith(isComplete: true);
    }
  }

  /// Resets to the beginning
  void reset() {
    state = IntroTextState.initial();
  }

  /// Gets the progress percentage (0.0 to 1.0)
  double get progress {
    return (state.currentIndex + 1) / IntroContent.phrases.length;
  }
}

/// Provider for the intro text controller
final introTextControllerProvider =
    StateNotifierProvider<IntroTextController, IntroTextState>((ref) {
  return IntroTextController();
});
