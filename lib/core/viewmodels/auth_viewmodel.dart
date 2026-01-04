import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/models/user.dart';
import 'package:cs_task_managment/core/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    await _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.login(email, password);

    if (success) {
      await _loadCurrentUser();
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    await _authService.register(name, email, phone, password, role);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyEmail(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    await _authService.verifyEmail(email, code);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendVerificationCode(String email) async {
    _isLoading = true;
    notifyListeners();

    await _authService.sendVerificationCode(email);

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateCurrentUser() async {
    await _authService.updateCurrentUser();
    await _loadCurrentUser();
  }
}
