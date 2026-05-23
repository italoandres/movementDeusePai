import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/book_content.dart';
import '../providers/progress_providers.dart';
import 'fade_in_widget.dart';

/// Widget displaying the user's reading progress
class ProgressDisplay extends ConsumerWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  const ProgressDisplay({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapter = ref.watch(currentChapterProvider);
    final totalChapters = BookContent.chapterTitles.length;

    return FadeInWidget(
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            BookContent.progressTitle,
            style: TextStyle(
              color: const Color(0xFFD4AF37), // Gold
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Capítulo $currentChapter de $totalChapters',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
