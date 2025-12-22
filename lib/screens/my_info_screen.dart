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
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('ほぞんしました', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          backgroundColor: Color(0xFF4CAF50),
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
            Icon(Icons.person_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('わたしのじょうほう', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showInfoCard,
            icon: const Icon(Icons.badge_rounded, size: 24),
            tooltip: 'カードひょうじ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _buildTextField('おなまえ', _nameController, Icons.person_rounded, const Color(0xFFD32F2F)),
            _buildTextField('びょうきやしょうがい', _conditionController, Icons.medical_services_rounded, const Color(0xFF1976D2)),
            _buildTextField('きんきゅうれんらくさき', _emergencyContactController, Icons.phone_rounded, const Color(0xFF388E3C)),
            _buildTextField('かかりつけびょういん', _hospitalController, Icons.local_hospital_rounded, const Color(0xFFF57C00)),
            _buildTextField('そのたメモ', _noteController, Icons.note_rounded, const Color(0xFF7B1FA2), maxLines: 2),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveData,
                icon: const Icon(Icons.save_rounded, size: 22),
                label: const Text('ほぞんする', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Color(0xFF222222)),
            decoration: InputDecoration(
              hintText: '$label をにゅうりょく',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color.withOpacity(0.6), width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 2.5),
              ),
            ),
          ),
        ],
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
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD32F2F).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emergency_rounded, size: 36, color: Color(0xFFD32F2F)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'きんきゅうカード',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'たすけがひつようなときにみせてください',
                        style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 3,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFF1976D2), Color(0xFF388E3C)],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person_rounded, 'なまえ', _nameController.text, const Color(0xFFD32F2F)),
                _buildInfoRow(Icons.medical_services_rounded, 'びょうきやしょうがい', _conditionController.text, const Color(0xFF1976D2)),
                _buildInfoRow(Icons.phone_rounded, 'きんきゅうれんらくさき', _emergencyContactController.text, const Color(0xFF388E3C)),
                _buildInfoRow(Icons.local_hospital_rounded, 'かかりつけびょういん', _hospitalController.text, const Color(0xFFF57C00)),
                if (_noteController.text.isNotEmpty)
                  _buildInfoRow(Icons.note_rounded, 'メモ', _noteController.text, const Color(0xFF7B1FA2)),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('とじる', style: TextStyle(color: Color(0xFF666666), fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'みとうろく' : value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: value.isEmpty ? const Color(0xFF999999) : const Color(0xFF333333),
                  ),
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