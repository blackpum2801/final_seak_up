import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bài tập phát âm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TopicExerciseScreen(),
    );
  }
}

// Models
class VocabularyItem {
  final String id;
  final String lessonId;
  final String word;
  final String phonetic;
  final String meaning;
  final String exampleSentence;
  final String createdAt;
  final String updatedAt;

  VocabularyItem({
    required this.id,
    required this.lessonId,
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.exampleSentence,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? 'demo',
      word: json['word'] ?? '',
      phonetic: json['ipa'] ?? json['phonetic'] ?? '',
      meaning: json['meaning'] ?? json['word'] ?? '',
      exampleSentence: json['exampleSentence'] ?? '',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class PronunciationAnalysisResult {
  final double accuracy;
  final Map<String, double> ipaAccuracy;
  final String ipaTranscript;
  final String pronunciationAccuracy;
  final String realTranscriptsIpa;
  final String matchedTranscriptsIpa;
  final String isLetterCorrectAllWords;
  final String pairAccuracyCategory;
  final String startTime;
  final String endTime;
  final String? error;

  PronunciationAnalysisResult({
    required this.accuracy,
    required this.ipaAccuracy,
    required this.ipaTranscript,
    required this.pronunciationAccuracy,
    required this.realTranscriptsIpa,
    required this.matchedTranscriptsIpa,
    required this.isLetterCorrectAllWords,
    required this.pairAccuracyCategory,
    required this.startTime,
    required this.endTime,
    this.error,
  });

  factory PronunciationAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PronunciationAnalysisResult(
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      ipaAccuracy: Map<String, double>.from(json['ipa_accuracy'] ?? {}),
      ipaTranscript: json['ipa_transcript'] ?? '',
      pronunciationAccuracy: json['pronunciation_accuracy'] ?? '0',
      realTranscriptsIpa: json['real_transcripts_ipa'] ?? '',
      matchedTranscriptsIpa: json['matched_transcripts_ipa'] ?? '',
      isLetterCorrectAllWords: json['is_letter_correct_all_words'] ?? '',
      pairAccuracyCategory: json['pair_accuracy_category'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      error: json['error'],
    );
  }
}

class TopicExerciseScreen extends StatefulWidget {
  const TopicExerciseScreen({Key? key}) : super(key: key);

  @override
  State<TopicExerciseScreen> createState() => _TopicExerciseScreenState();
}

class _TopicExerciseScreenState extends State<TopicExerciseScreen> {
  static const String apiMainPathSts = "http://192.168.1.6:3000";
  static const String stScoreApiKey =
      "rll5QsTiv83nti99BW6uCmvs9BDVxSB39SVFceYb";
  static const int badScoreThreshold = 30;
  static const int mediumScoreThreshold = 70;

  List<VocabularyItem> vocabulary = [];
  int currentIndex = 0;
  String? isCorrect;
  bool isChecked = false;
  bool isCompleted = false;
  int correctCount = 0;
  int totalCount = 0;
  double phonemeScore = 0;
  bool showExtraInfo = false;
  bool isRecording = false;
  String currentTextToPronounce = "";
  String currentDisplayWord = "";
  String currentIpa = "";
  String currentMeaning = "";
  String currentExampleSentence = "";
  String? pronunciationAccuracy;
  String? recordedIpaScript;
  List<String> realTranscriptsIpa = [];
  List<String> matchedTranscriptsIpa = [];
  List<String> wordCategories = [];
  List<String> lettersOfWordAreCorrect = [];
  List<String> startTime = [];
  List<String> endTime = [];
  bool currentSoundRecorded = false;
  String aiLanguage = "en";
  bool isPronouncingExampleSentence = false;
  bool isUiBlocked = false;
  String? error;
  bool loading = true;

  late FlutterTts flutterTts;
  late stt.SpeechToText speech;
  late AudioRecorder audioRecorder;
  late AudioPlayer audioPlayer;
  String? recordedAudioPath;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _fetchVocabulary();
    _requestMicrophonePermission();
  }

  Future<void> _requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      print("Quyền micro được cấp.");
    } else {
      _showError("Quyền micro bị từ chối. Vui lòng cấp quyền trong cài đặt.");
    }
  }

  void _initializeComponents() {
    flutterTts = FlutterTts();
    speech = stt.SpeechToText();
    audioRecorder = AudioRecorder();
    audioPlayer = AudioPlayer();

    _initializeTts();
    _initializeSpeech();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.7);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _initializeSpeech() async {
    bool available = await speech.initialize(
      onError: (error) {
        print('Lỗi nhận diện giọng nói: $error');
        // CHỈ LOG, không showError luôn
        // Nếu sau này không có onResult, mới báo lỗi
      },
      onStatus: (status) => print('Trạng thái nhận diện giọng nói: $status'),
    );
    if (!available) {
      setState(() {
        error = "Nhận diện giọng nói không khả dụng. Vui lòng kiểm tra micro.";
      });
    }
  }

  Future<void> _fetchVocabulary() async {
    setState(() {
      loading = true;
      error = null;
    });

    // Demo có cụm từ luôn
    setState(() {
      vocabulary = [
        VocabularyItem(
          id: '1',
          lessonId: 'demo',
          word: 'Hello',
          phonetic: '/həˈloʊ/',
          meaning: 'Xin chào',
          exampleSentence: 'Hello, how are you?',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        VocabularyItem(
          id: '2',
          lessonId: 'demo',
          word: 'Good morning',
          phonetic: '/ɡʊd ˈmɔːrnɪŋ/',
          meaning: 'Chào buổi sáng',
          exampleSentence: 'Good morning! How are you today?',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
        VocabularyItem(
          id: '3',
          lessonId: 'demo',
          word: 'Thank you very much',
          phonetic: '/ˌθæŋk juː ˈveri mʌtʃ/',
          meaning: 'Cảm ơn bạn rất nhiều',
          exampleSentence: 'Thank you very much for your help.',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      ];
      if (vocabulary.isNotEmpty) {
        _updateCurrentItemDisplay();
      } else {
        currentDisplayWord = "Không tìm thấy từ vựng.";
        currentTextToPronounce = "";
        currentIpa = "";
        currentMeaning = "";
        currentExampleSentence = "";
      }
      loading = false;
    });
  }

  void _updateCurrentItemDisplay() {
    if (vocabulary.isEmpty) return;

    final currentItem = vocabulary[currentIndex];
    setState(() {
      currentDisplayWord = currentItem.word;
      currentIpa = currentItem.phonetic;
      currentMeaning = currentItem.meaning;
      currentExampleSentence = currentItem.exampleSentence;
      currentTextToPronounce = isPronouncingExampleSentence
          ? currentItem.exampleSentence
          : currentItem.word;

      pronunciationAccuracy = null;
      recordedIpaScript = null;
      realTranscriptsIpa = [];
      matchedTranscriptsIpa = [];
      wordCategories = [];
      lettersOfWordAreCorrect = [];
      startTime = [];
      endTime = [];
      currentSoundRecorded = false;
      isCorrect = null;
      isChecked = false;
      phonemeScore = 0;
      isUiBlocked = false;
    });
    speech.cancel();
  }

  Future<void> _playAudio() async {
    _blockUI();
    final textToSpeak = isPronouncingExampleSentence
        ? currentExampleSentence
        : currentDisplayWord;

    if (textToSpeak.isEmpty) {
      _unblockUI();
      return;
    }

    try {
      await flutterTts.speak(textToSpeak);
      flutterTts.setCompletionHandler(_unblockUI);
      flutterTts.setErrorHandler((msg) {
        print('Lỗi TTS: $msg');
        _unblockUI();
      });
    } catch (e) {
      print('Lỗi TTS: $e');
      _unblockUI();
    }
  }

  Future<void> _startRecording() async {
    if (isUiBlocked || !speech.isAvailable) return;

    setState(() {
      isRecording = true;
      isChecked = false;
      isCorrect = null;
      phonemeScore = 0;
    });

    _blockUI();

    try {
      final directory = await getTemporaryDirectory();
      recordedAudioPath = '${directory.path}/recorded_audio.wav';

      await audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 48000,
          numChannels: 1,
        ),
        path: recordedAudioPath!,
      );

      speech.listen(
        onResult: (result) {},
        localeId: '${aiLanguage}-US',
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 1),
      );

      Timer(const Duration(seconds: 5), () async {
        await _stopRecording();
      });
    } catch (e) {
      print('Lỗi ghi âm: $e');
      _showError('Không thể bắt đầu ghi âm: ${e.toString()}');
      setState(() {
        isRecording = false;
      });
      _unblockUI();
    }
  }

  Future<void> _stopRecording() async {
    if (!isRecording) return;

    setState(() {
      isRecording = false;
    });

    try {
      await audioRecorder.stop();
      await speech.stop();

      if (recordedAudioPath != null) {
        await _processRecordedAudio();
      }
    } catch (e) {
      print('Lỗi dừng ghi âm: $e');
      _showError('Không thể dừng ghi âm');
      _unblockUI();
    }
  }

  Future<void> _playRecordedAudio({double? start, double? end}) async {
    if (recordedAudioPath == null) return;

    _blockUI();
    try {
      if (start != null && end != null) {
        await audioPlayer.play(DeviceFileSource(recordedAudioPath!),
            position: Duration(milliseconds: (start * 1000).toInt()));
        Timer(Duration(milliseconds: ((end - start) * 1000).toInt()), () {
          audioPlayer.stop();
          _unblockUI();
        });
      } else {
        await audioPlayer.play(DeviceFileSource(recordedAudioPath!));
        audioPlayer.onPlayerComplete.listen((_) => _unblockUI());
      }
    } catch (e) {
      print('Lỗi phát lại âm thanh: $e');
      _unblockUI();
    }
  }

  Future<void> _processRecordedAudio() async {
    if (recordedAudioPath == null) {
      _showError('Không có âm thanh được ghi lại');
      return;
    }
    setState(() {
      isUiBlocked = true;
      error = 'Đang xử lý âm thanh...';
    });

    try {
      final File audioFile = File(recordedAudioPath!);
      if (!await audioFile.exists()) {
        _showError('Tệp âm thanh không tồn tại');
        return;
      }

      final Uint8List audioBytes = await audioFile.readAsBytes();
      final String audioBase64 = base64Encode(audioBytes);

      final String cleanText = currentTextToPronounce
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      if (cleanText.isEmpty) {
        _showError('Không có văn bản để phân tích phát âm');
        return;
      }

      final response = await http.post(
        Uri.parse('$apiMainPathSts/GetAccuracyFromRecordedAudio'),
        headers: {
          'X-Api-Key': stScoreApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recorded_audio': 'data:audio/wav;base64,$audioBase64',
          'text': cleanText,
          'language': aiLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('===> Server Response: $data');
        print(
            '===> isLetterCorrectAllWords: ${data['is_letter_correct_all_words']}');
        final result = PronunciationAnalysisResult.fromJson(data);
        _handleAnalysisResult(result);
      } else {
        _showError('Không thể phân tích phát âm: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi xử lý âm thanh: $e');
      _showError('Không thể xử lý âm thanh: ${e.toString()}');
    } finally {
      setState(() {
        isUiBlocked = false;
        error = null;
      });
    }
  }

  double _calculateLetterAccuracy() {
    if (lettersOfWordAreCorrect.isEmpty) return 0;
    final letters = lettersOfWordAreCorrect.join('').replaceAll(' ', '');
    if (letters.isEmpty) return 0;
    final correct = letters.split('').where((c) => c == '1').length;
    return (correct / letters.length) * 100;
  }

  void _handleAnalysisResult(PronunciationAnalysisResult result) {
    setState(() {
      recordedIpaScript = '/ ${result.ipaTranscript} /';
      realTranscriptsIpa = result.realTranscriptsIpa.split(' ');
      matchedTranscriptsIpa = result.matchedTranscriptsIpa.split(' ');
      lettersOfWordAreCorrect =
          result.isLetterCorrectAllWords.trim().split(' ');
      wordCategories = result.pairAccuracyCategory.split(' ');
      startTime = result.startTime.split(' ');
      endTime = result.endTime.split(' ');
      currentSoundRecorded = true;

      print('===> lettersOfWordAreCorrect (split): $lettersOfWordAreCorrect');

      phonemeScore = _calculateLetterAccuracy();
      isCorrect = phonemeScore > 60
          ? "correct"
          : phonemeScore >= 40
              ? "nearly"
              : "incorrect";
      isChecked = true;
      totalCount++;
      if (phonemeScore > 60) {
        correctCount++;
      }
      pronunciationAccuracy = '${phonemeScore.round()}%';
    });

    _playFeedbackAudio(phonemeScore);
    _unblockUI();
  }

  void _playFeedbackAudio(double score) async {
    String assetPath;
    if (score < badScoreThreshold) {
      assetPath = 'assets/audio/ASR_bad.wav';
    } else if (score <= mediumScoreThreshold) {
      assetPath = 'assets/audio/ASR_okay.wav';
    } else {
      assetPath = 'assets/audio/ASR_good.wav';
    }

    try {
      await audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Lỗi âm thanh phản hồi: $e');
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void _playCurrentWordPart(int wordIdx) async {
    final textToSpeak = isPronouncingExampleSentence
        ? currentExampleSentence
        : currentDisplayWord;
    if (textToSpeak.isEmpty) return;

    final wordPart = textToSpeak.split(' ')[wordIdx];
    if (wordPart.isNotEmpty) {
      _blockUI();
      try {
        await flutterTts.speak(wordPart);
        flutterTts.setCompletionHandler(_unblockUI);
      } catch (e) {
        print('Lỗi TTS từ: $e');
        _unblockUI();
      }
    }
  }

  void _playRecordedWordPart(int wordIdx) {
    if (startTime.length > wordIdx && endTime.length > wordIdx) {
      final wordStartTime = double.tryParse(startTime[wordIdx]) ?? 0.0;
      final wordEndTime = double.tryParse(endTime[wordIdx]) ?? 0.0;
      _playRecordedAudio(start: wordStartTime, end: wordEndTime);
    }
  }

  void _playNativeAndRecordedWordPart(int wordIdx) {
    if (!currentSoundRecorded) {
      _playCurrentWordPart(wordIdx);
    } else {
      _playRecordedWordPart(wordIdx);
    }
  }

  void _handleNext() {
    if (currentIndex < vocabulary.length - 1) {
      setState(() {
        currentIndex++;
      });
      _updateCurrentItemDisplay();
    } else {
      setState(() {
        isCompleted = true;
      });
    }
  }

  void _handleRetry() {
    setState(() {
      isCorrect = null;
      isChecked = false;
      phonemeScore = 0;
      pronunciationAccuracy = null;
      recordedIpaScript = null;
      realTranscriptsIpa = [];
      matchedTranscriptsIpa = [];
      wordCategories = [];
      lettersOfWordAreCorrect = [];
      startTime = [];
      endTime = [];
      currentSoundRecorded = false;
    });
    speech.cancel();
  }

  void _handleRetryLesson() {
    setState(() {
      isCompleted = false;
      currentIndex = 0;
      isCorrect = null;
      isChecked = false;
      phonemeScore = 0;
      correctCount = 0;
      totalCount = 0;
    });
    _updateCurrentItemDisplay();
  }

  void _blockUI() {
    setState(() {
      isUiBlocked = true;
    });
  }

  void _unblockUI() {
    setState(() {
      isUiBlocked = false;
    });
  }

  void _showError(String message) {
    setState(() {
      error = message;
      isUiBlocked = true;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        error = null;
        isUiBlocked = false;
      });
    });
  }

  Widget _buildColoredText() {
    if (vocabulary.isEmpty || lettersOfWordAreCorrect.isEmpty) {
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
      final lettersCorrect = (w < lettersOfWordAreCorrect.length)
          ? lettersOfWordAreCorrect[w]
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
  void dispose() {
    flutterTts.stop();
    speech.stop();
    audioRecorder.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bài tập phát âm'),
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

    // if (!speech.isAvailable) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Bài tập phát âm'),
    //       backgroundColor: Colors.blue,
    //     ),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Icon(
    //             Icons.error_outline,
    //             size: 64,
    //             color: Colors.red[400],
    //           ),
    //           const SizedBox(height: 16),
    //           const Text(
    //             'Microphone không khả dụng. Vui lòng kiểm tra cài đặt.',
    //             style: TextStyle(fontSize: 18, color: Colors.red),
    //             textAlign: TextAlign.center,
    //           ),
    //           const SizedBox(height: 24),
    //           ElevatedButton(
    //             onPressed: () => Navigator.of(context).pop(),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.blue,
    //               padding:
    //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    //             ),
    //             child: const Text(
    //               'Quay về trang chủ',
    //               style: TextStyle(color: Colors.white),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    if (isCompleted) {
      final double score =
          totalCount > 0 ? (correctCount / totalCount) * 100 : 0;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kết quả'),
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
                      onPressed: _handleRetryLesson,
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
        title: const Text('Bài tập phát âm'),
        backgroundColor: Colors.blue,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Regular'),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Advanced',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error!,
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
                    onPressed: isUiBlocked || currentTextToPronounce.isEmpty
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
                  _buildColoredText(),
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
                  onPressed: (isUiBlocked || currentTextToPronounce.isEmpty)
                      ? null
                      : _startRecording,
                  icon: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 28,
                  ),
                  label: Text(
                    isRecording ? 'Đang nghe...' : 'Nói',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRecording ? Colors.red : Colors.blue,
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
                          phonemeScore > 60
                              ? '😊'
                              : phonemeScore >= 40
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
                                phonemeScore > 60
                                    ? 'Xuất sắc!'
                                    : phonemeScore >= 40
                                        ? 'Tốt!'
                                        : 'Thử lại!',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Bạn phát âm giống người bản xứ ${phonemeScore.round()}%!',
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
                                value: phonemeScore / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                                strokeWidth: 6,
                              ),
                            ),
                            Text(
                              '${phonemeScore.round()}%',
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
                          onPressed: _handleRetry,
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
                          onPressed: _handleNext,
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
                  showExtraInfo ? 'Ẩn thông tin bổ sung' : 'Thông tin bổ sung',
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
  }
}
