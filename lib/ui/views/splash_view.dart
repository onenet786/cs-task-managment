import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cs_task_managment/core/services/auth_service.dart';
import 'package:cs_task_managment/core/services/navigation_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();
    
    if (isLoggedIn) {
      final user = await authService.getCurrentUser();
      if (user != null) {
        if (user.isAdmin) {
          _navigationService.navigateTo('/admin-dashboard');
        } else if (user.isEmployee) {
          _navigationService.navigateTo('/employee-dashboard');
        } else {
          _navigationService.navigateTo('/customer-dashboard');
        }
      } else {
        _navigationService.navigateTo('/login');
      }
    } else {
      _navigationService.navigateTo('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'Customer Task Management',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
