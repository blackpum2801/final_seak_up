import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:speak_up/core/constants/api_constants.dart';

class DashboardProvider extends ChangeNotifier {
  /// Số bài học hoàn thành theo từng ngày
  Map<String, int> lessonsPerDay = {};

  /// Tổng số bài đã hoàn thành
  int completedLessons = 0;

  /// Tổng điểm user hiện có
  int totalScore = 0;

  /// Loading UI state
  bool isLoading = false;

  /// Gọi API và xử lý dữ liệu dashboard cho userId
  Future<void> loadDashboard(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Lấy token nếu API yêu cầu
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'accessToken');

      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.base, // <-- Dùng dotenv
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      // 1. Lấy lesson progress
      final response1 = await dio
          .get(ApiConstants.lessonProgress.replaceFirst(ApiConstants.base, ''));
      final List<dynamic> lessonProgressList =
          response1.data is List ? response1.data : response1.data['rs'];

      final filtered = lessonProgressList.where((e) =>
          (e['userId'] == userId ||
              (e['userId'] is Map && e['userId']['_id'] == userId)) &&
          e['isCompleted'] == true);

      lessonsPerDay = {};
      for (var item in filtered) {
        final date = DateTime.parse(item['updatedAt']);
        final key =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        lessonsPerDay[key] = (lessonsPerDay[key] ?? 0) + 1;
      }

      // 2. Lấy progress tracking
      final response2 = await dio.get(
          ApiConstants.progressTracking.replaceFirst(ApiConstants.base, ''));
      final List<dynamic> trackingList =
          response2.data is List ? response2.data : response2.data['rs'];
      final tracking = trackingList.firstWhere(
        (e) => (e['userId'] == userId ||
            (e['userId'] is Map && e['userId']['_id'] == userId)),
        orElse: () => null,
      );
      if (tracking != null) {
        completedLessons = tracking['completedLessons'] ?? 0;
        totalScore = tracking['totalScore'] ?? 0;
      } else {
        completedLessons = 0;
        totalScore = 0;
      }
    } catch (e) {
      print("Error loading dashboard: $e");
      lessonsPerDay = {};
      completedLessons = 0;
      totalScore = 0;
    }

    isLoading = false;
    notifyListeners();
  }
}
