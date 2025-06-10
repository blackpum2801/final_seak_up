class Exercise {
  final String id;
  final String? lessonId;
  final String? type;
  final String? prompt;
  final String? correctPronunciation;
  final String? difficultyLevel;

  Exercise({
    required this.id,
    this.lessonId,
    this.type,
    this.prompt,
    this.correctPronunciation,
    this.difficultyLevel,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'] ?? json['id'],
      lessonId: json['lessonId'] is String
          ? json['lessonId']
          : (json['lessonId']?['_id'] ?? json['lessonId']?['id']),
      type: json['type'],
      prompt: json['prompt'],
      correctPronunciation: json['correctPronunciation'],
      difficultyLevel: json['difficultyLevel'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'lessonId': lessonId,
        'type': type,
        'prompt': prompt,
        'correctPronunciation': correctPronunciation,
        'difficultyLevel': difficultyLevel,
      };
}
