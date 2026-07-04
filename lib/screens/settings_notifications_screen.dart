import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() => _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final ApiService _apiService = ApiService();
  
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _friendActivity = false;
  bool _tipsInsights = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _apiService.getSettings();
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final notif = data['notification'] ?? {};
        setState(() {
          _dailyReminder = notif['daily_reminder'] ?? true;
          _weeklyReport = notif['weekly_report'] ?? true;
          _friendActivity = notif['friend_activity'] ?? false;
          _tipsInsights = notif['tips_insights'] ?? true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat pengaturan'),
              backgroundColor: const Color(0xFFA83836),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pengaturan: $e'),
            backgroundColor: const Color(0xFFA83836),
          ),
        );
      }
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    setState(() {
      _isSaving = true;
    });
    
    Map<String, dynamic> settings = {};
    switch (key) {
      case 'daily_reminder':
        settings = {'daily_reminder': value};
        break;
      case 'weekly_report':
        settings = {'weekly_report': value};
        break;
      case 'friend_activity':
        settings = {'friend_activity': value};
        break;
      case 'tips_insights':
        settings = {'tips_insights': value};
        break;
    }
    
    final result = await _apiService.updateNotificationSettings(settings);
    
    setState(() {
      _isSaving = false;
    });
    
    if (!result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan pengaturan'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
      await _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2F2B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E2F2B),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Switch 1
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          secondary: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_active, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Pengingat Harian',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Terima notifikasi setiap hari untuk melakukan check-in',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _dailyReminder,
                          onChanged: (value) {
                            setState(() => _dailyReminder = value);
                            _saveSetting('daily_reminder', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      // Switch 2
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          secondary: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.bar_chart, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Laporan Mingguan',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Ringkasan mood dan aktivitas setiap minggu',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _weeklyReport,
                          onChanged: (value) {
                            setState(() => _weeklyReport = value);
                            _saveSetting('weekly_report', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      // Switch 3
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          secondary: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.people, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Aktivitas Teman',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Notifikasi saat teman melakukan check-in',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _friendActivity,
                          onChanged: (value) {
                            setState(() => _friendActivity = value);
                            _saveSetting('friend_activity', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      // Switch 4
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          secondary: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.lightbulb, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Tips & Wawasan',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Rekomendasi artikel dan tips kesehatan mental',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _tipsInsights,
                          onChanged: (value) {
                            setState(() => _tipsInsights = value);
                            _saveSetting('tips_insights', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Info Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFFF8A65), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Notifikasi akan dikirim sesuai pengaturan di atas. '
                                'Pastikan izin notifikasi diaktifkan di pengaturan perangkat Anda.',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6D5B56), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // ========== INI BAGIAN YANG DIPERBAIKI ==========
                // HAPUS const di depan Positioned
                if (_isSaving)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Menyimpan...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // ================================================
              ],
            ),
    );
  }
}