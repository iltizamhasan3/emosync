import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'daily_checkin_screen.dart';
import 'journal_screen.dart';
import 'content_screen.dart';
import 'friend_screen.dart';
import 'profile_screen.dart';
import 'mood_helper.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  
  int _currentIndex = 0;
  bool _hasCheckedIn = false;
  MoodType _todayMood = MoodType.netral;
  String _userName = '';
  int _streak = 0;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _weeklyData = [];
  Map<String, int> _moodDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _userName = authProvider.currentUser?.name ?? 'Pengguna';
      
      // Ambil dashboard data dari API
      final dashboardResult = await _apiService.getDashboard();
      
      if (dashboardResult['success']) {
        final dashboard = dashboardResult['data'];
        setState(() {
          _streak = dashboard.streak;
          _moodDistribution = dashboard.moodDistribution;
        });
        
        // Proses weekly checkins untuk chart - URUTAN DARI SENIN KE MINGGU
        final today = DateTime.now();
        final List<Map<String, dynamic>> weeklyDataTemp = [];
        
        // Cari hari Senin minggu ini
        final daysSinceMonday = today.weekday - 1;
        final monday = DateTime(today.year, today.month, today.day - daysSinceMonday);
        
        // Buat mapping checkin berdasarkan tanggal
        final Map<String, dynamic> checkinMap = {};
        for (var checkin in dashboard.weeklyCheckins) {
          final dateKey = '${checkin.createdAt.year}-${checkin.createdAt.month}-${checkin.createdAt.day}';
          checkinMap[dateKey] = checkin;
        }
        
        // Looping dari Senin ke Minggu (7 hari)
        for (int i = 0; i < 7; i++) {
          final date = DateTime(monday.year, monday.month, monday.day + i);
          final dayName = _getDayName(i + 1); // i=0 -> Senin, i=1 -> Selasa, dst
          final dateKey = '${date.year}-${date.month}-${date.day}';
          
          final checkin = checkinMap[dateKey];
          final isToday = date.year == today.year && 
                          date.month == today.month && 
                          date.day == today.day;
          
          if (checkin != null) {
            weeklyDataTemp.add({
              'day': dayName,
              'date': date,
              'mood': MoodHelper.fromString(checkin.mood),
              'hasChecked': true,
              'isToday': isToday,
            });
          } else {
            weeklyDataTemp.add({
              'day': dayName,
              'date': date,
              'mood': MoodType.netral,
              'hasChecked': false,
              'isToday': isToday,
            });
          }
        }
        
        setState(() {
          _weeklyData = weeklyDataTemp;
        });
      }
      
      // Cek apakah sudah check-in hari ini dan ambil mood terbaru
      final todayCheckinResult = await _apiService.getCheckinHistory();
      if (todayCheckinResult['success']) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final todayEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);
        
        final todayCheckins = (todayCheckinResult['data'] as List).where((checkin) {
          return checkin.createdAt.isAfter(todayStart) && 
                 checkin.createdAt.isBefore(todayEnd);
        }).toList();
        
        final hasChecked = todayCheckins.isNotEmpty;
        
        setState(() {
          _hasCheckedIn = hasChecked;
        });
        
        if (hasChecked && todayCheckins.isNotEmpty) {
          // Ambil check-in terbaru hari ini
          final latestCheckin = todayCheckins.first;
          setState(() {
            _todayMood = MoodHelper.fromString(latestCheckin.mood);
          });
        }
      }
      
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDayName(int weekday) {
    // weekday: 1=Senin, 2=Selasa, 3=Rabu, 4=Kamis, 5=Jumat, 6=Sabtu, 7=Minggu
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    await _loadData();
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
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFFFF8A65),
              child: _buildBody(),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const JournalPage();
      case 2:
        return const ContentPage();
      case 3:
        return const FriendPage();
      case 4:
        return const ProfilePage();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                _hasCheckedIn
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hebat, $_userName!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Color(0xFF3E2F2B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kamu sudah menyelaraskan dirimu hari ini.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6D5B56),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang, $_userName!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Color(0xFF3E2F2B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Ambil momen sejenak untuk mengenali perasaanmu.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6D5B56),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                _hasCheckedIn ? _buildFinishedBanner() : _buildCheckInBanner(),
                const SizedBox(height: 32),
                
                if (_weeklyData.isNotEmpty) ...[
                  _buildWeeklyHistorySection(),
                  const SizedBox(height: 24),
                ],
                
                Row(
                  children: [
                    Expanded(child: _buildStreakCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildMoodDominantCard()),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildEmotionChart(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
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

  Widget _buildCheckInBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A65), Color(0xFFFDAE96)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.2,
                child: const Icon(
                  Icons.sentiment_neutral,
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BELUM CHECK-IN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bagaimana perasaanmu\nhari ini?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyCheckInPage(),
                      ),
                    );
                    if (result != null) {
                      await _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF8A65),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Mulai Check-in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedBanner() {
    // Ambil label mood yang benar dari _todayMood
    final moodLabel = MoodHelper.getMoodLabel(_todayMood);
    final moodEmoji = MoodHelper.getMoodEmoji(_todayMood);
    
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF8A65), Color(0xFFFDAE96)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Transform.rotate(
                angle: 0.2,
                child: Icon(
                  MoodHelper.getMoodIcon(_todayMood),
                  size: 140,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CHECK-IN SELESAI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Perasaanmu hari ini:\n$moodLabel $moodEmoji',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Refleksikan Moodmu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHistorySection() {
    final checkedData = _weeklyData.where((item) => item['hasChecked'] == true).toList();
    if (checkedData.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'RIWAYAT MINGGUAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF6D5B56),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF8A65),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _weeklyData.map((data) {
              final day = data['day'] as String;
              final hasChecked = data['hasChecked'] as bool;
              final mood = data['mood'] as MoodType;
              final isToday = data['isToday'] as bool;
              
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? const Color(0xFFFF8A65) : const Color(0xFF6D5B56).withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasChecked 
                            ? MoodHelper.getMoodColor(mood) 
                            : Colors.transparent,
                        border: Border.all(
                          color: isToday
                              ? const Color(0xFFFF8A65)
                              : const Color(0xFFC3ADA7).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: hasChecked
                            ? const Icon(Icons.check, color: Colors.white, size: 24)
                            : isToday
                                ? const Icon(Icons.add, color: Color(0xFFFF8A65), size: 20)
                                : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFFF8A65),
            size: 24,
          ),
          const SizedBox(height: 16),
          Text(
            '$_streak ${_streak == 1 ? 'Hari' : 'Hari'}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3E2F2B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _streak > 0
                ? 'Streak $_streak hari berturut-turut!'
                : 'Check-in hari ini untuk memulai streak!',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6D5B56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDominantCard() {
    String dominantMood = 'Belum';
    String subText = 'Lakukan check-in';
    
    if (_moodDistribution.isNotEmpty) {
      var sortedEntries = _moodDistribution.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      if (sortedEntries.isNotEmpty) {
        dominantMood = _getMoodLabelInIndonesian(sortedEntries.first.key);
        subText = 'Dari ${sortedEntries.first.value} kali check-in';
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOOD DOMINAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF6D5B56),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dominantMood,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3E2F2B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6D5B56),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodLabelInIndonesian(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return 'Bahagia';
      case 'calm': return 'Tenang';
      case 'anxious': return 'Cemas';
      case 'sad': return 'Sedih';
      default: return mood;
    }
  }

  Widget _buildEmotionChart() {
    final hasAnyData = _weeklyData.any((item) => item['hasChecked'] == true);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'POLA EMOSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFF6D5B56),
                ),
              ),
              const Text(
                '7 HARI TERAKHIR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6D5B56),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyData.map((data) {
                final hasChecked = data['hasChecked'] as bool;
                final mood = data['mood'] as MoodType;
                final day = data['day'] as String;
                
                if (!hasChecked) {
                  return _buildEmptyBar(day);
                }
                return _buildChartBar(
                  day,
                  MoodHelper.getMoodHeight(mood),
                  MoodHelper.getMoodColor(mood),
                );
              }).toList(),
            ),
          ),
          if (!hasAnyData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Lakukan check-in untuk melihat pola emosimu',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF6D5B56).withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyBar(String day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFFC3ADA7).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFFC3ADA7),
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(String day, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6D5B56),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6).withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFFFF8A65),
        unselectedItemColor: const Color(0xFF6D5B56).withValues(alpha: 0.5),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'JOURNAL',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'CONTENT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'FRIEND',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'PROFILE',
          ),
        ],
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}