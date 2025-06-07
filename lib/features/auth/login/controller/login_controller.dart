import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/core/services/app_services.dart';
import 'package:speak_up/core/util/toast_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final AppService _apiService = AppService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> login({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required VoidCallback onStart,
    required VoidCallback onFinish,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ToastUtils.showErrorToast(context, 'Vui lòng điền đủ thông tin');
      return;
    }

    onStart();

    try {
      final response = await _apiService.loginUser(email, password);

      if (context.mounted && response['success'] == true) {
        final accessToken = response['accessToken'];
        final userData = response['userData'];

        if (accessToken == null ||
            userData == null ||
            userData['_id'] == null) {
          ToastUtils.showErrorToast(context, 'Dữ liệu trả về không hợp lệ');
          return;
        }

        await _saveUserData(userData, accessToken);

        ToastUtils.showSuccessToast(context, 'Đăng nhập thành công');
        GoRouter.of(context).replace(RouteNames.home);
      } else {
        ToastUtils.showErrorToast(
            context, response['mes'] ?? 'Đăng nhập thất bại');
      }
    } catch (error) {
      ToastUtils.showErrorToast(context, 'Lỗi đăng nhập: $error');
    } finally {
      onFinish();
    }
  }

  Future<void> loginFromDeepLink({
    required BuildContext context,
    required String id,
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);

    await storage.write(key: 'userId', value: id);
    await storage.write(key: 'accessToken', value: accessToken);
    await storage.write(key: 'refreshToken', value: refreshToken);

    ToastUtils.showSuccessToast(context, 'Đăng nhập thành công (OAuth)');
    GoRouter.of(context).replace(RouteNames.home);
  }

  Future<void> _saveUserData(
      Map<String, dynamic> userData, String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);

    final entries = {
      'accessToken': accessToken,
      'userId': userData['_id'],
      'firstName': userData['firstname'] ?? '',
      'lastName': userData['lastname'] ?? '',
      'email': userData['email'] ?? '',
      'avatar': userData['avatar'] ?? '',
      'gender': userData['gender'] ?? '',
      'address': userData['address'] ?? '',
      'nativeLang': userData['nativeLang'] ?? 'Vietnamese',
      'displayLang': userData['displayLang'] ?? 'Vietnamese',
    };

    for (final entry in entries.entries) {
      await storage.write(key: entry.key, value: entry.value);
    }
  }
}
