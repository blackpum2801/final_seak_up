import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/core/constants/api_constants.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/core/util/toast_utils.dart';
import 'package:speak_up/models/user.dart' as model_user;

class AppService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final cookieJar = CookieJar();

  late final Dio _dio;

  AppService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.authBase,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> loginWithGoogle(BuildContext context,
      {bool fromRegister = false}) async {
    try {
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final userData = _buildOAuthUserData(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        avatar: user.photoURL,
        typeLogin: 'google',
      );

      await _registerUserOAuth(context, userData, fromRegister);
      await _loginOAuthSuccess(context, userData['id'], userData['tokenLogin']);
    } catch (e) {
      ToastUtils.showErrorToast(context, 'Lỗi Google login: $e');
    }
  }

  Future<void> loginWithFacebook(BuildContext context,
      {bool fromRegister = false}) async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        ToastUtils.showErrorToast(context, 'Facebook login thất bại');
        return;
      }

      final fbData = await FacebookAuth.instance
          .getUserData(fields: "id,name,email,picture.width(200)");
      final userData = _buildOAuthUserData(
        uid: fbData['id'],
        email: fbData['email'],
        displayName: fbData['name'],
        avatar: fbData['picture']?['data']?['url'],
        typeLogin: 'facebook',
      );

      await _registerUserOAuth(context, userData, fromRegister);
      await _loginOAuthSuccess(context, userData['id'], userData['tokenLogin']);
    } catch (e) {
      ToastUtils.showErrorToast(context, 'Lỗi Facebook login: $e');
    }
  }

  Map<String, dynamic> _buildOAuthUserData({
    required String uid,
    String? email,
    String? displayName,
    String? avatar,
    required String typeLogin,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final tokenLogin = uid + now;
    final safeEmail = email ?? '$uid@$typeLogin.auto';
    final name = displayName ?? uid;
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final username = name.replaceAll(' ', '');

    return {
      'id': uid,
      'tokenLogin': tokenLogin,
      'email': safeEmail,
      'firstname': firstName,
      'lastname': lastName,
      'username': username,
      'typeLogin': typeLogin,
      'password': 'firebase-default',
      'avatar': avatar ?? '',
    };
  }

  Future<bool> _registerUserOAuth(BuildContext context,
      Map<String, dynamic> userData, bool fromRegister) async {
    try {
      final res = await _dio.post('/register', data: userData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        ToastUtils.showSuccessToast(
            context, 'Đăng ký thành công (${userData['typeLogin']})');
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        if (fromRegister) {
          ToastUtils.showErrorToast(context, 'Tài khoản đã tồn tại!');
          context.go(RouteNames.login);
        } else {
          ToastUtils.showSuccessToast(context, 'Đăng nhập thành công!');
          await _loginOAuthSuccess(
              context, userData['id'], userData['tokenLogin']);
        }
        return false;
      }

      print('❌ Register OAuth error: $e');
      ToastUtils.showErrorToast(context, 'Lỗi khi đăng ký OAuth: ${e.message}');
      return false;
    } catch (e) {
      print('❗ Unexpected register error: $e');
      ToastUtils.showErrorToast(context, 'Lỗi không xác định khi đăng ký');
      return false;
    }
  }

  Future<void> _loginOAuthSuccess(
      BuildContext context, String id, String tokenLogin) async {
    try {
      final res = await _dio.post('/login-success-mobile', data: {
        'id': id,
        'tokenLogin': tokenLogin,
      });

      final data = res.data;
      if (data['err'] == 0) {
        final accessToken = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);

        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'userId', value: id);
        await storage.write(key: 'firstName', value: data['firstname'] ?? '');
        await storage.write(key: 'lastName', value: data['lastname'] ?? '');
        await storage.write(key: 'avatar', value: data['avatar'] ?? '');
        await storage.write(key: 'email', value: data['email'] ?? '');
        await storage.write(key: 'gender', value: data['gender'] ?? '');
        await storage.write(key: 'address', value: data['address'] ?? '');
        await storage.write(
            key: 'nativeLang', value: data['nativeLang'] ?? 'Vietnamese');
        await storage.write(
            key: 'displayLang', value: data['displayLang'] ?? 'Vietnamese');

        ToastUtils.showSuccessToast(
            context, 'Đăng nhập ${data['typeLogin'] ?? ''} thành công!');
        context.go(RouteNames.home);
      } else {
        ToastUtils.showErrorToast(context, data['msg'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      print('❌ Login success error: $e');
      ToastUtils.showErrorToast(context, 'Lỗi đăng nhập thành công: $e');
    }
  }

  Future<Map<String, dynamic>> _registerUserTo(
      String url, model_user.User user) async {
    try {
      final response = await _dio.post(url, data: user.toJson());
      return (response.statusCode == 200 || response.statusCode == 201)
          ? response.data
          : {
              'success': false,
              'mes': response.data['mes'] ?? 'Đăng ký thất bại',
            };
    } on DioException catch (e) {
      return {
        'success': false,
        'mes': e.response?.data['mes'] ?? 'Kết nối lỗi: ${e.message}',
      };
    } catch (e) {
      return {'success': false, 'mes': 'Lỗi không xác định: $e'};
    }
  }

  Future<Map<String, dynamic>> registerUser(model_user.User user) async {
    return _registerUserTo('/register', user);
  }

  Future<Map<String, dynamic>> registerGoogleUser(model_user.User user) async {
    return _registerUserTo('/google', user);
  }

  Future<Map<String, dynamic>> registerFacebookUser(
      model_user.User user) async {
    return _registerUserTo('/facebook', user);
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      return (response.statusCode == 200 || response.statusCode == 201)
          ? response.data
          : {
              'success': false,
              'mes': response.data['mes'] ?? 'Đăng nhập thất bại',
            };
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final errorMes = e.response?.data['msg'] ?? e.message;

      return {
        'success': false,
        'mes': status == 400
            ? 'Tài khoản hoặc mật khẩu không đúng'
            : 'Lỗi kết nối: $errorMes',
      };
    } catch (e) {
      return {'success': false, 'mes': 'Lỗi không xác định: $e'};
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/user/$userId', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Update user error: $e');
      return false;
    }
  }

  Future<void> logoutUser() async {
    try {
      final response = await _dio.get('/logout');
      print('✅ Logout: ${response.statusCode} | ${response.data}');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  Future<bool> updateProfileOrPassword(Map<String, dynamic> data,
      {File? avatarFile}) async {
    try {
      final formData = FormData.fromMap({
        ...data,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path,
              filename: 'avatar.jpg'),
      });
      final response = await _dio.put(
        '/users/profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      print('👉 Gửi request tới: ${_dio.options.baseUrl}/users/profile');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ updateProfileOrPassword error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      print("❌ Lỗi khi đăng xuất: $e");
    }
  }

  User? get currentUser => _auth.currentUser;
}
