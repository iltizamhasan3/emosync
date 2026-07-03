import 'package:flutter/material.dart';
import 'login_screen.dart';

// Model untuk onboarding content
class OnboardingContent {
  final String title;
  final String subtitle;
  final String type;
  
  OnboardingContent({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}

final List<OnboardingContent> onboardingContents = [
  OnboardingContent(
    title: 'Kenali Dirimu',
    subtitle: 'Pantau kondisi mental harianmu melalui 4 kuadran rasa secara presisi.',
    type: 'quadrant',
  ),
  OnboardingContent(
    title: 'Cari Penyebabnya',
    subtitle: 'Catat aktivitas harian untuk melihat apa yang memengaruhi suasana hatimu.',
    type: 'activities',
  ),
  OnboardingContent(
    title: 'Lihat Polamu',
    subtitle: 'Ubah data harian menjadi statistik visual agar kamu tahu kapan harus beristirahat.',
    type: 'stats',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < onboardingContents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Stack(
        children: [
          // Background Decoration
          _buildBackgroundDecoration(),
          
          // Header (Logo) - Tetap di atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildHeader(),
            ),
          ),
          
          // Main Content - Posisi tengah vertical
          Column(
            children: [
              // Spacer besar di atas untuk mendorong konten ke tengah
              const Spacer(flex: 1),
              
              // Konten utama (PageView)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingContents.length,
                  itemBuilder: (context, index) {
                    return _buildPage(onboardingContents[index]);
                  },
                ),
              ),
              
              // Spacer kecil antara konten dan tombol
              const Spacer(flex: 1),
              
              // Bottom Controls
              _buildBottomControls(),
              
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bubble_chart,
            color: Color(0xFFFF8A65),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'EmoSync',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: const Color(0xFFFF8A65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A65).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF78584E).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(OnboardingContent content) {
    switch (content.type) {
      case 'quadrant':
        return _buildQuadrantPage(content);
      case 'activities':
        return _buildActivitiesPage(content);
      case 'stats':
        return _buildStatsPage(content);
      default:
        return const SizedBox();
    }
  }

  // ============ PAGE 1: KENALI DIRIMU (4 Kuadran Mood) ============
  Widget _buildQuadrantPage(OnboardingContent content) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bento Grid 4 Kuadran
              SizedBox(
                width: MediaQuery.of(context).size.width - 64,
                height: MediaQuery.of(context).size.width - 64,
                child: Transform.rotate(
                  angle: 0.05,
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildMoodQuadrant(
                        icon: Icons.light_mode,
                        color: const Color(0xFFFFD180),
                        offset: const Offset(0, -8),
                      ),
                      _buildMoodQuadrant(
                        icon: Icons.bolt,
                        color: const Color(0xFFFF8A65),
                        offset: const Offset(4, 0),
                      ),
                      _buildMoodQuadrant(
                        icon: Icons.cloudy_snowing,
                        color: const Color(0xFF90CAF9),
                        offset: const Offset(-4, 0),
                      ),
                      _buildMoodQuadrant(
                        icon: Icons.eco,
                        color: const Color(0xFFA5D6A7),
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF3E2F2B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  content.subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: const Color(0xFF6D5B56),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodQuadrant({
    required IconData icon,
    required Color color,
    required Offset offset,
  }) {
    return Transform.translate(
      offset: offset,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 44,
          ),
        ),
      ),
    );
  }

  // ============ PAGE 2: CARI PENYEBABNYA (Habits Grid) ============
  Widget _buildActivitiesPage(OnboardingContent content) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bento Grid Habits (tanpa teks keterangan)
              SizedBox(
                width: MediaQuery.of(context).size.width - 64,
                height: MediaQuery.of(context).size.width - 64,
                child: Column(
                  children: [
                    // Row 1: Coffee + Sleep
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildHabitIcon(
                              icon: Icons.coffee,
                              color: const Color(0xFFFFF3E0),
                              iconColor: const Color(0xFFFF8A65),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildHabitIcon(
                              icon: Icons.bedtime,
                              color: const Color(0xFFE8EAF6),
                              iconColor: const Color(0xFF5C6BC0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Study + Exercise
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildHabitIcon(
                              icon: Icons.menu_book,
                              color: const Color(0xFFFCE4EC),
                              iconColor: const Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _buildHabitIcon(
                              icon: Icons.fitness_center,
                              color: const Color(0xFFE8F5E9),
                              iconColor: const Color(0xFF66BB6A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF3E2F2B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  content.subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: const Color(0xFF6D5B56),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitIcon({
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 52,
        ),
      ),
    );
  }

  // ============ PAGE 3: LIHAT POLAMU (Bar Chart Clean) ============
  Widget _buildStatsPage(OnboardingContent content) {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bar Chart Card (tanpa label & insight tag)
              Container(
                width: MediaQuery.of(context).size.width - 64,
                height: MediaQuery.of(context).size.width - 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCleanBar(height: 60, color: const Color(0xFFE0F2F1)),
                      _buildCleanBar(height: 110, color: const Color(0xFFFFF9C4)),
                      _buildCleanBar(height: 80, color: const Color(0xFFF3E5F5)),
                      _buildCleanBar(height: 130, color: const Color(0xFFFF8A65)),
                      _buildCleanBar(height: 45, color: const Color(0xFFFFD180)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Text Content
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Color(0xFF3E2F2B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  content.subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: const Color(0xFF6D5B56),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCleanBar({required double height, required Color color}) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // ============ BOTTOM CONTROLS ============
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Dot Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingContents.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFFFF8A65)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A65),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                _currentPage == onboardingContents.length - 1
                    ? 'Mulai Sekarang'
                    : 'Lanjut',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}