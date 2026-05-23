import 'package:flutter/material.dart';
import '../../../../shared/design/ecosystem_theme.dart';
import '../../data/constants/book_content.dart';
import 'fade_in_widget.dart';

/// Header widget displaying the book title and subtitle
/// Uses EcosystemTheme for visual consistency
class BookHeader extends StatelessWidget {
  /// Whether to use mobile layout
  final bool isMobile;

  const BookHeader({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInWidget(
      delay: const Duration(milliseconds: 100),
      child: Column(
        children: [
          Text(
            BookContent.bookTitle,
            style: TextStyle(
              color: EcosystemTheme.textPrimary,
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            BookContent.bookSubtitle,
            style: TextStyle(
              color: EcosystemTheme.textSecondary,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
