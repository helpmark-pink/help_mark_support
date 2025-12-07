import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
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

  void _addReminder() {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('リマインダー追加'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'タイトル',
                  hintText: '例：内科受診、薬をもらう',
                  filled: true,
                  fillColor: const Color(0xFFFFFEF0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFFFACC15)),
                title: Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFFFACC15)),
                title: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setDialogState(() => selectedTime = time);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _reminders.add({
                      'title': titleController.text,
                      'date': '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}',
                      'time': '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      'done': false,
                    });
                  });
                  _saveReminders();
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
    _saveReminders();
  }

  void _toggleDone(int index) {
    setState(() {
      _reminders[index]['done'] = !_reminders[index]['done'];
    });
    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔔 リマインダー'),
      ),
      body: _reminders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📅',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'リマインダーがありません',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF78716C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '通院予定などを追加しましょう',
              style: TextStyle(color: Color(0xFF78716C)),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          final isDone = reminder['done'] ?? false;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Checkbox(
                value: isDone,
                onChanged: (_) => _toggleDone(index),
                activeColor: const Color(0xFF86EFAC),
              ),
              title: Text(
                reminder['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone
                      ? const Color(0xFF78716C)
                      : const Color(0xFF422006),
                ),
              ),
              subtitle: Text(
                '${reminder['date']} ${reminder['time']}',
                style: TextStyle(
                  color: isDone
                      ? const Color(0xFF78716C)
                      : const Color(0xFFFACC15),
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFFCA5A5)),
                onPressed: () => _deleteReminder(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        backgroundColor: const Color(0xFFFDE047),
        icon: const Icon(Icons.add),
        label: const Text('追加'),
      ),
    );
  }
}