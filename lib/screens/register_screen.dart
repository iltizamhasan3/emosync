import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../services/local_storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _passwordStrength = 0;
  
  String _usernameError = '';
  String _emailError = '';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isUsernameValid(String username) {
    if (username.isEmpty) return false;
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(username);
  }

  bool _isEmailValid(String email) {
    return email.contains('@') && email.contains('.com');
  }

  void _validateUsername(String username) {
    setState(() {
      if (username.isEmpty) {
        _usernameError = '';
      } else if (username.contains(' ')) {
        _usernameError = 'Username tidak boleh mengandung spasi';
      } else if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
        _usernameError = 'Username hanya boleh berisi huruf dan angka';
      } else {
        _usernameError = '';
      }
    });
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _emailError = '';
      } else if (!email.contains('@')) {
        _emailError = 'Email harus mengandung @';
      } else if (!email.contains('.com')) {
        _emailError = 'Email harus mengandung .com';
      } else {
        _emailError = '';
      }
    });
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.isEmpty || password.length < 8) {
        _passwordStrength = 0;
        return;
      }
      
      bool hasLetters = password.contains(RegExp(r'[A-Za-z]'));
      bool hasNumbers = password.contains(RegExp(r'[0-9]'));
      bool hasSymbols = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      
      if (hasLetters && !hasNumbers && !hasSymbols) {
        _passwordStrength = 0;
      } else if (hasLetters && (hasNumbers || hasSymbols) && !(hasNumbers && hasSymbols)) {
        _passwordStrength = 1;
      } else if (hasLetters && hasNumbers && hasSymbols) {
        _passwordStrength = 2;
      } else {
        _passwordStrength = 0;
      }
    });
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi semua field'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }
    
    if (!_isUsernameValid(_usernameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username hanya boleh huruf dan angka (tanpa spasi)'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }
    
    if (!_isEmailValid(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email harus mengandung @ dan .com'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }
    
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 8 karakter'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }

    if (_passwordStrength < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password harus mengandung angka atau simbol'),
          backgroundColor: Color(0xFFA83836),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registrasi gagal'),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              _buildHeader(),
              const SizedBox(height: 32),
              
              _buildRenderInfoBanner(),
              const SizedBox(height: 24),

              _buildForm(),
              const SizedBox(height: 24),
              
               _buildRegisterButton(),
              const SizedBox(height: 32),
              
               _buildFooterLink(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Info banner tentang cold start Render (server free tier)
  Widget _buildRenderInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD180)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFFF8A65),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Server mungkin butuh 30-60 detik',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Karena menggunakan server gratis, jika tidak ada aktivitas selama 15 menit server akan tidur. '
                  'Tunggu sebentar saat pertama kali mengakses fitur.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: const Color(0xFF795548),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
        const SizedBox(height: 24),
        const Text(
          'Mulai Perjalananmu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF3E2F2B),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bergabunglah dengan EmoSync untuk\nmenyelaraskan ketenangan batin Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF6D5B56),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NAMA LENGKAP',
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  hintStyle: TextStyle(
                    color: Color(0xFFC3ADA7),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'USERNAME',
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _usernameController,
                onChanged: _validateUsername,
                decoration: InputDecoration(
                  hintText: 'contoh: johndoe123',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC3ADA7),
                    fontSize: 14,
                  ),
                  suffixIcon: _usernameController.text.isNotEmpty && _usernameError.isEmpty
                      ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20)
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            if (_usernameError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  _usernameError,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA83836),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EMAIL',
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: _validateEmail,
                decoration: InputDecoration(
                  hintText: 'contoh@email.com',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC3ADA7),
                    fontSize: 14,
                  ),
                  suffixIcon: _emailController.text.isNotEmpty && _emailError.isEmpty
                      ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20)
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            if (_emailError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  _emailError,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA83836),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KATA SANDI',
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
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _checkPasswordStrength,
                decoration: InputDecoration(
                  hintText: 'Min. 8 karakter',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC3ADA7),
                    fontSize: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFFC3ADA7),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),
            
            if (_passwordController.text.isNotEmpty && _passwordController.text.length < 8)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'Password minimal 8 karakter',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA83836),
                  ),
                ),
              ),
            
            const SizedBox(height: 12),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 8),
            
            Text(
              _getPasswordStrengthText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPasswordStrengthColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    bool bar1Active = _passwordController.text.length >= 8;
    bool bar2Active = _passwordStrength >= 1 && _passwordController.text.length >= 8;
    bool bar3Active = _passwordStrength >= 2 && _passwordController.text.length >= 8;

    Color getBarColor(bool isActive) {
      if (!isActive) {
        return const Color(0xFFC3ADA7).withValues(alpha: 0.3);
      }
      switch (_passwordStrength) {
        case 0:
          return const Color(0xFFA83836);
        case 1:
          return const Color(0xFFFF8A65);
        case 2:
          return const Color(0xFF4CAF50);
        default:
          return const Color(0xFFC3ADA7);
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: getBarColor(bar1Active),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: getBarColor(bar2Active),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: getBarColor(bar3Active),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  String _getPasswordStrengthText() {
    if (_passwordController.text.length < 8) {
      return '';
    }
    switch (_passwordStrength) {
      case 0:
        return 'Lemah';
      case 1:
        return 'Sedang';
      case 2:
        return 'Kuat';
      default:
        return '';
    }
  }

  Color _getPasswordStrengthColor() {
    if (_passwordController.text.length < 8) {
      return const Color(0xFF6D5B56);
    }
    switch (_passwordStrength) {
      case 0:
        return const Color(0xFFA83836);
      case 1:
        return const Color(0xFFFF8A65);
      case 2:
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF6D5B56);
    }
  }

  Widget _buildRegisterButton() {
    bool isFormValid = _nameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _usernameError.isEmpty &&
        _emailController.text.isNotEmpty &&
        _emailError.isEmpty &&
        _passwordController.text.length >= 8 &&
        _passwordStrength >= 1;
    
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (_isLoading || !isFormValid) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A65),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
                'Mulai Perjalananmu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildFooterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun?',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF6D5B56),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Masuk',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF8A65),
            ),
          ),
        ),
      ],
    );
  }
}