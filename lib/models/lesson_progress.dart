class LessonProgressModel {
  final String id;
  final String lessonId;
  final String userId;
  final double score;
  final bool isCompleted;

  LessonProgressModel({
    required this.id,
    required this.lessonId,
    required this.userId,
    required this.score,
    required this.isCompleted,
  });

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['_id'] ?? '',
      lessonId:
          json['lessonId'] is Map ? json['lessonId']['_id'] : json['lessonId'],
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'userId': userId,
      'score': score,
      'isCompleted': isCompleted,
    };
  }
}
