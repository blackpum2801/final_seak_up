import 'package:go_router/go_router.dart';
import 'package:speak_up/features/home/screens/chat_screen.dart';
import 'package:speak_up/features/auth/login/screens/login.dart';
import 'package:speak_up/features/auth/register/screens/register.dart';
import 'package:speak_up/features/learn/learn_lesson/screens/lesson_screen.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_screen.dart';
import 'package:speak_up/features/splash/screens/home_screen.dart';
import 'package:speak_up/widgets/main_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const MainScreen(currentIndex: 0),
      ),
      GoRoute(
        path: RouteNames.learn,
        builder: (context, state) => const MainScreen(currentIndex: 1),
      ),
      GoRoute(
        path: RouteNames.expect,
        builder: (context, state) => const MainScreen(currentIndex: 2),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const MainScreen(currentIndex: 3),
      ),
      GoRoute(
        path: '/learn/lesson',
        builder: (context, state) => const LearnLessonScreen(),
      ),
      GoRoute(
        path: '/learn/topic',
        builder: (context, state) => const TopicScreen(),
      ),
      GoRoute(
        path: '/chatbot',
        builder: (context, state) => const AiChatScreen(),
      ),
    ],
  );
}
