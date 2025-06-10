import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/routing/app_router.dart';
import 'package:speak_up/provider/ai_conversation.dart';
import 'package:speak_up/provider/chat_provider.dart';
import 'package:speak_up/provider/course.dart';
import 'package:speak_up/provider/dashboard.dart';
import 'package:speak_up/provider/lesson.dart';
import 'package:speak_up/provider/speech.dart';
import 'package:speak_up/provider/topic.dart';
import 'package:speak_up/provider/user.dart';
import 'package:speak_up/provider/vocabulary.dart';
import 'package:speak_up/provider/wishlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase và Dotenv với xử lý lỗi
  try {
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      debugPrint("✅ API_BASE: ${dotenv.env['API_BASE']}");
    }
  } catch (e) {
    debugPrint("❌ Lỗi khởi tạo: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()),
        ChangeNotifierProvider(create: (_) => AiLessonProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
