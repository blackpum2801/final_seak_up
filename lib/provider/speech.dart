import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class SpeechToTextProvider with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    sendTimeout: Duration(seconds: 10),
  ));

  bool _isListening = false;
  bool _isRecorderInitialized = false;
  bool _isDisposed = false;

  String _recognizedWord = '';
  String? _audioPath;
  double _confidenceLevel = 0.0;
  double? _accuracy;

  bool get isListening => _isListening;
  String get recognizedWord => _recognizedWord;
  double get confidenceLevel => _confidenceLevel;
  double? get accuracy => _accuracy;

  SpeechToTextProvider() {
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      if (!_isRecorderInitialized) {
        await _recorder.openRecorder();
        _isRecorderInitialized = true;
        debugPrint('🎙 Recorder đã khởi tạo');
      }
    } catch (e) {
      debugPrint('❌ Lỗi khởi tạo recorder: $e');
    }
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    debugPrint('🎙 Quyền micro: ${status.isGranted}');
    return status.isGranted;
  }

  Future<bool> _initSpeech() async {
    try {
      return await _speech.initialize(
        onStatus: (status) => debugPrint('🎙 STT Status: $status'),
        onError: (error) {
          debugPrint('❌ STT Error: $error');
          _setListening(false);
        },
      );
    } catch (e) {
      debugPrint('❌ Lỗi khởi tạo STT: $e');
      return false;
    }
  }

  void _setListening(bool status) {
    if (_isListening != status && !_isDisposed) {
      _isListening = status;
      notifyListeners();
    }
  }

  Future<void> startListening({
    required String expectedWord,
    required Function(
            bool matched, String word, double confidence, String feedback)
        onResult,
    double confidenceThreshold = 0.7,
    Function(String)? onStatus, // ✅ Thêm callback onStatus
  }) async {
    if (_isDisposed) return;
    if (!_isRecorderInitialized) await _initRecorder();
    final available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('🎙 STT Status: $status');
        onStatus?.call(status); // ✅ Gọi callback nếu có
      },
      onError: (error) {
        debugPrint('❌ STT Error: $error');
        _setListening(false);
      },
    );

    if (!available) {
      onResult(false, '', 0.0, '❌ Không thể khởi tạo SpeechToText');
      return;
    }

    _recognizedWord = '';
    _confidenceLevel = 0.0;
    _accuracy = null;
    _audioPath = null;

    _setListening(true);
    bool resultSent = false;

    _speech.listen(
      onResult: (result) {
        _recognizedWord = result.recognizedWords.trim();
        _confidenceLevel = result.confidence;
        debugPrint('🗣 Nhận: $_recognizedWord (confidence: $_confidenceLevel)');

        if (result.finalResult && !resultSent) {
          resultSent = true;
          _stopAndSend(expectedWord, onResult);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      localeId: 'en_US',
    );

    // ⏰ Timeout fallback nếu không nói gì
    Future.delayed(const Duration(seconds: 7), () async {
      if (_isListening && _recognizedWord.trim().isEmpty && !resultSent) {
        resultSent = true;
        debugPrint('⏰ Timeout: Không phát hiện âm thanh');
        await stopListeningManually();
        onResult(false, '', 0.0, '⏰ Không phát hiện âm thanh');
      }
    });
  }

  Future<void> stopListeningManually() async {
    try {
      await _speech.stop();
      if (_recorder.isRecording) await _recorder.stopRecorder();
    } catch (e) {
      debugPrint('❌ stopListeningManually error: $e');
    }
    _setListening(false);
  }

  Future<void> _stopAndSend(String expectedWord,
      Function(bool, String, double, String) onResult) async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('❌ stop error: $e');
    }
    _setListening(false);

    final matched = _recognizedWord.toLowerCase() == expectedWord.toLowerCase();
    final feedback = matched
        ? '✅ Bạn phát âm chính xác!'
        : '❌ Bạn phát âm chưa đúng. Hãy thử lại.';
    onResult(matched, _recognizedWord, _confidenceLevel, feedback);

    // 📼 Record pronunciation again for scoring
    try {
      final dir = await getTemporaryDirectory();
      _audioPath = '${dir.path}/recorded.wav';

      if (_recorder.isRecording) await _recorder.stopRecorder();
      await _recorder.startRecorder(
          toFile: _audioPath, codec: Codec.pcm16WAV);
      debugPrint('🎙 Ghi âm đánh giá: $_audioPath');
      await Future.delayed(const Duration(seconds: 2));
      await _recorder.stopRecorder();
    } catch (e) {
      debugPrint('❌ Không thể ghi âm: $e');
      return;
    }

    if (_audioPath == null || !File(_audioPath!).existsSync()) {
      debugPrint('⚠️ Không tìm thấy file ghi âm');
      return;
    }

    try {
      final formData = FormData.fromMap({
        'word': _recognizedWord.toLowerCase(),
        'recorded_audio':
            await MultipartFile.fromFile(_audioPath!, filename: 'recorded.wav'),
      });

      final res = await _dio.post(
        'http://10.0.2.2:3000/GetAccuracyFromRecordedAudio',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      _accuracy = res.data['accuracy']?.toDouble();
      debugPrint('🎯 Accuracy từ server: ${_accuracy?.toStringAsFixed(2)}');
      if (!_isDisposed) notifyListeners();
    } catch (e) {
      debugPrint('❌ Gửi âm thanh lỗi: $e');
    }
  }

  void updateListeningStatus(bool status) {
    _setListening(status);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _speech.stop();
    if (_isRecorderInitialized) {
      _recorder.stopRecorder();
      _recorder.closeRecorder();
    }
    _dio.close();
    super.dispose();
  }
}
