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
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('ほぞんしました'),
            ],
          ),
          backgroundColor: Color(0xFFD4E3B8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('マイじょうほう', style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showInfoCard,
            icon: const Icon(Icons.badge_rounded, size: 22),
            tooltip: 'カードひょうじ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildTextField('おなまえ', _nameController, Icons.person_rounded, const Color(0xFFE8B4B8)),
            _buildTextField('びょうき・しょうじょう', _conditionController, Icons.medical_services_rounded, const Color(0xFFB8D4E3)),
            _buildTextField('きんきゅうれんらくさき', _emergencyContactController, Icons.phone_rounded, const Color(0xFFD4E3B8)),
            _buildTextField('びょういん', _hospitalController, Icons.local_hospital_rounded, const Color(0xFFE3D4B8)),
            _buildTextField('そのたメモ', _noteController, Icons.note_rounded, const Color(0xFFD4B8E3), maxLines: 2),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('ほぞんする', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4E3B8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      IconData icon,
      Color color, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color, fontSize: 12),
          prefixIcon: Icon(icon, color: color, size: 20),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _showInfoCard() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8B4B8).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_hospital_rounded, size: 28, color: Color(0xFFE8B4B8)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'きんきゅうカード',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5D4E4E)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE8B4B8), Color(0xFFB8D4E3), Color(0xFFD4E3B8)],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person_rounded, 'なまえ', _nameController.text, const Color(0xFFE8B4B8)),
                _buildInfoRow(Icons.medication_rounded, 'びょうき', _conditionController.text, const Color(0xFFB8D4E3)),
                _buildInfoRow(Icons.phone_rounded, 'れんらくさき', _emergencyContactController.text, const Color(0xFFD4E3B8)),
                _buildInfoRow(Icons.local_hospital_rounded, 'びょういん', _hospitalController.text, const Color(0xFFE3D4B8)),
                if (_noteController.text.isNotEmpty)
                  _buildInfoRow(Icons.note_rounded, 'メモ', _noteController.text, const Color(0xFFD4B8E3)),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('とじる', style: TextStyle(color: Color(0xFF5D4E4E), fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
                Text(
                  value.isEmpty ? 'みとうろく' : value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF5D4E4E)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
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