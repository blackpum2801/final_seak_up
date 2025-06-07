class Vocabulary {
  final String id;
  final String word;
  final String? phonetic;
  final String meaning;
  final String? exampleSentence;
  final String? audioUrl;
  final String lessonId;

  Vocabulary({
    required this.id,
    required this.word,
    this.phonetic,
    required this.meaning,
    this.exampleSentence,
    this.audioUrl,
    required this.lessonId,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['_id']?.toString() ?? '',
      word: json['word'] ?? '',
      phonetic: json['phonetic'],
      meaning: json['meaning'] ?? '',
      exampleSentence: json['exampleSentence'],
      audioUrl: json['audioUrl'],
      lessonId: json['lessonId']?.toString() ?? '',
    );
  }
}
