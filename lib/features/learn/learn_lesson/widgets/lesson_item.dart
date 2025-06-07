import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speak_up/core/constants/asset_color.dart';

class Lesson {
  final String title;
  final String progress;
  final String imagePath;
  final Widget destination;

  Lesson({
    required this.title,
    required this.progress,
    required this.imagePath,
    required this.destination,
  });
}

class LessonItem extends StatelessWidget {
  final Lesson lesson;

  const LessonItem({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: SvgPicture.asset(
          lesson.imagePath,
          width: 50,
          height: 50,
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lesson.progress,
          style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => lesson.destination),
          );
        },
      ),
    );
  }
}
