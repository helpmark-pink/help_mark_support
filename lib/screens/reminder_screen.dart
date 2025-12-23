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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alarm_add_rounded, color: Color(0xFFD4B8E3), size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'おしらせをついか',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                      decoration: InputDecoration(
                        labelText: 'なにをおしらせ？',
                        labelStyle: const TextStyle(fontSize: 12),
                        hintText: 'れい：くすり、びょういん',
                        hintStyle: const TextStyle(fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFFFAF8F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFFD4B8E3), size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFFD4B8E3), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${selectedDate.month}がつ${selectedDate.day}にち',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFD4B8E3), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${selectedTime.hour}じ${selectedTime.minute.toString().padLeft(2, '0')}ふん',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
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
                                  content: Text('これからのじかんをえらんで', style: TextStyle(fontSize: 13)),
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
                                content: Text('${selectedTime.hour}じ${selectedTime.minute.toString().padLeft(2, '0')}ふんにおしらせ', style: const TextStyle(fontSize: 13)),
                                backgroundColor: const Color(0xFFD4B8E3),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4B8E3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('とうろく', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('やめる', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
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
            Icon(Icons.alarm_rounded, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'おしらせよやく',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _reminders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_off_rounded, size: 48, color: Color(0xFFD4B8E3)),
            SizedBox(height: 12),
            Text('おしらせはありません', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
            SizedBox(height: 4),
            Text('したのボタンからついか', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final isDone = reminder['done'] ?? false;

          final dateParts = reminder['date'].split('/');
          final timeParts = reminder['time'].split(':');
          final displayDate = '${dateParts[1]}/${dateParts[2]}';
          final displayTime = '${timeParts[0]}:${timeParts[1]}';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDone ? const Color(0xFF8BC34A) : const Color(0xFFD4B8E3),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleDone(reminder['id']),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF8BC34A) : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDone ? const Color(0xFF8BC34A) : const Color(0xFFD4B8E3),
                          width: 2,
                        ),
                      ),
                      child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? const Color(0xFF999999) : const Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isDone ? Icons.check_circle : Icons.alarm_rounded,
                              size: 14,
                              color: isDone ? const Color(0xFF999999) : const Color(0xFFD4B8E3),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                isDone ? 'おわり' : '$displayDate $displayTime',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDone ? const Color(0xFF999999) : const Color(0xFF7B5EA7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(reminder['id']),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3B8B8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
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
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text('ついか', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('けしますか？', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('やめる', style: TextStyle(fontSize: 13, color: Color(0xFF666666))),
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
            child: const Text('けす', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}