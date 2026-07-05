import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'digital_detox_screen.dart';
import 'hydration_screen.dart';
import 'meditation_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    
                    _buildQuickActionsSection(context),
                    const SizedBox(height: 32),
                    
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
            'Jelajahi Dukungan',
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFEF5350).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tenangkan Dirimu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEF5350),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kami di sini untuk membantumu merasa lebih baik. Pilih salah satu aktivitas di bawah ini atau hubungi bantuan jika diperlukan.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6D5B56),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AKSI CEPAT UNTUK KETENANGAN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF6D5B56),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildActionCard(
              context: context,
              icon: Icons.self_improvement,
              title: 'Meditasi Singkat',
              description: 'Sesi 5 menit untuk memfokuskan pikiran kembali ke masa kini.',
              color: const Color(0xFF66BB6A),
              screen: const MeditationScreen(),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.air,
              title: 'Latihan Pernapasan',
              description: 'Teknik pernapasan kotak 4-4-4 untuk menurunkan detak jantung.',
              color: const Color(0xFF42A5F5),
              screen: const BreathingScreen(),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.phonelink_off,
              title: 'Jauh dari Layar 10 Menit',
              description: 'Istirahatkan matamu. Lihatlah ke luar jendela atau berjalan sejenak.',
              color: const Color(0xFFFFD54F),
              screen: const DigitalDetoxScreen(),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context: context,
              icon: Icons.water_drop,
              title: 'Minum Air Putih',
              description: 'Hidrasi dapat membantu fungsi otak dan menurunkan tingkat stres.',
              color: const Color(0xFF42A5F5),
              screen: const HydrationScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFC3ADA7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }


}