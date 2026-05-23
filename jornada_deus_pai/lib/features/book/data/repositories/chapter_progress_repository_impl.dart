import '../../domain/repositories/chapter_progress_repository.dart';
import '../data_sources/chapter_progress_local_data_source.dart';

/// Implementation of chapter progress repository
class ChapterProgressRepositoryImpl implements ChapterProgressRepository {
  final ChapterProgressLocalDataSource _localDataSource;

  ChapterProgressRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveProgress(int chapterId, int currentIndex) async {
    await _localDataSource.saveProgress(chapterId, currentIndex);
  }

  @override
  Future<int?> getProgress(int chapterId) async {
    return await _localDataSource.getProgress(chapterId);
  }

  @override
  Future<void> clearProgress(int chapterId) async {
    await _localDataSource.clearProgress(chapterId);
  }

  @override
  Future<bool> hasProgress(int chapterId) async {
    return await _localDataSource.hasProgress(chapterId);
  }
}
