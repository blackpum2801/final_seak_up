import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/features/learn/learn_lesson/screens/lesson_child_screen.dart';
import 'package:speak_up/provider/lesson.dart';

class LearnLessonScreen extends StatefulWidget {
  const LearnLessonScreen({super.key});

  @override
  State<LearnLessonScreen> createState() => _LearnLessonScreenState();
}

class _LearnLessonScreenState extends State<LearnLessonScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final LessonProvider _lessonProvider;

  @override
  void initState() {
    super.initState();
    _lessonProvider = context.read<LessonProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _lessonProvider.fetchLessonsBySection();
      }
    });
  }

  @override
  void dispose() {
    _lessonProvider.clearWithoutNotify();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _lessonProvider.fetchLessonsBySection();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "Bài học",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.background,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: Consumer<LessonProvider>(
          builder: (context, lessonProvider, _) {
            if (lessonProvider.isLoading) {
              return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2));
            }
            if (lessonProvider.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đã xảy ra lỗi khi tải bài học.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (lessonProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          lessonProvider.errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _onRefresh,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }
            if (lessonProvider.topics.isEmpty) {
              return const Center(
                child: Text(
                  'Không có bài học nào.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }
            return ListView.builder(
              cacheExtent: 1000,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: lessonProvider.topics.length,
              itemBuilder: (context, index) {
                final topic = lessonProvider.topics[index];
                return Card(
                  color: AppColors.secondBackground,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: CachedNetworkImage(
                        imageUrl: topic.thumbnail ??
                            'https://dummyimage.com/100x100/000/fff',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            (50 * MediaQuery.of(context).devicePixelRatio)
                                .toInt(),
                        memCacheHeight:
                            (50 * MediaQuery.of(context).devicePixelRatio)
                                .toInt(),
                        fadeInDuration: const Duration(milliseconds: 300),
                        placeholder: (context, url) => const SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      ),
                    ),
                    title: Text(
                      topic.title,
                      style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
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
                          builder: (context) => ChildLessonsScreen(
                            parentTopicId: topic.id,
                            parentTopicTitle: topic.title,
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
      ),
    );
  }
}
