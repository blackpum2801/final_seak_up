import 'dart:ui';

class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color background = Color(0xFF16103e);
  static const Color secondBackground = Color(0xFF1f1a50);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFB00020);
  static const Color tagEasy = Color(0xFF38b000);
  static const Color tagMedium = Color(0xFFF77F00);
  static const Color tagHard = Color(0xFFdc2f02);
  static const Color navigation = Color(0xFF16112f);

  static final List<Color> courseCardColors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF45B7D1),
    const Color(0xFFF7D794),
    const Color(0xFF9B59B6),
  ];
  static Color getCourseCardColor(int index) {
    return courseCardColors[index % courseCardColors.length];
  }
}
