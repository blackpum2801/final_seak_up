import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/models/topic.dart';
import 'package:speak_up/models/lesson_progress.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LessonProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<LessonModel> lessons = [];
  List<TopicModel> topics = [];
  Map<String, LessonProgressModel> lessonProgressMap = {};

  bool isLoading = false;
  bool isFetched = false;
  bool hasError = false;
  String? errorMessage;

  LessonProvider() {
    _dio.options
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10);
  }

  Future<bool> _setToken() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
        debugPrint('🔐 Token đã được gắn vào Authorization header');
        return true;
      } else {
        debugPrint("⚠️ Không tìm thấy token!");
        hasError = true;
        errorMessage = 'Không tìm thấy token. Vui lòng đăng nhập lại.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("❌ Error setToken: $e");
      hasError = true;
      errorMessage = 'Lỗi khi đọc token: $e';
      notifyListeners();
      return false;
    }
  }

  String _normalizeImageUrl(String? url) {
    try {
      final apiBase = dotenv.env['API_BASE'] ?? '';
      final uri = Uri.parse(apiBase);

      if (url == null || url.isEmpty || uri.host.isEmpty) {
        return 'https://dummyimage.com/100x100/000/fff';
      }

      if (url.contains('localhost')) {
        final parsedUrl = Uri.parse(url);
        final fixed = parsedUrl.replace(host: '10.0.2.2');
        return fixed.toString();
      }

      if (!url.startsWith('http')) {
        final base = uri.replace(path: '').toString();
        return '$base/$url';
      }

      return url;
    } catch (e) {
      debugPrint('❌ normalizeImageUrl error: $e');
      return 'https://dummyimage.com/100x100/000/fff';
    }
  }

  Future<void> fetchLessonsBySection() async {
    if (isFetched || isLoading) return;

    isLoading = true;
    hasError = false;
    errorMessage = null;
    notifyListeners();

    List<LessonModel> result = [];

    try {
      if (!await _setToken()) return;

      final topicRes = await _dio.get('/topic');
      final topicData = topicRes.data['rs'] ?? topicRes.data;

      if (topicData is! List) {
        debugPrint("❌ API topic không trả về List");
        hasError = true;
        errorMessage = 'Dữ liệu topic không đúng định dạng.';
        return;
      }

      final filteredTopics =
          topicData.where((t) => t['section'] == 'lesson').map((t) {
        final topic = TopicModel.fromJson(t);
        return TopicModel(
          id: topic.id,
          title: topic.title,
          content: topic.content,
          type: topic.type,
          section: topic.section,
          level: topic.level,
          thumbnail: _normalizeImageUrl(topic.thumbnail),
          totalLessons: topic.totalLessons,
        );
      }).toList();

      topics = filteredTopics;

      final topicIds = filteredTopics.map((e) => e.id).toList();
      debugPrint("📚 Có ${topicIds.length} topic thuộc section 'lesson'");

      final lessonResponses = await Future.wait(
        topicIds.map(
            (topicId) => _dio.get('/lesson/getLessonByParentTopicId/$topicId')),
      );

      for (final lessonRes in lessonResponses) {
        final data = lessonRes.data['rs'] ?? [];
        final lessonsInTopic = (data as List)
            .map((e) => LessonModel.fromJson(e))
            .where((l) => l.category == 'Basics')
            .toList();
        result.addAll(lessonsInTopic);
      }

      lessons = result;
      isFetched = true;
      debugPrint("✅ Tổng số bài học Basics: ${lessons.length}");
    } catch (e) {
      debugPrint("❌ Error fetchLessonsBySection: $e");
      hasError = true;
      errorMessage = 'Lỗi khi tải bài học: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLessonProgress(String userId) async {
    try {
      if (!await _setToken()) return;

      final res = await _dio.get('/lesson-progress/user/$userId');
      final data = res.data['rs'] ?? res.data;

      final progressList =
          (data as List).map((e) => LessonProgressModel.fromJson(e)).toList();

      lessonProgressMap.clear();
      for (var item in progressList) {
        lessonProgressMap[item.lessonId] = item;
      }

      debugPrint("📊 Fetched lesson progress: ${lessonProgressMap.length}");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetchLessonProgress: $e");
      hasError = true;
      errorMessage = 'Lỗi khi tải tiến độ học: $e';
      notifyListeners();
    }
  }

  Future<List<LessonModel>> fetchLessonsByParentTopic(String topicId) async {
    try {
      if (!await _setToken()) return [];

      final res = await _dio.get('/lesson/getLessonByParentTopicId/$topicId');
      debugPrint("📥 API response: ${res.data}");

      final raw = res.data['rs'] ?? res.data['lessons'] ?? res.data;

      final lessonsInTopic = (raw as List)
          .map((e) => LessonModel.fromJson(e))
          .where((l) => l.parentLessonId == null)
          .toList();

      debugPrint("✅ Có ${lessonsInTopic.length} bài học từ topic $topicId");
      return lessonsInTopic;
    } catch (e) {
      debugPrint("❌ Error fetchLessonsByParentTopic: $e");
      hasError = true;
      errorMessage = 'Lỗi khi tải bài học con: $e';
      notifyListeners();
      return [];
    }
  }

  Future<int> fetchSubLessonCount(String parentLessonId) async {
    try {
      if (!await _setToken()) return 0;

      final res = await _dio.get('/lesson/getLessonByParent/$parentLessonId');
      debugPrint(
          "📥 API sub lesson count response for $parentLessonId: ${res.data}");

      final raw = res.data['rs'] ?? res.data['lessons'] ?? res.data;
      return (raw as List).length;
    } catch (e) {
      debugPrint("❌ Error fetchSubLessonCount: $e");
      hasError = true;
      errorMessage = 'Lỗi khi lấy số lượng bài học con: $e';
      notifyListeners();
      return 0;
    }
  }

  Future<List<LessonModel>> fetchSubLessons(String parentId) async {
    try {
      if (!await _setToken()) return [];

      final res = await _dio.get('/lesson/getLessonByParent/$parentId');
      final data = res.data['lessons'] ?? res.data['rs'] ?? [];

      debugPrint("📥 Sub lesson data for $parentId: $data");

      return (data as List).map((e) => LessonModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("❌ Error fetchSubLessons: $e");
      hasError = true;
      errorMessage = 'Lỗi khi tải bài học con: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> updateLessonProgress({
    required String lessonId,
    required String userId,
    required double score,
    required bool isCompleted,
  }) async {
    try {
      if (!await _setToken()) return;

      final response = await _dio.put(
        '/lesson-progress/update-by-lesson/$lessonId',
        data: {
          'userId': userId,
          'score': score,
          'isCompleted': isCompleted,
        },
      );

      debugPrint('✅ LessonProgress updated: ${response.data}');
    } catch (e) {
      debugPrint('❌ Error updateLessonProgress: $e');
      hasError = true;
      errorMessage = 'Lỗi cập nhật tiến độ bài học: $e';
      notifyListeners();
    }
  }

  void clearWithoutNotify() {
    topics = [];
    lessons = [];
    lessonProgressMap.clear();
    isFetched = false;
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
