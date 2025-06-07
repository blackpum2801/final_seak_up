import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/provider/lesson.dart';

class SubLessonScreen extends StatelessWidget {
  final String parentLessonId;
  final String title;

  const SubLessonScreen({
    super.key,
    required this.parentLessonId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<LessonModel>>(
        future: context.read<LessonProvider>().fetchSubLessons(parentLessonId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final subLessons = snapshot.data ?? [];

          if (subLessons.isEmpty) {
            return const Center(
              child: Text('Không có bài học con',
                  style: TextStyle(color: Colors.white)),
            );
          }

          return ListView.builder(
            itemCount: subLessons.length,
            itemBuilder: (context, index) {
              final l = subLessons[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.secondBackground,
                child: ListTile(
                  title: Text(
                    l.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    l.content ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
