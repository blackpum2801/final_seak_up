import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/provider/chat_provider.dart';
import 'package:speak_up/features/home/screens/chat_screen.dart';
import 'package:speak_up/provider/ai_conversation.dart';

class AllConversationsScreen extends StatefulWidget {
  const AllConversationsScreen({super.key});

  @override
  State<AllConversationsScreen> createState() => _AllConversationsScreenState();
}

class _AllConversationsScreenState extends State<AllConversationsScreen> {
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int visibleCount = 10;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !isLoadingMore) {
        loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void loadMore() {
    final max = context.read<AiLessonProvider>().aiLessons.length;
    if (visibleCount >= max || isLoadingMore) return;

    setState(() => isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          visibleCount = (visibleCount + 10).clamp(0, max);
          isLoadingMore = false;
        });
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<AiLessonProvider>().refresh();
    if (mounted) {
      setState(() {
        visibleCount = 10; // Reset visible count
      });
    }
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.read<ChatProvider>();
    final lessons = context.watch<AiLessonProvider>().aiLessons;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Tất cả cuộc đàm thoại',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: lessons.isEmpty
            ? const Center(
                child: Text(
                  'Không có cuộc đàm thoại nào.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                itemCount: visibleCount + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= visibleCount) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  }
                  final lesson = lessons[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      leading: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: (lesson.thumbnail?.isNotEmpty ?? false)
                            ? CachedNetworkImage(
                                imageUrl: lesson.thumbnail!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                memCacheWidth: (80 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .toInt(),
                                memCacheHeight: (80 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .toInt(),
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                placeholder: (context, url) => const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) =>
                                    const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 80,
                                height: 80,
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                      ),
                      title: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: (lesson.content?.isNotEmpty ?? false)
                          ? Text(
                              lesson.content!,
                              style: const TextStyle(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      tileColor: AppColors.secondBackground,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      onTap: () {
                        chat.setTopic(lesson.title);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AiChatScreen(initialTopic: lesson.title),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
