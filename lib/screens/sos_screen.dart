import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE2E2),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => TtsService().speak('助けが必要です。声をかけてください。'),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 32),
                    color: const Color(0xFF422006),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text('🆘', style: TextStyle(fontSize: 80)),
                      SizedBox(height: 24),
                      Text(
                        '助けが必要です',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '声をかけてください',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF422006),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => TtsService().speak('助けが必要です。声をかけてください。'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCA5A5),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('音声で伝える', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}