import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

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
          'Bantuan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E2F2B),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // FAQ Section
            _buildSectionHeader('PERTANYAAN UMUM'),
            
            _buildFaqCard(
              question: 'Bagaimana cara melakukan check-in?',
              answer: 'Tekan tombol "Mulai Check-in" di halaman Home, pilih mood yang sesuai, lalu pilih faktor yang memengaruhi mood Anda.',
              icon: Icons.question_answer,
            ),
            _buildFaqCard(
              question: 'Apa itu streak?',
              answer: 'Streak adalah jumlah hari berturut-turut Anda melakukan check-in. Semakin panjang streak, semakin baik konsistensi Anda dalam memantau kesehatan mental.',
              icon: Icons.local_fire_department,
            ),
            _buildFaqCard(
              question: 'Bagaimana cara menambah teman?',
              answer: 'Buka halaman Friend, klik tombol "Tambah Teman Baru", masukkan username teman Anda, dan kirim permintaan.',
              icon: Icons.person_add,
            ),
            _buildFaqCard(
              question: 'Apakah data saya aman?',
              answer: 'Ya, semua data Anda dienkripsi dan hanya dapat diakses oleh Anda. Kami tidak akan membagikan data Anda dengan pihak ketiga tanpa izin.',
              icon: Icons.security,
            ),
            
            const SizedBox(height: 16),
            
            // App Info Section
            _buildSectionHeader('TENTANG APLIKASI'),
            
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bubble_chart, color: Color(0xFFFF8A65), size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'EmoSync',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3E2F2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Synchronize Your Mind and Body',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6D5B56),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Dibuat di', 'Indonesia'),
                  _buildInfoRow('Developer', 'Tim EmoSync'),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF6D5B56),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard({
    required String question,
    required String answer,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E0E0).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFFFF8A65), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E2F2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6D5B56),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6D5B56),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3E2F2B),
            ),
          ),
        ],
      ),
    );
  }
}