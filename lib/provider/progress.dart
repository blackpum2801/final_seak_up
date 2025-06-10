import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/api_constants.dart';
import 'package:speak_up/models/lesson_progress.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProgressProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  List<LessonProgressModel> _progresses = [];
  bool _isLoading = false;
  String? _error;

  List<LessonProgressModel> get progresses => _progresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String baseUrl = ApiConstants.lessonProgress;

  Future<String?> _getToken() async {
    return await _storage.read(key: "accessToken");
  }

  Future<void> fetchProgresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _progresses = (data['rs'] as List)
            .map((e) => LessonProgressModel.fromJson(e))
            .toList();
        _error = null;
      } else {
        _progresses = [];
        _error = data['rs'].toString();
      }
    } catch (e) {
      _error = e.toString();
      _progresses = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createProgress(LessonProgressModel progress) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(progress.toJson()),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Optionally add to _progresses
        fetchProgresses(); // refresh
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> updateProgressByLessonId({
    required String lessonId,
    required String userId,
    required double score,
    required bool isCompleted,
  }) async {
    try {
      final token = await _getToken();
      final url = "$baseUrl/lesson-progress/$lessonId";
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "userId": userId,
          "score": score,
          "isCompleted": isCompleted,
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchProgresses();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> deleteProgress(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        await fetchProgresses();
        return true;
      }
    } catch (_) {}
    return false;
  }

  LessonProgressModel? getProgressOfLesson(String lessonId, String userId) {
    try {
      return _progresses.firstWhere(
          (p) => p.lessonId == lessonId && p.userId == userId,
          orElse: () => throw StateError('No matching progress found'));
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _progresses = [];
    notifyListeners();
  }
}
