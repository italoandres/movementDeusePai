import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_providers.dart';
import '../providers/chapter_progress_providers.dart';
import 'chapter_list_item_with_progress.dart';
import 'fade_in_widget.dart';

/// Widget displaying the list of all chapters with their lock/unlock states
class ChapterList extends ConsumerWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  /// Callback when a chapter is tapped
  final Function(int chapterId)? onChapterTap;

  const ChapterList({
    super.key,
    required this.isMobile,
    this.onChapterTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapters = ref.watch(chaptersProvider);

    return FadeInWidget(
      delay: const Duration(milliseconds: 700),
      child: Column(
        children: chapters.map((chapter) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: isMobile ? 8 : 12,
            ),
            child: ChapterListItemWithProgress(
              chapter: chapter,
              isMobile: isMobile,
              onTap: () {
                if (onChapterTap != null) {
                  onChapterTap!(chapter.id);
                }
              },
              onRestart: () async {
                // Clear progress and navigate to chapter
                final repository = ref.read(chapterProgressRepositoryProvider);
                await repository.clearProgress(chapter.id);
                
                // Refresh the progress state
                ref.invalidate(hasChapterProgressProvider(chapter.id));
                
                // Navigate to chapter
                if (onChapterTap != null) {
                  onChapterTap!(chapter.id);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
