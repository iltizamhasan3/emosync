import 'package:flutter/material.dart';
import 'payment_screen.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  String? _selectedPlanId;

  final List<Map<String, dynamic>> plans = const [
    {
      'id': 'yearly',
      'name': 'Yearly Access',
      'price': 99900,
      'priceFormatted': 'Rp 99.900',
      'period': '/ tahun',
      'duration': 365,
      'badge': 'BEST VALUE',
      'saving': 'Hemat 16%',
    },
    {
      'id': 'monthly',
      'name': 'Monthly Access',
      'price': 9900,
      'priceFormatted': 'Rp 9.900',
      'period': '/ bulan',
      'duration': 30,
      'badge': null,
      'saving': null,
    },
  ];

  Map<String, dynamic>? get _selectedPlan {
    if (_selectedPlanId == null) return null;
    return plans.firstWhere((plan) => plan['id'] == _selectedPlanId);
  }

  void _selectPlan(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  void _navigateToPayment() {
    final selectedPlan = _selectedPlan;
    if (selectedPlan == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(plan: selectedPlan),
      ),
    ).then((result) {
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _selectedPlan;
    final isPlanSelected = selectedPlan != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2F2B)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'EmoSync+',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E2F2B),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Hero Section
              _buildHeroSection(),

              const SizedBox(height: 32),

              // Benefits Section
              _buildBenefitsSection(),

              const SizedBox(height: 32),

              // Pricing Section
              _buildPricingSection(),

              const SizedBox(height: 32),

              // CTA Button
              _buildCTAButton(isPlanSelected, selectedPlan),

              const SizedBox(height: 20),

              // Footer note
              _buildFooterNote(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF8A65).withValues(alpha: 0.1),
            const Color(0xFFFDAE96).withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFDAE96).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unlock Your Inner Peace',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Color(0xFF3E2F2B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dapatkan akses penuh ke fitur premium dan tingkatkan perjalanan kesehatan mentalmu.',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF6D5B56),
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

  Widget _buildBenefitsSection() {
    final benefits = [
      {'icon': Icons.lock_open, 'text': 'Akses penuh ke semua konten mindfulness & eksklusif'},
      {'icon': Icons.psychology, 'text': 'AI Insight personal di Journal Screen'},
      {'icon': Icons.emoji_events, 'text': 'Badge eksklusif & achievement tracker'},
    ];

    return Column(
      children: benefits.map((benefit) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: const Color(0xFFFF8A65),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  benefit['text'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2F2B),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPricingSection() {
    return Column(
      children: plans.map((plan) {
        final isSelected = _selectedPlanId == plan['id'];
        final isPopular = plan['badge'] != null;

        Widget planCard = GestureDetector(
          onTap: () => _selectPlan(plan['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF8A65)
                    : const Color(0xFFC3ADA7).withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF8A65).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: isSelected
                        ? const Color(0xFFFF8A65)
                        : const Color(0xFF6D5B56),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan['priceFormatted'] as String,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3E2F2B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan['period'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D5B56),
                      ),
                    ),
                  ],
                ),
                if (plan['saving'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8A65).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              plan['saving'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF8A65),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFFFF8A65),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );

        if (isPopular) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: planCard,
              ),
              Positioned(
                top: 0,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8A65),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8A65).withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return planCard;
      }).toList(),
    );
  }

  Widget _buildCTAButton(bool isPlanSelected, Map<String, dynamic>? selectedPlan) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isPlanSelected ? _navigateToPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A65),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFFF8A65).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFFF8A65).withValues(alpha: 0.3),
        ),
        child: Text(
          isPlanSelected
              ? 'Upgrade Sekarang • ${selectedPlan!['priceFormatted']}${selectedPlan['period']}'
              : 'Pilih Paket Terlebih Dahulu',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      children: [
        Text(
          'Subscription auto-renews unless canceled 24h before period ends.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF6D5B56).withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage in Play Store / App Store settings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF6D5B56).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}