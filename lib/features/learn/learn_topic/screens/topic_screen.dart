import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/core/routing/route_names.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_all_category.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_detail.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_sublesson.dart';
import 'package:speak_up/features/learn/learn_topic/widgets/topic_category.dart';
import 'package:speak_up/features/learn/learn_topic/widgets/topic_custom.dart';
import 'package:speak_up/provider/topic.dart';
import 'package:speak_up/provider/wishlist.dart';
import 'package:speak_up/widgets/custom_text.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  bool _initDone = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);

    final topicProvider = context.read<TopicProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    // Chỉ gọi nếu chưa từng fetch
    if (!topicProvider.isFetched) {
      await topicProvider.fetchTopicsAndLessons();
    }

    // Wishlist có thể cập nhật liên tục nên vẫn fetch mỗi lần
    await wishlistProvider.fetchWishlist();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _initDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone || _isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _buildMainContent();
  }

  Widget _buildMainContent() {
    final topicProvider = context.watch<TopicProvider>();
    final wishlistProvider = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const CustomText(
          text: 'Chủ đề',
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.push(RouteNames.learn),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh mục
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const CustomText(
                    text: 'Danh mục',
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AllTopicsScreen()),
                    ),
                    child: const CustomText(
                      text: 'Xem tất cả',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: topicProvider.topics.length,
                itemBuilder: (context, index) {
                  final topic = topicProvider.topics[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CategoryTopicCard(
                      title: topic.title,
                      subtitle: '${topic.totalLessons} chủ đề',
                      imagePath: topic.thumbnail,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicDetailScreen(
                            topicId: topic.id,
                            title: topic.title,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Yêu thích
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: CustomText(
                text: 'Yêu thích của tôi',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            wishlistProvider.items.isEmpty
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.imageFavourite,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: 'Bạn chưa có chủ đề yêu thích nào.',
                                fontSize: 18,
                                maxLines: 2,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: 4),
                              CustomText(
                                text:
                                    'Nhấp vào biểu tượng trái tim để thêm chủ đề vào danh sách yêu thích của bạn.',
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 12),
                    child: SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: wishlistProvider.items.length,
                        itemBuilder: (context, index) {
                          final item = wishlistProvider.items[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: SizedBox(
                              width: 260,
                              child: TopicCard(
                                image: item.lessonThumbnail ?? '',
                                title: item.lessonTitle ?? '',
                                subtitle: item.lessonContent ?? '',
                                lesson: '${item.totalLessons ?? 0} Bài học',
                                isFavorite: true,
                                isHorizontal: false,
                                onFavoriteToggle: () async {
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  await wishlistProvider
                                      .removeFromWishlist(item.lessonId);
                                  await wishlistProvider.fetchWishlist();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Đã xoá khỏi danh sách yêu thích'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

            // Trending
            if (topicProvider.trendingLessons.isNotEmpty)
              _buildLessonSection(
                title: 'Đang thịnh hành',
                lessons: topicProvider.trendingLessons,
                wishlistProvider: wishlistProvider,
              ),

            // Latest
            if (topicProvider.latestLessons.isNotEmpty)
              _buildLessonSection(
                title: 'Nội dung mới phát hành',
                lessons: topicProvider.latestLessons,
                wishlistProvider: wishlistProvider,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonSection({
    required String title,
    required List<dynamic> lessons,
    required WishlistProvider wishlistProvider,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 260,
                    child: TopicCard(
                      image: lesson.thumbnail ?? '',
                      title: lesson.title,
                      subtitle: lesson.content ?? '',
                      lesson: title == 'Đang thịnh hành'
                          ? 'Bài học nổi bật'
                          : 'Phát hành gần đây',
                      isFavorite: wishlistProvider.isInWishlist(lesson.id),
                      isHorizontal: false,
                      onFavoriteToggle: () async {
                        final isFav = wishlistProvider.isInWishlist(lesson.id);
                        if (isFav) {
                          await wishlistProvider.removeFromWishlist(lesson.id);
                        } else {
                          await wishlistProvider.addToWishlist(lesson.id);
                        }
                        await wishlistProvider.fetchWishlist();
                      },
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubLessonScreen(
                            parentLessonId: lesson.id,
                            title: lesson.title,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
