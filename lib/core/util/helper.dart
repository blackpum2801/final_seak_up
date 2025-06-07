import 'package:flutter/material.dart';

Icon getLessonTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'listening':
      return const Icon(Icons.headphones, color: Colors.blue);
    case 'speaking':
      return const Icon(Icons.record_voice_over, color: Colors.orange);
    case 'vocabulary':
      return const Icon(Icons.translate, color: Colors.green);
    case 'pronunciation':
      return const Icon(Icons.mic, color: Colors.purple);
    default:
      return const Icon(Icons.book, color: Colors.grey);
  }
}
