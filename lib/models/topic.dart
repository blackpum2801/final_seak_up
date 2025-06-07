class TopicModel {
  final String id;
  final String title;
  final String? content; // Nullable
  final String type;
  final String section;
  final int level;
  final String thumbnail;
  final int totalLessons;

  TopicModel({
    required this.id,
    required this.title,
    this.content, // Không bắt buộc
    required this.type,
    required this.section,
    required this.level,
    required this.thumbnail,
    required this.totalLessons,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'], // Không cần giá trị mặc định
      type: json['type'] ?? '',
      section: json['section'] ?? '',
      level: json['level'] ?? 1,
      thumbnail: json['thumbnail'] ?? '',
      totalLessons: json['totalLessons'] ?? 0,
    );
  }
}
