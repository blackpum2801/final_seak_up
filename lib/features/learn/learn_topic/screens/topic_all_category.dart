import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/features/learn/learn_topic/screens/topic_detail.dart';
import 'package:speak_up/provider/topic.dart';
import 'package:speak_up/widgets/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllTopicsScreen extends StatefulWidget {
  const AllTopicsScreen({super.key});

  @override
  State<AllTopicsScreen> createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _onRefresh() async {
    await context.read<TopicProvider>().fetchTopicsAndLessons();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final topics = context.watch<TopicProvider>().topics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Tất cả danh mục',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _onRefresh,
        header: const WaterDropHeader(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: GridView.builder(
            itemCount: topics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final topic = topics[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicDetailScreen(
                        topicId: topic.id,
                        title: topic.title,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.05),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(topic.thumbnail),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: topic.title,
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        maxLines: 2,
                      ),
                      const Spacer(),
                      CustomText(
                        text: '${topic.totalLessons} Chủ đề',
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
