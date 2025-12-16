import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {'icon': Icons.event_seat_rounded, 'text': 'せきをゆずってください'},
      {'icon': Icons.self_improvement_rounded, 'text': 'すこしやすませてください'},
      {'icon': Icons.directions_walk_rounded, 'text': 'ゆっくりあるきます'},
      {'icon': Icons.handshake_rounded, 'text': 'てをかしてください'},
      {'icon': Icons.location_on_rounded, 'text': 'みちをおしえてください'},
      {'icon': Icons.volunteer_activism_rounded, 'text': 'ありがとうございます'},
      {'icon': Icons.medication_rounded, 'text': 'たいちょうがわるいです'},
      {'icon': Icons.local_hospital_rounded, 'text': 'びょういんにれんらく'},
    ];

    final colors = [
      const Color(0xFFE8B4B8),
      const Color(0xFFB8D4E3),
      const Color(0xFFD4E3B8),
      const Color(0xFFE3D4B8),
      const Color(0xFFD4B8E3),
      const Color(0xFFB8E3D4),
      const Color(0xFFE3B8D4),
      const Color(0xFFB8C4E3),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('メッセージ', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showMessageDialog(context, message['text'], message['icon'], colors[index]),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors[index], width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors[index].withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(message['icon'], size: 24, color: colors[index]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message['text'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5D4E4E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, color: colors[index], size: 14),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessageDialog(BuildContext context, String text, IconData icon, Color color) {
    final ttsService = TtsService();
    bool isSpeaking = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 44, color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4E4E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isSpeaking) {
                              await ttsService.stop();
                              setState(() => isSpeaking = false);
                            } else {
                              setState(() => isSpeaking = true);
                              await ttsService.speak(text);
                              setState(() => isSpeaking = false);
                            }
                          },
                          icon: Icon(
                            isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isSpeaking ? 'とめる' : 'よみあげ',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSpeaking ? const Color(0xFFB8D4E3) : color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ttsService.stop();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'とじる',
                          style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}