import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speak_up/widgets/custom_text.dart';

class CustomCard extends StatelessWidget {
  final String svgPath;
  final String title;
  final int currentLessons;
  final int totalLessons;
  final VoidCallback onTapA;

  const CustomCard({
    super.key,
    required this.svgPath,
    required this.title,
    required this.currentLessons,
    required this.totalLessons,
    required this.onTapA,
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalLessons > 0 ? currentLessons / totalLessons : 0;

    return SizedBox(
      width: 160,
      height: 200,
      child: InkWell(
        onTap: onTapA,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  svgPath,
                  height: 70,
                  width: 70,
                ),
                const SizedBox(height: 10),
                CustomText(
                  text: title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Roboto",
                ),
                const Spacer(),
                const SizedBox(height: 5),
                CustomText(
                  text: '$currentLessons/$totalLessons bài học',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "OpenSans",
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
