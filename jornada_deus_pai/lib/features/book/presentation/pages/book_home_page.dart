import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_providers.dart';
import '../widgets/book_header.dart';
import '../widgets/chapter_list.dart';
import '../widgets/cta_button.dart';
import '../widgets/intro_list_item.dart';
import '../widgets/progress_display.dart';
import '../widgets/rotating_quote.dart';

/// Main page for the book home - displays progress, chapters, and reflection quotes
class BookHomePage extends ConsumerStatefulWidget {
  const BookHomePage({super.key});

  @override
  ConsumerState<BookHomePage> createState() => _BookHomePageState();
}

class _BookHomePageState extends ConsumerState<BookHomePage> {
  @override
  void initState() {
    super.initState();
    // Load progress when page initializes
    Future.microtask(() {
      ref.read(progressNotifierProvider.notifier).loadProgress();
    });
  }

  void _navigateToChapter(int chapterId) {
    // Update current chapter
    ref.read(progressNotifierProvider.notifier).setCurrentChapter(chapterId);
    
    // Navigate to introduction or chapter
    if (chapterId == 0) {
      // Navigate to introduction
      context.push('/book/intro');
    } else {
      // Navigate to chapter reading page
      context.push('/book/chapter/$chapterId');
    }
  }

  void _handleCTAPress() {
    final currentChapter = ref.read(currentChapterProvider);
    
    // If starting fresh (chapter 1), go to introduction first
    if (currentChapter == 1) {
      context.push('/book/intro');
    } else {
      _navigateToChapter(currentChapter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(progressNotifierProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD4AF37), // Gold
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  width: isMobile ? double.infinity : 800,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 48,
                    vertical: isMobile ? 24 : 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      BookHeader(isMobile: isMobile),
                      
                      SizedBox(height: isMobile ? 32 : 48),
                      
                      // Rotating Quote
                      RotatingQuote(isMobile: isMobile),
                      
                      SizedBox(height: isMobile ? 32 : 48),
                      
                      // Progress Display
                      ProgressDisplay(isMobile: isMobile),
                      
                      SizedBox(height: isMobile ? 32 : 48),
                      
                      // Introduction Item
                      IntroListItem(
                        isMobile: isMobile,
                        onTap: () => context.push('/book/intro'),
                      ),
                      
                      SizedBox(height: isMobile ? 16 : 24),
                      
                      // Chapter List
                      ChapterList(
                        isMobile: isMobile,
                        onChapterTap: _navigateToChapter,
                      ),
                      
                      SizedBox(height: isMobile ? 32 : 48),
                      
                      // CTA Button
                      CTAButton(
                        isMobile: isMobile,
                        onPressed: _handleCTAPress,
                      ),
                      
                      // Error Display (if any)
                      if (state.error != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            state.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
