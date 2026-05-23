import '../models/user_progress.dart';

/// Abstract repository interface for managing user reading progress
abstract class ProgressRepository {
  /// Retrieves the user's current progress
  ///
  /// Returns null if no progress has been saved yet
  Future<UserProgress?> getProgress();

  /// Saves the user's progress
  Future<void> saveProgress(UserProgress progress);

  /// Clears all progress data
  Future<void> clearProgress();
}
