import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speak_up/provider/speech.dart';
import 'package:speak_up/provider/vocabulary.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/models/vocabulary.dart';

class VocabularyListScreen extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const VocabularyListScreen({
    Key? key,
    required this.lessonId,
    required this.lessonTitle,
  }) : super(key: key);

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  int currentIndex = 0;
  String? isCorrect;
  bool isChecked = false;
  bool isCompleted = false;
  int correctCount = 0;
  int totalCount = 0;
  bool showExtraInfo = false;
  String currentTextToPronounce = "";
  String currentDisplayWord = "";
  String currentIpa = "";
  String currentMeaning = "";
  String currentExampleSentence = "";
  bool isPronouncingExampleSentence = false;

  @override
  void initState() {
    super.initState();
    // Gọi fetchVocabulary khi màn hình khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VocabularyProvider>();
      provider.fetchVocabulary(widget.lessonId);
    });
  }

  void _initScreenData(List<Vocabulary> vocabulary) {
    if (vocabulary.isEmpty) return;
    final currentItem = vocabulary[currentIndex];
    setState(() {
      currentDisplayWord = currentItem.word;
      currentIpa = currentItem.phonetic ?? '';
      currentMeaning = currentItem.meaning;
      currentExampleSentence = currentItem.exampleSentence ?? '';
      currentTextToPronounce = isPronouncingExampleSentence
          ? (currentItem.exampleSentence ?? currentItem.word)
          : currentItem.word;

      isCorrect = null;
      isChecked = false;
    });

    // Reset speech provider
    final speechProvider = context.read<SpeechProvider>();
    speechProvider.resetAnalysisResults();
  }

  Future<void> _playAudio() async {
    final speechProvider = context.read<SpeechProvider>();
    final textToSpeak = isPronouncingExampleSentence
        ? currentExampleSentence
        : currentDisplayWord;

    if (textToSpeak.isNotEmpty) {
      await speechProvider.playAudio(textToSpeak);
    }
  }

  Future<void> _startRecording() async {
    final speechProvider = context.read<SpeechProvider>();

    if (speechProvider.isUiBlocked || currentTextToPronounce.isEmpty) return;

    setState(() {
      isChecked = false;
      isCorrect = null;
    });

    await speechProvider.startRecording(currentTextToPronounce);
  }

  void _handleAnalysisComplete() {
    final speechProvider = context.read<SpeechProvider>();
    final score = speechProvider.phonemeScore;

    setState(() {
      isCorrect = score > 60
          ? "correct"
          : score >= 40
              ? "nearly"
              : "incorrect";
      isChecked = true;
      totalCount++;
      if (score > 60) {
        correctCount++;
      }
    });
  }

  void _handleNext(List<Vocabulary> vocabulary) {
    if (currentIndex < vocabulary.length - 1) {
      setState(() {
        currentIndex++;
      });
      _initScreenData(vocabulary);
    } else {
      setState(() {
        isCompleted = true;
      });
    }
  }

  void _handleRetry(List<Vocabulary> vocabulary) {
    setState(() {
      isCorrect = null;
      isChecked = false;
    });
    final speechProvider = context.read<SpeechProvider>();
    speechProvider.resetAnalysisResults();
    _initScreenData(vocabulary);
  }

  void _handleRetryLesson(List<Vocabulary> vocabulary) {
    setState(() {
      isCompleted = false;
      currentIndex = 0;
      isCorrect = null;
      isChecked = false;
      correctCount = 0;
      totalCount = 0;
    });
    _initScreenData(vocabulary);
  }

  void _playCurrentWordPart(int wordIdx) async {
    final speechProvider = context.read<SpeechProvider>();
    final textToSpeak = isPronouncingExampleSentence
        ? currentExampleSentence
        : currentDisplayWord;

    if (textToSpeak.isNotEmpty) {
      await speechProvider.playCurrentWordPart(textToSpeak, wordIdx);
    }
  }

  void _playNativeAndRecordedWordPart(int wordIdx) {
    final speechProvider = context.read<SpeechProvider>();
    speechProvider.playNativeAndRecordedWordPart(
        currentTextToPronounce, wordIdx);
  }

  Widget _buildColoredText(
      List<Vocabulary> vocabulary, SpeechProvider speechProvider) {
    if (vocabulary.isEmpty || speechProvider.lettersOfWordAreCorrect.isEmpty) {
      return GestureDetector(
        onTap: () => _playCurrentWordPart(0),
        child: Text(
          currentDisplayWord,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );
    }

    final words = vocabulary[currentIndex].word.split(' ');
    List<Widget> wordWidgets = [];

    for (int w = 0; w < words.length; w++) {
      final word = words[w];
      final lettersCorrect = (w < speechProvider.lettersOfWordAreCorrect.length)
          ? speechProvider.lettersOfWordAreCorrect[w]
          : '';
      List<TextSpan> spans = [];

      for (int i = 0; i < word.length; i++) {
        final bool isCorrect =
            i < lettersCorrect.length && lettersCorrect[i] == '1';
        spans.add(
          TextSpan(
            text: word[i],
            style: TextStyle(
              color: isCorrect ? Colors.green : Colors.red,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      wordWidgets.add(
        GestureDetector(
          onTap: () => _playNativeAndRecordedWordPart(w),
          child: RichText(text: TextSpan(children: spans)),
        ),
      );

      if (w < words.length - 1) {
        wordWidgets.add(const SizedBox(width: 12));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: wordWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VocabularyProvider, SpeechProvider>(
      builder: (context, vocabProvider, speechProvider, _) {
        final vocabulary = vocabProvider.getVocab(widget.lessonId);
        final isLoading = vocabProvider.isLoading;

        // Listen for analysis completion
        if (speechProvider.currentSoundRecorded && !isChecked) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleAnalysisComplete();
          });
        }

        if (isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.lessonTitle),
              backgroundColor: Colors.blue,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (vocabulary.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.lessonTitle),
              backgroundColor: Colors.blue,
            ),
            body: const Center(
              child: Text(
                'Không có từ vựng nào',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }

        // Init data lần đầu khi có dữ liệu
        if (currentDisplayWord.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initScreenData(vocabulary);
          });
        }

        if (isCompleted) {
          final double score =
              totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.lessonTitle),
              backgroundColor: Colors.blue,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    score >= 60 ? Icons.check_circle : Icons.cancel,
                    size: 100,
                    color: score >= 60 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    score >= 60 ? 'Hoàn thành!' : 'Bài tập chưa hoàn thành',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: score >= 60 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    score >= 60
                        ? 'Bạn đã hoàn thành tất cả từ vựng với ${score.round()}% đúng.'
                        : 'Bạn chỉ đạt ${score.round()}% đúng. Điểm tối thiểu để hoàn thành là 60%.',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Quay về trang chủ',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (score < 60) ...[
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => _handleRetryLesson(vocabulary),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            'Làm lại bài tập',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(widget.lessonTitle),
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (speechProvider.error != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      speechProvider.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: speechProvider.isUiBlocked ||
                                currentTextToPronounce.isEmpty
                            ? null
                            : _playAudio,
                        icon: const Icon(Icons.volume_up, color: Colors.white),
                        label: const Text('Nghe',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Nghe và nói từ hiển thị.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildColoredText(vocabulary, speechProvider),
                      const SizedBox(height: 8),
                      Text(
                        currentIpa.isNotEmpty ? currentIpa : 'N/A',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isChecked) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton.icon(
                      onPressed: (speechProvider.isUiBlocked ||
                              currentTextToPronounce.isEmpty)
                          ? null
                          : _startRecording,
                      icon: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 28,
                      ),
                      label: Text(
                        speechProvider.isRecording ? 'Đang nghe...' : 'Nói',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: speechProvider.isRecording
                            ? Colors.red
                            : Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              speechProvider.phonemeScore > 60
                                  ? '😊'
                                  : speechProvider.phonemeScore >= 40
                                      ? '😐'
                                      : '😞',
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    speechProvider.phonemeScore > 60
                                        ? 'Xuất sắc!'
                                        : speechProvider.phonemeScore >= 40
                                            ? 'Tốt!'
                                            : 'Thử lại!',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Bạn phát âm giống người bản xứ ${speechProvider.phonemeScore.round()}%!',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: speechProvider.phonemeScore / 100,
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.green),
                                    strokeWidth: 6,
                                  ),
                                ),
                                Text(
                                  '${speechProvider.phonemeScore.round()}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => _handleRetry(vocabulary),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Làm lại',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () => _handleNext(vocabulary),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text(
                                'Tiếp tục',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showExtraInfo = !showExtraInfo;
                      });
                    },
                    child: Text(
                      showExtraInfo
                          ? 'Ẩn thông tin bổ sung'
                          : 'Thông tin bổ sung',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                if (showExtraInfo) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentMeaning,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentExampleSentence,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
