import 'package:cs_task_managment/core/models/user.dart';
import 'package:cs_task_managment/core/services/api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<User> getCurrentUser() async {
    return await _apiService.getCurrentUser();
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _apiService.updateUser(id, data);
  }

  Future<List<User>> getAllUsers() async {
    // This would be an admin-only endpoint
    final response = await _apiService.get('/users');
    return response.data.map<User>((e) => User.fromJson(e)).toList();
  }

  Future<List<User>> getEmployees() async {
    final response = await _apiService.get('/users/employees');
    return response.data.map<User>((e) => User.fromJson(e)).toList();
  }

  Future<List<User>> getCustomers() async {
    final response = await _apiService.get('/users/customers');
    return response.data.map<User>((e) => User.fromJson(e)).toList();
  }
}
