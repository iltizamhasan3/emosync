import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'premium_plan_screen.dart';
import 'settings_notifications_screen.dart';
import 'settings_privacy_screen.dart';
import 'settings_help_screen.dart';
import 'edit_profile_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  
  String _userName = '';
  String _userUsername = '';
  String _userEmail = '';
  String _userAvatar = 'male';
  int _checkinCount = 0;
  int _friendCount = 0;
  int _streak = 0;
  bool _isPremium = false;
  String _currentPlan = 'monthly';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final userName = await LocalStorageService.getUserName();
    final userUsername = await LocalStorageService.getUserUsername();
    final userEmail = await LocalStorageService.getUserEmail();
    
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool('is_premium') ?? false;
    final currentPlan = prefs.getString('premium_plan') ?? '';
    final userAvatar = prefs.getString('user_avatar') ?? 'male';
    
    try {
      // Jalankan 4 API call secara parallel
      final results = await Future.wait([
        _apiService.getProfile(),
        _apiService.getDashboard(),
        _apiService.getCheckinHistory(),
        _apiService.getFriends(),
      ]);
      
      final profileResult = results[0];
      final dashboardResult = results[1];
      final checkinsResult = results[2];
      final friendsResult = results[3];

      if (profileResult['success'] && profileResult['data'] != null) {
        final data = profileResult['data'];
        _userAvatar = data['avatar'] ?? 'male';
        await prefs.setString('user_avatar', _userAvatar);
      } else {
        _userAvatar = userAvatar;
      }
      
      if (dashboardResult['success']) {
        final dashboard = dashboardResult['data'];
        _streak = dashboard.streak;
      }
      
      if (checkinsResult['success']) {
        _checkinCount = checkinsResult['data'].length;
      }
      
      if (friendsResult['success']) {
        _friendCount = friendsResult['data'].length;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading profile data: $e');
    }
    
    setState(() {
      _userName = userName ?? 'Pengguna';
      _userUsername = userUsername ?? '@pengguna';
      _userEmail = userEmail ?? 'user@example.com';
      _isPremium = isPremium;
      _currentPlan = currentPlan.isEmpty ? 'monthly' : currentPlan;
      _isLoading = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6D5B56))),
          ),
          TextButton(
            onPressed: () async {
              await _apiService.logout();
              await LocalStorageService.clearUser();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Color(0xFFA83836))),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    ).then((_) {
      _loadUserData();
    });
  }

  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumPlansScreen()),
    ).then((_) {
      _loadUserData();
    });
  }

  // ============ MANAGE SUBSCRIPTION ============
  void _showManageSubscriptionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Manage Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2F2B),
                  ),
                ),
              ),
              const Divider(),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF8A65).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: Color(0xFFFF8A65), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Paket Saat Ini',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6D5B56),
                              ),
                            ),
                            Text(
                              _currentPlan == 'yearly' ? 'Yearly Access' : 'Monthly Access',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8A65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              ListTile(
                leading: const Icon(Icons.cancel, color: Color(0xFFA83836)),
                title: const Text('Batalkan Langganan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFA83836))),
                subtitle: const Text('Akses premium akan berakhir setelah periode berjalan'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmCancelSubscription();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Color(0xFFFF8A65)),
                title: const Text('Ganti Paket', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pindah ke paket Yearly atau Monthly'),
                onTap: () {
                  Navigator.pop(context);
                  _changePlan();
                },
              ),
              
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmCancelSubscription() async {
    String planName = _currentPlan == 'yearly' ? 'Yearly' : 'Monthly';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Langganan'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan langganan $planName?\n\nAkses premium Anda akan berakhir pada periode berjalan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak', style: TextStyle(color: Color(0xFF6D5B56))),
          ),
          TextButton(
            onPressed: () async {
              final result = await _apiService.cancelSubscription();
              if (result['success']) {
                await _loadUserData();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Langganan premium telah dibatalkan'),
                      backgroundColor: Color(0xFFFF8A65),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Color(0xFFA83836))),
          ),
        ],
      ),
    );
  }

  Future<void> _changePlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumPlansScreen()),
    );
    if (result == true) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildProfileSection(),
                          const SizedBox(height: 24),
                          _buildStatsSection(),
                          const SizedBox(height: 24),
                          _buildPremiumBanner(),
                          const SizedBox(height: 24),
                          _buildMenuSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.bubble_chart,
            color: Color(0xFFFF8A65),
            size: 28,
          ),
          SizedBox(width: 8),
          Text(
            'EmoSync',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFFFF8A65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _userAvatar == 'male' 
                    ? const Color(0xFFE3F2FD)  // Biru sangat muda
                    : const Color(0xFFFCE4EC), // Pink sangat muda
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _userAvatar == 'male' ? Icons.person : Icons.person_outline,
                  color: _userAvatar == 'male' 
                      ? const Color(0xFF2196F3)  // Biru sedang
                      : const Color(0xFFE91E63), // Pink sedang
                  size: 40,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _navigateToEditProfile,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A65),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A65).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
            if (_isPremium)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8A65),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF3E2F2B),
              ),
            ),
            if (_isPremium)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF8A65)),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFF8A65),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _userUsername,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFF8A65),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _userEmail,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6D5B56),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatCard(
          value: '$_checkinCount',
          label: 'CHECK-IN',
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          value: '$_friendCount',
          label: 'TEMAN',
          icon: Icons.people_outline,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          value: '$_streak',
          label: 'STREAK',
          icon: Icons.local_fire_department,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFF8A65), size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3E2F2B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Color(0xFF6D5B56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    if (_isPremium) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF8A65).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFFFF8A65), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Premium Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF8A65),
                    ),
                  ),
                  Text(
                    _currentPlan == 'yearly' ? 'Paket Yearly • Aktif' : 'Paket Monthly • Aktif',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _showManageSubscriptionDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return GestureDetector(
      onTap: _navigateToPremium,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8A65), Color(0xFFFDAE96)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to EmoSync+',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Akses semua konten & fitur eksklusif',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'PENGATURAN AKUN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF6D5B56),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Notifikasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsSettingsPage()),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Privasi',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacySettingsPage()),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Bantuan',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpCenterPage()),
            );
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Keluar',
          isLogout: true,
          onTap: _logout,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
    bool isDemo = false,
    bool isPremium = false,
  }) {
    Color bgColor = isLogout 
        ? const Color(0xFFA83836).withValues(alpha: 0.1)
        : const Color(0xFFFF8A65).withValues(alpha: 0.1);
    
    Color iconColor = isLogout 
        ? const Color(0xFFA83836)
        : const Color(0xFFFF8A65);
    
    Color textColor = isLogout 
        ? const Color(0xFFA83836)
        : const Color(0xFF3E2F2B);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout ? iconColor.withValues(alpha: 0.5) : const Color(0xFFC3ADA7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}