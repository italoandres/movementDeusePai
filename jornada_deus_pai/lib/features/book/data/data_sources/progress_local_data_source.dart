import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_progress.dart';

/// Local data source for reading progress using SharedPreferences (Local Storage)
class ProgressLocalDataSource {
  static const String _progressKey = 'user_progress';
  final SharedPreferences _prefs;

  ProgressLocalDataSource(this._prefs);

  /// Retrieves the user's progress from Local Storage
  ///
  /// Returns null if no progress has been saved yet
  Future<UserProgress?> getProgress() async {
    try {
      final jsonString = _prefs.getString(_progressKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProgress.fromJson(json);
    } catch (e) {
      throw Exception('Failed to load progress from Local Storage: $e');
    }
  }

  /// Saves the user's progress to Local Storage
  Future<void> saveProgress(UserProgress progress) async {
    try {
      final jsonString = jsonEncode(progress.toJson());
      await _prefs.setString(_progressKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save progress to Local Storage: $e');
    }
  }

  /// Clears all progress data from Local Storage
  Future<void> clearProgress() async {
    try {
      await _prefs.remove(_progressKey);
    } catch (e) {
      throw Exception('Failed to clear progress from Local Storage: $e');
    }
  }
}
