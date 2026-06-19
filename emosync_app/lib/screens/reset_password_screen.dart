import 'package:flutter/material.dart';
import 'login_screen.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return email.contains('@') && email.contains('.com');
  }

  void _handleResetPassword() {
    // Validasi email kosong
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan alamat email'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }
    
    // Validasi format email
    if (!_isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email harus mengandung @ dan .com'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi pengiriman email
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEmailSent = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instruksi reset password telah dikirim ke email Anda'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        
        // Kembali ke login setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Decoration
            _buildBackgroundDecoration(),
            
            // Main Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),
                    
                    // Main Content
                    _buildMainContent(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecoration() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD180).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A65).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bubble_chart,
              color: Color(0xFFFF8A65),
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'EmoSync',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: const Color(0xFFFF8A65),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Atur ulang kata sandi akunmu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF6D5B56),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    if (_isEmailSent) {
      return _buildSuccessScreen();
    }
    
    return Column(
      children: [
        // Title (tanpa simbol gembok)
        const Text(
          'Reset Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Masukkan email yang terdaftar dan kami akan mengirimkan instruksi untuk mengatur ulang kata sandimu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF6D5B56),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALAMAT EMAIL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: Color(0xFF6D5B56),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'nama@email.com',
                  hintStyle: TextStyle(
                    color: const Color(0xFFC3ADA7).withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  suffixIcon: const Icon(
                    Icons.mail,
                    color: Color(0xFFC3ADA7),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            // Pesan error email
            if (_emailController.text.isNotEmpty && !_isEmailValid(_emailController.text))
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Email harus mengandung @ dan .com',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFFA83836),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Security Info Card
        _buildSecurityCard(),
        const SizedBox(height: 32),
        
        // Reset Button
        _buildResetButton(),
        const SizedBox(height: 24),
        
        // Back to Login Link
        _buildBackToLoginLink(),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Column(
      children: [
        // Success Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Cek Email Anda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kami telah mengirimkan instruksi reset password ke ${_emailController.text}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF6D5B56),
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Back to Login Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF8A65),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Kembali ke Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFC3ADA7).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD180).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.security,
                color: Color(0xFF8C4F3C),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KEAMANAN TERJAMIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Color(0xFF6D5B56),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Proses enkripsi ujung ke ujung untuk permintaan Anda.',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF6D5B56).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    bool isEmailValid = _emailController.text.isNotEmpty && _isEmailValid(_emailController.text);
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || !isEmailValid) ? null : _handleResetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A65),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          shadowColor: const Color(0xFFFF8A65).withValues(alpha: 0.2),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Kirim Instruksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.arrow_back,
            size: 18,
            color: Color(0xFF6D5B56),
          ),
          const SizedBox(width: 8),
          Text(
            'Kembali ke Login',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6D5B56),
            ),
          ),
        ],
      ),
    );
  }
}