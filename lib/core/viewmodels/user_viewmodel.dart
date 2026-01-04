import 'package:flutter/material.dart';
import 'package:cs_task_managment/core/models/user.dart';
import 'package:cs_task_managment/core/services/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<User> _users = [];
  List<User> get users => _users;

  List<User> _employees = [];
  List<User> get employees => _employees;

  List<User> _customers = [];
  List<User> get customers => _customers;

  Future<void> getCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.getCurrentUser();
      // Handle current user
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.updateUser(id, data);
      // Refresh user data if needed
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      _employees = await _userService.getEmployees();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _userService.getCustomers();
    } catch (e) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }
}
