// chat_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatProvider extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _player = AudioPlayer();
  final List<Map<String, dynamic>> _messages = [];

  bool _isListening = false;
  String _topic = "";
  String _language = "en";
  bool _initialized = false;

  bool get isListening => _isListening;
  List<Map<String, dynamic>> get messages => _messages;
  String get topic => _topic;
  String get language => _language;

  void setTopic(String value) {
    if (_topic != value) {
      _topic = value;
      _messages.clear();
      _initialized = false;
      notifyListeners();
    }
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  Future<void> initChat() async {
    if (_initialized) return;
    _initialized = true;
    await sendToBackend("...", _topic, _language);
  }

  Future<void> startListening(Function(String) onFinalText) async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (error) {
        _isListening = false;
        notifyListeners();
      },
    );

    if (available) {
      _isListening = true;
      notifyListeners();

      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            final userText = result.recognizedWords.trim();
            if (userText.isNotEmpty) {
              _messages.add({"from": "user", "text": userText});
              notifyListeners();
              onFinalText(userText);
            }
            await _speech.stop();
            _isListening = false;
            notifyListeners();
          }
        },
      );

      Future.delayed(const Duration(seconds: 5), () {
        if (_isListening) stopListening();
      });
    } else {
      _isListening = false;
      notifyListeners();
    }
  }

  Future<void> sendToBackend(
      String userText, String topic, String language) async {
    final dio = Dio();
    const baseUrl = 'http://10.0.2.2:3000';
    debugPrint(
        "🚀 Sending to server: '$userText' | topic: '$topic' | lang: '$language'");

    try {
      final response = await dio.post(
        '$baseUrl/text-and-respond/',
        data: {"user_text": userText, "topic": topic, "language": language},
      );

      final aiText = response.data['ai_response'];
      final rawAudioUrl = response.data['audio_url'];
      final audioUrl =
          rawAudioUrl.startsWith("http") ? rawAudioUrl : "$baseUrl$rawAudioUrl";

      _messages.add({"from": "ai", "text": aiText, "audio": audioUrl});
      notifyListeners();

      debugPrint("📩 Server response: $aiText");
      await _player.setUrl(audioUrl);
      await _player.play();
    } catch (e) {
      if (kDebugMode) debugPrint("❌ API error: $e");
    }
  }

  void repeatLastAIMessage() async {
    final last = _messages.lastWhere(
      (m) => m['from'] == 'ai' && m['audio'] != null,
      orElse: () => {},
    );

    if (last.isNotEmpty && last['audio'] != null) {
      try {
        await _player.setUrl(last['audio']);
        await _player.play();
      } catch (e) {
        if (kDebugMode) debugPrint("❌ Repeat audio error: $e");
      }
    }
  }

  Future<String> translateLastAIMessage() async {
    final last = _messages.lastWhere(
      (m) => m['from'] == 'ai',
      orElse: () => {},
    );

    if (last.isNotEmpty) {
      try {
        final dio = Dio();
        final response = await dio.post(
          'https://translate.googleapis.com/translate_a/single',
          queryParameters: {
            'client': 'gtx',
            'sl': 'en',
            'tl': 'vi',
            'dt': 't',
            'q': last['text'],
          },
        );

        final translations = response.data[0] as List;
        final translated =
            translations.map((item) => item[0].toString()).join(' ');
        return translated;
      } catch (e) {
        if (kDebugMode) debugPrint("❌ Translation error: $e");
      }
    }
    return "";
  }

  void stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _topic = "";
    _initialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _speech.stop();
    _player.dispose();
    super.dispose();
  }
}
