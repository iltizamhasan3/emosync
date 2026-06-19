import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HydrationScreen extends StatefulWidget {
  const HydrationScreen({super.key});

  @override
  State<HydrationScreen> createState() => _HydrationScreenState();
}

class _HydrationScreenState extends State<HydrationScreen> {
  int _glassesCount = 0;
  final int _dailyTarget = 8;
  String _lastDate = '';

  @override
  void initState() {
    super.initState();
    _loadHydrationData();
  }

  Future<void> _loadHydrationData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final lastDate = prefs.getString('hydration_last_date') ?? '';
    final savedCount = prefs.getInt('hydration_count') ?? 0;

    setState(() {
      if (lastDate != today) {
        _glassesCount = 0;
        _lastDate = today;
      } else {
        _glassesCount = savedCount;
        _lastDate = lastDate;
      }
    });
  }

  Future<void> _saveHydrationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hydration_count', _glassesCount);
    await prefs.setString('hydration_last_date', _lastDate);
  }

  void _drinkWater() {
    setState(() {
      if (_glassesCount < _dailyTarget) {
        _glassesCount++;
        _saveHydrationData();
      }
    });
  }

  void _skip(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_glassesCount / _dailyTarget) * 100;
    final isComplete = _glassesCount >= _dailyTarget;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      _buildWaterIllustration(),
                      const SizedBox(height: 32),
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      _buildProgressSection(percentage, isComplete),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF6D5B56),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Minum Air Putih',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: Color(0xFF3E2F2B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterIllustration() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: (_glassesCount / _dailyTarget).clamp(0.0, 1.0) * 180,
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF42A5F5).withValues(alpha: 0.8),
              size: 48,
            ),
          ),
          Positioned(
            bottom: -10,
            left: -15,
            child: Icon(
              Icons.water_drop,
              color: const Color(0xFF42A5F5).withValues(alpha: 0.4),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          'Waktunya Hidrasi!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF3E2F2B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Minum air putih membantu otakmu bekerja lebih tajam, menjaga energimu tetap stabil, dan membantu tubuhmu membuang racun. Segelas air sekarang dapat memperbaiki suasana hatimu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6D5B56),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(double percentage, bool isComplete) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Asupan Hari Ini',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF6D5B56),
                ),
              ),
              Text(
                '$_glassesCount / $_dailyTarget Gelas',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF42A5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (index) {
              return Icon(
                Icons.water_drop,
                color: index < _glassesCount
                    ? const Color(0xFF42A5F5)
                    : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
                size: 28,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            isComplete
                ? 'Selamat! Kamu sudah mencapai target harianmu! 🎉'
                : 'Kamu sudah mencapai ${percentage.toInt()}% dari target harianmu. Ayo sedikit lagi!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isComplete ? const Color(0xFF4CAF50) : const Color(0xFF6D5B56),
              fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isComplete = _glassesCount >= _dailyTarget;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: isComplete ? null : _drinkWater,
            icon: Icon(Icons.local_drink, size: 24, color: isComplete ? Colors.white70 : Colors.white),
            label: Text(
              isComplete ? 'Target Tercapai!' : 'Minum Sekarang',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? Colors.grey : const Color(0xFF42A5F5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _skip(context),
          child: const Text(
            'Nanti Saja',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6D5B56),
            ),
          ),
        ),
      ],
    );
  }
}