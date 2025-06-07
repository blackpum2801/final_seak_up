// import 'package:flutter/material.dart';
// import 'package:speak_up/features/learn/learn_lesson/screens/exercise_list.dart';
// import 'package:speak_up/features/learn/learn_lesson/widgets/video_lesson.dart';

// class LessonFlowScreen extends StatefulWidget {
//   final String lessonTitle;
//   final String videoUrl;
//   final List<String> exercises;
//   final List<VideoInfo> relatedVideos;
//   const LessonFlowScreen({
//     super.key,
//     required this.lessonTitle,
//     required this.videoUrl,
//     required this.exercises,
//     required this.relatedVideos,
//   });

//   @override
//   State<LessonFlowScreen> createState() => _LessonFlowScreenState();
// }

// class _LessonFlowScreenState extends State<LessonFlowScreen> {
//   int _currentStep = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _currentStep,
//         children: [
//           VideoLesson(
//             videoUrl: widget.videoUrl,
//             onNext: () => setState(() => _currentStep = 1),
//             relatedVideos: widget.relatedVideos,
//           ),
//           // ExerciseList(
//           //   exercises: widget.exercises,
//           //   lessonTitle: widget.lessonTitle,
//           //   onComplete: () {},
//           //   introVideoUrl: widget.videoUrl,
//           //   relatedVideos: widget.relatedVideos,
//           // ),
//         ],
//       ),
//     );
//   }
// }
