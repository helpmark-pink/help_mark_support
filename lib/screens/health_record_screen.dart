import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  List<Map<String, dynamic>> _records = [];
  int _selectedMood = 3;
  final _memoController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😣', 'label': 'つらい', 'color': const Color(0xFFFCA5A5)},
    {'emoji': '😔', 'label': 'いまいち', 'color': const Color(0xFFFED7AA)},
    {'emoji': '😐', 'label': 'ふつう', 'color': const Color(0xFFFDE047)},
    {'emoji': '🙂', 'label': 'まあまあ', 'color': const Color(0xFFBBF7D0)},
    {'emoji': '😊', 'label': '元気', 'color': const Color(0xFF86EFAC)},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString('health_records');
    if (recordsJson != null) {
      setState(() {
        _records = List<Map<String, dynamic>>.from(json.decode(recordsJson));
      });
    }
  }

  Future<void> _saveRecord() async {
    final now = DateTime.now();
    final record = {
      'date': '${now.year}/${now.month}/${now.day}',
      'time': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'mood': _selectedMood,
      'memo': _memoController.text,
    };

    setState(() {
      _records.insert(0, record);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('health_records', json.encode(_records));

    _memoController.clear();
    _selectedMood = 3;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('記録しました'),
          backgroundColor: Color(0xFF86EFAC),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ 体調記録'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今の気分は？',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF422006),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final mood = _moods[index];
                    final isSelected = _selectedMood == index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMood = index + 1),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? mood['color'] : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? mood['color'] : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(mood['emoji'], style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? const Color(0xFF422006) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _memoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'メモ（任意）',
                    filled: true,
                    fillColor: const Color(0xFFFFFEF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.add),
                    label: const Text('記録する', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _records.isEmpty
                ? const Center(
              child: Text(
                'まだ記録がありません',
                style: TextStyle(color: Color(0xFF78716C)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final mood = _moods[record['mood'] - 1];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: mood['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(mood['emoji'], style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    title: Text(
                      '${record['date']} ${record['time']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: record['memo']?.isNotEmpty == true ? Text(record['memo']) : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }
}