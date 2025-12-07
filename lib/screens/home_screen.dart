import 'package:flutter/material.dart';
import 'sos_screen.dart';
import 'message_screen.dart';
import 'my_info_screen.dart';
import 'health_record_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('☀️ ', style: TextStyle(fontSize: 24)),
            Text('ヘルプマークサポート'),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // SOS ボタン
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SosScreen()),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFCA5A5), Color(0xFFF87171)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFCA5A5).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🆘', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 8),
                        Text(
                          '助けを呼ぶ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // メニューグリッド
              Expanded(
                flex: 3,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.message_rounded,
                      label: 'メッセージ',
                      color: const Color(0xFFFDE047),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MessageScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.person_rounded,
                      label: 'マイ情報',
                      color: const Color(0xFF86EFAC),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyInfoScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.favorite_rounded,
                      label: '体調記録',
                      color: const Color(0xFFFDA4AF),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HealthRecordScreen()),
                      ),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.notifications_rounded,
                      label: 'リマインダー',
                      color: const Color(0xFF93C5FD),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReminderScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF422006)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF422006),
              ),
            ),
          ],
        ),
      ),
    );
  }
}