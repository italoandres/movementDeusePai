import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/constants/book_content.dart';
import '../../data/data_sources/progress_local_data_source.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/models/chapter.dart';
import '../../domain/repositories/progress_repository.dart';
import '../state/progress_notifier.dart';
import '../state/progress_state.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for ProgressLocalDataSource
final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProgressLocalDataSource(prefs);
});

/// Provider for ProgressRepository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dataSource = ref.watch(progressLocalDataSourceProvider);
  return ProgressRepositoryImpl(dataSource);
});

/// StateNotifier Provider for progress management
final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return ProgressNotifier(repository);
});

/// Derived provider for current chapter number
final currentChapterProvider = Provider<int>((ref) {
  final state = ref.watch(progressNotifierProvider);
  return state.currentChapter;
});

/// Derived provider for unlocked chapters list
final unlockedChaptersProvider = Provider<List<int>>((ref) {
  final state = ref.watch(progressNotifierProvider);
  return state.unlockedChapters;
});

/// Derived provider for completed chapters list
final completedChaptersProvider = Provider<List<int>>((ref) {
  final state = ref.watch(progressNotifierProvider);
  return state.completedChapters;
});

/// Derived provider that combines chapter data with unlock/complete status
final chaptersProvider = Provider<List<Chapter>>((ref) {
  final unlockedChapters = ref.watch(unlockedChaptersProvider);
  final completedChapters = ref.watch(completedChaptersProvider);

  return List.generate(
    BookContent.chapterTitles.length,
    (index) {
      final chapterId = index + 1; // 1-indexed
      return Chapter(
        id: chapterId,
        title: BookContent.chapterTitles[index],
        // TEMPORARY: All chapters unlocked for testing
        isUnlocked: true, // unlockedChapters.contains(chapterId),
        isCompleted: completedChapters.contains(chapterId),
      );
    },
  );
});
