/// Chapter model for the book
///
/// Represents a chapter in the spiritual journey book with its
/// unlock status and metadata.
class Chapter {
  final int id;
  final String title;
  final bool isUnlocked;
  final bool isCompleted;

  const Chapter({
    required this.id,
    required this.title,
    required this.isUnlocked,
    this.isCompleted = false,
  });

  Chapter copyWith({
    int? id,
    String? title,
    bool? isUnlocked,
    bool? isCompleted,
  }) {
    return Chapter(
      id: id ?? this.id,
      title: title ?? this.title,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
