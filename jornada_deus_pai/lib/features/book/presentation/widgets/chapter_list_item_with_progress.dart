import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/chapter.dart';
import '../providers/chapter_progress_providers.dart';

/// Chapter list item with progress tracking and restart functionality
class ChapterListItemWithProgress extends ConsumerStatefulWidget {
  /// The chapter to display
  final Chapter chapter;

  /// Whether to use mobile layout
  final bool isMobile;

  /// Callback when chapter is tapped
  final VoidCallback? onTap;

  /// Callback when restart is tapped
  final VoidCallback? onRestart;

  const ChapterListItemWithProgress({
    super.key,
    required this.chapter,
    required this.isMobile,
    this.onTap,
    this.onRestart,
  });

  @override
  ConsumerState<ChapterListItemWithProgress> createState() =>
      _ChapterListItemWithProgressState();
}

class _ChapterListItemWithProgressState
    extends ConsumerState<ChapterListItemWithProgress> {
  bool _isHovered = false;

  void _handleTap() {
    if (widget.chapter.isUnlocked && widget.onTap != null) {
      widget.onTap!();
    }
  }

  Future<void> _handleRestart() async {
    if (widget.onRestart != null) {
      widget.onRestart!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasProgressAsync = ref.watch(hasChapterProgressProvider(widget.chapter.id));

    return hasProgressAsync.when(
      data: (hasProgress) {
        final semanticLabel = widget.chapter.isUnlocked
            ? 'Capítulo ${widget.chapter.id}: ${widget.chapter.title}. ${hasProgress ? "Em progresso. Continuar leitura" : "Não iniciado. Começar leitura"}.'
            : 'Capítulo ${widget.chapter.id}: ${widget.chapter.title}. Bloqueado.';

        return Semantics(
          label: semanticLabel,
          button: widget.chapter.isUnlocked,
          enabled: widget.chapter.isUnlocked,
          child: MouseRegion(
            onEnter: (_) {
              if (widget.chapter.isUnlocked) {
                setState(() => _isHovered = true);
              }
            },
            onExit: (_) {
              if (widget.chapter.isUnlocked) {
                setState(() => _isHovered = false);
              }
            },
            cursor: widget.chapter.isUnlocked
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: _handleTap,
              child: Opacity(
                opacity: widget.chapter.isUnlocked ? 1.0 : 0.4,
                child: Container(
                  padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: _isHovered && widget.chapter.isUnlocked
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: _isHovered && widget.chapter.isUnlocked
                        ? Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.chapter.id}. ${widget.chapter.title}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isMobile ? 16 : 18,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (hasProgress && widget.chapter.isUnlocked) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Em progresso',
                                style: TextStyle(
                                  color: const Color(0xFFD4AF37).withOpacity(0.7),
                                  fontSize: widget.isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!widget.chapter.isUnlocked) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '🔒',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                      if (widget.chapter.isUnlocked) ...[
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.replay,
                            color: Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                          onPressed: _handleRestart,
                          tooltip: 'Recomeçar capítulo do zero',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoadingItem(),
      error: (_, __) => _buildErrorItem(),
    );
  }

  Widget _buildLoadingItem() {
    return Opacity(
      opacity: widget.chapter.isUnlocked ? 1.0 : 0.4,
      child: Container(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${widget.chapter.id}. ${widget.chapter.title}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isMobile ? 16 : 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (!widget.chapter.isUnlocked) ...[
              const SizedBox(width: 8),
              const Text(
                '🔒',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorItem() {
    return _buildLoadingItem(); // Fallback to basic item on error
  }
}
