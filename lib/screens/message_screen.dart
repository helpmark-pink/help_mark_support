import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {'icon': '🪑', 'text': '席を譲っていただけますか？'},
      {'icon': '😌', 'text': '少し休ませてください'},
      {'icon': '🚶', 'text': 'ゆっくり歩きます。お先にどうぞ'},
      {'icon': '🤝', 'text': '手を貸していただけますか？'},
      {'icon': '📍', 'text': '道を教えていただけますか？'},
      {'icon': '🙏', 'text': 'ありがとうございます'},
      {'icon': '💊', 'text': '体調が悪いです'},
      {'icon': '🏥', 'text': '病院に連絡してください'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 メッセージ'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _showMessageDialog(context, message['text']),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(message['icon'], style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        message['text'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF422006),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFF78716C)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF422006),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => TtsService().speak(text),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('読み上げ'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}