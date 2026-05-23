/// Journey Stage Enum
/// Represents the current stage of the user's spiritual journey
enum JourneyStage {
  entry('entry'),
  carta('carta'),
  transition('transition'),
  journey('journey'),
  preparation('preparation'),
  chat('chat');

  final String value;
  const JourneyStage(this.value);

  /// Create JourneyStage from string
  static JourneyStage fromString(String value) {
    return JourneyStage.values.firstWhere(
      (stage) => stage.value == value,
      orElse: () => JourneyStage.entry,
    );
  }

  @override
  String toString() => value;
}
