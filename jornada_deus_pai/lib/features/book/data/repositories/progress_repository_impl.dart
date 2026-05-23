import '../../domain/models/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../data_sources/progress_local_data_source.dart';
import '../constants/book_content.dart';

/// Implementation of ProgressRepository using Local Storage
class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressLocalDataSource _localDataSource;

  ProgressRepositoryImpl(this._localDataSource);

  @override
  Future<UserProgress?> getProgress() async {
    try {
      final progress = await _localDataSource.getProgress();
      if (progress == null) return null;

      // Validate and correct invalid state
      return _validateProgress(progress);
    } catch (e) {
      throw Exception('Failed to load progress: $e');
    }
  }

  @override
  Future<void> saveProgress(UserProgress progress) async {
    try {
      // Validate before saving
      final validatedProgress = _validateProgress(progress);
      await _localDataSource.saveProgress(validatedProgress);
    } catch (e) {
      throw Exception('Failed to save progress: $e');
    }
  }

  @override
  Future<void> clearProgress() async {
    try {
      await _localDataSource.clearProgress();
    } catch (e) {
      throw Exception('Failed to clear progress: $e');
    }
  }

  /// Validates and corrects invalid progress state
  UserProgress _validateProgress(UserProgress progress) {
    final totalChapters = BookContent.chapterTitles.length;

    // Correct current chapter if out of bounds
    final validCurrentChapter = progress.currentChapter.clamp(1, totalChapters);

    // Remove invalid chapter IDs from completed list
    final validCompleted = progress.completedChapters
        .where((id) => id >= 1 && id <= totalChapters)
        .toList();

    // Remove invalid chapter IDs from unlocked list
    final validUnlocked = progress.unlockedChapters
        .where((id) => id >= 1 && id <= totalChapters)
        .toList();

    // Ensure at least chapter 1 is unlocked
    if (!validUnlocked.contains(1)) {
      validUnlocked.insert(0, 1);
    }

    // Return corrected progress if any changes were made
    if (validCurrentChapter != progress.currentChapter ||
        !_listEquals(validCompleted, progress.completedChapters) ||
        !_listEquals(validUnlocked, progress.unlockedChapters)) {
      return UserProgress(
        currentChapter: validCurrentChapter,
        completedChapters: validCompleted,
        unlockedChapters: validUnlocked,
      );
    }

    return progress;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
