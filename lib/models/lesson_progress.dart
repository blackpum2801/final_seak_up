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

  // Hàm parse an toàn
  static String parseId(dynamic input) {
    if (input == null) return '';
    if (input is Map && input['_id'] != null) return input['_id'].toString();
    return input.toString();
  }

  factory LessonProgressModel.fromJson(Map<String, dynamic> json) {
    return LessonProgressModel(
      id: json['_id']?.toString() ?? '',
      lessonId: parseId(json['lessonId']),
      userId: parseId(json['userId']),
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] == true,
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
