import 'package:flutter/material.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/features/expect/widgets/card_title.dart';
import 'package:speak_up/features/expect/widgets/type_game.dart';
import 'package:speak_up/widgets/custom_text.dart';

class ExpectScreen extends StatefulWidget {
  const ExpectScreen({Key? key}) : super(key: key);

  @override
  State<ExpectScreen> createState() => _ExpectScreenState();
}

class _ExpectScreenState extends State<ExpectScreen> {
  final List<TypeGame> sampleData = [
    TypeGame(
      iconPath: AppAssets.iconAiBot,
      title: 'Speak AI',
      colorIndex: 0,
      onTap: () {
        debugPrint("Icon 0 tapped!");
      },
    ),
    TypeGame(
      iconPath: AppAssets.iconScrabble,
      title: 'Sắp xếp từ',
      colorIndex: 4,
      onTap: () {
        debugPrint("Icon 0 tapped!");
      },
    ),
    TypeGame(
      iconPath: AppAssets.iconCrossword,
      title: 'Điền chữ',
      colorIndex: 2,
      onTap: () {
        debugPrint("Icon 2 tapped!");
      },
    ),
    TypeGame(
      iconPath: AppAssets.iconMic,
      title: 'Phát âm',
      colorIndex: 3,
      onTap: () {
        debugPrint("Icon 3 tapped!");
      },
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 12, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text: 'LOẠI TRÒ CHƠI',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 15,
                        right: index == sampleData.length - 1 ? 0 : 15,
                      ),
                      child: sampleData[index],
                    );
                  },
                ),
              ),
              const CustomText(
                text: 'CÔNG CỤ & TÍNH NĂNG',
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconVoice,
                iconColor: Color(0xFF9b5de5),
                title: 'Phân tích giọng nói',
                subtitle:
                    'Đánh giá khả năng nói tự do của bạn và nhận phản hồi về các kỹ năng',
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconTodoList,
                iconColor: Color(0xFFf15bb5),
                title: 'Bộ Bài Học',
                subtitle:
                    'Tạo các Bộ học tập của riêng bạn, hoặc khám phá các bộ được tạo bởi những người dùng khác',
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconDictionary,
                iconColor: Color(0xFFfee440),
                title: 'Từ điển',
                subtitle:
                    'Tra nghĩa và cách phát âm đúng của bất kỳ từ hay cụm từ nào',
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconFilter,
                iconColor: Color(0xFF00bbf9),
                title: 'Công cụ tìm Khóa học',
                subtitle:
                    'Lọc nội dung để tìm các bài học phù hợp với bạn nhất',
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconCoachAi,
                iconColor: Color(0xFF00f5d4),
                title: 'Huấn luyện viên',
                subtitle:
                    'Luyện các bài học đề xuất dựa trên tiến trình của bạn',
              ),
              const SizedBox(height: 15),
              const CustomText(
                text: 'HỌC TẬP CÙNG CỘNG ĐỒNG',
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
              const CardTitleExpect(
                iconPath: AppAssets.iconCommunity,
                iconColor: Color(0xFFf6f4d2),
                title: 'Tham gia vào cộng đồng',
                subtitle:
                    'Tham gia cộng đồng toàn cầu của Speak Up để chia sẻ và học hỏi lẫn nhau',
              ),
              const SizedBox(height: 6),
              const CardTitleExpect(
                iconPath: AppAssets.iconNews,
                iconColor: Color(0xFFf19c79),
                title: 'Trang tin cộng đồng',
                subtitle:
                    'Đọc những cập nhật mới nhất từ cộng đồng toàn cầu của chúng tôi',
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}
