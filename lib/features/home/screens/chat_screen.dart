// chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speak_up/core/constants/asset_color.dart';
import 'package:speak_up/provider/chat_provider.dart';
import 'package:flutter/widgets.dart';

class AiChatScreen extends StatefulWidget {
  final String? initialTopic;
  const AiChatScreen({super.key, this.initialTopic});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late ChatProvider _chat;
  bool _isSendingMic = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _chat = Provider.of<ChatProvider>(context, listen: false);
      if (widget.initialTopic != null) {
        _chat.setTopic(widget.initialTopic!);
      }
      _chat.initChat();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<bool> _showConfirmExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.secondBackground,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thoát cuộc trò chuyện?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn có chắc muốn thoát cuộc trò chuyện này?',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child:
                        const Text('Hủy', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Thoát',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final chat = Provider.of<ChatProvider>(context);

    final languages = {
      "English": "en",
      "Vietnamese": "vi",
      "Japanese": "ja",
      "Korean": "ko",
      "Chinese": "zh",
    };

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, [Object? result]) async {
        if (!didPop) {
          final shouldExit = await _showConfirmExitDialog();
          if (shouldExit) {
            chat.clearChat();
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final shouldExit = await _showConfirmExitDialog();
              if (shouldExit) {
                chat.clearChat();
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            chat.topic.isNotEmpty ? chat.topic : "ELSA AI Role-play",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: chatUI(chat, languages),
      ),
    );
  }

  Widget chatUI(ChatProvider chat, Map<String, String> languages) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: chat.messages.length,
            itemBuilder: (context, index) {
              final msg = chat.messages[index];
              final isUser = msg['from'] == 'user';
              final isAI = msg['from'] == 'ai';

              return KeyedSubtree(
                key: ValueKey('$index-${msg['text']}'),
                child: Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue[300] : Colors.purple[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            if (msg.containsKey('translated'))
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  msg['translated'],
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 236, 230, 230),
                                      fontSize: 16),
                                ),
                              )
                          ],
                        ),
                      ),
                      if (isAI)
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => chat.repeatLastAIMessage(),
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.white),
                              label: const Text("Repeat",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final translated =
                                    await chat.translateLastAIMessage();
                                if (translated.isNotEmpty) {
                                  final lastIndex = chat.messages
                                      .lastIndexWhere((m) => m['from'] == 'ai');
                                  if (lastIndex != -1) {
                                    setState(() {
                                      chat.messages[lastIndex]['translated'] =
                                          translated;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.translate,
                                  color: Colors.white),
                              label: const Text("Translate",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: chat.isListening || _isSendingMic
                    ? null
                    : () async {
                        setState(() => _isSendingMic = true);
                        await chat.startListening((userText) {
                          chat.messages.add({"from": "user", "text": userText});
                          chat.notifyListeners();
                          chat.sendToBackend(
                              userText, chat.topic, chat.language);
                        });
                        setState(() => _isSendingMic = false);
                      },
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: chat.isListening || _isSendingMic
                      ? Colors.grey
                      : Colors.lightBlue,
                  child: const Icon(Icons.mic, size: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.deepPurple[700],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          chat.messages.add({"from": "user", "text": text});
                          chat.notifyListeners();
                          chat.sendToBackend(text, chat.topic, chat.language);
                          _textController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
