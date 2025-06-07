// register_controller.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/core/services/app_services.dart';
import 'package:speak_up/core/util/toast_utils.dart';
import 'package:speak_up/models/user.dart';
import 'package:uuid/uuid.dart';

class RegisterController {
  final AppService _apiService = AppService();

  Future<void> register({
    required BuildContext context,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstnameController,
    required TextEditingController lastnameController,
    required TextEditingController addressController,
    required String gender,
    required String username,
    required VoidCallback onStart,
    required VoidCallback onFinish,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final firstname = firstnameController.text.trim();
    final lastname = lastnameController.text.trim();
    final address = addressController.text.trim();

    if ([email, password, firstname, lastname, address, gender]
        .any((e) => e.isEmpty)) {
      ToastUtils.showErrorToast(context, 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (password != confirmPassword) {
      ToastUtils.showErrorToast(context, 'Mật khẩu không khớp');
      return;
    }

    final user = User(
      id: const Uuid().v4(),
      tokenLogin: const Uuid().v4(),
      typeLogin: 'email',
      username: username,
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      refreshToken: '',
      avatar: '',
      role: 'student',
      level: 0,
      totalScore: 0,
      address: address,
      gender: gender,
    );

    onStart();

    try {
      final response = await _apiService.registerUser(user);
      if (context.mounted && response['success'] == true) {
        ToastUtils.showSuccessToast(context, 'Đăng ký thành công');
        await Future.delayed(const Duration(milliseconds: 300));
        GoRouter.of(context).replace(RouteNames.login, extra: {
          'email': email,
          'password': password,
        });
      } else {
        ToastUtils.showErrorToast(context, response['mes'] ?? 'Đã xảy ra lỗi');
      }
    } catch (error) {
      ToastUtils.showErrorToast(context, 'Đã xảy ra lỗi! $error');
    } finally {
      onFinish();
    }
  }
}
