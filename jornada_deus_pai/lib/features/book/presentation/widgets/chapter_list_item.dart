import 'package:flutter/material.dart';
import '../../domain/models/chapter.dart';

/// Individual chapter list item with lock/unlock state and hover feedback
class ChapterListItem extends StatefulWidget {
  /// The chapter to display
  final Chapter chapter;

  /// Whether to use mobile layout
  final bool isMobile;

  /// Callback when chapter is tapped
  final VoidCallback? onTap;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.isMobile,
    this.onTap,
  });

  @override
  State<ChapterListItem> createState() => _ChapterListItemState();
}

class _ChapterListItemState extends State<ChapterListItem> {
  bool _isHovered = false;

  void _handleTap() {
    if (widget.chapter.isUnlocked && widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticLabel = widget.chapter.isUnlocked
        ? 'Capítulo ${widget.chapter.id}: ${widget.chapter.title}. Desbloqueado. Toque para ler.'
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
          ),
        ),
      ),
    );
  }
}
