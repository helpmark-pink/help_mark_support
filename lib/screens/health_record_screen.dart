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
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();

  final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.sentiment_very_dissatisfied, 'label': 'つらい', 'color': const Color(0xFFE3B8B8)},
    {'icon': Icons.sentiment_dissatisfied, 'label': 'いまいち', 'color': const Color(0xFFE3D4B8)},
    {'icon': Icons.sentiment_neutral, 'label': 'ふつう', 'color': const Color(0xFFE3E3B8)},
    {'icon': Icons.sentiment_satisfied, 'label': 'まあまあ', 'color': const Color(0xFFD4E3B8)},
    {'icon': Icons.sentiment_very_satisfied, 'label': 'げんき', 'color': const Color(0xFFB8E3B8)},
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

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('health_records', json.encode(_records));
  }

  void _addRecord(int mood, String memo) {
    final dateStr = '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}';
    final now = DateTime.now();
    final record = {
      'date': dateStr,
      'time': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'mood': mood,
      'memo': memo,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    setState(() {
      _records.insert(0, record);
    });
    _saveRecords();
  }

  void _deleteRecord(String id) {
    setState(() {
      _records.removeWhere((record) => record['id'] == id);
    });
    _saveRecords();
  }

  List<Map<String, dynamic>> _getRecordsForDate(DateTime date) {
    final dateStr = '${date.year}/${date.month}/${date.day}';
    return _records.where((r) => r['date'] == dateStr).toList();
  }

  Map<String, dynamic>? _getMoodForDate(DateTime date) {
    final records = _getRecordsForDate(date);
    if (records.isEmpty) return null;
    return records.first;
  }

  void _showAddRecordDialog() {
    int selectedMood = 3;
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_selectedDate.month}/${_selectedDate.day} のきろく',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5D4E4E)),
                  ),
                  const SizedBox(height: 8),
                  const Text('きぶんは？', style: TextStyle(fontSize: 11, color: Color(0xFF5D4E4E))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    alignment: WrapAlignment.center,
                    children: List.generate(5, (index) {
                      final mood = _moods[index];
                      final isSelected = selectedMood == index + 1;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedMood = index + 1),
                        child: Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? mood['color'] : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? mood['color'] : Colors.grey.shade300, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Icon(mood['icon'], size: 20, color: isSelected ? const Color(0xFF5D4E4E) : Colors.grey),
                              const SizedBox(height: 2),
                              Text(mood['label'], style: TextStyle(fontSize: 7, color: isSelected ? const Color(0xFF5D4E4E) : Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: memoController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'メモ',
                      hintStyle: const TextStyle(fontSize: 11),
                      filled: true,
                      fillColor: const Color(0xFFFAF8F5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.all(6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _addRecord(selectedMood, memoController.text);
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('きろくしました'),
                                  ],
                                ),
                                backgroundColor: Color(0xFFD4E3B8),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: const Text('きろく', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8B4B8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('キャンセル', style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 11)),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth - 16) / 7;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('たいちょう', style: TextStyle(fontSize: 15)),
          ],
        ),
        toolbarHeight: 44,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      color: const Color(0xFFE8B4B8),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                    Text(
                      '${_currentMonth.year}/${_currentMonth.month}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4E4E)),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      color: const Color(0xFFE8B4B8),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
                Row(
                  children: ['日', '月', '火', '水', '木', '金', '土'].map((day) {
                    Color color = const Color(0xFF5D4E4E);
                    if (day == '日') color = const Color(0xFFE8B4B8);
                    if (day == '土') color = const Color(0xFFB8D4E3);
                    return Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 9),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            color: Colors.white,
            child: _buildCalendarGrid(cellSize),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.month}/${_selectedDate.day}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF5D4E4E)),
                      ),
                      GestureDetector(
                        onTap: _showAddRecordDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFE8B4B8), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 14),
                              SizedBox(width: 2),
                              Text('ついか', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(child: _buildRecordsList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(double cellSize) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    List<Widget> rows = [];
    List<Widget> currentRow = [];

    for (int i = 0; i < startWeekday; i++) {
      currentRow.add(Expanded(child: SizedBox(height: cellSize * 0.6)));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final moodRecord = _getMoodForDate(date);
      final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
      final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

      currentRow.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              height: cellSize * 0.6,
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8B4B8) : (moodRecord != null ? (_moods[moodRecord['mood'] - 1]['color'] as Color).withOpacity(0.5) : null),
                borderRadius: BorderRadius.circular(4),
                border: isToday ? Border.all(color: const Color(0xFFE8B4B8), width: 1) : null,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF5D4E4E))),
                      if (moodRecord != null) Icon(_moods[moodRecord['mood'] - 1]['icon'], size: 10, color: isSelected ? Colors.white : const Color(0xFF5D4E4E)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if ((startWeekday + day) % 7 == 0) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }

    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(Expanded(child: SizedBox(height: cellSize * 0.6)));
      }
      rows.add(Row(children: currentRow));
    }

    return Column(children: rows);
  }

  Widget _buildRecordsList() {
    final records = _getRecordsForDate(_selectedDate);

    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_rounded, size: 32, color: Color(0xFFD4D4D4)),
            SizedBox(height: 4),
            Text('きろくなし', style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 10)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final mood = _moods[record['mood'] - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (mood['color'] as Color).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: mood['color'] as Color, width: 1),
          ),
          child: Row(
            children: [
              Icon(mood['icon'], size: 20, color: mood['color']),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record['time']} ${mood['label']}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF5D4E4E), fontSize: 9),
                    ),
                    if (record['memo']?.isNotEmpty == true)
                      Text(
                        record['memo'],
                        style: const TextStyle(color: Color(0xFF5D4E4E), fontSize: 8),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showDeleteDialog(record['id']),
                child: const Icon(Icons.close, color: Color(0xFFE3B8B8), size: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('さくじょ？', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('いいえ', style: TextStyle(fontSize: 11))),
          TextButton(
            onPressed: () {
              _deleteRecord(id);
              Navigator.pop(context);
            },
            child: const Text('はい', style: TextStyle(color: Color(0xFFE3B8B8), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}