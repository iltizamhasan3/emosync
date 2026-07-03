import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isPremium => _currentUser?.isPremium ?? false;

  Future<bool> login(String login, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _apiService.login(login, password);
      
      if (result['success']) {
        _currentUser = result['user'];
        // Simpan ke LocalStorage untuk offline mode
        await LocalStorageService.saveUser(
          name: _currentUser!.name,
          username: _currentUser!.username,
          email: _currentUser!.email,
          avatar: _currentUser!.avatar,
          isPremium: _currentUser!.isPremium,
          premiumPlan: _currentUser!.premiumPlan,
        );
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _apiService.register(
        name: name,
        username: username,
        email: email,
        password: password,
      );
      
      if (result['success']) {
        _currentUser = result['user'];
        await LocalStorageService.saveUser(
          name: _currentUser!.name,
          username: _currentUser!.username,
          email: _currentUser!.email,
          avatar: _currentUser!.avatar,
          isPremium: _currentUser!.isPremium,
          premiumPlan: _currentUser!.premiumPlan,
        );
        _setLoading(false);
        return true;
      } else {
        _errorMessage = result['message'];
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _apiService.logout();
    await LocalStorageService.clearUser();
    _currentUser = null;
    _setLoading(false);
  }

  Future<void> loadUserFromStorage() async {
    final userData = await LocalStorageService.getUser();
    if (userData['name'] != null) {
      _currentUser = UserModel(
        id: 0,
        name: userData['name']!,
        username: userData['username']!,
        email: userData['email']!,
        avatar: userData['avatar'] ?? 'male',
        isPremium: userData['is_premium'] ?? false,
        premiumPlan: userData['premium_plan'],
      );
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    final user = await _apiService.getCurrentUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}