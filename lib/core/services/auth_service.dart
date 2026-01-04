import 'package:cs_task_managment/core/models/user.dart';
import 'package:cs_task_managment/core/services/api_service.dart';
import 'package:cs_task_managment/core/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<bool> login(String email, String password) async {
    try {
      final user = await _apiService.login(email, password);
      await _storageService.saveUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> register(String name, String email, String phone, String password, String role) async {
    await _apiService.register(name, email, phone, password, role);
  }

  Future<void> verifyEmail(String email, String code) async {
    await _apiService.verifyEmail(email, code);
  }

  Future<void> sendVerificationCode(String email) async {
    await _apiService.sendVerificationCode(email);
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _storageService.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> logout() async {
    await _storageService.clearUser();
  }

  Future<void> updateCurrentUser() async {
    final currentUser = await getCurrentUser();
    if (currentUser != null) {
      final updatedUser = await _apiService.getCurrentUser();
      await _storageService.saveUser(updatedUser);
    }
  }
}
