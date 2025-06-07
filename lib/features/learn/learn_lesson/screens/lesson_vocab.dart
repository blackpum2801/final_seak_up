import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/core/constants/assets.dart';
import 'package:speak_up/features/learn/learn_lesson/widgets/vocab_card.dart';
import 'package:speak_up/models/vocabulary.dart';
import 'package:speak_up/provider/speech.dart';
import 'package:speak_up/provider/vocabulary.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class VocabularyListScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const VocabularyListScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _isCorrect = false;
  String _feedback = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final vocabProvider =
        Provider.of<VocabularyProvider>(context, listen: false);
    await vocabProvider.fetchVocabulary(widget.lessonId);

    final vocabList = vocabProvider.getVocab(widget.lessonId);
    if (vocabList.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('totalWords_${widget.lessonId}', vocabList.length);
      final firstAudioUrl = vocabList[0].audioUrl;
      if (firstAudioUrl?.isNotEmpty ?? false) {
        await _playAudio(firstAudioUrl!);
      }
    }

    await _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('completedWords_${widget.lessonId}') ?? [];
    final current = list.isNotEmpty ? int.tryParse(list.last) ?? 0 : 0;

    if (mounted) {
      setState(() {
        _currentIndex = current;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_currentIndex);
        }
      });
    }
  }

  Future<void> _playAudio(String url, {double speed = 1.0}) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(speed);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi phát âm thanh: $e')),
        );
      }
    }
  }

  Future<void> _saveProgress(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'completedWords_${widget.lessonId}';
    final completed = prefs.getStringList(key)?.toSet() ?? {};
    if (completed.add(index.toString())) {
      await prefs.setStringList(key, completed.toList());
      await prefs.setInt('progress_${widget.lessonId}', completed.length);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Hoàn thành!'),
        content: const Text('Bạn đã học xong toàn bộ từ vựng trong bài.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _nextWord(List<Vocabulary> vocabList) {
    if (_isCorrect) _saveProgress(_currentIndex);

    if (_currentIndex < vocabList.length - 1) {
      setState(() {
        _currentIndex++;
        _isCorrect = false;
        _feedback = '';
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      final nextAudio = vocabList[_currentIndex].audioUrl;
      if (nextAudio?.isNotEmpty ?? false) _playAudio(nextAudio!);
    } else {
      if (_isCorrect) _saveProgress(_currentIndex);
      _showCompletionDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabProvider = Provider.of<VocabularyProvider>(context);
    final speechProvider = Provider.of<SpeechToTextProvider>(context);
    final vocabList = vocabProvider.getVocab(widget.lessonId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lessonTitle,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
      ),
      body: vocabProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vocabList.isEmpty
              ? const Center(child: Text('Không có từ vựng'))
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: vocabList.length,
                      onPageChanged: (index) {
                        if (_currentIndex != index) {
                          setState(() {
                            _currentIndex = index;
                            _isCorrect = false;
                            _feedback = '';
                          });
                          final audio = vocabList[index].audioUrl;
                          if (audio?.isNotEmpty ?? false) _playAudio(audio!);
                        }
                      },
                      itemBuilder: (_, index) => VocabularyCard(
                        vocab: vocabList[index],
                        isListening: speechProvider.isListening,
                        confidenceLevel: speechProvider.confidenceLevel,
                        accuracy: speechProvider.accuracy,
                        feedback: _feedback,
                        onPlayAudio: () {
                          final audioUrl = vocabList[index].audioUrl ?? '';
                          if (audioUrl.isNotEmpty) _playAudio(audioUrl);
                        },
                        onPlaySlowAudio: () {
                          final audioUrl = vocabList[index].audioUrl ?? '';
                          if (audioUrl.isNotEmpty)
                            _playAudio(audioUrl, speed: 0.6);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_isCorrect) const SizedBox(width: 16),
                            _isCorrect
                                ? ElevatedButton(
                                    onPressed: () => _nextWord(vocabList),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                    ),
                                    child: const Text('Tiếp theo',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white)),
                                  )
                                : FloatingActionButton(
                                    backgroundColor: speechProvider.isListening
                                        ? Colors.red
                                        : Colors.lightBlue,
                                    onPressed: () async {
                                      if (speechProvider.isListening) {
                                        await speechProvider
                                            .stopListeningManually();
                                        return;
                                      }
                                      final granted = await speechProvider
                                          .requestPermission();
                                      if (!granted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Không có quyền dùng micro')),
                                        );
                                        return;
                                      }
                                      final vocab = vocabList[_currentIndex];
                                      try {
                                        await speechProvider.startListening(
                                          expectedWord: vocab.word,
                                          onResult: (success, spoken,
                                              confidence, feedback) async {
                                            await speechProvider
                                                .stopListeningManually();
                                            if (mounted) {
                                              setState(() {
                                                _isCorrect = success;
                                                _feedback = feedback;
                                                if (!success &&
                                                    spoken.isEmpty) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Không nhận diện được giọng nói.')),
                                                  );
                                                }
                                              });
                                            }
                                          },
                                          onStatus: (status) {
                                            speechProvider
                                                .updateListeningStatus(
                                                    status == 'listening');
                                          },
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Lỗi khi ghi âm: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      speechProvider.isListening
                                          ? Icons.mic
                                          : Icons.mic_none,
                                      size: 24,
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            if (!_isCorrect)
                              ElevatedButton(
                                onPressed: () => _nextWord(vocabList),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                ),
                                child: const Text(
                                  'Bỏ qua',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
