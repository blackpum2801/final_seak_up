import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/models/vocabulary.dart';

class VocabularyProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;

  final Map<String, List<Vocabulary>> _vocabByLesson = {};
  bool isLoading = false;

  List<Vocabulary> getVocab(String lessonId) => _vocabByLesson[lessonId] ?? [];

  Future<void> fetchVocabulary(String lessonId) async {
    if (_vocabByLesson.containsKey(lessonId)) return;

    isLoading = true;
    notifyListeners();

    try {
      final res = await _dio.get('/vocabulary/getByLessonId/$lessonId');
      debugPrint("📥 Vocabulary response: ${res.data}");

      final raw = res.data;
      final data = (raw is Map && raw.containsKey('rs')) ? raw['rs'] : raw;
      final validList = (data as List)
          .where((e) =>
              e != null &&
              e is Map<String, dynamic> &&
              e['word'] != null &&
              e['word'] is String)
          .map((e) => Vocabulary.fromJson(e))
          .toList();

      _vocabByLesson[lessonId] = validList;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint("⚠️ No vocabulary for lesson $lessonId (404)");
        _vocabByLesson[lessonId] = [];
      } else {
        debugPrint("❌ Dio error fetching vocab for $lessonId: $e");
        _vocabByLesson[lessonId] = [];
      }
    } catch (e) {
      debugPrint("❌ Unknown error fetching vocab for $lessonId: $e");
      _vocabByLesson[lessonId] = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
