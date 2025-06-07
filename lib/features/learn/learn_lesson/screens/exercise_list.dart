// import 'package:flutter/material.dart';
// import 'package:speak_up/core/constants/asset_color.dart';
// import 'package:speak_up/features/learn/learn_lesson/widgets/video_lesson.dart';
// import 'package:speak_up/mock/mock_learn.dart';
// import 'package:speak_up/widgets/custom_text.dart';
// import '../widgets/lesson_tabs_widget.dart';

// class ExerciseList extends StatelessWidget {
//   final List<String> exercises;
//   final String lessonTitle;
//   final VoidCallback onComplete;
//   final String introVideoUrl;
//   final List<VideoInfo> relatedVideos;
//   const ExerciseList({
//     super.key,
//     required this.exercises,
//     required this.lessonTitle,
//     required this.onComplete,
//     required this.introVideoUrl,
//     required this.relatedVideos,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: CustomText(
//           text: lessonTitle,
//           fontSize: 18,
//           fontFamily: 'Roboto',
//           fontWeight: FontWeight.w600,
//           color: Colors.white,
//         ),
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: AppColors.background,
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: constraints.maxHeight,
//               ),
//               child: LessonTabsWidget(
//                 introVideoTitle: "Video Giới thiệu",
//                 categories: mockLessonData
//                     .map((key, value) => MapEntry(key, parseLevels(value))),
//                 introVideoUrl: introVideoUrl,
//                 relatedVideos: relatedVideos,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
