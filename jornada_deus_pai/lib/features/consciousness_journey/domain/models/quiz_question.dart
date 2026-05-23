/// Model for a consciousness quiz question
class QuizQuestion {
  final int id;
  final String text;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}
