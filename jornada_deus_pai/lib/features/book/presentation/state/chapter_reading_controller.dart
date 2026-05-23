import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter_text_item.dart';
import '../../domain/repositories/chapter_progress_repository.dart';

/// State for chapter reading
class ChapterReadingState {
  final int currentIndex;
  final int totalItems;
  final bool isComplete;
  final bool isLoading;

  const ChapterReadingState({
    required this.currentIndex,
    required this.totalItems,
    required this.isComplete,
    this.isLoading = false,
  });

  ChapterReadingState copyWith({
    int? currentIndex,
    int? totalItems,
    bool? isComplete,
    bool? isLoading,
  }) {
    return ChapterReadingState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalItems: totalItems ?? this.totalItems,
      isComplete: isComplete ?? this.isComplete,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  double get progress => totalItems > 0 ? currentIndex / totalItems : 0.0;
}

/// Controller for chapter reading progression with auto-save
class ChapterReadingController extends StateNotifier<ChapterReadingState> {
  final List<ChapterTextItem> content;
  final int chapterId;
  final ChapterProgressRepository repository;

  ChapterReadingController({
    required this.content,
    required this.chapterId,
    required this.repository,
  }) : super(ChapterReadingState(
          currentIndex: 0,
          totalItems: content.length,
          isComplete: false,
          isLoading: true,
        )) {
    _loadProgress();
  }

  /// Load saved progress
  Future<void> _loadProgress() async {
    final savedIndex = await repository.getProgress(chapterId);
    state = state.copyWith(
      currentIndex: savedIndex ?? 0,
      isLoading: false,
    );
  }

  /// Move to next text item and auto-save
  Future<void> next() async {
    if (state.currentIndex < state.totalItems - 1) {
      final newIndex = state.currentIndex + 1;
      state = state.copyWith(currentIndex: newIndex);
      
      // Auto-save progress
      await repository.saveProgress(chapterId, newIndex);
    } else {
      state = state.copyWith(isComplete: true);
    }
  }

  /// Move to previous text item
  void previous() {
    if (state.currentIndex > 0) {
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        isComplete: false,
      );
    }
  }

  /// Reset to beginning and clear saved progress
  Future<void> reset() async {
    await repository.clearProgress(chapterId);
    state = ChapterReadingState(
      currentIndex: 0,
      totalItems: content.length,
      isComplete: false,
    );
  }

  /// Get current text item
  ChapterTextItem? get currentItem {
    if (state.currentIndex >= 0 && state.currentIndex < content.length) {
      return content[state.currentIndex];
    }
    return null;
  }
}
