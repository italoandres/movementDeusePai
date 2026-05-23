import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/data_sources/chapter_progress_local_data_source.dart';
import '../../data/repositories/chapter_progress_repository_impl.dart';
import '../../domain/repositories/chapter_progress_repository.dart';

/// Provider for chapter progress local data source
final chapterProgressLocalDataSourceProvider = Provider<ChapterProgressLocalDataSource>((ref) {
  return ChapterProgressLocalDataSource();
});

/// Provider for chapter progress repository
final chapterProgressRepositoryProvider = Provider<ChapterProgressRepository>((ref) {
  final localDataSource = ref.watch(chapterProgressLocalDataSourceProvider);
  return ChapterProgressRepositoryImpl(localDataSource);
});

/// Provider for saving chapter progress
final saveChapterProgressProvider = FutureProvider.family<void, ({int chapterId, int index})>((ref, params) async {
  final repository = ref.watch(chapterProgressRepositoryProvider);
  await repository.saveProgress(params.chapterId, params.index);
});

/// Provider for getting chapter progress
final getChapterProgressProvider = FutureProvider.family<int?, int>((ref, chapterId) async {
  final repository = ref.watch(chapterProgressRepositoryProvider);
  return await repository.getProgress(chapterId);
});

/// Provider for checking if chapter has progress
final hasChapterProgressProvider = FutureProvider.family<bool, int>((ref, chapterId) async {
  final repository = ref.watch(chapterProgressRepositoryProvider);
  return await repository.hasProgress(chapterId);
});

/// Provider for clearing chapter progress
final clearChapterProgressProvider = FutureProvider.family<void, int>((ref, chapterId) async {
  final repository = ref.watch(chapterProgressRepositoryProvider);
  await repository.clearProgress(chapterId);
});
