import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for chapter reading progress
class ChapterProgressLocalDataSource {
  static const String _keyPrefix = 'book_progress_';

  /// Save chapter reading progress
  Future<void> saveProgress(int chapterId, int currentIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$chapterId';
    await prefs.setInt(key, currentIndex);
  }

  /// Get chapter reading progress
  Future<int?> getProgress(int chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$chapterId';
    return prefs.getInt(key);
  }

  /// Clear chapter reading progress
  Future<void> clearProgress(int chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$chapterId';
    await prefs.remove(key);
  }

  /// Check if chapter has saved progress
  Future<bool> hasProgress(int chapterId) async {
    final progress = await getProgress(chapterId);
    return progress != null && progress > 0;
  }
}
