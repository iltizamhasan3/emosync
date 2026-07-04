import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  final ApiService _apiService = ApiService();
  
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _showMoodHistory = true;
  bool _allowFriendRequests = true;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
  }

  Future<void> _loadPrivacySettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final result = await _apiService.getSettings();
      
      if (result['success'] && result['data'] != null) {
        final data = result['data'];
        final privacy = data['privacy'] ?? {};
        setState(() {
          _showOnlineStatus = privacy['show_active'] ?? true;
          _showLastSeen = privacy['show_last_seen'] ?? true;
          _showMoodHistory = privacy['show_mood'] ?? true;
          _allowFriendRequests = privacy['allow_requests'] ?? true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat pengaturan privasi'),
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
            content: Text('Gagal memuat pengaturan privasi: $e'),
            backgroundColor: const Color(0xFFA83836),
          ),
        );
      }
    }
  }

  Future<void> _savePrivacySetting(String key, bool value) async {
    setState(() {
      _isSaving = true;
    });
    
    final Map<String, dynamic> settings = {key: value};
    final result = await _apiService.updatePrivacySettings(settings);
    
    setState(() {
      _isSaving = false;
    });
    
    if (!result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal menyimpan pengaturan privasi'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
      await _loadPrivacySettings();
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
          'Privasi',
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
                      
                      // Header section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: const Text(
                          'Pengaturan Visibilitas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8A65),
                          ),
                        ),
                      ),
                      
                      // Switch 1: Online Status
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
                            child: const Icon(Icons.circle, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Status Online',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Tunjukkan status online Anda kepada teman',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _showOnlineStatus,
                          onChanged: (value) {
                            setState(() => _showOnlineStatus = value);
                            _savePrivacySetting('show_active', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      // Switch 2: Last Seen
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
                            child: const Icon(Icons.access_time, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Terakhir Dilihat',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Tampilkan waktu terakhir Anda aktif',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _showLastSeen,
                          onChanged: (value) {
                            setState(() => _showLastSeen = value);
                            _savePrivacySetting('show_last_seen', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Header section 2
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: const Text(
                          'Bagikan Data',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF8A65),
                          ),
                        ),
                      ),
                      
                      // Switch 3: Mood History
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
                            child: const Icon(Icons.mood, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Riwayat Mood',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Izinkan teman melihat riwayat mood Anda',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _showMoodHistory,
                          onChanged: (value) {
                            setState(() => _showMoodHistory = value);
                            _savePrivacySetting('show_mood', value);
                          },
                          activeColor: const Color(0xFFFF8A65),
                        ),
                      ),
                      
                      // Switch 4: Friend Requests
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
                            child: const Icon(Icons.person_add, color: Color(0xFFFF8A65), size: 22),
                          ),
                          title: const Text(
                            'Permintaan Pertemanan',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF3E2F2B)),
                          ),
                          subtitle: const Text(
                            'Izinkan orang lain mengirim permintaan teman',
                            style: TextStyle(fontSize: 11, color: Color(0xFF6D5B56)),
                          ),
                          value: _allowFriendRequests,
                          onChanged: (value) {
                            setState(() => _allowFriendRequests = value);
                            _savePrivacySetting('allow_requests', value);
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
                            const Icon(Icons.security, color: Color(0xFFFF8A65), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pengaturan privasi ini hanya mengontrol visibilitas data Anda '
                                'kepada pengguna lain. Data Anda tetap aman dan tidak akan dibagikan '
                                'kepada pihak ketiga.',
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
                
                // Saving Indicator (SAMA seperti Notifikasi, const sudah dihapus)
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
              ],
            ),
    );
  }
}