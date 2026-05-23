import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/chapter_1_content.dart';
import '../../data/constants/chapter_2_content.dart';
import '../../data/constants/chapter_3_content.dart';
import '../../data/constants/chapter_4_content.dart';
import '../../data/constants/chapter_5_content.dart';
import '../../data/constants/chapter_6_content.dart';
import '../../data/constants/chapter_7_content.dart';
import '../../data/constants/chapter_8_content.dart';
import '../../data/constants/chapter_9_content.dart';
import '../../data/constants/chapter_10_content.dart';
import '../../data/constants/chapter_11_content.dart';
import '../../data/constants/chapter_12_content.dart';
import '../../data/constants/chapter_13_content.dart';
import '../../data/constants/chapter_14_content.dart';
import '../../data/constants/chapter_15_content.dart';
import '../../domain/models/chapter_text_item.dart';
import '../state/chapter_reading_controller.dart';
import 'chapter_progress_providers.dart';

/// Get chapter content by ID
List<ChapterTextItem> getChapterContent(int chapterId) {
  switch (chapterId) {
    case 1:
      return chapter1Content;
    case 2:
      return chapter2Content;
    case 3:
      return chapter3Content;
    case 4:
      return chapter4Content;
    case 5:
      return chapter5Content;
    case 6:
      return chapter6Content;
    case 7:
      return chapter7Content;
    case 8:
      return chapter8Content;
    case 9:
      return chapter9Content;
    case 10:
      return chapter10Content;
    case 11:
      return chapter11Content;
    case 12:
      return chapter12Content;
    case 13:
      return chapter13Content;
    case 14:
      return chapter14Content;
    case 15:
      return chapter15Content;
    default:
      return chapter1Content; // Fallback to chapter 1
  }
}

/// Provider for chapter reading controller (supports multiple chapters)
final chapterControllerProvider = StateNotifierProvider.autoDispose
    .family<ChapterReadingController, ChapterReadingState, int>(
  (ref, chapterId) {
    final repository = ref.watch(chapterProgressRepositoryProvider);
    final content = getChapterContent(chapterId);
    return ChapterReadingController(
      content: content,
      chapterId: chapterId,
      repository: repository,
    );
  },
);
