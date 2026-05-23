import 'package:flutter/material.dart';
import '../../domain/models/chapter_text_item.dart';

/// Widget that renders a chapter text item based on its type
class ChapterTextRenderer extends StatelessWidget {
  final ChapterTextItem item;

  const ChapterTextRenderer({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case TextType.subtitle:
        return Text(
          item.text,
          style: const TextStyle(
            color: Color(0xFFD4AF37), // Gold
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        );

      case TextType.impact:
        return Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        );

      case TextType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            item.text,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      color: Colors.white.withOpacity(0.3),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Imagem não disponível',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

      case TextType.normal:
      default:
        return Text(
          item.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.3,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        );
    }
  }
}
