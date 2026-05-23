import 'package:flutter/material.dart';

/// Special list item for the introduction
class IntroListItem extends StatefulWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  /// Callback when intro is tapped
  final VoidCallback? onTap;

  const IntroListItem({
    super.key,
    required this.isMobile,
    this.onTap,
  });

  @override
  State<IntroListItem> createState() => _IntroListItemState();
}

class _IntroListItemState extends State<IntroListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Introdução. Desbloqueado. Toque para ler.',
      button: true,
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: _isHovered
                  ? Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Special icon for introduction
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Color(0xFFD4AF37),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Introdução',
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: widget.isMobile ? 16 : 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
