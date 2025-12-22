import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> _reminders = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initNotification();
    _loadReminders();
  }

  Future<void> _initNotification() async {
    await _notificationService.init();
    await _notificationService.requestPermission();
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? remindersJson = prefs.getString('reminders');
    if (remindersJson != null) {
      setState(() {
        _reminders = List<Map<String, dynamic>>.from(json.decode(remindersJson));
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminders', json.encode(_reminders));
  }

  void _deleteReminder(String id) {
    final notificationId = int.parse(id) % 100000;
    _notificationService.cancelNotification(notificationId);
    setState(() {
      _reminders.removeWhere((r) => r['id'] == id);
    });
    _saveReminders();
  }

  void _toggleDone(String id) {
    setState(() {
      final index = _reminders.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        _reminders[index]['done'] = !_reminders[index]['done'];
        if (_reminders[index]['done'] == true) {
          final notificationId = int.parse(id) % 100000;
          _notificationService.cancelNotification(notificationId);
        }
      }
    });
    _saveReminders();
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute + 2);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4B8E3).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.alarm_add_rounded, color: Color(0xFFD4B8E3), size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'おしらせをついか',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'せっていしたじかんに\nおしらせがとどきます',
                      style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        labelText: 'なにをおしらせする？',
                        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
                        hintText: 'れい：くすりをのむ、びょういん',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                        filled: true,
                        fillColor: const Color(0xFFFAF8F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFFD4B8E3), size: 22),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4B8E3).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFFD4B8E3), size: 22),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ひにち', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                Text(
                                  '${selectedDate.year}ねん${selectedDate.month}がつ${selectedDate.day}にち',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD4B8E3).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFD4B8E3), size: 22),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('じかん', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
                                Text(
                                  '${selectedTime.hour}じ${selectedTime.minute.toString().padLeft(2, '0')}ふん',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (titleController.text.trim().isNotEmpty) {
                                final id = DateTime.now().millisecondsSinceEpoch.toString();
                                final notificationId = int.parse(id) % 100000;

                                final scheduledDateTime = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );

                                if (scheduledDateTime.isBefore(DateTime.now())) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                                          SizedBox(width: 8),
                                          Text('これからのじかんをえらんでください', style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFFE3B8B8),
                                    ),
                                  );
                                  return;
                                }

                                final reminder = {
                                  'id': id,
                                  'title': titleController.text.trim(),
                                  'date': '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                                  'time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  'done': false,
                                };

                                await _notificationService.scheduleNotification(
                                  id: notificationId,
                                  title: 'おしらせ',
                                  body: titleController.text.trim(),
                                  scheduledDate: scheduledDateTime,
                                );

                                setState(() {
                                  _reminders.add(reminder);
                                });
                                _saveReminders();

                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text('${selectedTime.hour}じ${selectedTime.minute.toString().padLeft(2, '0')}ふんにおしらせします', style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFD4B8E3),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_rounded, size: 22),
                            label: const Text('とうろくする', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4B8E3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('やめる', style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.alarm_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('おしらせよやく', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: _reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD4B8E3).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_off_rounded, size: 56, color: Color(0xFFD4B8E3)),
            ),
            const SizedBox(height: 16),
            const Text('おしらせはありません', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
            const SizedBox(height: 8),
            const Text('したのボタンから\nおしらせをついかできます', style: TextStyle(color: Color(0xFF666666), fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final isDone = reminder['done'] ?? false;

          // 日時をわかりやすく変換
          final dateParts = reminder['date'].split('/');
          final timeParts = reminder['time'].split(':');
          final displayDate = '${dateParts[1]}がつ${dateParts[2]}にち';
          final displayTime = '${timeParts[0]}じ${timeParts[1]}ふん';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone ? const Color(0xFF8BC34A) : const Color(0xFFD4B8E3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // チェックボックス
                  GestureDetector(
                    onTap: () => _toggleDone(reminder['id']),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF8BC34A) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDone ? const Color(0xFF8BC34A) : const Color(0xFFD4B8E3),
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? const Color(0xFF999999) : const Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDone ? const Color(0xFFEEEEEE) : const Color(0xFFD4B8E3).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDone ? Icons.check_circle : Icons.alarm_rounded,
                                size: 16,
                                color: isDone ? const Color(0xFF999999) : const Color(0xFFD4B8E3),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isDone ? 'かんりょう' : '$displayDate $displayTime',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDone ? const Color(0xFF999999) : const Color(0xFF7B5EA7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 削除ボタン
                  GestureDetector(
                    onTap: () => _showDeleteDialog(reminder['id']),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3B8B8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFD4B8E3),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text('おしらせをついか', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: Color(0xFFE3B8B8), size: 24),
            SizedBox(width: 8),
            Text('けしますか？', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('このおしらせをけします', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('やめる', style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReminder(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE3B8B8),
              foregroundColor: Colors.white,
            ),
            child: const Text('けす', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}