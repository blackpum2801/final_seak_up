import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/provider/lesson.dart';
// Nếu có màn VocabularyListScreen thì import luôn
import 'package:speak_up/features/learn/learn_lesson/screens/lesson_vocab.dart';

class SubLessonScreen extends StatefulWidget {
  final String parentLessonId;
  final String title;

  const SubLessonScreen({
    super.key,
    required this.parentLessonId,
    required this.title,
  });

  @override
  State<SubLessonScreen> createState() => _SubLessonScreenState();
}

class _SubLessonScreenState extends State<SubLessonScreen> {
  late Future<List<LessonModel>> _subLessonsFuture;

  @override
  void initState() {
    super.initState();
    _subLessonsFuture =
        context.read<LessonProvider>().fetchSubLessons(widget.parentLessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<List<LessonModel>>(
        future: _subLessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
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
              child: Text(
                'Không có bài học con',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: subLessons.length,
            itemBuilder: (context, index) {
              final l = subLessons[index];
              // TODO: Nếu có progress thì tính toán giống bên ChildLessonsScreen, còn không thì bỏ progress = 0.0
              double progress = 0.0;
              // Nếu bạn muốn có progress thực, cần truyền vào dữ liệu, còn không thì chỉ để 0.

              return Card(
                color: AppColors.secondBackground,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white12,
                    child: Icon(Icons.mic, color: Colors.white),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.title,
                        style: GoogleFonts.notoSans(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                  subtitle: l.content != null && l.content!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            l.content!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : null,
                  onTap: () {
                    // Nếu muốn mở màn học vocabulary thì truyền sang đúng màn hình
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VocabularyListScreen(
                          lessonId: l.id,
                          lessonTitle: l.title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
