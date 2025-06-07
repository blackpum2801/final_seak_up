import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static final String _base = dotenv.env['API_BASE']!;
  static final String _authBase = dotenv.env['AUTH_BASE']!;

  static String get base => _base;
  static String get authBase => _authBase;

  static String get lesson => '$base/lesson';
  static String get lessonProgress => '$base/lessonProgress';
  static String get progressTracking => '$base/progressTracking';
}
