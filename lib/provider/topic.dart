import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/models/topic.dart';
import 'package:speak_up/models/lesson.dart';

class TopicProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  List<TopicModel> topics = [];
  Map<String, List<LessonModel>> topicLessons = {}; // topicId → bài học cha

  List<LessonModel> _trendingLessons = [];
  List<LessonModel> _latestLessons = [];

  List<LessonModel> get trendingLessons => _trendingLessons;
  List<LessonModel> get latestLessons => _latestLessons;

  bool isLoading = false;
  bool isFetched = false;

  Future<void> _setToken() async {
    final token = await _storage.read(key: 'accessToken');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔐 Token attached');
    } else {
      debugPrint("⚠️ Token not found");
    }
  }

  /// 📥 Lấy danh sách topic và bài học cha trong từng topic
  Future<void> fetchTopicsAndLessons() async {
    if (isFetched) return;

    isLoading = true;
    notifyListeners();

    try {
      await _setToken();

      final res = await _dio.get('/topic');
      final raw = res.data['rs'] ?? res.data;

      if (raw is! List) {
        debugPrint("❌ API /topic không trả về List");
        return;
      }

      topics = raw
          .where((t) => t['section'] == 'topic')
          .map((t) => TopicModel.fromJson(t))
          .toList();

      debugPrint("📦 Có ${topics.length} topic (section = topic)");

      final lessonResponses = await Future.wait(
        topics.map(
          (t) => _dio.get('/lesson/getLessonByParentTopicId/${t.id}'),
        ),
      );

      for (var i = 0; i < topics.length; i++) {
        final topicId = topics[i].id;
        final lessonRes = lessonResponses[i];
        final data = lessonRes.data['rs'] ?? [];

        final parentLessons = (data as List)
            .map((e) => LessonModel.fromJson(e))
            .where((l) => l.parentLessonId == null)
            .toList();

        topicLessons[topicId] = parentLessons;

        debugPrint("✅ ${topics[i].title} có ${parentLessons.length} bài học cha");
      }

      _generateTrendingLessons();
      _generateLatestLessons();

      isFetched = true;
    } catch (e) {
      debugPrint("❌ Lỗi fetchTopicsAndLessons: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔁 Cho phép làm mới thủ công nếu cần
  Future<void> refreshTopics() async {
    isFetched = false;
    await fetchTopicsAndLessons();
  }

  /// 🔥 Random 10 bài học trending duy nhất
  void _generateTrendingLessons() {
    final allLessons = topicLessons.values.expand((e) => e).toList();
    if (allLessons.length <= 10) {
      _trendingLessons = allLessons;
      return;
    }

    final random = Random();
    final selected = <LessonModel>[];
    final usedIndexes = <int>{};

    while (selected.length < 10) {
      final index = random.nextInt(allLessons.length);
      if (!usedIndexes.contains(index)) {
        usedIndexes.add(index);
        selected.add(allLessons[index]);
      }
    }

    _trendingLessons = selected;
  }

  /// 📅 Lấy 10 bài học mới nhất theo createdAt
  void _generateLatestLessons() {
    final allLessons = topicLessons.values.expand((e) => e).toList();

    allLessons.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate); // Mới nhất lên đầu
    });

    _latestLessons = allLessons.take(10).toList();
  }

  List<LessonModel> getLessonsForTopic(String topicId) {
    return topicLessons[topicId] ?? [];
  }

  LessonModel? getLessonByIdLocally(String topicId, String lessonId) {
    final lessons = topicLessons[topicId];
    if (lessons == null) return null;

    try {
      return lessons.firstWhere((l) => l.id == lessonId);
    } catch (e) {
      return null;
    }
  }

  Future<TopicModel?> fetchTopicById(String topicId) async {
    try {
      await _setToken();

      final res = await _dio.get('/topic/$topicId');
      final data = res.data['rs'];

      if (res.data['success'] == true && data is Map<String, dynamic>) {
        return TopicModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("❌ Lỗi fetchTopicById: $e");
      return null;
    }
  }
}
