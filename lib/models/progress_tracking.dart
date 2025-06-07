class ProgressTrackingModel {
  final String id;
  final String userId;
  final int completedLessons;
  final double totalScore;

  ProgressTrackingModel({
    required this.id,
    required this.userId,
    required this.completedLessons,
    required this.totalScore,
  });

  factory ProgressTrackingModel.fromJson(Map<String, dynamic> json) {
    return ProgressTrackingModel(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['_id'] : json['userId'],
      completedLessons: json['completedLessons'] ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'completedLessons': completedLessons,
      'totalScore': totalScore,
    };
  }
}
