import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/mood_model.dart';
import 'influence_checkin_screen.dart';
import 'mood_helper.dart';

class DailyCheckInPage extends StatefulWidget {
  const DailyCheckInPage({super.key});

  @override
  State<DailyCheckInPage> createState() => _DailyCheckInPageState();
}

class _DailyCheckInPageState extends State<DailyCheckInPage> {
  final ApiService _apiService = ApiService();
  String? selectedMood;
  List<Map<String, dynamic>> _pemicuList = [];
  bool _isLoadingPemicu = true;
  bool _hasCheckedInToday = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkTodayCheckin();
    _loadPemicu();
  }

  Future<void> _checkTodayCheckin() async {
    final result = await _apiService.getCheckinHistory();
    if (result['success']) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final hasChecked = (result['data'] as List).any((checkin) {
        return checkin.createdAt.isAfter(todayStart);
      });
      
      if (mounted) {
        setState(() {
          _hasCheckedInToday = hasChecked;
        });
      }
      
      if (hasChecked && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamu sudah check-in hari ini!'),
            backgroundColor: Color(0xFFFF8A65),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  Future<void> _loadPemicu() async {
    setState(() {
      _isLoadingPemicu = true;
    });
    
    final result = await _apiService.getPemicu();
    
    final List<Map<String, dynamic>> defaultPemicu = [
      {'id': 1, 'name': 'Work', 'kategori': 'Aktivitas', 'icon': Icons.work, 'color': const Color(0xFFFFF3E0)},
      {'id': 2, 'name': 'Study', 'kategori': 'Aktivitas', 'icon': Icons.school, 'color': const Color(0xFFFFF3E0)},
      {'id': 3, 'name': 'Exercise', 'kategori': 'Aktivitas', 'icon': Icons.fitness_center, 'color': const Color(0xFFFFF3E0)},
      {'id': 4, 'name': 'Screen Time', 'kategori': 'Aktivitas', 'icon': Icons.important_devices, 'color': const Color(0xFFFFF3E0)},
      {'id': 5, 'name': 'Sleep', 'kategori': 'Gaya Hidup', 'icon': Icons.nightlight, 'color': const Color(0xFFE8F5E9)},
      {'id': 6, 'name': 'Food', 'kategori': 'Gaya Hidup', 'icon': Icons.restaurant, 'color': const Color(0xFFE8F5E9)},
      {'id': 7, 'name': 'Caffeine', 'kategori': 'Gaya Hidup', 'icon': Icons.local_cafe, 'color': const Color(0xFFE8F5E9)},
      {'id': 8, 'name': 'Weather', 'kategori': 'Lingkungan', 'icon': Icons.cloud, 'color': const Color(0xFFE3F2FD)},
      {'id': 9, 'name': 'Nature', 'kategori': 'Lingkungan', 'icon': Icons.park, 'color': const Color(0xFFE3F2FD)},
      {'id': 10, 'name': 'Music', 'kategori': 'Lingkungan', 'icon': Icons.music_note, 'color': const Color(0xFFE3F2FD)},
      {'id': 11, 'name': 'Social', 'kategori': 'Sosial', 'icon': Icons.people, 'color': const Color(0xFFFCE4EC)},
      {'id': 12, 'name': 'Relationship', 'kategori': 'Sosial', 'icon': Icons.favorite_border, 'color': const Color(0xFFFCE4EC)},
      {'id': 13, 'name': 'Health', 'kategori': 'Kesehatan', 'icon': Icons.medical_services, 'color': const Color(0xFFF3E5F5)},
      {'id': 14, 'name': 'Stress', 'kategori': 'Kesehatan', 'icon': Icons.psychology, 'color': const Color(0xFFF3E5F5)},
      {'id': 15, 'name': 'Finance', 'kategori': 'Keuangan', 'icon': Icons.payments, 'color': const Color(0xFFFFF8E1)},
    ];

    if (result['success'] && mounted && result['data'] != null && (result['data'] as List).isNotEmpty) {
      final List<dynamic> apiData = result['data'] as List;
      // Validasi data dari API punya field id & nama
      final bool validData = apiData.every((p) => p is PemicuModel);
      if (!validData) {
        if (mounted) {
          setState(() {
            _pemicuList = defaultPemicu;
            _isLoadingPemicu = false;
          });
        }
        return;
      }
      setState(() {
        _pemicuList = List<Map<String, dynamic>>.from(result['data'].map((p) => {
          'id': p.id,
          'name': p.nama,
          'kategori': p.kategori ?? 'Lainnya',
          'icon': _getIconForPemicu(p.nama),
          'color': _getColorForKategori(p.kategori ?? ''),
        }));
        _isLoadingPemicu = false;
      });
    } else if (mounted) {
      setState(() {
        _pemicuList = defaultPemicu;
        _isLoadingPemicu = false;
      });
    }
  }

  Color _getColorForKategori(String kategori) {
    switch (kategori) {
      case 'Aktivitas': return const Color(0xFFFFF3E0);
      case 'Gaya Hidup': return const Color(0xFFE8F5E9);
      case 'Lingkungan': return const Color(0xFFE3F2FD);
      case 'Sosial': return const Color(0xFFFCE4EC);
      case 'Kesehatan': return const Color(0xFFF3E5F5);
      case 'Keuangan': return const Color(0xFFFFF8E1);
      default: return const Color(0xFFF5F5F5);
    }
  }

  IconData _getIconForPemicu(String nama) {
    switch (nama.toLowerCase()) {
      case 'work': return Icons.work;
      case 'study': return Icons.school;
      case 'sleep': return Icons.nightlight;
      case 'exercise': return Icons.fitness_center;
      case 'food': return Icons.restaurant;
      case 'caffeine': return Icons.local_cafe;
      case 'social': return Icons.people;
      case 'music': return Icons.music_note;
      case 'nature': return Icons.park;
      case 'screen time': return Icons.important_devices;
      case 'weather': return Icons.cloud;
      case 'stress': return Icons.psychology;
      case 'relationship': return Icons.favorite_border;
      case 'finance': return Icons.payments;
      case 'health': return Icons.medical_services;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCheckedInToday) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFFF8A65), size: 64),
              const SizedBox(height: 16),
              const Text(
                'Kamu sudah check-in hari ini!',
                style: TextStyle(fontSize: 16, color: Color(0xFF3E2F2B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Kembali', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingPemicu) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF9F6),
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
          ),
        ),
      );
    }

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Gimana kabarmu sekarang?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF3E2F2B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ketuk area yang paling mewakili\nenergimu saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6D5B56),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildMoodCard(moodType: MoodType.cemas),
                  _buildMoodCard(moodType: MoodType.bahagia),
                  _buildMoodCard(moodType: MoodType.sedih),
                  _buildMoodCard(moodType: MoodType.tenang),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (selectedMood == null || _isChecking) ? null : () async {
                  setState(() {
                    _isChecking = true;
                  });
                  
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfluenceCheckInPage(
                        selectedMood: selectedMood!,
                        pemicuList: _pemicuList,
                      ),
                    ),
                  );
                  
                  setState(() {
                    _isChecking = false;
                  });
                  
                  if (result == true && mounted) {
                    Navigator.pop(context, selectedMood);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8A65),
                  disabledBackgroundColor: const Color(0xFFFF8A65).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isChecking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Lanjut',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard({
    required MoodType moodType,
  }) {
    final String title = MoodHelper.getMoodEnglishLabel(moodType);
    final String desc = MoodHelper.getMoodDescription(moodType);
    final String energyLabel = MoodHelper.getEnergyLabel(moodType);
    final Color bgColor = MoodHelper.getMoodBgColor(moodType);
    final Color iconBgColor = MoodHelper.getMoodIconColor(moodType);
    final bool isSelected = selectedMood == title;
    final bool isAnySelected = selectedMood != null;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMood = title;
        });
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAnySelected && !isSelected ? 0.3 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: isSelected
                ? Border.all(color: const Color(0xFFFF8A65), width: 3)
                : Border.all(color: Colors.transparent, width: 3),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: iconBgColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBgColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      MoodHelper.getMoodIcon(moodType),
                      color: iconBgColor,
                      size: 24,
                    ),
                  ),
                  Text(
                    energyLabel,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isSelected ? const Color(0xFFFF8A65) : iconBgColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF3E2F2B)
                      : iconBgColor.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.grey[600]
                      : iconBgColor.withValues(alpha: 0.6),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}