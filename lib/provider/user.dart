import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:speak_up/core/services/dio_client.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final Dio _dio = DioClient().dio;

  Future<bool> updateProfile(Map<String, dynamic> data,
      {File? avatarFile}) async {
    _setLoading(true);
    _error = null;

    try {
      final formData = FormData.fromMap({
        ...data,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path,
              filename: 'avatar.jpg'),
      });

      final response = await _dio.put(
        '/users/profile', // ✅ Đảm bảo đúng route backend
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _error = response.data['rs'] ?? 'Cập nhật thất bại';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
