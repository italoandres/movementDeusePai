import 'package:flutter/material.dart';
import '../../data/constants/book_content.dart';
import 'fade_in_widget.dart';

/// Section displaying deep reflection quotes with staggered fade-in animations
class ReflectionQuotesSection extends StatelessWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  const ReflectionQuotesSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: BookContent.reflectionQuotes.asMap().entries.map((entry) {
        final index = entry.key;
        final quote = entry.value;
        
        return FadeInWidget(
          delay: Duration(milliseconds: 300 + (index * 100)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 12 : 16,
            ),
            child: Text(
              quote,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.w300,
                height: 1.6,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}
