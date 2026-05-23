import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import 'progress_state.dart';

/// StateNotifier that manages user reading progress
class ProgressNotifier extends StateNotifier<ProgressState> {
  final ProgressRepository _repository;

  ProgressNotifier(this._repository) : super(ProgressState.initial());

  /// Loads progress from the repository
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final progress = await _repository.getProgress();
      
      if (progress != null) {
        state = ProgressState(
          currentChapter: progress.currentChapter,
          completedChapters: progress.completedChapters,
          unlockedChapters: progress.unlockedChapters,
          isLoading: false,
          error: null,
        );
      } else {
        // No saved progress, use initial state
        state = ProgressState.initial();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Não foi possível carregar seu progresso. Começando do Capítulo 1.',
      );
    }
  }

  /// Marks a chapter as completed and unlocks the next chapter
  Future<void> completeChapter(int chapterId) async {
    // Add to completed chapters if not already there
    final updatedCompleted = [...state.completedChapters];
    if (!updatedCompleted.contains(chapterId)) {
      updatedCompleted.add(chapterId);
    }

    // Unlock next chapter if not already unlocked
    final updatedUnlocked = [...state.unlockedChapters];
    final nextChapterId = chapterId + 1;
    if (!updatedUnlocked.contains(nextChapterId)) {
      updatedUnlocked.add(nextChapterId);
    }

    // Update current chapter to next chapter
    final nextChapter = nextChapterId;

    // Update state
    state = state.copyWith(
      currentChapter: nextChapter,
      completedChapters: updatedCompleted,
      unlockedChapters: updatedUnlocked,
      error: null,
    );

    // Save progress
    await _saveProgress();
  }

  /// Updates the current chapter (for navigation purposes)
  Future<void> setCurrentChapter(int chapterId) async {
    // Only allow setting to unlocked chapters
    if (!state.unlockedChapters.contains(chapterId)) {
      return;
    }

    state = state.copyWith(
      currentChapter: chapterId,
      error: null,
    );

    await _saveProgress();
  }

  /// Private method to save progress to repository
  Future<void> _saveProgress() async {
    try {
      final progress = UserProgress(
        currentChapter: state.currentChapter,
        completedChapters: state.completedChapters,
        unlockedChapters: state.unlockedChapters,
      );
      
      await _repository.saveProgress(progress);
    } catch (e) {
      state = state.copyWith(
        error: 'Não foi possível salvar seu progresso. Verifique o espaço disponível.',
      );
    }
  }

  /// Clears all progress and resets to initial state
  Future<void> clearProgress() async {
    try {
      await _repository.clearProgress();
      state = ProgressState.initial();
    } catch (e) {
      state = state.copyWith(
        error: 'Não foi possível limpar o progresso.',
      );
    }
  }
}
