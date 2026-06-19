import 'package:flutter/material.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  bool _isBreathing = false;
  int _currentPhase = 0;
  int _cycleCount = 0;
  final List<String> _phases = ['Tarik', 'Tahan', 'Hembus'];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextPhase();
        }
      });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _currentPhase = 0;
      _cycleCount = 0;
    });
    _breathingController.forward(from: 0.0);
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
    });
    _breathingController.stop();
  }

  void _nextPhase() {
    setState(() {
      if (_currentPhase == 2) {
        _currentPhase = 0;
        _cycleCount++;
        if (_cycleCount >= 3) {
          _isBreathing = false;
          _breathingController.stop();
          _cycleCount = 0;
          return;
        }
      } else {
        _currentPhase++;
      }
    });
    _breathingController.forward(from: 0.0);
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTitleSection(),
                      const SizedBox(height: 40),
                      _buildBreathingCircle(),
                      const SizedBox(height: 32),
                      _buildPhaseIndicators(),
                      const SizedBox(height: 32),
                      _buildInstructions(),
                      const SizedBox(height: 24),
                      _buildActionButton(),
                      const SizedBox(height: 32),
                      const Text(
                        'Sesi Disarankan: 3 Menit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF6D5B56),
                        ),
                      ),
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
            'Latihan Pernapasan',
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

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          'Teknik Kotak 4-4-4',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF3E2F2B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Metode sederhana untuk menenangkan sistem saraf dan mengurangi stres dalam hitungan menit.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6D5B56),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingCircle() {
    final scale = _isBreathing ? Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    ) : const AlwaysStoppedAnimation(1.0);

    return Center(
      child: AnimatedBuilder(
        animation: _breathingController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isBreathing ? scale.value : 1.0,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.air,
                      color: Color(0xFF42A5F5),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isBreathing ? _phases[_currentPhase] : 'Mulai',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF42A5F5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseIndicator('Tarik Nafas', '4', _currentPhase == 0),
        const SizedBox(width: 16),
        _buildPhaseIndicator('Tahan', '4', _currentPhase == 1),
        const SizedBox(width: 16),
        _buildPhaseIndicator('Hembus', '4', _currentPhase == 2),
      ],
    );
  }

  Widget _buildPhaseIndicator(String label, String duration, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF42A5F5) : const Color(0xFFE0E0E0).withValues(alpha: 0.5),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            duration,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isActive ? const Color(0xFF42A5F5) : const Color(0xFF6D5B56),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isActive ? const Color(0xFF42A5F5) : const Color(0xFF6D5B56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
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
          _buildInstructionItem('1', 'Duduk atau berbaring dengan nyaman. Letakkan tanganmu di perut.'),
          const SizedBox(height: 16),
          _buildInstructionItem('2', 'Ikuti ritme lingkaran: Tarik melalui hidung, tahan sejenak, lalu hembuskan lewat mulut perlahan.'),
          const SizedBox(height: 16),
          _buildInstructionItem('3', 'Fokuskan pikiran hanya pada aliran udara yang masuk dan keluar.'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF42A5F5).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF42A5F5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6D5B56),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isBreathing ? _stopBreathing : _startBreathing,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42A5F5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_isBreathing ? Icons.stop : Icons.play_arrow, size: 20),
            const SizedBox(width: 8),
            Text(
              _isBreathing ? 'Hentikan Latihan' : 'Mulai Latihan',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}