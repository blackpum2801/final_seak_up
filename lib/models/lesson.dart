class LessonModel {
  final String id;
  final String courseId;
  final String? parentTopicId;
  final String title;
  final String? content;
  final String
      type; // "listening" | "speaking" | "vocabulary" | "pronunciation"
  final String? parentLessonId;
  final int? totalLessons;
  final String? thumbnail;
  final String? aiImg;
  final String? name;
  final bool? isAIConversationEnabled;
  final String category; // "Basics" | "Intermediate" | "Professional"
  final int level;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LessonModel({
    required this.id,
    required this.courseId,
    this.parentTopicId,
    required this.title,
    this.content,
    required this.type,
    this.parentLessonId,
    this.totalLessons,
    this.thumbnail,
    this.aiImg,
    this.name,
    this.isAIConversationEnabled,
    required this.category,
    required this.level,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['_id']?.toString() ?? json['lessonId']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      parentTopicId: json['parentTopicId']?.toString(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString(),
      type: json['type']?.toString() ?? '',
      parentLessonId: json['parentLessonId']?.toString(),
      totalLessons: json['totalLessons'] is int
          ? json['totalLessons']
          : int.tryParse(json['totalLessons']?.toString() ?? ''),
      thumbnail: json['thumbnail']?.toString(),
      aiImg: json['aiImg']?.toString(),
      name: json['name']?.toString(),
      isAIConversationEnabled: json['isAIConversationEnabled'] == true,
      category: json['category']?.toString() ?? '',
      level: json['level'] is int
          ? json['level']
          : int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'courseId': courseId,
      'parentTopicId': parentTopicId,
      'title': title,
      'content': content,
      'type': type,
      'parentLessonId': parentLessonId,
      'totalLessons': totalLessons,
      'thumbnail': thumbnail,
      'aiImg': aiImg,
      'name': name,
      'isAIConversationEnabled': isAIConversationEnabled,
      'category': category,
      'level': level,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
