/// Text types for chapter content
enum TextType {
  normal,
  impact,
  subtitle,
  image, // New type for image content
}

/// Model for a single text item in a chapter
class ChapterTextItem {
  final TextType type;
  final String text;

  const ChapterTextItem({
    required this.type,
    required this.text,
  });
}
