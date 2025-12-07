import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _conditionController.text = prefs.getString('condition') ?? '';
      _emergencyContactController.text = prefs.getString('emergencyContact') ?? '';
      _hospitalController.text = prefs.getString('hospital') ?? '';
      _noteController.text = prefs.getString('note') ?? '';
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('condition', _conditionController.text);
    await prefs.setString('emergencyContact', _emergencyContactController.text);
    await prefs.setString('hospital', _hospitalController.text);
    await prefs.setString('note', _noteController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('保存しました'),
          backgroundColor: Color(0xFF86EFAC),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 マイ情報'),
        actions: [
          IconButton(
            onPressed: _showInfoCard,
            icon: const Icon(Icons.visibility),
            tooltip: 'カード表示',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('お名前', _nameController, Icons.person),
            _buildTextField('持病・症状', _conditionController, Icons.medical_services),
            _buildTextField('緊急連絡先', _emergencyContactController, Icons.phone),
            _buildTextField('かかりつけ病院', _hospitalController, Icons.local_hospital),
            _buildTextField('その他メモ', _noteController, Icons.note, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save),
                label: const Text('保存する', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF86EFAC),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFFACC15)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFDE047), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFACC15), width: 2),
          ),
        ),
      ),
    );
  }

  void _showInfoCard() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  '🏥 緊急連絡カード',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF422006),
                  ),
                ),
              ),
              const Divider(height: 32),
              _buildInfoRow('名前', _nameController.text),
              _buildInfoRow('持病・症状', _conditionController.text),
              _buildInfoRow('緊急連絡先', _emergencyContactController.text),
              _buildInfoRow('かかりつけ病院', _hospitalController.text),
              if (_noteController.text.isNotEmpty)
                _buildInfoRow('メモ', _noteController.text),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF78716C),
            ),
          ),
          Text(
            value.isEmpty ? '未登録' : value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF422006),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    _emergencyContactController.dispose();
    _hospitalController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}