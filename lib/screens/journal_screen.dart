import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'daily_checkin_screen.dart';
import 'support_screen.dart';
import 'mood_helper.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final ApiService _apiService = ApiService();
  
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _checkins = [];
  List<Map<String, dynamic>> _recentCheckins = [];
  bool _isLoading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

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
      final result = await _apiService.getCheckinHistory();
      
      if (result['success'] && result['data'] != null) {
        final List checkins = result['data'];
        final sortedCheckins = List<Map<String, dynamic>>.from(checkins.map((c) => {
          'id': c.id,
          'mood': c.mood,
          'factors': c.pemicus,
          'journal': c.catatan,
          'date': c.createdAt.toIso8601String(),
          'timestamp': c.createdAt.millisecondsSinceEpoch,
        }))..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        
        setState(() {
          _checkins = sortedCheckins;
          _recentCheckins = sortedCheckins.take(4).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memuat riwayat'),
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
            content: Text('Gagal memuat riwayat: $e'),
            backgroundColor: const Color(0xFFA83836),
          ),
        );
      }
    }
  }

  Color? _getMoodColorForDate(DateTime date) {
    for (var checkin in _checkins) {
      final checkinDate = DateTime.parse(checkin['date']);
      if (checkinDate.year == date.year &&
          checkinDate.month == date.month &&
          checkinDate.day == date.day) {
        final mood = MoodHelper.fromString(checkin['mood']);
        return MoodHelper.getMoodColor(mood);
      }
    }
    return null;
  }

  Map<String, dynamic>? _getCheckinForDate(DateTime date) {
    for (var checkin in _checkins) {
      final checkinDate = DateTime.parse(checkin['date']);
      if (checkinDate.year == date.year &&
          checkinDate.month == date.month &&
          checkinDate.day == date.day) {
        return checkin;
      }
    }
    return null;
  }

  String? _getLatestMood() {
    if (_checkins.isEmpty) return null;
    return _checkins.first['mood'];
  }

  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOffset(int month, int year) {
    final firstDay = DateTime(year, month, 1);
    return (firstDay.weekday - 1) % 7;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  String _getAIInsight() {
    if (_checkins.isEmpty) {
      return 'Mulai check-in dulu ya, nanti AI akan memberikan insight menarik untukmu!';
    }
    
    final moods = _checkins.map((c) => c['mood'].toLowerCase()).toList();
    final moodCount = {};
    for (var mood in moods) {
      moodCount[mood] = (moodCount[mood] ?? 0) + 1;
    }
    
    String dominantMood = '';
    int maxCount = 0;
    moodCount.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });
    
    switch (dominantMood) {
      case 'happy':
        return 'Kamu cenderung merasa bahagia! Pertahankan energi positifmu. Coba bagikan kebahagiaanmu dengan teman-teman.';
      case 'anxious':
        return 'Kamu sering merasa cemas. Yuk coba fitur meditasi atau latihan pernapasan untuk menenangkan pikiran.';
      case 'calm':
        return 'Moodmu sangat stabil dan tenang. Kamu hebat dalam mengelola emosi! Terus pertahankan.';
      case 'sad':
        return 'Kamu sering merasa sedih. Ingat, tidak apa-apa merasa seperti ini. Coba tulis jurnal atau bicara dengan teman.';
      default:
        return 'Terus pantau moodmu setiap hari. Konsistensi adalah kunci untuk memahami dirimu lebih baik!';
    }
  }

  void _showAIInsightDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Color(0xFFFF8A65), size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Insight',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFFFF8A65), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getAIInsight(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF3E2F2B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup', style: TextStyle(color: Color(0xFFFF8A65))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<AuthProvider>().isPremium;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        
                        if (isPremium) _buildAIInsightBanner(),
                        if (isPremium) const SizedBox(height: 24),
                        
                        _buildCalendarSection(),
                        const SizedBox(height: 24),
                        
                        _buildDynamicBanner(),
                        const SizedBox(height: 24),
                        
                        _buildRecentHistorySection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
            SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightBanner() {
    return GestureDetector(
      onTap: _showAIInsightDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insight',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dapatkan analisis mood personalmu',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final daysInMonth = _getDaysInMonth(_selectedMonth, _selectedYear);
    final firstDayOffset = _getFirstDayOffset(_selectedMonth, _selectedYear);
    final now = DateTime.now();
    final isCurrentMonth = now.year == _selectedYear && now.month == _selectedMonth;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KALENDER MOOD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Color(0xFF3E2F2B),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF6D5B56)),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 1) {
                        _selectedMonth = 12;
                        _selectedYear--;
                      } else {
                        _selectedMonth--;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_getMonthName(_selectedMonth)} $_selectedYear',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFF8A65),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF6D5B56)),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 12) {
                        _selectedMonth = 1;
                        _selectedYear++;
                      } else {
                        _selectedMonth++;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _DayLabel('S'),
                  _DayLabel('S'),
                  _DayLabel('R'),
                  _DayLabel('K'),
                  _DayLabel('J'),
                  _DayLabel('S'),
                  _DayLabel('M'),
                ],
              ),
              const SizedBox(height: 16),
              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final dayNumber = index - firstDayOffset + 1;
                  final isValidDay = dayNumber >= 1 && dayNumber <= daysInMonth;
                  
                  if (!isValidDay) {
                    return const SizedBox();
                  }
                  
                  final date = DateTime(_selectedYear, _selectedMonth, dayNumber);
                  final isToday = isCurrentMonth && _isToday(date);
                  final isSelected = _selectedDate.day == dayNumber &&
                      _selectedDate.month == _selectedMonth &&
                      _selectedDate.year == _selectedYear;
                  final moodColor = _getMoodColorForDate(date);
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: moodColor ?? Colors.transparent,
                        border: isSelected
                            ? Border.all(color: const Color(0xFFFF8A65), width: 2)
                            : isToday
                                ? Border.all(color: const Color(0xFFFF8A65).withValues(alpha: 0.5), width: 1.5)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: moodColor != null
                                ? Colors.white
                                : (isToday ? const Color(0xFFFF8A65) : const Color(0xFF6D5B56).withValues(alpha: 0.6)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicBanner() {
    final latestMood = _getLatestMood();
    
    if (latestMood == null) {
      return _buildDefaultBanner();
    }
    
    switch (latestMood.toLowerCase()) {
      case 'happy':
        return _buildHappyBanner();
      case 'calm':
      case 'tenang':
        return _buildCalmBanner();
      case 'sad':
      case 'sedih':
        return _buildSadBanner();
      case 'anxious':
      case 'cemas':
        return _buildAnxiousBanner();
      default:
        return _buildDefaultBanner();
    }
  }

  Widget _buildDefaultBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mulai Petualangan\nMoodmu!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lacak perasaanmu setiap hari.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHappyBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Positif Terdeteksi!',
            style: TextStyle(
              color: Color(0xFF3E2F2B),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Melihat riwayat moodmu, kami mendeteksi kamu merasa bahagia hari ini. Pertahankan energi positifmu!',
            style: TextStyle(
              color: const Color(0xFF3E2F2B).withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF66BB6A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moodmu Stabil dan Tenang!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat moodmu menunjukkan kestabilan dan ketenangan yang patut diapresiasi. Lanjutkan kebiasaan baikmu!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSadBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF42A5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Butuh Teman Cerita?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Melihat riwayat moodmu, kami mendeteksi kamu merasa sedih akhir-akhir ini. Ada banyak cara untuk merasa lebih baik.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Jelajahi Dukungan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF42A5F5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnxiousBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF5350).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kamu Tidak Sendirian!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Melihat riwayat moodmu, kami mendeteksi kamu merasa cemas belakangan ini. Yuk cari tahu cara mengelolanya.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Jelajahi Dukungan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF5350),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistorySection() {
    if (_recentCheckins.isEmpty) {
      return _buildEmptyHistory();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT CHECK-IN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 16),
        ..._recentCheckins.map((checkin) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCheckinCard(checkin),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCheckinCard(Map<String, dynamic> checkin) {
    final moodType = MoodHelper.fromString(checkin['mood']);
    final factors = List<String>.from(checkin['factors']);
    final journal = checkin['journal'] ?? '';
    final date = DateTime.parse(checkin['date']);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: MoodHelper.getMoodBgColor(moodType),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    MoodHelper.getMoodIcon(moodType),
                    color: MoodHelper.getMoodIconColor(moodType),
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
                      MoodHelper.getMoodLabel(moodType),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MoodHelper.getMoodIconColor(moodType),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6D5B56),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          const SizedBox(height: 16),
          
          if (factors.isNotEmpty) ...[
            const Text(
              'FAKTOR YANG MEMENGARUHI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF6D5B56),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: factors.map((factor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    factor,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          if (journal.isNotEmpty) ...[
            const Text(
              'CATATAN JURNAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color(0xFF6D5B56),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                journal,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF3E2F2B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RIWAYAT CHECK-IN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  size: 40,
                  color: Color(0xFFC3ADA7),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Riwayat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3E2F2B),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Riwayat check-in kamu akan muncul di sini setelah kamu mulai mencatat mood harianmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6D5B56),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  String _formatDateTime(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DayLabel extends StatelessWidget {
  final String label;
  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6D5B56),
      ),
    );
  }
}