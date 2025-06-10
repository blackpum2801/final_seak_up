import 'package:speak_up/models/exercise.dart';

class PronunciationScore {
  final String id;
  final String? exerciseId;
  final Exercise? exercise;
  final String? phonetic;
  final String? userAudioUrl;
  final double score;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PronunciationScore({
    required this.id,
    this.exerciseId,
    this.exercise,
    this.phonetic,
    this.userAudioUrl,
    required this.score,
    this.createdAt,
    this.updatedAt,
  });

  factory PronunciationScore.fromJson(Map<String, dynamic> json) {
    // exerciseId có thể là String hoặc Map (object Exercise)
    return PronunciationScore(
      id: json['_id'] ?? json['id'],
      exercise: json['exerciseId'] is Map<String, dynamic>
          ? Exercise.fromJson(json['exerciseId'])
          : null,
      exerciseId: json['exerciseId'] is String
          ? json['exerciseId']
          : (json['exerciseId']?['_id'] ?? json['exerciseId']?['id']),
      phonetic: json['phonetic'],
      userAudioUrl: json['userAudioUrl'],
      score: (json['score'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'exerciseId': exerciseId ?? exercise?.id,
        'phonetic': phonetic,
        'userAudioUrl': userAudioUrl,
        'score': score,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
