// File: lib/mock/mock_learn.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:speak_up/features/learn/learn_lesson/widgets/lesson_item.dart';
import 'package:speak_up/features/learn/learn_lesson/screens/lesson_flow_screen.dart';
import 'package:speak_up/features/learn/learn_lesson/widgets/video_lesson.dart';

/// -------------------- MOCK LESSON TABS DATA --------------------
final Map<String, List<Map<String, dynamic>>> mockLessonData = {
  "Business": [
    {
      'levelName': "Level 1 - Introduction",
      'current': 1,
      'total': 2,
      'lessons': [
        {
          'title': "Lesson 1 - Common Idioms",
          'difficulty': "EASY",
          'isLocked': false,
          'stars': 0,
          'totalStars': 3,
          'icon': Icons.mic,
        },
        {
          'title': "Lesson 2 - New Job",
          'difficulty': "EASY",
          'isLocked': false,
          'stars': 2,
          'totalStars': 3,
          'icon': Icons.mic,
        },
      ],
    },
    {
      'levelName': "Level 2 - Office Conversations",
      'current': 0,
      'total': 10,
      'lessons': [
        {
          'title': "Lesson 3 - Starting a call",
          'difficulty': "EASY",
          'isLocked': true,
          'stars': 0,
          'totalStars': 3,
          'icon': Icons.chat,
        },
        {
          'title': "Lesson 4 - Taking a break",
          'difficulty': "EASY",
          'isLocked': true,
          'stars': 0,
          'totalStars': 3,
          'icon': Icons.chat,
        },
      ],
    },
  ],
  "Family": [
    {
      'levelName': "Level 1 - Basic Phrases",
      'current': 0,
      'total': 3,
      'lessons': [
        {
          'title': "Lesson 1 - Hello",
          'difficulty': "EASY",
          'isLocked': false,
          'stars': 1,
          'totalStars': 3,
          'icon': Icons.mic,
        },
        {
          'title': "Lesson 2 - Introducing",
          'difficulty': "EASY",
          'isLocked': false,
          'stars': 0,
          'totalStars': 3,
          'icon': Icons.chat,
        },
      ],
    },
  ],
};

/// -------------------- MOCK LEARN LESSON DATA --------------------
final List<Map<String, dynamic>> mockLearnLessonList = [
  {
    'title': "Skill 1 - Ending sounds",
    'progress': "0 / 8",
    'imagePath': "assets/images/hanhtinh1.svg",
    'lessonTitle': "Skill 2 - /p/,/t/,/k/",
    'videoUrl': "https://www.youtube.com/watch?v=IG95Nc_KV5g",
    'exercises': ["Bài tập A", "Bài tập B", "Bài tập C"],
    'relatedVideos': [
      {
        'title': "Ending Voiced vs Unvoiced Consonants",
        'videoUrl': "https://www.youtube.com/watch?v=IG95Nc_KV5g",
      },
      {
        'title': "Vowels IPA",
        'videoUrl': "https://www.youtube.com/watch?v=Aecgq7-9GmI&t=16s",
      },
      {
        'title': "How To Pronounce BRONCHITIS + IPA",
        'videoUrl': "https://www.youtube.com/watch?v=Ep9AY6mYVyA",
      },
    ],
  },
];

String getYouTubeThumbnail(String url) {
  final videoId = YoutubePlayer.convertUrlToId(url);
  return videoId != null
      ? "https://img.youtube.com/vi/$videoId/hqdefault.jpg"
      : "https://via.placeholder.com/150";
}

// List<Lesson> buildLessonsFromMock() {
//   return mockLearnLessonList.map((data) {
//     return Lesson(
//       title: data['title'],
//       progress: data['progress'],
//       imagePath: data['imagePath'],
//       destination: LessonFlowScreen(
//         lessonTitle: data['lessonTitle'],
//         videoUrl: data['videoUrl'],
//         exercises: List<String>.from(data['exercises']),
//         relatedVideos: (data['relatedVideos'] as List)
//             .map((v) => VideoInfo(
//                   title: v['title'],
//                   videoUrl: v['videoUrl'],
//                   thumbnailUrl: getYouTubeThumbnail(v['videoUrl']),
//                 ))
//             .toList(),
//       ),
//     );
//   }).toList();
// }

final Map<String, Map<String, String>> lessonSpeakingData = {
  "Lesson 1 - Common Idioms": {
    "phrase": "on the same page",
    "ipa": "/ɒn ðə seɪm peɪdʒ/",
    "meaning": "đồng ý với ai đó về việc gì",
    "definition": "To agree with someone",
    "audioUrl":
        "https://api.dictionaryapi.dev/media/pronunciations/en/hello-au.mp3",
  },
  "Lesson 2 - New Job": {
    "phrase": "get the ball rolling",
    "ipa": "/ɡet ðə bɔːl ˈrəʊ.lɪŋ/",
    "meaning": "bắt đầu công việc",
    "definition": "To start an activity",
    "audioUrl":
        "https://api.dictionaryapi.dev/media/pronunciations/en/job-au.mp3",
  },
  "Lesson 3 - Starting a call": {
    "phrase": "Can you hear me?",
    "ipa": "/kæn juː hɪə(r) miː/",
    "meaning": "Bạn có nghe thấy tôi không?",
    "definition": "Common phrase in calls",
    "audioUrl":
        "https://api.dictionaryapi.dev/media/pronunciations/en/call-au.mp3",
  },
  // thêm tiếp cho các lesson khác...
};
