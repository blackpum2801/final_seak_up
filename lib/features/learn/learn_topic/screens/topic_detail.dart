import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_sublesson.dart';
import 'package:speak_up/features/learn/learn_topic/widgets/topic_custom.dart';
import 'package:speak_up/models/topic.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/provider/lesson.dart';
import 'package:speak_up/provider/topic.dart';
import 'package:speak_up/provider/wishlist.dart';

class TopicDetailScreen extends StatefulWidget {
  final String topicId;
  final String title;

  const TopicDetailScreen({
    super.key,
    required this.topicId,
    required this.title,
  });

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  TopicModel? topic;
  List<LessonModel> lessons = [];
  bool isLoading = true;
  final Map<String, int> _subLessonCounts = {};

  @override
  void initState() {
    super.initState();
    loadTopicAndLessons();
  }

  Future<void> loadTopicAndLessons() async {
    final topicProvider = context.read<TopicProvider>();
    final lessonProvider = context.read<LessonProvider>();

    final fetchedTopic = await topicProvider.fetchTopicById(widget.topicId);
    final fetchedLessons =
        await lessonProvider.fetchLessonsByParentTopic(widget.topicId);

    final countFutures = fetchedLessons
        .map((l) => lessonProvider.fetchSubLessonCount(l.id))
        .toList();
    final counts = await Future.wait(countFutures);
    for (var i = 0; i < fetchedLessons.length; i++) {
      _subLessonCounts[fetchedLessons[i].id] = counts[i];
    }

    setState(() {
      topic = fetchedTopic;
      lessons = fetchedLessons;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : topic == null
              ? const Center(child: Text('Không tìm thấy chủ đề'))
              : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    final total = _subLessonCounts[lesson.id] ?? 0;
                    return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SubLessonScreen(
                                  parentLessonId: lesson.id,
                                  title: lesson.title,
                                ),
                              ),
                            );
                          },
                          child: TopicCard(
                            image: lesson.thumbnail ?? topic!.thumbnail,
                            title: lesson.title,
                            subtitle: lesson.content ?? '',
                            lesson: '$total Bài học',
                            isHorizontal: true,
                            isFavorite:
                                wishlistProvider.isInWishlist(lesson.id),
                            onFavoriteToggle: () async {
                              if (wishlistProvider.isInWishlist(lesson.id)) {
                                await wishlistProvider
                                    .removeFromWishlist(lesson.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Đã xoá khỏi danh sách yêu thích')),
                                );
                              } else {
                                await wishlistProvider.addToWishlist(lesson.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Đã thêm yêu thích thành công')),
                                );
                              }
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
