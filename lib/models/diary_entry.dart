class DiaryEntry {
  final String text;
  final DateTime date;
  final String emotion;
  final String suggestion;
  final String imagePath;

  DiaryEntry({
    required this.text,
    required this.date,
    required this.emotion,
    required this.suggestion,
    required this.imagePath,
  });

  // For debugging purposes
  @override
  String toString() {
    return 'DiaryEntry(date: $date, emotion: $emotion, text: ${text.substring(0, text.length > 30 ? 30 : text.length)}...)';
  }

  // Convert DiaryEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'suggestion': suggestion,
      'imagePath': imagePath,
    };
  }

  // Create DiaryEntry from JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      emotion: json['emotion'] as String,
      suggestion: json['suggestion'] as String,
      imagePath: json['imagePath'] as String,
    );
  }
}
