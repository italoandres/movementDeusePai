/// Represents the user's reading progress through the book.
///
/// This model tracks which chapter the user is currently reading,
/// which chapters have been completed, and which chapters are unlocked.
class UserProgress {
  /// The current chapter number the user is reading (1-indexed)
  final int currentChapter;

  /// List of chapter IDs that have been completed
  final List<int> completedChapters;

  /// List of chapter IDs that are unlocked and accessible
  final List<int> unlockedChapters;

  const UserProgress({
    required this.currentChapter,
    required this.completedChapters,
    required this.unlockedChapters,
  });

  /// Creates a default UserProgress with Chapter 1 unlocked
  factory UserProgress.initial() {
    return const UserProgress(
      currentChapter: 1,
      completedChapters: [],
      unlockedChapters: [1],
    );
  }

  /// Creates a UserProgress from JSON map
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      currentChapter: json['currentChapter'] as int,
      completedChapters: (json['completedChapters'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      unlockedChapters: (json['unlockedChapters'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }

  /// Converts this UserProgress to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentChapter': currentChapter,
      'completedChapters': completedChapters,
      'unlockedChapters': unlockedChapters,
    };
  }

  /// Creates a copy of this UserProgress with the given fields replaced
  UserProgress copyWith({
    int? currentChapter,
    List<int>? completedChapters,
    List<int>? unlockedChapters,
  }) {
    return UserProgress(
      currentChapter: currentChapter ?? this.currentChapter,
      completedChapters: completedChapters ?? this.completedChapters,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProgress &&
        other.currentChapter == currentChapter &&
        _listEquals(other.completedChapters, completedChapters) &&
        _listEquals(other.unlockedChapters, unlockedChapters);
  }

  @override
  int get hashCode {
    return currentChapter.hashCode ^
        completedChapters.hashCode ^
        unlockedChapters.hashCode;
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'UserProgress(currentChapter: $currentChapter, completedChapters: $completedChapters, unlockedChapters: $unlockedChapters)';
  }
}
