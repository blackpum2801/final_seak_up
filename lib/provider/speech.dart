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

class SpeechProvider extends ChangeNotifier {
  static const String apiMainPathSts = "http://10.0.2.2:3000";
  static const String stScoreApiKey =
      "rll5QsTiv83nti99BW6uCmvs9BDVxSB39SVFceYb";
  static const int badScoreThreshold = 30;
  static const int mediumScoreThreshold = 70;

  // TTS & Speech Recognition
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  late AudioRecorder _audioRecorder;
  late AudioPlayer _audioPlayer;

  // State variables
  bool _isRecording = false;
  bool _isUiBlocked = false;
  String? _error;
  String? _recordedAudioPath;
  bool _currentSoundRecorded = false;
  String _aiLanguage = "en";

  // Pronunciation analysis results
  double _phonemeScore = 0;
  String? _pronunciationAccuracy;
  String? _recordedIpaScript;
  List<String> _realTranscriptsIpa = [];
  List<String> _matchedTranscriptsIpa = [];
  List<String> _wordCategories = [];
  List<String> _lettersOfWordAreCorrect = [];
  List<String> _startTime = [];
  List<String> _endTime = [];

  // Getters
  bool get isRecording => _isRecording;
  bool get isUiBlocked => _isUiBlocked;
  String? get error => _error;
  bool get currentSoundRecorded => _currentSoundRecorded;
  double get phonemeScore => _phonemeScore;
  String? get pronunciationAccuracy => _pronunciationAccuracy;
  String? get recordedIpaScript => _recordedIpaScript;
  List<String> get realTranscriptsIpa => _realTranscriptsIpa;
  List<String> get matchedTranscriptsIpa => _matchedTranscriptsIpa;
  List<String> get wordCategories => _wordCategories;
  List<String> get lettersOfWordAreCorrect => _lettersOfWordAreCorrect;
  List<String> get startTime => _startTime;
  List<String> get endTime => _endTime;

  SpeechProvider() {
    _initializeComponents();
    _requestMicrophonePermission();
  }

  Future<void> _requestMicrophonePermission() async {
    if (await Permission.microphone.request().isGranted) {
      debugPrint("Quyền micro được cấp.");
    } else {
      _showError("Quyền micro bị từ chối. Vui lòng cấp quyền trong cài đặt.");
    }
  }

  void _initializeComponents() {
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();

    _initializeTts();
    _initializeSpeech();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize(
      onError: (error) {
        debugPrint('Lỗi nhận diện giọng nói: $error');
      },
      onStatus: (status) =>
          debugPrint('Trạng thái nhận diện giọng nói: $status'),
    );
  }

  Future<void> playAudio(String textToSpeak) async {
    if (textToSpeak.isEmpty) return;

    _blockUI();
    try {
      await _flutterTts.speak(textToSpeak);
      _flutterTts.setCompletionHandler(_unblockUI);
      _flutterTts.setErrorHandler((msg) {
        debugPrint('Lỗi TTS: $msg');
        _unblockUI();
      });
    } catch (e) {
      debugPrint('Lỗi TTS: $e');
      _unblockUI();
    }
  }

  Future<void> startRecording(String textToPronounce) async {
    if (_isUiBlocked || !_speech.isAvailable) return;

    _isRecording = true;
    _phonemeScore = 0;
    notifyListeners();

    _blockUI();

    try {
      final directory = await getTemporaryDirectory();
      _recordedAudioPath = '${directory.path}/recorded_audio.wav';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 48000,
          numChannels: 1,
        ),
        path: _recordedAudioPath!,
      );

      _speech.listen(
        onResult: (result) {},
        localeId: '$_aiLanguage-US',
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 1),
      );

      Timer(const Duration(seconds: 5), () async {
        await stopRecording(textToPronounce);
      });
    } catch (e) {
      debugPrint('Lỗi ghi âm: $e');
      _showError('Không thể bắt đầu ghi âm: ${e.toString()}');
      _isRecording = false;
      _unblockUI();
      notifyListeners();
    }
  }

  Future<void> stopRecording(String textToPronounce) async {
    if (!_isRecording) return;

    _isRecording = false;
    notifyListeners();

    try {
      await _audioRecorder.stop();
      await _speech.stop();

      if (_recordedAudioPath != null) {
        await _processRecordedAudio(textToPronounce);
      }
    } catch (e) {
      debugPrint('Lỗi dừng ghi âm: $e');
      _showError('Không thể dừng ghi âm');
      _unblockUI();
    }
  }

  Future<void> playRecordedAudio({double? start, double? end}) async {
    if (_recordedAudioPath == null) return;

    _blockUI();
    try {
      if (start != null && end != null) {
        await _audioPlayer.play(DeviceFileSource(_recordedAudioPath!),
            position: Duration(milliseconds: (start * 1000).toInt()));
        Timer(Duration(milliseconds: ((end - start) * 1000).toInt()), () {
          _audioPlayer.stop();
          _unblockUI();
        });
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedAudioPath!));
        _audioPlayer.onPlayerComplete.listen((_) => _unblockUI());
      }
    } catch (e) {
      debugPrint('Lỗi phát lại âm thanh: $e');
      _unblockUI();
    }
  }

  Future<void> _processRecordedAudio(String textToPronounce) async {
    if (_recordedAudioPath == null) {
      _showError('Không có âm thanh được ghi lại');
      return;
    }

    _isUiBlocked = true;
    _error = 'Đang xử lý âm thanh...';
    notifyListeners();

    try {
      final File audioFile = File(_recordedAudioPath!);
      if (!await audioFile.exists()) {
        _showError('Tệp âm thanh không tồn tại');
        return;
      }

      final Uint8List audioBytes = await audioFile.readAsBytes();
      final String audioBase64 = base64Encode(audioBytes);

      final String cleanText = textToPronounce
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
          'language': _aiLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('===> Server Response: $data');
        final result = PronunciationAnalysisResult.fromJson(data);
        _handleAnalysisResult(result);
      } else {
        _showError('Không thể phân tích phát âm: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi xử lý âm thanh: $e');
      _showError('Không thể xử lý âm thanh: ${e.toString()}');
    } finally {
      _isUiBlocked = false;
      _error = null;
      notifyListeners();
    }
  }

  double _calculateLetterAccuracy() {
    if (_lettersOfWordAreCorrect.isEmpty) return 0;
    final letters = _lettersOfWordAreCorrect.join('').replaceAll(' ', '');
    if (letters.isEmpty) return 0;
    final correct = letters.split('').where((c) => c == '1').length;
    return (correct / letters.length) * 100;
  }

  void _handleAnalysisResult(PronunciationAnalysisResult result) {
    _recordedIpaScript = '/ ${result.ipaTranscript} /';
    _realTranscriptsIpa = result.realTranscriptsIpa.split(' ');
    _matchedTranscriptsIpa = result.matchedTranscriptsIpa.split(' ');
    _lettersOfWordAreCorrect = result.isLetterCorrectAllWords.trim().split(' ');
    _wordCategories = result.pairAccuracyCategory.split(' ');
    _startTime = result.startTime.split(' ');
    _endTime = result.endTime.split(' ');
    _currentSoundRecorded = true;

    debugPrint(
        '===> lettersOfWordAreCorrect (split): $_lettersOfWordAreCorrect');

    _phonemeScore = _calculateLetterAccuracy();
    _pronunciationAccuracy = '${_phonemeScore.round()}%';

    _playFeedbackAudio(_phonemeScore);
    _unblockUI();
    notifyListeners();
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
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Lỗi âm thanh phản hồi: $e');
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> playCurrentWordPart(String textToSpeak, int wordIdx) async {
    if (textToSpeak.isEmpty) return;

    final wordPart = textToSpeak.split(' ')[wordIdx];
    if (wordPart.isNotEmpty) {
      _blockUI();
      try {
        await _flutterTts.speak(wordPart);
        _flutterTts.setCompletionHandler(_unblockUI);
      } catch (e) {
        debugPrint('Lỗi TTS từ: $e');
        _unblockUI();
      }
    }
  }

  void playRecordedWordPart(int wordIdx) {
    if (_startTime.length > wordIdx && _endTime.length > wordIdx) {
      final wordStartTime = double.tryParse(_startTime[wordIdx]) ?? 0.0;
      final wordEndTime = double.tryParse(_endTime[wordIdx]) ?? 0.0;
      playRecordedAudio(start: wordStartTime, end: wordEndTime);
    }
  }

  void playNativeAndRecordedWordPart(String textToSpeak, int wordIdx) {
    if (!_currentSoundRecorded) {
      playCurrentWordPart(textToSpeak, wordIdx);
    } else {
      playRecordedWordPart(wordIdx);
    }
  }

  void resetAnalysisResults() {
    _phonemeScore = 0;
    _pronunciationAccuracy = null;
    _recordedIpaScript = null;
    _realTranscriptsIpa = [];
    _matchedTranscriptsIpa = [];
    _wordCategories = [];
    _lettersOfWordAreCorrect = [];
    _startTime = [];
    _endTime = [];
    _currentSoundRecorded = false;
    _speech.cancel();
    notifyListeners();
  }

  void _blockUI() {
    _isUiBlocked = true;
    notifyListeners();
  }

  void _unblockUI() {
    _isUiBlocked = false;
    notifyListeners();
  }

  void _showError(String message) {
    _error = message;
    _isUiBlocked = true;
    notifyListeners();

    Timer(const Duration(seconds: 2), () {
      _error = null;
      _isUiBlocked = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Model nhận kết quả chấm điểm từ server
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
