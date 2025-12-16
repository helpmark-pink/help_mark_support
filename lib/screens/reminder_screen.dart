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
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_rounded, color: Color(0xFFD4B8E3), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'リマインダーついか',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF5D4E4E)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'タイトル',
                        labelStyle: const TextStyle(fontSize: 12),
                        hintText: 'れい：びょういん、くすり',
                        hintStyle: const TextStyle(fontSize: 11),
                        filled: true,
                        fillColor: const Color(0xFFFAF8F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFFD4B8E3), size: 18),
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
                            Text(
                              '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4E4E)),
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
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF5D4E4E)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
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
                                          Icon(Icons.warning_rounded, color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text('みらいのじかんをえらんでください'),
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
                                  title: 'リマインダー',
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
                                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                        const SizedBox(width: 8),
                                        Text('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')} につうちします'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFFD4B8E3),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('ついか', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4B8E3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('キャンセル', style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 12)),
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
            Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('リマインダー', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: _reminders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded, size: 56, color: Color(0xFFD4D4D4)),
            SizedBox(height: 10),
            Text('リマインダーがありません', style: TextStyle(fontSize: 14, color: Color(0xFF5D4E4E))),
            SizedBox(height: 4),
            Text('ついかすると、つうちがとどきます', style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 11)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final isDone = reminder['done'] ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDone ? const Color(0xFFD4E3B8) : const Color(0xFFD4B8E3),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleDone(reminder['id']),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFD4E3B8) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDone ? const Color(0xFFD4E3B8) : const Color(0xFFD4B8E3),
                          width: 1.5,
                        ),
                      ),
                      child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            color: isDone ? const Color(0xFF5D4E4E).withOpacity(0.5) : const Color(0xFF5D4E4E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 11,
                              color: isDone ? const Color(0xFF5D4E4E).withOpacity(0.3) : const Color(0xFFD4B8E3),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${reminder['date']} ${reminder['time']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDone ? const Color(0xFF5D4E4E).withOpacity(0.5) : const Color(0xFFD4B8E3),
                                  fontWeight: FontWeight.w500,
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3B8B8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
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
        label: const Text('ついか', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('さくじょしますか？', style: TextStyle(fontSize: 14)),
        content: const Text('つうちもキャンセルされます', style: TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: () {
              _deleteReminder(id);
              Navigator.pop(context);
            },
            child: const Text('さくじょ', style: TextStyle(color: Color(0xFFE3B8B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}