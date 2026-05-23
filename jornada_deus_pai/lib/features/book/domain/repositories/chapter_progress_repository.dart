/// Repository interface for chapter reading progress
abstract class ChapterProgressRepository {
  /// Save chapter reading progress
  Future<void> saveProgress(int chapterId, int currentIndex);

  /// Get chapter reading progress
  Future<int?> getProgress(int chapterId);

  /// Clear chapter reading progress
  Future<void> clearProgress(int chapterId);

  /// Check if chapter has saved progress
  Future<bool> hasProgress(int chapterId);
}
