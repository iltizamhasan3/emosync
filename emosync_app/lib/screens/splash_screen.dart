import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class EmoSyncSplashScreen extends StatefulWidget {
  const EmoSyncSplashScreen({super.key});

  @override
  State<EmoSyncSplashScreen> createState() => _EmoSyncSplashScreenState();
}

class _EmoSyncSplashScreenState extends State<EmoSyncSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Tunggu 2 detik untuk splash screen
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUserFromStorage();
    
    if (authProvider.isLoggedIn) {
      // Refresh user data dari server
      await authProvider.refreshUser();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1412) : const Color(0xFFFFF8F6),
      body: Stack(
        children: [
          _buildBackgroundDecoration(isDarkMode),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildBlob(
                          size: 56,
                          color: isDarkMode 
                              ? const Color(0xFFFFCDD2).withValues(alpha: 0.7)
                              : const Color(0xFFFFCDD2),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(60),
                            bottomLeft: Radius.circular(70),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildBlob(
                          size: 56,
                          color: isDarkMode
                              ? const Color(0xFFFFF9C4).withValues(alpha: 0.7)
                              : const Color(0xFFFFF9C4),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(70),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: _buildBlob(
                          size: 56,
                          color: isDarkMode
                              ? const Color(0xFFE1F5FE).withValues(alpha: 0.7)
                              : const Color(0xFFE1F5FE),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(70),
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _buildBlob(
                          size: 56,
                          color: isDarkMode
                              ? const Color(0xFFE8F5E9).withValues(alpha: 0.7)
                              : const Color(0xFFE8F5E9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(70),
                            topRight: Radius.circular(30),
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                Column(
                  children: [
                    Text(
                      'EmoSync',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDarkMode ? Colors.white : const Color(0xFF3E2F2B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Synchronize Your Mind and Body',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: isDarkMode 
                            ? Colors.grey[400] 
                            : const Color(0xFF6D5B56),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.grey[800] 
                        : const Color(0xFFC3ADA7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? const Color(0xFFFDAD95) 
                          : const Color(0xFF8C4F3C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'INITIALIZING SANCTUARY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isDarkMode ? Colors.grey[500] : const Color(0xFF6D5B56),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob({
    required double size,
    required Color color,
    required BorderRadius borderRadius,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildBackgroundDecoration(bool isDarkMode) {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -80,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF755449).withValues(alpha: 0.15)
                  : const Color(0xFFFFDBD0).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -80,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF6B521D).withValues(alpha: 0.1)
                  : const Color(0xFFF9D593).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}