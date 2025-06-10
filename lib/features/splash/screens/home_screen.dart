import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/routing/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        GoRouter.of(context).go(RouteNames.register);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Loading...', style: TextStyle(fontSize: 24))),
    );
  }
}
