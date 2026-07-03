import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'mood_helper.dart';
import 'home_screen.dart';

class InfluenceCheckInPage extends StatefulWidget {
  final String selectedMood;
  final List<Map<String, dynamic>> pemicuList;

  const InfluenceCheckInPage({
    super.key,
    required this.selectedMood,
    required this.pemicuList,
  });

  @override
  State<InfluenceCheckInPage> createState() => _InfluenceCheckInPageState();
}

class _InfluenceCheckInPageState extends State<InfluenceCheckInPage> {
  final ApiService _apiService = ApiService();
  final Set<int> selectedPemicuIds = {};
  final TextEditingController _journalController = TextEditingController();
  bool _isSaving = false;

  static const _kategoriColors = {
    'Aktivitas': Color(0xFFFFF3E0),
    'Gaya Hidup': Color(0xFFE8F5E9),
    'Lingkungan': Color(0xFFE3F2FD),
    'Sosial': Color(0xFFFCE4EC),
    'Kesehatan': Color(0xFFF3E5F5),
    'Keuangan': Color(0xFFFFF8E1),
  };

  static const _kategoriIcons = {
    'Aktivitas': Icons.trending_up,
    'Gaya Hidup': Icons.wb_sunny,
    'Lingkungan': Icons.public,
    'Sosial': Icons.people,
    'Kesehatan': Icons.favorite,
    'Keuangan': Icons.account_balance,
  };

  List<MapEntry<String, List<Map<String, dynamic>>>> _groupedByKategori() {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in widget.pemicuList) {
      final kat = p['kategori'] as String? ?? 'Lainnya';
      grouped.putIfAbsent(kat, () => []);
      grouped[kat]!.add(p);
    }
    final order = ['Aktivitas', 'Gaya Hidup', 'Lingkungan', 'Sosial', 'Kesehatan', 'Keuangan'];
    final entries = grouped.entries.toList();
    entries.sort((a, b) => order.indexOf(a.key).compareTo(order.indexOf(b.key)));
    return entries;
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _saveCheckin() async {
    if (widget.selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood tidak valid'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final moodValue = _getMoodValue(widget.selectedMood);
    
    final result = await _apiService.createCheckin(
      mood: moodValue,
      catatan: _journalController.text.trim().isEmpty ? null : _journalController.text.trim(),
      pemicuIds: selectedPemicuIds.toList(),
    );

    setState(() {
      _isSaving = false;
    });

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in berhasil disimpan! ✨'),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 1),
        ),
      );
      
      // Refresh auth provider untuk update streak
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan check-in'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

  String _getMoodValue(String moodLabel) {
    switch (moodLabel.toLowerCase()) {
      case 'happy': return 'happy';
      case 'anxious': return 'anxious';
      case 'calm': return 'calm';
      case 'sad': return 'sad';
      default: return 'neutral';
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodType = MoodHelper.fromString(widget.selectedMood);
    final moodColor = MoodHelper.getMoodIconColor(moodType);
    final moodBgColor = MoodHelper.getMoodBgColor(moodType);
    const outlineColor = Color(0xFFFF8A65);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6D5B56)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DAILY CHECK-IN',
          style: TextStyle(
            color: Color(0xFF6D5B56),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: moodBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: moodColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: moodColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        MoodHelper.getMoodIcon(moodType),
                        color: moodColor,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mood hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: const Color(0xFF6D5B56),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MoodHelper.getMoodLabel(moodType),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: moodColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Center(
              child: Text(
                'Apa yang memengaruhinya?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF3E2F2B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            _buildPemicuSections(outlineColor),
            const SizedBox(height: 32),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'CATATAN JURNAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Color(0xFF6D5B56),
                  ),
                ),
                Text(
                  'opsional',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF6D5B56),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _journalController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Apa yang ada di pikiranmu?',
                hintStyle: const TextStyle(
                  color: Color(0xFFC3ADA7),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6D5B56),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCheckin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  disabledBackgroundColor: const Color(0xFFFF8A65).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPemicuSections(Color accentColor) {
    final grouped = _groupedByKategori();
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: grouped.map((entry) {
        final kategori = entry.key;
        final items = entry.value;
        final bgColor = _kategoriColors[kategori] ?? const Color(0xFFF5F5F5);
        final icon = _kategoriIcons[kategori] ?? Icons.help_outline;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF6D5B56)),
                  const SizedBox(width: 8),
                  Text(
                    kategori.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final factor = items[index];
                final isSelected = selectedPemicuIds.contains(factor['id']);
                return _buildFactorItem(factor, isSelected, accentColor);
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFactorItem(Map<String, dynamic> factor, bool isSelected, Color accentColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedPemicuIds.remove(factor['id']);
          } else {
            selectedPemicuIds.add(factor['id']);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: factor['color'],
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: accentColor, width: 2) 
              : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              factor['icon'],
              color: isSelected ? accentColor : const Color(0xFF6D5B56),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              factor['name'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : const Color(0xFF6D5B56),
              ),
            ),
          ],
        ),
      ),
    );
  }
}