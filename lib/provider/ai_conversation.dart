import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/models/lesson.dart';
import 'dart:convert';

class AiLessonProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<LessonModel> aiLessons = [];
  bool isLoading = false;
  bool _isFetched = false;
  bool hasError = false;
  String? errorMessage;

  bool get isFetched => _isFetched;

  static List<LessonModel> _parseLessons(List<dynamic> raw) {
    return raw
        .map((e) => LessonModel.fromJson(e))
        .where((l) =>
            l.isAIConversationEnabled == true && l.parentLessonId == null)
        .toList();
  }

  Future<void> getAIConversation() async {
    if (_isFetched || isLoading) return;

    isLoading = true;
    hasError = false;
    errorMessage = null;
    notifyListeners();

    try {
      // 📦 Đọc cache nếu có
      final cached = await _storage.read(key: 'aiLessons');
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached);
          if (decoded is List) {
            final parsed = await compute(_parseLessons, decoded);
            if (parsed.isNotEmpty) {
              aiLessons = parsed;
              _isFetched = true;
              debugPrint("✅ Đã load từ cache: ${aiLessons.length} bài học");
              isLoading = false;
              notifyListeners();
              return;
            } else {
              debugPrint("⚠️ Cache tồn tại nhưng không có bài học hợp lệ");
              await _storage.delete(key: 'aiLessons');
            }
          } else {
            throw Exception("❌ Dữ liệu cache không phải dạng danh sách");
          }
        } catch (e) {
          debugPrint("⚠️ Lỗi khi parse cache, sẽ gọi API mới: $e");
          await _storage.delete(key: 'aiLessons');
        }
      }

      // 🌐 Gọi API nếu cache không có hoặc không dùng được
      final res = await _dio.get('/lesson');
      final raw = res.data['rs'] ?? res.data;
      if (raw is! List) throw Exception("❌ API trả về không phải danh sách");

      aiLessons = await compute(_parseLessons, raw);
      await _storage.write(key: 'aiLessons', value: jsonEncode(raw));
      _isFetched = true;
      debugPrint("✅ Đã load ${aiLessons.length} bài học AI từ API");
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
      debugPrint("❌ Lỗi khi load bài học AI: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isFetched = false;
    aiLessons.clear();
    await _storage.delete(key: 'aiLessons');
    await getAIConversation();
  }

  void clearWithoutNotify() {
    aiLessons = [];
    _isFetched = false;
    hasError = false;
    errorMessage = null;
  }
}
