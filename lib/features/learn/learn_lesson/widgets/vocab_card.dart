import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/models/vocabulary.dart';

class VocabularyCard extends StatelessWidget {
  final Vocabulary vocab;
  final bool isListening;
  final double confidenceLevel;
  final double? accuracy;
  final String feedback;
  final VoidCallback onPlayAudio;
  final VoidCallback onPlaySlowAudio;

  const VocabularyCard({
    required this.vocab,
    required this.isListening,
    required this.confidenceLevel,
    this.accuracy,
    required this.feedback,
    required this.onPlayAudio,
    required this.onPlaySlowAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                const CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(AppAssets.imageAiVoice)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isListening ? 'Đang ghi âm...' : 'Nhấn 🎤 để nói từ này',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(vocab.word,
              style: GoogleFonts.notoSans(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (vocab.phonetic?.isNotEmpty ?? false)
            Text(vocab.phonetic!,
                style: GoogleFonts.notoSans(
                    fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: onPlayAudio),
              const SizedBox(width: 16),
              IconButton(
                  icon:
                      const Icon(Icons.slow_motion_video, color: Colors.orange),
                  onPressed: onPlaySlowAudio),
            ],
          ),
          const SizedBox(height: 16),
          if (!isListening && (accuracy != null || confidenceLevel > 0))
            Column(
              children: [
                if (confidenceLevel > 0)
                  Text(
                      'Confidence: ${(confidenceLevel * 100).toStringAsFixed(2)}%'),
                if (accuracy != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                        '🎯 Accuracy: ${(accuracy! * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(color: Colors.green)),
                  ),
                if (feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(feedback,
                        style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          Text('Nghĩa: ${vocab.meaning}',
              style: GoogleFonts.notoSans(fontSize: 16),
              textAlign: TextAlign.center),
          if (vocab.exampleSentence?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text('Ví dụ: ${vocab.exampleSentence}',
                style:
                    GoogleFonts.notoSans(fontSize: 14, color: Colors.grey[700]),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}
