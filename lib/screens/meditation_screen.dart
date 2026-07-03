import 'dart:async';
import 'package:flutter/material.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  Timer? _timer;
  int _remainingSeconds = 5 * 60;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5 * 60),
    );
  }

  @override
  void dispose() {
    _timerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startMeditation() {
    setState(() {
      _isActive = true;
    });
    _timerController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _stopMeditation();
        }
      });
    });
  }

  void _stopMeditation() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
    });
  }

  void _resetMeditation() {
    _stopMeditation();
    _timerController.reset();
    setState(() {
      _remainingSeconds = 5 * 60;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildMeditationCircle(),
                      const SizedBox(height: 24),
                      const Text(
                        'Temukan Ketenangan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Color(0xFF3E2F2B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Luangkan waktu sejenak untuk menenangkan pikiran dan raga.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF6D5B56),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTechniquesSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                      const SizedBox(height: 32),
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
            'Meditasi Singkat',
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

  Widget _buildMeditationCircle() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF66BB6A).withValues(alpha: 0.2),
                width: 10,
              ),
            ),
          ),
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: _isActive ? _remainingSeconds / (5 * 60) : 1,
              strokeWidth: 10,
              backgroundColor: const Color(0xFF66BB6A).withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF66BB6A)),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(_remainingSeconds),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3E2F2B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '5 Menit',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF6D5B56),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesSection() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'TEKNIK REKOMENDASI',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF6D5B56),
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
          ],
        ),
        const SizedBox(height: 12),
        _buildTechniqueItem(
          Icons.air,
          'Fokus pada Napas',
          'Ikuti ritme napas yang masuk dan keluar',
        ),
        const SizedBox(height: 8),
        _buildTechniqueItem(
          Icons.accessibility_new,
          'Pindai Tubuh',
          'Rasakan sensasi dari ujung kaki ke kepala',
        ),
        const SizedBox(height: 8),
        _buildTechniqueItem(
          Icons.lightbulb,
          'Visualisasi Positif',
          'Bayangkan tempat paling damai bagimu',
        ),
      ],
    );
  }

  Widget _buildTechniqueItem(IconData icon, String title, String subtitle) {
    return Container(
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF66BB6A), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2F2B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6D5B56),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isActive ? _stopMeditation : _startMeditation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF66BB6A), // Hijau
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isActive ? Icons.stop : Icons.play_arrow, size: 18),
                const SizedBox(width: 8),
                Text(
                  _isActive ? 'Hentikan' : 'Mulai Meditasi',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isActive)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: _resetMeditation,
              child: const Text(
                'Reset Timer',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6D5B56),
                ),
              ),
            ),
          ),
      ],
    );
  }
}