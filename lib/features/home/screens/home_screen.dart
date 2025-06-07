import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/provider/chat_provider.dart';
import 'package:speak_up/features/home/screens/chat_screen.dart';
import 'package:speak_up/features/home/screens/home_all_conversation.dart';
import 'package:speak_up/features/home/widgets/card_convertion.dart';
import 'package:speak_up/features/home/widgets/card_title.dart';
import 'package:speak_up/models/lesson.dart';
import 'package:speak_up/provider/ai_conversation.dart';
import 'package:speak_up/widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  String firstName = 'Người dùng';
  String lastName = '';
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final provider = context.read<AiLessonProvider>();

    if (!provider.isFetched && !provider.isLoading) {
      await provider.getAIConversation();
    }

    final fName = await storage.read(key: 'firstName');
    final lName = await storage.read(key: 'lastName');

    if (mounted) {
      setState(() {
        firstName = fName ?? 'Người dùng';
        lastName = lName ?? '';
        _initDone = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    await context.read<AiLessonProvider>().refresh();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiLessons = context.select((AiLessonProvider p) => p.aiLessons);
    final isLoading = context.select((AiLessonProvider p) => p.isLoading);
    final hasError = context.select((AiLessonProvider p) => p.hasError);
    final errorMessage = context.select((AiLessonProvider p) => p.errorMessage);
    final previewLessons = aiLessons.take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomText(
              text: 'Chào mừng bạn trở lại',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            CustomText(
              text: '$firstName $lastName',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
      body: !_initDone || isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CustomText(
                        text: 'Đã xảy ra lỗi khi tải dữ liệu',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      CustomText(
                        text: errorMessage ?? 'Không xác định',
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _onRefresh,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: [
                      _buildAICard(previewLessons),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: CustomText(
                          text: "Hôm nay, chúng ta nên làm gì?",
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            CardTitle(
                              iconPath: AppAssets.iconHomework,
                              iconColor: Colors.amberAccent,
                              title: "Luyện tập Bài học Hàng ngày",
                            ),
                            SizedBox(height: 6),
                            CardTitle(
                              iconPath: AppAssets.iconWaveform,
                              iconColor: Color.fromARGB(255, 40, 172, 233),
                              title: "Cải thiện Phát âm",
                            ),
                            SizedBox(height: 6),
                            CardTitle(
                              iconPath: AppAssets.iconMessage,
                              iconColor: Color.fromARGB(255, 213, 40, 243),
                              title: "Học theo Chủ đề",
                            ),
                            SizedBox(height: 6),
                            CardTitle(
                              iconPath: AppAssets.iconCertificate,
                              iconColor: Colors.orangeAccent,
                              title: "Nhận được Chứng chỉ",
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAICard(List<LessonModel> previewLessons) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Card(
        color: AppColors.secondBackground,
        elevation: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: CustomText(
                text: 'SPEAKUP AI Conversations',
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<AiLessonProvider>(
                    builder: (context, provider, _) => CustomText(
                      text: "Có ${provider.aiLessons.length} Cuộc ĐÀM THOẠI",
                      color: Colors.amberAccent,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllConversationsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            previewLessons.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CustomText(
                      text: 'Chưa có cuộc đàm thoại nào.',
                      color: Colors.white,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 360,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: previewLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = previewLessons[index];
                        return AspectRatio(
                          aspectRatio: 3.5 / 5,
                          child: CardConVerSation(
                            imageUrl: lesson.thumbnail ?? '',
                            title: lesson.title,
                            tag: lesson.category ?? '',
                            tagColor: _getTagColor(lesson.category),
                            onTap: () {
                              context
                                  .read<ChatProvider>()
                                  .setTopic(lesson.title);
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
          ],
        ),
      ),
    );
  }

  Color _getTagColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'basics':
        return Colors.green;
      case 'travel':
        return Colors.blue;
      case 'business':
        return Colors.orange;
      case 'family':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
