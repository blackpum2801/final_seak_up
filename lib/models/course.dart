class Course {
  final String id;
  final String title;
  final String description;
  final String image;
  final String level;

  Course(
      {required this.id,
      required this.title,
      required this.description,
      required this.image,
      required this.level});

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['_id'],
        title: json['title'],
        description: json['description'],
        image: json['image'],
        level: json['level'],
      );
}
