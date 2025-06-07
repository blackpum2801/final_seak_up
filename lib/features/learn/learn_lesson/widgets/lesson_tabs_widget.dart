// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:speak_up/core/constants/asset_color.dart';
// import 'package:speak_up/features/learn/learn_lesson/widgets/video_lesson.dart';
// import 'package:speak_up/widgets/custom_text.dart';
// import 'package:speak_up/provider/lesson.dart'; // ✅ Dùng LessonProvider

// class LessonUnit {
//   final String title;
//   final String difficulty;
//   final bool isLocked;
//   final int stars;
//   final int totalStars;
//   final IconData icon;

//   LessonUnit({
//     required this.title,
//     this.difficulty = "EASY",
//     this.isLocked = false,
//     this.stars = 0,
//     this.totalStars = 3,
//     required this.icon,
//   });
// }

// class LessonLevel {
//   final String name;
//   final int current;
//   final int total;
//   final List<LessonUnit> lessons;

//   LessonLevel({
//     required this.name,
//     required this.current,
//     required this.total,
//     required this.lessons,
//   });
// }

// class LessonTabsWidget extends StatefulWidget {
//   final Map<String, List<LessonLevel>> categories;
//   final String? introVideoTitle;
//   final String introVideoUrl;
//   final List<VideoInfo> relatedVideos;

//   const LessonTabsWidget({
//     super.key,
//     required this.categories,
//     this.introVideoTitle,
//     required this.introVideoUrl,
//     required this.relatedVideos,
//   });

//   @override
//   State<LessonTabsWidget> createState() => _LessonTabsWidgetState();
// }

// class _LessonTabsWidgetState extends State<LessonTabsWidget> {
//   late String _selectedCategory;

//   Map<String, List<LessonLevel>> _categoryLessons = {};
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _selectedCategory = widget.categories.keys.first;

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _loadLessonsForCategory(_selectedCategory);
//     });
//   }

//   Future<void> _loadLessonsForCategory(String parentId) async {
//     setState(() => _isLoading = true);

//     final lessonProvider = Provider.of<LessonProvider>(context, listen: false);
//     final rawLessons = await lessonProvider.fetchLessonsByParent(parentId);

//     setState(() {
//       _categoryLessons[parentId] = [
//         LessonLevel(
//           name: 'Bài học',
//           current: 0,
//           total: rawLessons.length,
//           lessons: rawLessons
//               .map((l) => LessonUnit(
//                     title: l.title,
//                     difficulty: "EASY",
//                     icon: Icons.book,
//                     isLocked: false,
//                     stars: 0,
//                   ))
//               .toList(),
//         )
//       ];
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final levels = _categoryLessons[_selectedCategory] ?? [];

//     return Container(
//       color: AppColors.background,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 32),
//             _buildCategoryChips(),
//             const SizedBox(height: 24),
//             if (widget.introVideoTitle != null) _buildIntroVideoTile(),
//             const SizedBox(height: 24),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else
//               ...levels.map(_buildLevel),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryChips() {
//     return Center(
//       child: Wrap(
//         spacing: 20,
//         runSpacing: 20,
//         children: widget.categories.keys.map((cat) {
//           final selected = _selectedCategory == cat;
//           return ChoiceChip(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//             label: CustomText(
//               text: cat,
//               color: selected ? Colors.black : Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//             selected: selected,
//             selectedColor: Colors.white,
//             backgroundColor: AppColors.secondBackground,
//             showCheckmark: false,
//             side: BorderSide.none,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             onSelected: (_) async {
//               setState(() => _selectedCategory = cat);
//               await _loadLessonsForCategory(cat);
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildIntroVideoTile() {
//     return Card(
//       color: AppColors.secondBackground,
//       child: ListTile(
//         leading:
//             const Icon(Icons.play_circle_sharp, color: Colors.blue, size: 30),
//         title: CustomText(
//           text: widget.introVideoTitle!,
//           fontSize: 16,
//           color: Colors.white,
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => VideoLesson(
//                 videoUrl: widget.introVideoUrl,
//                 onNext: () {},
//                 relatedVideos: widget.relatedVideos,
//                 showNextButton: false,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLevel(LessonLevel level) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(left: 8),
//             child: Text(
//               "${level.name} ${level.current}/${level.total}",
//               style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//           const SizedBox(height: 10),
//           ...level.lessons.map(_buildLessonTile),
//         ],
//       ),
//     );
//   }

//   Widget _buildLessonTile(LessonUnit unit) {
//     return Card(
//       color: AppColors.secondBackground,
//       child: ListTile(
//         leading: Icon(unit.icon, color: Colors.white),
//         title: Text(unit.title, style: const TextStyle(color: Colors.white)),
//         subtitle:
//             Text(unit.difficulty, style: const TextStyle(color: Colors.grey)),
//         trailing: unit.isLocked
//             ? const Icon(Icons.lock, color: Colors.white)
//             : Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(
//                   unit.totalStars,
//                   (i) => Icon(
//                     i < unit.stars ? Icons.star : Icons.star_border,
//                     color: i < unit.stars ? Colors.amber : Colors.grey,
//                     size: 20,
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
