import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
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
    if (result['success'] && mounted) {
      setState(() {
        _pemicuList = List<Map<String, dynamic>>.from(result['data'].map((p) => {
          'id': p.id,
          'name': p.nama,
          'kategori': p.kategori ?? '',
          'icon': _getIconForPemicu(p.nama),
          'color': const Color(0xFFFFF3E0),
        }));
        _isLoadingPemicu = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingPemicu = false;
      });
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