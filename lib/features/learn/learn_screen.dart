import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/features/home/widgets/category_card.dart';
import 'package:speak_up/features/learn/widgets/community_card.dart';
import 'package:speak_up/features/learn/widgets/custom_card.dart';
import 'package:speak_up/widgets/custom_text.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  _PageTwoScreenState createState() => _PageTwoScreenState();
}

class _PageTwoScreenState extends State<LearnScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  final List<Map<String, String>> categories = [
    {
      'title': 'Bài học',
      'imagePath': AppAssets.imageLesson,
    },
    {
      'title': 'Chủ đề',
      'imagePath': AppAssets.imageTopic,
    },
  ];

  final List<Map<String, dynamic>> sampleData = [
    {
      'logo': AppAssets.logoElsa,
      'title': 'Bài học 1',
      'author': 'Tác giả 1',
      'vocabulary': '10',
      'likes': 100,
      'backgroundColor': AppColors.getCourseCardColor(0),
    },
    {
      'logo': AppAssets.logoElsa,
      'title': 'Bài học 2',
      'author': 'Tác giả 2',
      'vocabulary': '20',
      'likes': 200,
      'backgroundColor': AppColors.getCourseCardColor(1),
    },
    {
      'logo': AppAssets.logoElsa,
      'title': 'Bài học 3',
      'author': 'Tác giả 3',
      'vocabulary': '20',
      'likes': 200,
      'backgroundColor': AppColors.getCourseCardColor(3),
    },
    {
      'logo': AppAssets.logoElsa,
      'title': 'Bài học 4',
      'author': 'Tác giả 4',
      'vocabulary': '20',
      'likes': 200,
      'backgroundColor': AppColors.getCourseCardColor(4),
    },
    {
      'logo': AppAssets.logoElsa,
      'title': 'Bài học 5',
      'author': 'Tác giả 5',
      'vocabulary': '20',
      'likes': 200,
      'backgroundColor': AppColors.getCourseCardColor(5),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: categories
                    .map(
                      (item) => Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 10, left: 8, right: 8),
                          child: InkWell(
                            onTap: () {
                              final title = item['title']!;
                              if (title == 'Lesson' || title == 'Bài học') {
                                context.push('/learn/lesson');
                              } else if (title == 'Topic' ||
                                  title == 'Chủ đề') {
                                context.push('/learn/topic');
                              }
                            },
                            child: CategoryCard(
                              title: item['title']!,
                              imagePath: item['imagePath']!,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 18,
                endIndent: 18,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      text: "Gợi ý cho bạn",
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    const CustomText(
                      text: "Tập trung các kỹ năng này để cải thiện nhanh nhất",
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: Color.fromARGB(255, 212, 210, 210),
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    CustomCard(
                      svgPath: AppAssets.imageHanhtinh,
                      title: 'Tiếng Anh',
                      currentLessons: 10,
                      totalLessons: 38,
                      onTapA: () {},
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const CustomText(
                          text: "Học phần đã được tuyển chọn",
                          fontFamily: 'OpenSans',
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            print("Clicked Xem tất cả");
                          },
                          child: const CustomText(
                            text: "Xem tất cả",
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const CustomText(
                      text: "Các học phần phổ biến nhất từ cộng đồng Speak Up",
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: Color.fromARGB(255, 212, 210, 210),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 280,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sampleData.length,
                    itemBuilder: (context, index) {
                      final data = sampleData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CardCommunity(
                          logo: data['logo'],
                          title: data['title'],
                          author: data['author'],
                          vocabulary: data['vocabulary'],
                          likes: data['likes'],
                          backgroundColor: data['backgroundColor'],
                          onTap: () {
                            print("Clicked ${data['title']}");
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
