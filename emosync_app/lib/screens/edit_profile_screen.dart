import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedAvatar = 'male';
  String _currentName = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.getProfile();

    if (result['success'] && mounted) {
      final data = result['data'];
      setState(() {
        _currentName = data['name'] ?? '';
        _selectedAvatar = data['avatar'] ?? 'male';
        _nameController.text = _currentName;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      _showError(result['message'] ?? 'Gagal memuat profil');
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama tidak boleh kosong');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final result = await _apiService.updateProfile(
      name: _nameController.text.trim(),
      avatar: _selectedAvatar,
    );

    setState(() {
      _isSaving = false;
    });

    if (result['success'] && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUser();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      _showError(result['message'] ?? 'Gagal menyimpan profil');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFA83836),
        ),
      );
    }
  }

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
          'Edit Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3E2F2B),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8A65)),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Avatar Selection Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Pilih Avatar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E2F2B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Avatar Male (Cowo) - Biru Muda
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatar = 'male';
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedAvatar == 'male'
                                              ? const Color(0xFF64B5F6)  // Biru muda
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: const Color(0xFFE3F2FD),  // Biru sangat muda
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: _selectedAvatar == 'male'
                                              ? const Color(0xFF2196F3)  // Biru sedang
                                              : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Laki-laki',
                                      style: TextStyle(
                                        fontWeight: _selectedAvatar == 'male'
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: _selectedAvatar == 'male'
                                            ? const Color(0xFF2196F3)
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              // Avatar Female (Cewe) - Pink Muda
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAvatar = 'female';
                                  });
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _selectedAvatar == 'female'
                                              ? const Color(0xFFF48FB1)  // Pink muda
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: const Color(0xFFFCE4EC),  // Pink sangat muda
                                        child: Icon(
                                          Icons.person_outline,
                                          size: 60,
                                          color: _selectedAvatar == 'female'
                                              ? const Color(0xFFE91E63)  // Pink sedang
                                              : Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Perempuan',
                                      style: TextStyle(
                                        fontWeight: _selectedAvatar == 'female'
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: _selectedAvatar == 'female'
                                            ? const Color(0xFFE91E63)
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name Input Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama Lengkap',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6D5B56),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3E2F2B),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama Anda',
                                hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                                filled: true,
                                fillColor: const Color(0xFFF5F5F5),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A65),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}