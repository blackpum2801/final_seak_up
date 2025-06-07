import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:speak_up/core/services/dio_client.dart';
import 'package:speak_up/models/course.dart';

class CourseProvider extends ChangeNotifier {
  final Dio _dio = DioClient().dio;

  List<Course> _courses = [];
  bool isLoading = false;

  List<Course> get courses => _courses;

  Future<void> fetchCourses() async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await _dio.get('/courses');
      _courses = List<Course>.from(
        (res.data as List).map((e) => Course.fromJson(e)),
      );
    } catch (e) {
      debugPrint("❌ Error fetching courses: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
