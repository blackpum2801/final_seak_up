import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/core/services/app_services.dart';
import 'package:speak_up/features/auth/login/controller/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AppLinks _appLinks;
  final LoginController _loginController = LoginController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listenDeepLinks();
  }

  void _listenDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'login-success') {
        final id = uri.pathSegments[0];
        final token = uri.pathSegments[1];
        final refreshToken = uri.queryParameters['refreshToken'] ?? '';
        _loginController.loginFromDeepLink(
          context: context,
          id: id,
          accessToken: token,
          refreshToken: refreshToken,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    _loginController.login(
      context: context,
      emailController: _emailController,
      passwordController: _passwordController,
      onStart: () => setState(() => _isLoading = true),
      onFinish: () => setState(() => _isLoading = false),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Your email address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Your password',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot password?',
                    style: TextStyle(color: Colors.blue)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: SvgPicture.asset(AppAssets.logoGoogle, width: 32),
                  onPressed: () => AppService().loginWithGoogle(context),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: SvgPicture.asset(AppAssets.logoFb, width: 36),
                  onPressed: () => AppService().loginWithFacebook(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white))
                  : const Text('Đăng nhập',
                      style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: RichText(
                text: TextSpan(
                  text: 'Bạn chưa có tài khoản? ',
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Đăng ký',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.go(RouteNames.register),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
