/// Immutable state object for user reading progress
class ProgressState {
  /// The current chapter number the user is reading (1-indexed)
  final int currentChapter;

  /// List of chapter IDs that have been completed
  final List<int> completedChapters;

  /// List of chapter IDs that are unlocked and accessible
  final List<int> unlockedChapters;

  /// Whether the state is currently loading
  final bool isLoading;

  /// Error message if an error occurred
  final String? error;

  const ProgressState({
    required this.currentChapter,
    required this.completedChapters,
    required this.unlockedChapters,
    this.isLoading = false,
    this.error,
  });

  /// Creates an initial state with Chapter 1 unlocked
  factory ProgressState.initial() {
    return const ProgressState(
      currentChapter: 1,
      completedChapters: [],
      unlockedChapters: [1],
      isLoading: false,
      error: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced
  ProgressState copyWith({
    int? currentChapter,
    List<int>? completedChapters,
    List<int>? unlockedChapters,
    bool? isLoading,
    String? error,
  }) {
    return ProgressState(
      currentChapter: currentChapter ?? this.currentChapter,
      completedChapters: completedChapters ?? this.completedChapters,
      unlockedChapters: unlockedChapters ?? this.unlockedChapters,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProgressState &&
        other.currentChapter == currentChapter &&
        _listEquals(other.completedChapters, completedChapters) &&
        _listEquals(other.unlockedChapters, unlockedChapters) &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return currentChapter.hashCode ^
        completedChapters.hashCode ^
        unlockedChapters.hashCode ^
        isLoading.hashCode ^
        error.hashCode;
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
    return 'ProgressState(currentChapter: $currentChapter, completedChapters: $completedChapters, unlockedChapters: $unlockedChapters, isLoading: $isLoading, error: $error)';
  }
}
