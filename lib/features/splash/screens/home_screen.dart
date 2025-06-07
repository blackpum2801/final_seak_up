import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/routing/route_names.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      GoRouter.of(context).go(RouteNames.register);
    });

    return Scaffold(
      body: Center(child: Text('Loading...', style: TextStyle(fontSize: 24))),
    );
  }
}
