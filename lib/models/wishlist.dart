class WishlistModel {
  final String id; // MongoDB _id
  final String userId;
  final String lessonId;
  final DateTime createdAt;

  // Thông tin bài học để hiển thị
  final String? lessonTitle;
  final String? lessonThumbnail;
  final String? lessonContent;
  final int? totalLessons; // Tổng số bài học con

  WishlistModel({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.createdAt,
    this.lessonTitle,
    this.lessonThumbnail,
    this.lessonContent,
    this.totalLessons,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    final dynamic lesson = json['lessonId'];

    return WishlistModel(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      lessonId: lesson is String ? lesson : (lesson['_id'] ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lessonTitle: lesson is Map<String, dynamic> ? lesson['title'] : null,
      lessonThumbnail:
          lesson is Map<String, dynamic> ? lesson['thumbnail'] : null,
      lessonContent: lesson is Map<String, dynamic> ? lesson['content'] : null,
      totalLessons:
          lesson is Map<String, dynamic> && lesson['totalLessons'] != null
              ? int.tryParse(lesson['totalLessons'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'lessonId': lessonId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
