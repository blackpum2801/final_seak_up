import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/features/learn/learn_lesson/screens/lesson_vocab.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/provider/lesson.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChildLessonsScreen extends StatefulWidget {
  final String parentTopicId;
  final String parentTopicTitle;

  const ChildLessonsScreen({
    super.key,
    required this.parentTopicId,
    required this.parentTopicTitle,
  });

  @override
  State<ChildLessonsScreen> createState() => _ChildLessonsScreenState();
}

class _ChildLessonsScreenState extends State<ChildLessonsScreen> {
  late List<LessonModel> childLessons = [];
  late bool isLoading = true;
  late Map<String, double> lessonProgress = {};
  late SharedPreferences prefs;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _initPrefsAndLoadLessons();
  }

  Future<void> _initPrefsAndLoadLessons() async {
    prefs = await SharedPreferences.getInstance();
    await _loadChildLessons();
  }

  Future<void> _loadChildLessons() async {
    final lessonProvider = context.read<LessonProvider>();

    print("📥 Gọi API bài học con với parentTopicId: ${widget.parentTopicId}");

    if (widget.parentTopicId.isEmpty) {
      print("❌ parentTopicId rỗng, không gọi API.");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    final result =
        await lessonProvider.fetchLessonsByParentTopic(widget.parentTopicId);

    print("📦 Nhận được ${result.length} bài học con");

    // Tải tiến độ cho từng bài học một lần
    final progressMap = <String, double>{};
    for (var lesson in result) {
      final completedWords = prefs.getInt('progress_${lesson.id}') ?? 0;
      final totalWords = prefs.getInt('totalWords_${lesson.id}') ?? 0;
      final progress = (totalWords > 0) ? (completedWords / totalWords) : 0.0;
      progressMap[lesson.id] = progress.clamp(0.0, 1.0);
    }

    if (mounted) {
      setState(() {
        childLessons = result;
        lessonProgress = progressMap;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadChildLessons();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          widget.parentTopicTitle,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : childLessons.isEmpty
                ? const Center(
                    child: Text(
                      "Không có bài học con",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    cacheExtent: 1000,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: childLessons.length,
                    itemBuilder: (context, index) {
                      final lesson = childLessons[index];
                      final progress = lessonProgress[lesson.id] ?? 0.0;
                      return Card(
                        color: AppColors.secondBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                                lesson.title,
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
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VocabularyListScreen(
                                  lessonId: lesson.id,
                                  lessonTitle: lesson.title,
                                ),
                              ),
                            ).then((_) {
                              _loadChildLessons();
                            });
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
